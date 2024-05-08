// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer' as logger show log;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gokreasi_new/core/config/theme.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/core/config/enum.dart';
import 'package:flutter/foundation.dart';
import 'package:flash/flash_helper.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/home/presentation/bloc/ptn/ptn_bloc.dart';
import 'package:gokreasi_new/features/profile/domain/entity/kelompok_ujian.dart';
import 'package:gokreasi_new/features/profile/domain/entity/mapel_pilihan.dart';
import 'package:gokreasi_new/features/profile/presentation/bloc/profile/profile_bloc.dart';
import 'package:gokreasi_new/features/ptn/module/ptnclopedia/entity/kampus_impian.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/presentation/bloc/tobk/tobk_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'popup_tobk_bersyarat.dart';
import '../../entity/tob.dart';
import '../../entity/syarat_tobk.dart';
import '../../../../../profile/presentation/widget/pilih_kelompok_ujian.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/constant.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/helper/hive_helper.dart';
import '../../../../../../core/shared/widget/empty/basic_empty.dart';
import '../../../../../../core/shared/widget/loading/shimmer_list_tiles.dart';
import '../../../../../../core/shared/widget/watermark/watermark_widget.dart';
import '../../../../../../core/shared/widget/refresher/custom_smart_refresher.dart';

/// [TOBList] merupakan Widget List TOB.<br><br>
/// Digunakan pada produk-produk berikut:<br>
/// 1. TOBK (id: 25).<br>
class TOBList extends StatefulWidget {
  final int idJenisProduk;
  final String namaJenisProduk;
  final bool isRencanaPicker;

  /// [selectedKodeTOB] merupakan kodeTOB yang didapat dari rencana belajar
  /// atau onClick Notification
  final String? selectedKodeTOB;

  /// [selectedKodeTOB] merupakan namaTOB yang didapat dari rencana belajar
  /// atau onClick Notification
  final String? selectedNamaTOB;

  /// Untuk keperluan handle push and pop
  final String? diBukaDari;

  const TOBList({
    Key? key,
    required this.idJenisProduk,
    required this.namaJenisProduk,
    this.isRencanaPicker = false,
    this.selectedKodeTOB,
    this.selectedNamaTOB,
    this.diBukaDari,
  }) : super(key: key);

  @override
  State<TOBList> createState() => _TOBListState();
}

