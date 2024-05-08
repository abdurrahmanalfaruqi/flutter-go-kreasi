// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer' as logger show log;
import 'dart:math';

import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/home/presentation/bloc/ptn/ptn_bloc.dart';
import 'package:gokreasi_new/features/ptn/module/ptnclopedia/entity/kampus_impian.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/presentation/bloc/tobk/tobk_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'laporan_goa_widget.dart';
import '../provider/tob_provider.dart';
import '../../entity/paket_to.dart';
import '../../../../model/detail_hasil_model.dart';
import '../../../../presentation/widget/kisi_kisi_widget.dart';
import '../../../../presentation/provider/solusi_provider.dart';
import '../../../../../leaderboard/model/capaian_detail_score.dart';
import '../../../../../leaderboard/presentation/widget/home/detail_capaian_chart.dart';
import '../../../../../../core/config/enum.dart';
import '../../../../../../core/config/theme.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/constant.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/widget/empty/basic_empty.dart';
import '../../../../../../core/shared/widget/separator/dash_divider.dart';
import '../../../../../../core/shared/widget/image/custom_image_network.dart';
import '../../../../../../core/shared/widget/loading/shimmer_list_tiles.dart';
import '../../../../../../core/shared/widget/watermark/watermark_widget.dart';
import '../../../../../../core/shared/widget/expanded/custom_expanded_widget.dart';
import '../../../../../../core/shared/widget/refresher/custom_smart_refresher.dart';

/// [PaketTimerList] merupakan Widget List Paket Timer selain TOBK.<br><br>
/// Digunakan pada produk-produk berikut:<br>
/// 1. GOA (id: 12).<br>
/// 2. Kuis (id: 16).<br>
/// 3. Racing (id: 80).<br>
class PaketTimerList extends StatefulWidget {
  final int idJenisProduk;
  final String namaJenisProduk;
  final bool isRencanaPicker;

  /// [kodeTOB] dikirim dari rencana belajar notification
  /// untuk keperluan Selected Item
  final String? kodeTOB;

  /// [kodePaket] dikirim dari rencana belajar notification
  /// untuk keperluan Selected Item
  final String? kodePaket;
  final String? label;

  const PaketTimerList({
    Key? key,
    required this.idJenisProduk,
    required this.namaJenisProduk,
    this.isRencanaPicker = false,
    this.kodeTOB,
    this.kodePaket,
    this.label,
  }) : super(key: key);

  @override
  State<PaketTimerList> createState() => _PaketTimerListState();
}

class _PaketTimerListState extends State<PaketTimerList> {
  @override
  void didUpdateWidget(covariant PaketTimerList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the idJenisProduk has changed
    if (widget.idJenisProduk != oldWidget.idJenisProduk) {
      // Call the refresh function when idJenisProduk changes
      _onRefreshPaket(refresh: false, idJenisProduct: widget.idJenisProduk);
    }
  }

  late final NavigatorState _navigator = Navigator.of(context);
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final RefreshController _emptyRefreshController =
      RefreshController(initialRefresh: false);
  final ScrollController _scrollController = ScrollController();

  late TOBKBloc tobkBloc;
  UserModel? userData;
  List<PaketTO> listPaketTO = [];
  int page = 1;
  int jumlahHalaman = 0;
  bool isPaginateLoading = false;
  List<KampusImpian> listKampusImpian = [];

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is LoadedUser) {
      userData = authState.user;
    }
    tobkBloc = context.read<TOBKBloc>();
    _onRefreshPaket(refresh: false);
    _scrollController.addListener(paginationListener);

    final ptnState = context.read<PtnBloc>().state;
    if (ptnState is PtnDataLoaded) {
      listKampusImpian = ptnState.listKampusPilihan;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _refreshController.dispose();
    _emptyRefreshController.dispose();
    _scrollController.dispose();
    // Dissmis bottom dialog when pop screen
    if (gPreviousBottomDialog?.isDisposed == false) {
      gPreviousBottomDialog?.dismiss(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TOBKBloc, TOBKState>(
      listener: (context, state) {
        if (state is TOBKErrorResponse) {
          isPaginateLoading = false;
        }

        if (state is TOBKError) {
          isPaginateLoading = false;
          if (state.page == 1) {
            listPaketTO.clear();
          }
        }

        if (state is TOBKSuccessMulaiTO) {
          _navigateToSoalTimerScreen(state.paketTO, state.isRemedialGOA);
        }
      },
      builder: (context, state) {
        if (state is TOBKError && state.shouldBeEmpty == true) {
          listPaketTO.clear();
        }

        if (state is TOBKLoading) {
          return const ShimmerListTiles(isWatermarked: true);
        }

        if (state is TOBKPaginateLoading) {
          isPaginateLoading = true;
        }

        if (state is LoadedListTO) {
          isPaginateLoading = false;
          page = state.page ?? 1;
          jumlahHalaman = state.jumlahHalaman ?? 1;
          listPaketTO = state.paketTO;
        }

        var refreshWidget = CustomSmartRefresher(
          controller: (listPaketTO.isEmpty)
              ? _emptyRefreshController
              : _refreshController,
          onRefresh: _onRefreshPaket,
          isDark: true,
          child: (listPaketTO.isEmpty)
              ? _getIllustrationImage(widget.idJenisProduk)
              : (widget.idJenisProduk == 16)
                  ? _buildListKuis(listPaketTO)
                  : _buildListPaketTimer(listPaketTO),
        );

        return (listPaketTO.isEmpty)
            ? refreshWidget
            : WatermarkWidget(child: refreshWidget);
      },
    );
  }

  // On Refresh Function
  Future<void> _onRefreshPaket({
    bool refresh = true,
    int? idJenisProduct,
    int page = 1,
  }) async {
    // Function load and refresh data
    List<int> listIdProduk =
        userData?.listIdProduk == null ? [] : (userData?.listIdProduk ?? []);
    tobkBloc.add(TOBKGetListTO(
      idJenisProduk: idJenisProduct ?? widget.idJenisProduk,
      isRefresh: refresh,
      listIdProduk: listIdProduk,
      page: page,
      noRegistrasi: userData?.noRegistrasi,
      idBundlingAktif: userData?.idBundlingAktif ?? 0,
    ));

    await gSetServerTimeOffset();

    // if (refresh && mounted) setState(() {});
  }

  Future<void> _onClickPaketTO(
    PaketTO paketTO,
    bool isRemedialGOA,
    Function(bool) isConfirm,
  ) async {
    tobkBloc.add(
      TOBKSetMulaiTO(
          noRegister: userData?.noRegistrasi ?? '',
          tahunAjaran: userData?.tahunAjaran ?? '',
          kodePaket: paketTO.kodePaket,
          totalWaktuPaket: paketTO.totalWaktu,
          paketTO: paketTO,
          idJenisProduk: widget.idJenisProduk,
          isRemedialGOA: isRemedialGOA,
          tingkatKelas: int.parse(userData?.tingkatKelas ?? '0')),
    );

    isConfirm(true);
  }

  Future<void> _harusMengumpulkan(PaketTO paketTO) async {
    await gShowBottomDialog(
      context,
      persistent: true,
      barrierDismissible: true,
      title: 'Kumpulkan ${paketTO.kodePaket}',
      message: 'Kamu belum mengumpulkan ${paketTO.kodePaket} Sobat. '
          'Kamu tidak bisa lanjut mengerjakan karena batas pengerjaan '
          'paket ${paketTO.kodePaket} hanya sampai ${paketTO.displayDeadlinePengerjaan}. '
          'Kumpulkan sebelum ${paketTO.displayTanggalBerakhir} yaa!',
      actions: (controller) => [
        TextButton(
            onPressed: () {
              var completer = Completer();
              context.showBlockDialog(dismissCompleter: completer);

              if (widget.idJenisProduk == 12 || widget.idJenisProduk == 80) {
                context
                    .read<TOBProvider>()
                    .kumpulkanJawabanGOA(
                      tahunAjaran: userData?.tahunAjaran ?? '',
                      noRegistrasi: userData?.noRegistrasi,
                      tipeUser: userData?.siapa,
                      tingkatKelas: userData?.tingkatKelas ?? tingkatKelas,
                      idSekolahKelas: userData?.idSekolahKelas ?? '14',
                      idKota: userData?.idKota ?? '',
                      idGedung: userData?.idGedung ?? '',
                      idJenisProduk: widget.idJenisProduk,
                      namaJenisProduk: widget.namaJenisProduk,
                      kodeTOB: paketTO.kodeTOB,
                      kodePaket: paketTO.kodePaket,
                      listKampusImpian: listKampusImpian,
                    )
                    .then((_) => completer.complete(),
                        onError: (_, __) => completer.complete());
              } else {
                context
                    .read<TOBProvider>()
                    .updatePesertaTO(
                      tahunAjaran: tahunAjaran,
                      noRegistrasi: userData?.noRegistrasi,
                      tipeUser:
                          userData?.siapa ?? AuthRole.siswa.name.toUpperCase(),
                      tingkatKelas: userData?.tingkatKelas ?? tingkatKelas,
                      idSekolahKelas: userData?.idSekolahKelas ?? '14',
                      idJenisProduk: widget.idJenisProduk,
                      namaJenisProduk: widget.namaJenisProduk,
                      kodeTOB: paketTO.kodeTOB,
                      kodePaket: paketTO.kodePaket,
                      listPaketTO: listPaketTO,
                      listKampusImpian: listKampusImpian,
                    )
                    .then((_) => completer.complete(),
                        onError: (_, __) => completer.complete());
              }
              controller.dismiss(true);
            },
            child: const Text('Kumpulkan Sekarang'))
      ],
    );
  }

  Future<void> _onClickPaketListTile({
    required PaketTO paketTO,
    PaketTO? paketSebelumnya,
    required bool isHarusKumpulkan,
    required bool isPernahMengerjakan,
    required bool isSudahDikumpulkan,
    required bool isWaktuHabis,
    required bool isTOBBerakhir,
    required bool isRemedialGOA,
  }) async {
    if (kDebugMode) {
      logger.log('CLICK PAKET TIMER:\n'
          'paketSebelumnya >> $paketSebelumnya\n'
          'paketTO >> $paketTO\n'
          'isHarusKumpulkan >> $isHarusKumpulkan\n'
          'isPernahMengerjakan >> $isPernahMengerjakan\n'
          'isSudahDikumpulkan >> $isSudahDikumpulkan\n'
          'isWaktuHabis >> $isWaktuHabis\n'
          'isTOBBerakhir >> $isTOBBerakhir\n'
          'isRemedialGOA >> $isRemedialGOA');
    }

    if (widget.isRencanaPicker) {
      var isBerakhir = paketTO.isTOBBerakhir == true;

      if (!isBerakhir) {
        // Kembali ke Rencana Belajar Editor
        Navigator.pop(context, {
          'kodeTOB': paketTO.kodeTOB,
          'kodePaket': paketTO.kodePaket,
          'idJenisProduk': widget.idJenisProduk,
          'namaJenisProduk': widget.namaJenisProduk,
          'keterangan':
              'Mengerjakan ${widget.namaJenisProduk.replaceFirst('e-', '')} '
                  'dengan Kode Paket ${paketTO.kodePaket}',
        });
      } else {
        gShowBottomDialogInfo(context,
            title: 'Paket ${paketTO.kodePaket} Telah Berakhir',
            message: 'Kamu tidak dapat memilih Paket ${paketTO.kodePaket} '
                'untuk rencana belajar karena Paket ${paketTO.kodePaket} telah berakhir!');
      }
    } else {
      if (paketTO.isTOBMulai != true) {
        gShowBottomDialogInfo(context,
            message:
                'Hai Sobat! Paket ini baru akan dimulai pada ${paketTO.displayTanggalMulai}. '
                'Saat ini sobat hanya bisa melihat kisi-kisi saja. '
                'Yuk persiapkan diri kamu untuk raih hasil yang maksimal!');
        return;
      }

      // bool harusMengumpulkan = isHarusKumpulkan;

      // if (!harusMengumpulkan &&
      //     isPernahMengerjakan &&
      //     paketTO.tanggalSiswaSubmit == null) {
      //   harusMengumpulkan =
      //       paketTO.isHarusKumpulkan(DateTime.now().serverTimeFromOffset);
      // }

      // if (harusMengumpulkan) {
      //   await _harusMengumpulkan(paketTO);
      //   return;
      // }

      if ((isWaktuHabis || isSudahDikumpulkan) &&
          !isTOBBerakhir &&
          paketTO.idJenisProduk != '12') {
        gShowBottomDialogInfo(context,
            dialogType: DialogType.info,
            title: 'Belum Boleh Melihat Solusi',
            message: 'Masa paket belum berakhir, kamu '
                '${(paketTO.displayTanggalBerakhir != null) ? 'baru bisa melihat solusi setelah ${paketTO.displayTanggalBerakhir}' : 'belum bisa melihat solusi.'}');
        return;
      }

      bool isSiapMengerjakan = isPernahMengerjakan;

      if (!isPernahMengerjakan && !isTOBBerakhir) {
        isSiapMengerjakan = await gShowBottomDialog(
          context,
          title: 'Konfirmasi mulai mengerjakan Paket ${paketTO.kodePaket}',
          message:
              'Pastikan kamu sudah siap dan dalam kondisi nyaman untuk mengerjakan Paket ${paketTO.kodePaket}. Setelah Paket dimulai, kamu tidak dapat keluar dari halaman pengerjaan sebelum waktu habis / sudah mengumpulkan jawaban. Siap mengerjakan sekarang Sobat?',
          dialogType: DialogType.warning,
        );
      }

      if (!isSiapMengerjakan && isTOBBerakhir) {
        await gShowBottomDialogInfo(
          context,
          message: 'Kamu tidak mengerjakan Paket ini, sobat',
          dialogType: DialogType.warning,
        );
        return;
      }

      if (paketTO.idJenisProduk == '12' && isSudahDikumpulkan) {
        await _showLaporanGOA(paketTO: paketTO);
        return;
      }

      if (paketTO.isPernahMengerjakan) {
        _navigateToSoalTimerScreen(paketTO, false);
      } else if (isSiapMengerjakan) {
        _onClickPaketTO(
          paketTO,
          false,
          (_) {},
        );
      }
    }
  }

  Future<void> _showLaporanGOA({required PaketTO paketTO}) async {
    // Membuat variableTemp guna mengantisipasi rebuild saat scroll
    Widget? childWidget;
    await showModalBottomSheet(
      context: context,
      enableDrag: true,
      isDismissible: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        minHeight: 10,
        maxHeight: context.dh * ((context.isMobile) ? 0.9 : 0.86),
      ),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        childWidget ??= LaporanGOAWidget(
          paketTO: paketTO,
          onHarusMengumpulkan: _harusMengumpulkan,
          onClickNavigateTOSoalTimerScreen: (paketTO, isRemedialGOA) {
            return _onClickPaketTO(
              paketTO,
              isRemedialGOA,
              (isConfirm) {
                if (isConfirm) Navigator.pop(context);
              },
            );
          },
        );
        return childWidget!;
      },
    );
  }

  Future<void> _onClickLihatKisiKisi(String kodePaket) async {
    // Membuat variableTemp guna mengantisipasi rebuild saat scroll
    Widget? childWidget;
    await showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      useRootNavigator: true,
      constraints: BoxConstraints(
        minHeight: 10,
        maxHeight: context.dh * 0.86,
        maxWidth: min(650, context.dw),
      ),
      backgroundColor: Colors.transparent,
      builder: (_) {
        childWidget ??= KisiKisiWidget(
          kodePaket: kodePaket,
          idJenisProduk: widget.idJenisProduk,
        );
        return childWidget!;
      },
    );
  }

  // Get Illustration Image Function
  Widget _getIllustrationImage(int idJenisProduk) {
    bool isProdukDibeli =
        userData.isProdukDibeliSiswa(idJenisProduk, ortuBolehAkses: true);
    String imageUrl = 'ilustrasi_soal_emwa.png'.illustration;
    String title = 'Buku Soal';

    switch (idJenisProduk) {
      case 12:
        imageUrl = 'ilustrasi_profiling_goa.png'.illustration;
        title = 'GO-Assessment';
        break;
      case 16:
        imageUrl = 'ilustrasi_soal_quiz.png'.illustration;
        title = 'Kuis';
        break;
      case 80:
        imageUrl = 'ilustrasi_soal_racing.png'.illustration;
        title = 'Racing Soal';
        break;
      default:
        break;
    }

    Widget basicEmpty = BasicEmpty(
      shrink: (context.dh < 600) ? !context.isMobile : false,
      imageUrl: imageUrl,
      title: title,
      subTitle: gEmptyProductSubtitle(
          namaProduk: title,
          isProdukDibeli: isProdukDibeli,
          isOrtu: userData.isOrtu,
          isNotSiswa: !userData.isSiswa),
      emptyMessage: gEmptyProductText(
        namaProduk: title,
        isOrtu: userData.isOrtu,
        isProdukDibeli: isProdukDibeli,
      ),
    );

    return (context.isMobile || context.dh > 600)
        ? basicEmpty
        : SingleChildScrollView(
            child: basicEmpty,
          );
  }

  Widget _buildLeadingItem({
    required PaketTO paketTO,
    required bool isTeaser,
    required bool isWaktuHabis,
    required bool isTOBBerakhir,
    required bool isSudahDikumpulkan,
  }) {
    var leadingWidget = Container(
      padding: EdgeInsets.symmetric(
        horizontal: min(12, context.dp(8)),
        vertical: min(14, context.dp(8)),
      ),
      constraints: BoxConstraints(
        minWidth: min(118, context.dp(72)),
        maxWidth: min(120, context.dp(74)),
      ),
      decoration: BoxDecoration(
        color: (isSudahDikumpulkan)
            ? Palette.kSuccessSwatch[500]
            : (isWaktuHabis && !isTOBBerakhir)
                ? Palette.kSecondarySwatch[600]
                : (paketTO.isPernahMengerjakan && !isTOBBerakhir)
                    ? Palette.kSecondarySwatch[400]
                    : (!isSudahDikumpulkan && isTOBBerakhir)
                        ? context.primaryColor
                        : isTOBBerakhir
                            ? context.disableColor
                            : isTeaser
                                ? context.tertiaryColor
                                : context.background,
        border:
            (isTeaser || isTOBBerakhir || isSudahDikumpulkan || isWaktuHabis)
                ? null
                : Border.all(
                    color: (paketTO.isPernahMengerjakan)
                        ? Palette.kSecondarySwatch[600]!
                        : context.tertiaryColor),
        borderRadius: BorderRadius.circular(min(18, context.dp(14))),
      ),
      child: Text(
        (context.isMobile)
            ? paketTO.kodePaket.replaceAll('-', '\n')
            : paketTO.kodePaket,
        maxLines: 2,
        textAlign: TextAlign.center,
        overflow: TextOverflow.fade,
        style: context.text.labelMedium?.copyWith(
          fontSize: (context.isMobile) ? 12 : 10,
          fontWeight: FontWeight.bold,
          color: (isSudahDikumpulkan)
              ? Colors.white70
              : (paketTO.isPernahMengerjakan || isWaktuHabis || isTOBBerakhir)
                  ? context.onPrimary
                  : isTeaser
                      ? context.onTertiary
                      : context.tertiaryColor,
        ),
      ),
    );

    return !isTeaser
        ? leadingWidget
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotatedBox(
                quarterTurns: 3,
                child: Text(
                  'TEASER',
                  style: context.text.labelSmall?.copyWith(
                    color: isTOBBerakhir
                        ? context.disableColor
                        : context.tertiaryColor,
                    fontSize: 8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              leadingWidget,
            ],
          );
  }

  Widget _buildListPaketTimer(List<PaketTO> listPaketTO) {
    // initial paket di perlukan untuk keperluan Rencana Belajar.
    int initialPaketIndex = (widget.kodeTOB == null || widget.kodePaket == null)
        ? 0
        : listPaketTO.indexWhere(
            (paket) =>
                paket.kodeTOB == widget.kodeTOB &&
                paket.kodePaket == widget.kodePaket,
          );

    if (kDebugMode) {
      logger.log('PAKET_TIMER_LIST-ListPaketTimer: '
          'initial index >> $initialPaketIndex');
      logger.log('PAKET_TIMER_LIST-ListPaketTimer: '
          'selected KodeTOB & KodePaket >> ${widget.kodeTOB}, ${widget.kodePaket}');
    }

    if (initialPaketIndex < 0) {
      initialPaketIndex = 0;

      gShowBottomDialogInfo(context,
          message: 'Paket ${widget.namaJenisProduk.replaceAll('e-', '')} '
              'dengan Kode ${widget.kodePaket} tidak ditemukan');
    }

    return ListView.separated(
      controller: _scrollController,
      shrinkWrap: true,
      padding: EdgeInsets.only(
        top: min(16, context.dp(10)),
        bottom: 120,
        left: min(16, context.dp(12)),
        right: min(16, context.dp(12)),
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: listPaketTO.length + 1,
      itemBuilder: (_, index) {
        if (index < listPaketTO.length) {
          PaketTO paketTO = listPaketTO[index];

          return _buildItemPaketTimer(
            paketTO,
            (index > 0) ? listPaketTO[index - 1] : null,
            false,
          );
        } else {
          if (!isPaginateLoading) {
            return Container();
          }
          return const ShimmerListTiles(jumlahItem: 1, shrinkWrap: true);
        }
      },
    );
  }

  // List Kuis akan di group by kelompok ujian masing-masing
  ListView _buildListKuis(List<PaketTO> listPaketTO) {
    // Mengelompokkan kuis by kelompok ujian.
    Map<String, List<PaketTO>> listKuis =
        listPaketTO.fold<Map<String, List<PaketTO>>>(
      {},
      (prev, paketTO) {
        // String namaMataUji =
        //     Constant.kInitialKelompokUjian[paketTO.idKelompokUjian]?['nama'] ??
        //         'Undefined';
        String namaMataUji = paketTO.namaKelompokUjian;
        prev.putIfAbsent(namaMataUji, () => []).add(paketTO);
        return prev;
      },
    );

    return ListView.separated(
      padding: EdgeInsets.only(
        top: min(16, context.dp(10)),
        bottom: 38,
        left: min(16, context.dp(12)),
        right: min(16, context.dp(12)),
      ),
      itemCount: listKuis.length,
      separatorBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: DashedDivider(
          dashColor: context.outline,
          strokeWidth: 0.6,
          dash: 4,
          direction: Axis.horizontal,
        ),
      ),
      itemBuilder: (_, index) {
        String namaKelompokUjian = listKuis.keys.toList()[index];
        List<PaketTO> listPaketTO = listKuis.values.toList()[index];
        // int idKelompokUjian = listPaketTO.first.idKelompokUjian;

        // final iconKelompokUjian = Constant.kIconMataPelajaran.entries
        //     .where(
        //       (iconMapel) =>
        //           iconMapel.value['idKelompokUjian']
        //               ?.contains(idKelompokUjian) ??
        //           false,
        //     )
        //     .toList();
        // final String initialKelompokUjian =
        //     Constant.kInitialKelompokUjian[idKelompokUjian]?['initial'] ??
        //         'N/a';
        final String initialKelompokUjian = listPaketTO.first.initial;
        final String iconKelompokUjian = listPaketTO.first.iconMapel;
        listPaketTO.sort(
          (a, b) {
            int tingkatKelas = a.tingkatKelas.compareTo(b.tingkatKelas);
            if (tingkatKelas == 0) {
              int sekolahKelas = a.sekolahKelas.compareTo(b.sekolahKelas);
              if (sekolahKelas == 0) {
                int kedaluwarsa = a.tanggalKedaluwarsaDateTime!
                    .compareTo(b.tanggalKedaluwarsaDateTime!);
                if (kedaluwarsa == 0) {
                  int berlaku = a.tanggalBerlakuDateTime!
                      .compareTo(b.tanggalBerlakuDateTime!);
                  if (berlaku == 0) {
                    return a.deskripsi.compareTo(b.deskripsi);
                  }
                  return -berlaku;
                }
                return -kedaluwarsa;
              }
              return sekolahKelas;
            }
            return -tingkatKelas;
          },
        );
        listPaketTO.sort(
          (a, b) => (a.tanggalBerlakuDateTime ?? DateTime.now())
              .compareTo(b.tanggalBerlakuDateTime ?? DateTime.now()),
        );

        var ex = CustomExpandedWidget(
          shaderStart: 0.6,
          title: namaKelompokUjian,
          subTitle: 'Singkatan: $initialKelompokUjian',
          moreItemCount: listPaketTO.length - 1,
          useBottomIndicator: listPaketTO.length > 1,
          collapsedVisibilityFactor: 1 / listPaketTO.length,
          leadingItem: (iconKelompokUjian.isEmpty)
              ? const SizedBox.shrink()
              : CustomImageNetwork.rounded(
                  iconKelompokUjian,
                  width: 32,
                  height: 32,
                  fit: BoxFit.fitHeight,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: List<Widget>.generate(
                listPaketTO.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: _buildItemPaketTimer(
                    listPaketTO[index],
                    (index > 0) ? listPaketTO[index - 1] : null,
                    true,
                  ),
                ),
              ),
            ),
          ),
        );
        return ex;
      },
    );
  }

  Widget _buildItemPaketTimer(
    PaketTO paketTO,
    PaketTO? paketSebelumnya,
    bool isKuis,
  ) {
    bool isBolehLihatKisiKisi =
        paketTO.isTOBMulai == true && paketTO.isTOBBerakhir != true;
    bool isPernahMengerjakan = paketTO.isPernahMengerjakan;
    bool isSudahDikumpulkan = paketTO.tanggalSiswaSubmit != null;
    bool isTOBBerakhir = paketTO.isTOBBerakhir == true;

    bool isWaktuHabis = paketTO.isTOBBerakhir == true;
    return Builder(
      builder: (context) {
        bool isRemedialGOA = (widget.idJenisProduk != 12)
            ? false
            : context.select<TOBProvider, bool>((tob) =>
                tob.getLaporanGOAByKodePaket(paketTO.kodePaket).isRemedial);

        return InkWell(
          onTap: () async => await _onClickPaketListTile(
              paketTO: paketTO,
              paketSebelumnya: paketSebelumnya,
              isHarusKumpulkan: isPernahMengerjakan &&
                  !isSudahDikumpulkan &&
                  isWaktuHabis &&
                  !isTOBBerakhir,
              isPernahMengerjakan: isPernahMengerjakan,
              isSudahDikumpulkan: isSudahDikumpulkan,
              isWaktuHabis: isWaktuHabis,
              isTOBBerakhir: isTOBBerakhir,
              isRemedialGOA: isRemedialGOA),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(min(24, context.dp(18))),
              border: Border.all(width: 0.5, color: context.hintColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildLeadingItem(
                      paketTO: paketTO,
                      isTeaser: paketTO.isTeaser,
                      isWaktuHabis: isWaktuHabis,
                      isTOBBerakhir: isTOBBerakhir,
                      isSudahDikumpulkan: isSudahDikumpulkan,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            paketTO.deskripsi,
                            style: context.text.labelMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            semanticsLabel: 'Paket ${paketTO.deskripsi}',
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.rocket_launch_outlined,
                                  color: context.tertiaryColor, size: 18),
                              Text(
                                ' ${paketTO.sekolahKelas} | ',
                                semanticsLabel:
                                    'Tingkat ${paketTO.sekolahKelas}',
                                style: context.text.bodySmall?.copyWith(
                                  color: context.tertiaryColor,
                                  fontSize: 11,
                                ),
                              ),
                              Icon(Icons.timer_outlined,
                                  color: context.tertiaryColor, size: 18),
                              Text(
                                ' ${paketTO.displayDurasiSingkat} | ',
                                semanticsLabel:
                                    'Durasi ${paketTO.displayDurasiSingkat}',
                                style: context.text.bodySmall?.copyWith(
                                  color: context.tertiaryColor,
                                  fontSize: 11,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${paketTO.jumlahSoal} soal',
                                  semanticsLabel: '${paketTO.jumlahSoal} soal',
                                  style: context.text.bodySmall?.copyWith(
                                    color: context.tertiaryColor,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const Divider(thickness: 0.15, indent: 12, endIndent: 12),
                if (isTOBBerakhir)
                  Padding(
                    padding: EdgeInsets.only(left: (isKuis) ? 6 : 10),
                    child: Text(
                      'Berakhir Pada: ${paketTO.displayTanggalBerakhir}',
                      semanticsLabel: 'paket-to-item-sub-title-duration',
                      style: context.text.bodySmall?.copyWith(
                        color: context.onBackground.withOpacity(0.8),
                      ),
                    ),
                  ),
                if (isPernahMengerjakan &&
                    !(!isSudahDikumpulkan && isTOBBerakhir))
                  Padding(
                    padding: EdgeInsets.only(left: (isKuis) ? 6 : 10),
                    child: Text(
                      (isSudahDikumpulkan)
                          ? 'Dikumpulkan Pada: ${paketTO.displayTanggalSiswaSubmit}\n'
                              'Berakhir: ${paketTO.displayTanggalBerakhir}'
                          : (isPernahMengerjakan && !isWaktuHabis)
                              ? 'Batas Pengerjaan: ${paketTO.displayDeadlinePengerjaan}'
                              : 'Batas Pengumpulan: ${paketTO.displayTanggalBerakhir}',
                      semanticsLabel: 'paket-to-item-sub-title-date',
                      style: context.text.bodySmall?.copyWith(
                        color: context.onBackground.withOpacity(0.8),
                        // fontWeight: ((isPernahMengerjakan && !isWaktuHabis) ||
                        //         (!isSudahDikumpulkan && isWaktuHabis))
                        //     ? FontWeight.w500
                        //     : FontWeight.w300,
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(
                      top: (isPernahMengerjakan) ? 4 : 0,
                      left: (isKuis) ? 6 : 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: (isPernahMengerjakan || isTOBBerakhir)
                            ? Text(
                                (isSudahDikumpulkan)
                                    ? 'Kamu sudah mengumpulkan paket ini sobat'
                                    : (isPernahMengerjakan && !isWaktuHabis)
                                        ? 'Yuk, lanjut mengerjakan sebelum waktu habis!'
                                        : (!isSudahDikumpulkan && isTOBBerakhir)
                                            ? 'Kamu tidak ${isPernahMengerjakan ? 'mengumpulkan' : 'mengerjakan'} paket ini sobat'
                                            : 'Jangan lupa kumpulkan jawaban kamu ya! Klik untuk mengumpulkan jawaban.',
                                semanticsLabel: 'Pesan tidak mengerjakan',
                                style: context.text.bodySmall?.copyWith(
                                  color: context.onBackground.withOpacity(0.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : (!isPernahMengerjakan && !isTOBBerakhir)
                                ? Text(
                                    'Dimulai: ${paketTO.displayTanggalMulai}\n'
                                    'Berakhir: ${paketTO.displayTanggalBerakhir}',
                                    style: context.text.bodySmall?.copyWith(
                                        color: context.onBackground
                                            .withOpacity(0.8)),
                                  )
                                : const Spacer(),
                      ),
                      InkWell(
                        onTap: (!isSudahDikumpulkan && isTOBBerakhir)
                            ? null
                            : () {
                                if (isSudahDikumpulkan || isTOBBerakhir) {
                                  if (paketTO.idJenisProduk == '12') {
                                    _showLaporanGOA(paketTO: paketTO);
                                  } else {
                                    _showDetailHasil(context, paketTO);
                                  }
                                } else if (isBolehLihatKisiKisi) {
                                  _onClickLihatKisiKisi(paketTO.kodePaket);
                                } else {
                                  _showDetailHasil(context, paketTO);
                                }
                              },
                        child: Chip(
                          label: Text(
                            (isSudahDikumpulkan)
                                ? 'Lihat hasil'
                                : (isBolehLihatKisiKisi)
                                    ? 'Lihat kisi-kisi'
                                    : 'Lihat hasil',
                            semanticsLabel: (isSudahDikumpulkan)
                                ? 'Lihat hasil'
                                : (isBolehLihatKisiKisi)
                                    ? 'Lihat kisi-kisi'
                                    : 'Lihat hasil',
                          ),
                          labelStyle: context.text.bodySmall?.copyWith(
                            color: (!isSudahDikumpulkan && isTOBBerakhir)
                                ? context.disableColor
                                : context.tertiaryColor,
                            fontSize: 10,
                          ),
                          labelPadding: EdgeInsets.zero,
                          padding: (context.isMobile)
                              ? const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 12)
                              : const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                          backgroundColor:
                              (!isSudahDikumpulkan && isTOBBerakhir)
                                  ? context.disableColor
                                  : null,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(context.dp(32)),
                              side: BorderSide(color: context.tertiaryColor)),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _showDetailHasil(BuildContext context, PaketTO paketTO) async {
    final getDetailHasil = context.read<SolusiProvider>().getDetailHasil(
          noRegistrasi: gNoRegistrasi,
          idSekolahKelas: userData?.idSekolahKelas ?? '14',
          kodePaket: paketTO.kodePaket,
          jumlahSoal: paketTO.jumlahSoal,
          tingkatkelas: paketTO.tingkatKelas,
          jenisHasil: 'paket',
        );

    Widget? childWidget;

    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      constraints: BoxConstraints(maxHeight: context.dh * 0.9),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        childWidget ??= Selector<SolusiProvider, List<DetailHasilModel>>(
            selector: (_, solusi) => solusi.listDetailHasil,
            builder: (context, listDetailHasil, _) {
              return FutureBuilder(
                future: getDetailHasil,
                builder: (context, snapshot) {
                  bool isLoading =
                      snapshot.connectionState == ConnectionState.waiting ||
                          context.select<SolusiProvider, bool>(
                              (solusi) => solusi.isloading);

                  if (isLoading) {
                    return const ShimmerListTiles(
                        shrinkWrap: true, jumlahItem: 2);
                  }

                  if (listDetailHasil.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: context.dp(18),
                        left: context.dp(18),
                        top: context.dp(24),
                        bottom: context.dp(24),
                      ),
                      child: Text(
                        "Belum ada soal ${paketTO.kodePaket} yang telah Sobat kerjakan, "
                        "yuk kerjain soal dulu Sobat.",
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: context.dp(18), horizontal: 16),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: listDetailHasil.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (index == 0)
                              Column(
                                children: [
                                  Center(
                                    child: Text(paketTO.kodePaket,
                                        style: context.text.titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                  constraints:
                                      BoxConstraints(maxWidth: context.dw - 32),
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Text(
                                    listDetailHasil[index]
                                        .namaKelompokUjian
                                        .toString(),
                                    style: context.text.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                            DetailCapaianChart(
                              capaianDetail: CapaianDetailScore(
                                label: listDetailHasil[index]
                                    .namaKelompokUjian
                                    .toString(),
                                benar: listDetailHasil[index].benar,
                                salah: listDetailHasil[index].salah,
                                kosong: listDetailHasil[index].kosong,
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  );
                },
              );
            });

        return childWidget!;
      },
    );
  }

  void _navigateToSoalTimerScreen(PaketTO paketTO, bool isRemedialGOA) {
    _navigator.pushNamed(Constant.kRouteSoalTimerScreen, arguments: {
      'kodeTOB': paketTO.kodeTOB,
      'kodePaket': paketTO.kodePaket,
      'idJenisProduk': widget.idJenisProduk,
      'namaJenisProduk': widget.namaJenisProduk,
      'waktu': paketTO.totalWaktu,
      'tanggalSelesai': paketTO.deadlinePengerjaan,
      'tanggalSiswaSubmit': paketTO.tanggalSiswaSubmit,
      'tanggalKedaluwarsaTOB': paketTO.tanggalKedaluwarsaDateTime,
      'isBlockingTime': paketTO.isBlockingTime,
      'isPernahMengerjakan':
          isRemedialGOA ? false : paketTO.isPernahMengerjakan,
      'isRandom': paketTO.isRandom,
      'isBolehLihatSolusi': (paketTO.isTOBBerakhir == true) ||
          ((paketTO.idJenisProduk == '16' || paketTO.idJenisProduk == '80') &&
              paketTO.isSelesai),
      'isRemedialGOA': isRemedialGOA,
      'urutan': widget.idJenisProduk == 16 ? 1 : paketTO.urutanAktif,
      'isNextSoal': true,
      'listIdBundelSoal': paketTO.listIdBundleSoal,
      'isSelesai': paketTO.isSelesai,
      'jumlahSoalPaket': paketTO.jumlahSoal,
    }).then((_) => _onRefreshPaket());
  }

  String get tingkatKelas =>
      Constant.kDataSekolahKelas.singleWhere(
        (sekolah) => sekolah['id'] == userData?.idSekolahKelas,
        orElse: () => {
          'id': '0',
          'kelas': 'Undefined',
          'tingkat': 'Other',
          'tingkatKelas': '0'
        },
      )['tingkatKelas'] ??
      '0';

  String get tahunAjaran {
    final bulanSekarang = DateTime.now().month;
    final tahunSekarang = DateTime.now().year;
    final tahunDepan = tahunSekarang + 1;
    final tahunKemarin = tahunSekarang - 1;

    final defaultTahunAjaran = (bulanSekarang < 7)
        ? '$tahunKemarin/$tahunSekarang'
        : '$tahunSekarang/$tahunDepan';
    return defaultTahunAjaran;
  }

  void paginationListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        page < jumlahHalaman) {
      _onRefreshPaket(page: page += 1);
    }
  }
}