class _TOBListState extends State<TOBList> {
  late final NavigatorState _navigator = Navigator.of(context);
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final RefreshController _emptyRefreshController =
      RefreshController(initialRefresh: false);
  late TOBKBloc tobkBloc;
  Tob? selectedTOB;
  Map<String, dynamic> selectedParamLaporan = {};
  List<Tob> listTOB = [];
  SyaratTOBK? selectedSyaratTOBK;
  var completer = Completer();
  bool isBolehTO = false;
  bool? isMemenuhiSyarat = false;
  bool? isTOBLoading;
  UserModel? userData;
  List<MapelPilihan> listCurrentMapel = [];
  List<KampusImpian> listKampusPilihan = [];

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is LoadedUser) {
      userData = authState.user;
    }
    tobkBloc = context.read<TOBKBloc>();
    _onRefreshTOB(false);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _emptyRefreshController.dispose();
    if (HiveHelper.isBoxOpen<KelompokUjian>(
        boxName: HiveHelper.kKelompokUjianPilihanBox)) {
      HiveHelper.closeBox<KelompokUjian>(
          boxName: HiveHelper.kKelompokUjianPilihanBox);
    }
    if (HiveHelper.isBoxOpen<List<KelompokUjian>>(
        boxName: HiveHelper.kKonfirmasiTOMerdekaBox)) {
      HiveHelper.closeBox<List<KelompokUjian>>(
          boxName: HiveHelper.kKonfirmasiTOMerdekaBox);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(context.textScale12),
      ),
      child: BlocBuilder<PtnBloc, PtnState>(
        builder: (_, ptnState) {
          if (ptnState is PtnDataLoaded) {
            listKampusPilihan = ptnState.listKampusPilihan;
          }

          return BlocBuilder<ProfileBloc, ProfileState>(
            builder: (_, state) {
              if (state is LoadedGetCurrentMapel) {
                listCurrentMapel = state.listMapelPilihan;
              }

              return BlocConsumer<TOBKBloc, TOBKState>(
                listener: (_, state) async {
                  // pakai groute untuk menghindari looping navigate
                  if (state is LoadedListTO &&
                      gRoute != Constant.kRoutePaketTOScreen &&
                      !state.isRefresh) {
                    _navigateToPaketTOBK();
                  }

                  if (state is TOBKSyaratLoading) {
                    context.showBlockDialog(dismissCompleter: completer);
                  }

                  if (state is! TOBKSyaratLoading) {
                    if (!completer.isCompleted) {
                      completer.complete();
                    }
                  }

                  if (state is TOBKErrorMapel) {
                    await _pilihKelompokUjian(tob: selectedTOB!);
                  }

                  if (state is LoadedItemSyaratTOBK) {
                    if (isBolehTO) {
                      isMemenuhiSyarat = isBolehTO;
                      if (selectedTOB?.isFormatTOMerdeka == true) {
                        List<int> listIdProduk = userData?.listIdProduk == null
                            ? []
                            : (userData?.listIdProduk ?? []);
                        tobkBloc.add(TOBKGetListTO(
                          listIdProduk: listIdProduk,
                          isRefresh: false,
                          idJenisProduk: widget.idJenisProduk,
                          kodeTOB: selectedTOB?.kodeTOB,
                          noRegistrasi: userData?.noRegistrasi,
                          idBundlingAktif: userData?.idBundlingAktif ?? 0,
                        ));
                      } else {
                        if (gRoute != Constant.kRoutePaketTOScreen) {
                          _navigateToPaketTOBK();
                        }
                      }
                    }
                  }

                  if (state is LoadedPopUpSyaratTOBK) {
                    SyaratTOBK? syarat =
                        state.listSyaratTOB[selectedTOB?.kodeTOB];

                    final popUpWidget = PopUpTOBKBersyarat(
                      syaratTOBK: syarat,
                      namaTOB: selectedTOB?.namaTOB ?? '',
                      diBukaDari: widget.diBukaDari,
                    );

                    bool? confirmMulai = await showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      clipBehavior: Clip.hardEdge,
                      constraints: BoxConstraints(
                        maxWidth: min(650, context.dw),
                        maxHeight: context.dh * 0.89,
                      ),
                      builder: (context) => popUpWidget,
                    );

                    isBolehTO = confirmMulai ?? false;

                    // List<KelompokUjian> daftarMataUjiPilihan = [];
                    //
                    // if (isBolehTO && selectedTOB?.isFormatTOMerdeka == true) {
                    //   daftarMataUjiPilihan =
                    //       await HiveHelper.getKonfirmasiTOMerdeka(
                    //           kodeTOB: selectedTOB?.kodeTOB ?? '');
                    //
                    //   if (daftarMataUjiPilihan.isEmpty) {
                    //     isBolehTO = await _pilihKelompokUjian(tob: selectedTOB!);
                    //     daftarMataUjiPilihan =
                    //         await HiveHelper.getKonfirmasiTOMerdeka(
                    //             kodeTOB: selectedTOB?.kodeTOB ?? '');
                    //   }
                    // }

                    if (!completer.isCompleted) {
                      completer.complete();
                    }

                    if (confirmMulai != true) return;

                    if (selectedTOB?.isFormatTOMerdeka == true) {
                      List<int> listIdProduk = userData?.listIdProduk == null
                          ? []
                          : (userData?.listIdProduk ?? []);
                      tobkBloc.add(TOBKGetListTO(
                        listIdProduk: listIdProduk,
                        isRefresh: false,
                        idJenisProduk: widget.idJenisProduk,
                        kodeTOB: selectedTOB?.kodeTOB,
                        noRegistrasi: userData?.noRegistrasi,
                        idBundlingAktif: userData?.idBundlingAktif ?? 0,
                      ));
                    } else {
                      isMemenuhiSyarat = syarat?.isLulus;
                      if (gRoute != Constant.kRoutePaketTOScreen) {
                        _navigateToPaketTOBK();
                      }
                    }
                  }

                  if (state is TOBKErrorSyarat) {
                    Future.delayed(Duration.zero, () {
                      gShowTopFlash(
                        context,
                        kDebugMode ? state.err : gPesanError,
                        dialogType: DialogType.error,
                      );
                    });
                    if (!completer.isCompleted) {
                      completer.complete();
                    }
                  }
                },
                builder: (context, state) {
                  isTOBLoading = state is TOBKSyaratLoading;

                  if (state is TOBKLoading ||
                      state is TOBIsLoading ||
                      state is TOBKSyaratLoading) {
                    return const ShimmerListTiles(isWatermarked: true);
                  }

                  if (state is LoadedListTOB) {
                    listTOB = state.listTOB;
                  }

                  listTOB.sort((a, b) =>
                      b.tanggalMulaiDateTime.compareTo(a.tanggalMulaiDateTime));

                  var refreshWidget = CustomSmartRefresher(
                    controller: (listTOB.isEmpty)
                        ? _emptyRefreshController
                        : _refreshController,
                    isDark: true,
                    onRefresh: _onRefreshTOB,
                    child: (listTOB.isEmpty)
                        ? _getIllustrationImage(widget.idJenisProduk)
                        : _buildListTOB(listTOB),
                  );

                  return (listTOB.isEmpty)
                      ? refreshWidget
                      : WatermarkWidget(
                          child: refreshWidget,
                        );
                },
              );
            },
          );
        },
      ),
    );
  }

  // On Refresh Function
  Future<void> _onRefreshTOB([bool refresh = true]) async {
    // Function load and refresh data

    List<int> listIdProduk =
        userData?.listIdProduk == null ? [] : (userData?.listIdProduk ?? []);
    Map<String, dynamic> params = {}
      ..['list_id_produk'] = listIdProduk
      ..['no_register'] = userData?.noRegistrasi;
    tobkBloc.add(TOBKGetDaftarTOB(
      isRefresh: refresh,
      params: params,
      idJenisProduk: widget.idJenisProduk,
      idBundlingAktif: userData?.idBundlingAktif ?? 0,
    ));

    context.read<ProfileBloc>().add(ProfileGetSekolahKelas(userData));

    // Open KelompokUjianPilihanBox untuk mengecek
    // pilihan mata uji untuk TOBK merdeka.
    if (!HiveHelper.isBoxOpen<KelompokUjian>(
        boxName: HiveHelper.kKelompokUjianPilihanBox)) {
      await HiveHelper.openBox<KelompokUjian>(
          boxName: HiveHelper.kKelompokUjianPilihanBox);
    }
    if (!HiveHelper.isBoxOpen<List<KelompokUjian>>(
        boxName: HiveHelper.kKonfirmasiTOMerdekaBox)) {
      await HiveHelper.openBox<List<KelompokUjian>>(
          boxName: HiveHelper.kKonfirmasiTOMerdekaBox);
    }
  }

  Future<bool> _pilihKelompokUjian({required Tob tob}) async {
    // Membuat variableTemp guna mengantisipasi rebuild saat scroll
    Widget? childWidget;
    bool? sudahTerkonfirmasi = await showModalBottomSheet(
      context: context,
      elevation: 4,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: context.background,
      constraints: BoxConstraints(
        minHeight: 10,
        maxHeight: context.dh * 0.86,
        maxWidth: min(650, context.dw),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        childWidget ??= PilihKelompokUjian(
          isFromTOBK: true,
          currentMapel: listCurrentMapel,
        );
        return childWidget!;
      },
    );

    if (gRoute != Constant.kRoutePaketTOScreen && sudahTerkonfirmasi == true) {
      _navigateToPaketTOBK();
    }

    if (!(sudahTerkonfirmasi ?? false) && mounted) {
      gShowBottomDialogInfo(context,
          title: 'Belum Mengkonfirmasi Mata Uji Pilihan',
          message:
              'TryOut ${tob.namaTOB} merupakan TryOut dengan format kurikulum merdeka. '
              'TryOut kurikulum merdeka membutuhkan konfirmasi mata uji pilihan');
    }

    return sudahTerkonfirmasi ?? false;
  }

  // ON-CLICK TOB
  Future<void> _onClickTOB({
    required Tob tob,
    required Map<String, dynamic> paramsLaporan,
    required bool isTOBBerakhir,
  }) async {
    if (widget.isRencanaPicker) {
      if (isTOBBerakhir) {
        await gShowBottomDialogInfo(
          context,
          message: 'Maaf, TOB telah berakhir sobat',
        );
        return;
      }

      var isBerakhir = (tob.isTOBBerakhir == true);

      if (!isBerakhir) {
        // Kembali ke Rencana Belajar Editor
        Navigator.pop(context, {
          'idJenisProduk': 25,
          'namaJenisProduk': 'e-TOBK',
          'kodeTOB': tob.kodeTOB,
          'namaTOB': tob.namaTOB,
          'keterangan':
              'Mengerjakan TryOut ${tob.namaTOB} dimulai pada ${tob.displayTanggalMulai} '
                  'sampai dengan ${tob.displayTanggalBerakhir}',
        });
      } else {
        gShowBottomDialogInfo(context,
            title: 'TryOut ${tob.namaTOB} Telah Berakhir',
            message: 'Kamu tidak dapat memilih TryOut ${tob.namaTOB} '
                'untuk rencana belajar karena TryOut ini telah berakhir!');
      }
    } else {
      selectedTOB = tob;
      selectedParamLaporan = paramsLaporan;

      isBolehTO = true;

      if (userData?.isBolehPTN == true &&
          tob.jenisTOB.equalsIgnoreCase('UTBK')) {
        KampusImpian? kampusImpian1 =
            (listKampusPilihan.isEmpty) ? null : listKampusPilihan.first;

        if (kampusImpian1 == null && !isTOBBerakhir) {
          await gShowTopFlash(
            context,
            'Silahkan pilih kampus impian dulu, sobat',
            dialogType: DialogType.error,
          );

          Map<String, dynamic> params = await _paketTOArguments();
          Navigator.pushNamed(
            context,
            Constant.kRouteImpianPicker,
            arguments: {
              'pilihanKe': 1,
              'kampusPilihan': kampusImpian1,
              'paketTOArguments': params,
            },
          );
          return;
        }
      }

      tobkBloc.add(TOBKCekBolehTO(
        noRegistrasi: userData?.noRegistrasi,
        kodeTOB: selectedTOB?.kodeTOB ?? '',
        namaTOB: selectedTOB?.namaTOB ?? '',
        isPopup: selectedTOB?.isBersyarat == true,
      ));
    }
  }

  // Get Illustration Image Function
  BasicEmpty _getIllustrationImage(int idJenisProduk) {
    bool isProdukDibeli =
        userData.isProdukDibeliSiswa(idJenisProduk, ortuBolehAkses: true);
    String imageUrl = 'ilustrasi_tobk.png'.illustration;
    String title = 'TryOut Berbasis Komputer';

    return BasicEmpty(
      isLandscape: !context.isMobile,
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
  }

  Widget _buildLeadingItem({
    required Tob tob,
    required bool isTeaser,
    required bool isKedaluwarsa,
  }) {
    Widget leadingWidget = Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: min(12, context.dp(8)),
        vertical: min(14, context.dp(6)),
      ),
      constraints: BoxConstraints(
        minWidth: min(76, context.dp(72)),
        maxWidth: min(80, context.dp(76)),
        minHeight: min(36, context.dp(32)),
        maxHeight: min(46, context.dp(42)),
      ),
      decoration: BoxDecoration(
        color: (tob.isSelesai)
            ? Palette.kSuccessSwatch[500]
            : (tob.isPernahMengerjakan)
                ? Palette.kSecondarySwatch[400]
                : (!tob.isSudahDiKumpulkan && (tob.isTOBBerakhir == true))
                    ? context.primaryColor
                    : (tob.isTOBBerakhir == true)
                        ? context.disableColor
                        : isTeaser
                            ? context.tertiaryColor
                            : context.background,
        border: (isTeaser) ? null : Border.all(color: context.tertiaryColor),
        borderRadius: BorderRadius.circular(min(16, context.dp(14))),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          // 'Ujian\nSekolah',
          (context.isMobile)
              ? tob.jenisTOB.replaceAll(' ', '\n')
              : tob.jenisTOB,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.fade,
          style: context.text.labelMedium?.copyWith(
            fontSize: (context.isMobile) ? 12 : 10,
            fontWeight: FontWeight.bold,
            color: isKedaluwarsa
                ? context.disableColor
                : isTeaser
                    ? context.onTertiary
                    : context.tertiaryColor,
          ),
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
                    color: isKedaluwarsa
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

  // List Bundel Widgets
  Widget _buildListTOB(List<Tob> listTOB) {
    // initial kodeTOB di perlukan untuk keperluan Rencana Belajar.
    int initialTOBIndex = (widget.selectedKodeTOB == null)
        ? 0
        : listTOB.indexWhere((tob) => tob.kodeTOB == widget.selectedKodeTOB);

    if (kDebugMode) {
      logger.log('TOB_LIST-ListTOB: initial index >> $initialTOBIndex');
      logger.log('TOB_LIST-ListTOB: selected KodeTOB '
          '>> ${widget.selectedKodeTOB}, ${widget.selectedNamaTOB}');
    }

    if (initialTOBIndex < 0) {
      initialTOBIndex = 0;

      gShowBottomDialogInfo(context,
          message: 'Tryout ${widget.selectedNamaTOB} tidak ditemukan');
    }

    return ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.only(top: 8, bottom: context.dp(30)),
        itemCount: (context.isMobile)
            ? listTOB.length
            : (listTOB.length.isEven)
                ? (listTOB.length / 2).floor()
                : (listTOB.length / 2).floor() + 1,
        itemBuilder: (context, index) {
          return (context.isMobile)
              ? _buildItemTOB(
                  context,
                  index: index,
                  listTOB: listTOB,
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildItemTOB(
                        context,
                        index: index * 2,
                        listTOB: listTOB,
                      ),
                    ),
                    (((index * 2) + 1) < listTOB.length)
                        ? Expanded(
                            child: _buildItemTOB(
                              context,
                              index: (index * 2) + 1,
                              listTOB: listTOB,
                            ),
                          )
                        : const Spacer(),
                  ],
                );
        });
  }

  Widget _buildItemTOB(
    BuildContext context, {
    required int index,
    required List<Tob> listTOB,
  }) {
    return Builder(builder: (context) {
      Tob tob = listTOB[index];
      bool isTOBBerakhir = tob.isTOBBerakhir == true;
      Map<String, dynamic> paramsLaporan = {
        "penilaian": (tob.jenisTOB == "UTBK") ? "IRT" : "B Saja",
        "kodeTOB": tob.kodeTOB,
        'namaTOB': tob.namaTOB,
        'jenisTO': tob.jenisTOB,
        'showEPB': false,
        'isExists': false,
        'link': "",
      };
      Map<String, dynamic> paramsJawabanLaporan = {
        "noRegister": userData?.noRegistrasi ?? '',
        "kodeTOB": tob.kodeTOB,
        'namaTOB': tob.namaTOB,
        'jenisTO': tob.jenisTOB,
        'tingkatKelas': userData?.tingkatKelas ?? '',
      };

      return InkWell(
        onTap: (isTOBLoading != true)
            ? () async => await _onClickTOB(
                  tob: tob,
                  paramsLaporan: paramsLaporan,
                  isTOBBerakhir: isTOBBerakhir,
                )
            : null,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (widget.selectedNamaTOB == tob.namaTOB)
                ? context.secondaryContainer
                : (isTOBBerakhir)
                    ? context.disableColor
                    : null,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(width: 0.5, color: context.hintColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLeadingItem(
                    tob: tob,
                    isTeaser: tob.isTeaser,
                    isKedaluwarsa: isTOBBerakhir,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tob.namaTOB,
                          style: context.text.labelMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          semanticsLabel: tob.namaTOB,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (tob.isBersyarat)
                              Icon(Icons.gpp_maybe_outlined,
                                  color: (isTOBBerakhir)
                                      ? context.hintColor
                                      : context.primaryColor,
                                  size: 18),
                            if (tob.isBersyarat)
                              Text(
                                ' Bersyarat |  ',
                                semanticsLabel: 'bersyarat ${tob.isBersyarat}',
                                style: context.text.bodySmall?.copyWith(
                                    color: (isTOBBerakhir)
                                        ? context.hintColor
                                        : context.tertiaryColor,
                                    fontSize: 11),
                              ),
                            Icon(Icons.settings_ethernet_rounded,
                                color: (isTOBBerakhir)
                                    ? context.hintColor
                                    : context.tertiaryColor,
                                size: 18),
                            // Expanded(
                            //   child: Text(
                            //     '  ${tob.jarakAntarPaket} menit interval',
                            //     semanticsLabel:
                            //         '${tob.jarakAntarPaket} menit interval',
                            //     style: context.text.bodySmall?.copyWith(
                            //       color: (isTOBBerakhir)
                            //           ? context.hintColor
                            //           : context.tertiaryColor,
                            //       fontSize: 11,
                            //     ),
                            //   ),
                            // )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(thickness: 0.15, indent: 12, endIndent: 12),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        (isTOBBerakhir)
                            ? 'Berakhir pada: ${tob.displayTanggalBerakhir}'
                            : 'Dimulai: ${tob.displayTanggalMulai}\n'
                                'Berakhir: ${tob.displayTanggalBerakhir}',
                        semanticsLabel: 'Waktu tayag paket soal',
                        style: context.text.bodySmall?.copyWith(
                          color: context.onBackground.withOpacity(0.8),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (userData.isLogin) {
                          // sementara di by pass
                          // if (isTOBBerakhir) {
                          //   Navigator.of(context).pushNamed(
                          //       Constant.kRouteLaporanTryOutNilai,
                          //       arguments: paramsLaporan);
                          // } else {
                          //   gShowBottomDialogInfo(context,
                          //       message: '${tob.namaTOB} belum berakhir, '
                          //           'sehingga kamu belum bisa melihat hasil TryOut.');
                          // }
                          Navigator.of(context).pushNamed(
                              Constant.kRouteLaporanJawaban,
                              arguments: paramsJawabanLaporan);
                        } else {
                          gShowBottomDialogInfo(context,
                              message: 'Laporan Try Out hanya tersedia '
                                  'untuk siswa Ganesha Operation');
                        }
                      },
                      child: Chip(
                        label: Text(
                            (context.isMobile) ? 'Laporan' : 'Lihat Laporan'),
                        labelStyle: context.text.bodySmall?.copyWith(
                          color: (isTOBBerakhir)
                              ? context.onPrimaryContainer
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
                            (isTOBBerakhir) ? context.primaryContainer : null,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(context.dp(32)),
                            side: BorderSide(color: context.tertiaryColor)),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _navigateToPaketTOBK() async {
    _navigator
        .pushNamed(
          Constant.kRoutePaketTOScreen,
          arguments: await _paketTOArguments(),
        )
        .then((_) => _onRefreshTOB(false));
  }

  Future<Map<String, dynamic>> _paketTOArguments() async {
    String deviceId = await gGetIdDevice() ?? 'FAILED_TO_GET_DEVICE_ID';
    return {
      'idJenisProduk': widget.idJenisProduk,
      'namaJenisProduk': widget.namaJenisProduk,
      'paramsLaporan': selectedParamLaporan,
      'kodeTOB': selectedTOB?.kodeTOB,
      'noRegistrasi': userData?.noRegistrasi ?? deviceId,
      'namaTOB': selectedTOB?.namaTOB,
      'interval': selectedTOB?.jarakAntarPaket,
      'tanggalMulai': selectedTOB?.tanggalMulaiDateTime,
      'tanggalBerakhir': selectedTOB?.tanggalBerakhirDateTime,
      'isFormatTOMerdeka': selectedTOB?.isFormatTOMerdeka,
      // 'daftarMataUjiPilihan': daftarMataUjiPilihan,
      'isBolehLihatKisiKisi': selectedTOB?.isTOBBerakhir != true,
      'isTOBRunning': selectedTOB?.isTOBMulai == true,
      'isMemenuhiSyarat': isMemenuhiSyarat,
      'userData': userData,
      'selectedTOB': selectedTOB,
    };
  }
}
