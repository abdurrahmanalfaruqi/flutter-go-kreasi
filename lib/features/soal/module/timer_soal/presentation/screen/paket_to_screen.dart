// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:developer' as logger show log;
import 'dart:math';

import 'package:flash/flash.dart';
import 'package:flash/flash_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gokreasi_new/core/config/theme.dart';
import 'package:gokreasi_new/core/shared/widget/empty/basic_empty.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/home/presentation/bloc/ptn/ptn_bloc.dart';
import 'package:gokreasi_new/features/laporan/module/tobk/model/laporan_tryout_tob_model.dart';
import 'package:gokreasi_new/features/laporan/module/tobk/presentation/bloc/laporan_tobk/laporan_tobk_bloc.dart';
import 'package:gokreasi_new/features/ptn/module/ptnclopedia/entity/kampus_impian.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/entity/tob.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/presentation/bloc/tobk/tobk_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../provider/tob_provider.dart';
import '../../entity/paket_to.dart';
import '../../../../presentation/widget/kisi_kisi_widget.dart';
import '../../../../../../core/config/enum.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/constant.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/util/data_formatter.dart';
import '../../../../../../core/shared/screen/basic_screen.dart';
import '../../../../../../core/shared/widget/loading/shimmer_list_tiles.dart';
import '../../../../../../core/shared/widget/watermark/watermark_widget.dart';
import '../../../../../../core/shared/widget/refresher/custom_smart_refresher.dart';

/// [PaketToScreen] halaman yang digunakan untuk menampilkan daftar
/// Paket Soal khusus dari TOBK (id: 25).
class PaketToScreen extends StatefulWidget {
  final int idJenisProduk;
  final String namaJenisProduk;
  final String kodeTOB;
  final String namaTOB;
  final String noRegistrasi;
  final int jarakAntarPaket;
  final DateTime tanggalMulaiTO;
  final DateTime tanggalBerakhirTO;
  // final List<KelompokUjian> daftarMataUjiPilihan;
  final bool isFormatTOMerdeka;
  final bool isBolehLihatKisiKisi;
  final bool isTOBRunning;
  final bool isMemenuhiSyarat;
  final Map<String, dynamic> paramsLaporan;
  final UserModel? userData;
  final Tob? selectedTOB;

  const PaketToScreen({
    Key? key,
    required this.idJenisProduk,
    required this.namaJenisProduk,
    required this.kodeTOB,
    required this.noRegistrasi,
    required this.jarakAntarPaket,
    required this.tanggalMulaiTO,
    required this.tanggalBerakhirTO,
    required this.namaTOB,
    required this.isFormatTOMerdeka,
    required this.isBolehLihatKisiKisi,
    required this.isTOBRunning,
    required this.isMemenuhiSyarat,
    // required this.daftarMataUjiPilihan,
    required this.paramsLaporan,
    required this.userData,
    required this.selectedTOB,
  }) : super(key: key);

  @override
  State<PaketToScreen> createState() => _PaketToScreenState();
}

class _PaketToScreenState extends State<PaketToScreen> {
  late final NavigatorState _navigator = Navigator.of(context);
  late TOBKBloc tobkBloc;
  late LaporanTobkBloc laporanTobkBloc;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final RefreshController _emptyRefreshController =
      RefreshController(initialRefresh: false);

  late final String _displayTOBBerakhir = DataFormatter.formatDate(
    DataFormatter.dateTimeToString(widget.tanggalBerakhirTO),
    '[HH:mm] dd MMM y',
  );
  late final String _displayTOBMulai = DataFormatter.formatDate(
    DataFormatter.dateTimeToString(widget.tanggalMulaiTO),
    '[HH:mm] dd MMM y',
  );

  List<PaketTO> listPaketTO = [];
  List<KampusImpian> listKampusImpian = [];
  var completer = Completer();

  UserModel? userData;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    tobkBloc = context.read<TOBKBloc>();
    laporanTobkBloc = context.read<LaporanTobkBloc>();
    final authState = context.read<AuthBloc>().state;
    if (authState is LoadedUser) {
      userData = authState.user;
    }
    _onRefreshPaketTO(false);

    startTimer();

    final ptnState = context.read<PtnBloc>().state;
    if (ptnState is PtnDataLoaded) {
      listKampusImpian = ptnState.listKampusPilihan;
    }
  }

  @override
  void dispose() async {
    gRoute = Constant.kRouteTobkScreen;
    _refreshController.dispose();
    _emptyRefreshController.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasicScreen(
      title: widget.namaTOB,
      subTitle: (widget.selectedTOB?.isTOBBerakhir == true)
          ? 'Berakhir Pada: $_displayTOBBerakhir'
          : (!widget.isTOBRunning)
              ? 'Dimulai Pada: $_displayTOBMulai'
              : (widget.jarakAntarPaket > 0)
                  ? 'Interval: ${widget.jarakAntarPaket} menit'
                  : 'Dimulai Pada: $_displayTOBMulai',
      jumlahBarisTitle: (widget.jarakAntarPaket > 0) ? 2 : 1,
      body: (widget.selectedTOB?.isTOBBerakhir == true) ||
              (!widget.isTOBRunning) ||
              (!widget.isMemenuhiSyarat)
          ? Column(
              children: [
                _buildPesanTryoutSelesai(),
                Expanded(child: _buildPaketTOContent()),
              ],
            )
          : _buildPaketTOContent(),
      floatingActionButton: (widget.selectedTOB?.isTOBBerakhir == true)
          ? BlocSelector<LaporanTobkBloc, LaporanTobkState, bool>(
              selector: (state) => state is LaporanTobkLoading,
              builder: (context, isLoading) {
                if (isLoading) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    width: (context.isMobile)
                        ? context.dw * 0.4
                        : context.dw * 0.175,
                    height: (context.isMobile) ? 50 : 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: context.secondaryContainer,
                    ),
                    child: const Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                }

                return ElevatedButton.icon(
                  onPressed: (isLoading) ? null : _onClickLaporanFAB,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.secondaryContainer,
                    foregroundColor: context.onSecondaryContainer,
                    padding: EdgeInsets.only(
                      right: (context.isMobile) ? context.dp(18) : 24,
                      left: (context.isMobile) ? context.dp(14) : 18,
                      top: (context.isMobile) ? context.dp(12) : 16,
                      bottom: (context.isMobile) ? context.dp(12) : 16,
                    ),
                  ),
                  icon: const Icon(Icons.assignment_outlined),
                  label: const Text('Lihat Laporan'),
                );
              })
          : null,
    );
  }

  Future<void> _onRefreshPaketTO([bool refresh = true]) async {
    List<int> listIdProduk =
        userData?.listIdProduk == null ? [] : (userData?.listIdProduk ?? []);
    // Function load and refresh data
    tobkBloc.add(TOBKGetListTO(
      listIdProduk: listIdProduk,
      isRefresh: refresh,
      idJenisProduk: widget.idJenisProduk,
      kodeTOB: widget.kodeTOB,
      noRegistrasi: userData?.noRegistrasi,
      idBundlingAktif: userData?.idBundlingAktif ?? 0,
    ));
    await gSetServerTimeOffset();
  }

  Future<void> _kumpulkanPaket({
    required FlashController controller,
    required PaketTO paketTO,
  }) async {
    final tobProvider = context.read<TOBProvider>();
    final completer = Completer();
    context.showBlockDialog(dismissCompleter: completer);

    await tobProvider
        .olahDataJawaban(
      namaJenisProduk: widget.namaJenisProduk,
      userData: userData,
      kodePaket: paketTO.kodePaket,
      idJenisProduk: widget.idJenisProduk,
    )
        .then((_) async {
      await tobProvider.submitJawabanSiswa(
        isOutOfTime: false,
        userData: userData,
        kodePaket: paketTO.kodePaket,
        idJenisProduk: widget.idJenisProduk,
        kodeTOB: widget.kodeTOB,
      );
    });

    completer.complete();
    controller.dismiss(true);
  }

  /// [harusMengumpulkan] jika sudah mengerjakan tapi belum disubmit, namun
  /// siswa keluar aplikasi sebelum submit dan siswa harus .
  Future<void> _onClickPaketTO({
    required PaketTO paketTO,
    PaketTO? paketSelanjutnya,
    required bool isTOBerakhir,
    required bool harusMengumpulkan,
  }) async {
    if (harusMengumpulkan) {
      String message = 'Kamu belum mengumpulkan ${paketTO.kodePaket} Sobat. '
          'Kamu tidak bisa lanjut mengerjakan karena batas pengerjaan '
          'paket ${paketTO.kodePaket} hanya sampai ${paketTO.displayDeadlinePengerjaan}. '
          'Kumpulkan ${paketTO.kodePaket} sebelum ${widget.tanggalBerakhirTO.hoursMinutesDDMMMYYYY} ';

      message += (paketSelanjutnya == null)
          ? 'yaa!'
          : 'agar bisa lanjut ke paket ${paketSelanjutnya.kodePaket} ya Sobat!';

      await gShowBottomDialog(
        context,
        title: 'Kumpulkan ${paketTO.kodePaket}',
        message: message,
        actions: (controller) => [
          TextButton(
              onPressed: () async => await _kumpulkanPaket(
                    controller: controller,
                    paketTO: paketTO,
                  ),
              child: const Text('Kumpulkan Sekarang'))
        ],
      );
    } else {
      if (!paketTO.isSelesai && paketTO.isPernahMengerjakan) {
        _navigateToSoalTimerScreen(paketTO);
      } else {
        final TOBProvider tobProvider = context.read<TOBProvider>();
        var completer = Completer();
        context.showBlockDialog(dismissCompleter: completer);

        // DetailBundel detailBundel =
        //     tobProvider.getListDetailWaktuByKodePaket(paketTO.kodePaket).first;

        DateTime serverTime = await gGetServerTime();
        tobProvider.serverTime = serverTime;
        tobkBloc.add(
          TOBKSetMulaiTO(
              noRegister: userData?.noRegistrasi ?? '',
              tahunAjaran: userData?.tahunAjaran ?? '',
              kodePaket: paketTO.kodePaket,
              totalWaktuPaket: paketTO.totalWaktu,
              paketTO: paketTO,
              idJenisProduk: widget.idJenisProduk,
              isRemedialGOA: false,
              tingkatKelas: int.parse(userData?.tingkatKelas ?? '0')),
        );

        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    }
  }

  Future<void> _onClickPaketListTile({
    required PaketTO paketTO,
    PaketTO? paketSebelumnya,
    PaketTO? paketSelanjutnya,
    required bool isPernahMengerjakan,
    required bool isSudahDikumpulkan,
    required bool isWaktuHabis,
    required bool isTOBBerakhir,
  }) async {
    BuildContext ctx = context;
    DateTime serverTime = DateTime.now().serverTimeFromOffset;

    if (kDebugMode) {
      logger.log(
          'PAKET_TO_SCREEN-OnClickPaketListTile: $paketSebelumnya | ${paketSebelumnya?.isSelesai} | ${widget.isBolehLihatKisiKisi}');
    }

    if (isTOBBerakhir) {
      _navigateToSoalTimerScreen(paketTO);
      return;
    }

    if ((widget.selectedTOB?.isTOBMulai != true) ||
        (!widget.isMemenuhiSyarat &&
            (widget.selectedTOB?.isTOBMulai == true))) {
      gShowBottomDialogInfo(context,
          message: (widget.selectedTOB?.isTOBMulai != true)
              ? 'Hai Sobat! Tryout ini baru akan dimulai pada $_displayTOBMulai. '
                  'Saat ini sobat hanya bisa melihat kisi-kisi saja. '
                  'Yuk persiapkan diri kamu untuk raih hasil yang maksimal!'
              : 'Hai Sobat! Kamu tidak bisa mengerjakan TryOut ini, karena tidak '
                  'memenuhi prasyarat Empati Wajib dari ${widget.namaTOB}. '
                  'Namun, kamu masih bisa melihat kunci dan solusi dari '
                  'TOBK ini setelah periode TOBK berakhir.');
      return;
    }

    if (paketTO.isSelesai) {
      if (paketSelanjutnya == null || paketSelanjutnya.isSelesai) {
        gShowBottomDialogInfo(context,
            message:
                'Kamu sudah menyelesaikan semua Paket sobat, silahkan tunggu hasilnya ya.');
      } else {
        gShowBottomDialogInfo(context,
            message:
                'Kamu sudah mengerjakan Paket ini sobat, silahkan lanjut ke Paket selanjutnya ya.');
      }
      return;
    }

    if (paketSebelumnya != null && !paketSebelumnya.isSelesai && !isWaktuHabis
        // hardcode by arifin
        // && !serverTime.isAfter(widget.tanggalBerakhirTO)
        ) {
      // hardcode by arifin
      gShowBottomDialogInfo(context,
          message: 'Kamu harus mengerjakan paket ${paketSebelumnya.kodePaket} '
              'sebelum bisa mengerjakan paket ${paketTO.kodePaket} Sobat');
      // if (!paketSebelumnya.isPernahMengerjakan) {
      //   gShowBottomDialogInfo(context,
      //       message:
      //           'Kamu harus mengerjakan paket ${paketSebelumnya.kodePaket} '
      //           'sebelum bisa mengerjakan paket ${paketTO.kodePaket} Sobat');
      // } else {
      //   gShowBottomDialog(
      //     context,
      //     title: 'Belum bisa membuka paket ${paketTO.kodePaket}',
      //     message:
      //         'Untuk melanjutkan ke paket soal selanjutnya, Silahkan kumpulkan '
      //         'paket ${paketSebelumnya.kodePaket} dengan nomor urut ${paketSebelumnya.nomorUrut} '
      //         'terlebih dahulu',
      //     actions: (controller) => [
      //       TextButton(
      //           onPressed: () async => await _kumpulkanPaket(
      //                 controller: controller,
      //                 paketTO: paketSebelumnya,
      //               ),
      //           child: Text('Kumpulkan Paket ${paketSebelumnya.kodePaket}'))
      //     ],
      //   );
      // }
    } else {
      // hardcode by arifin
      // bool bolehMengerjakan = paketSebelumnya == null ||
      //     paketSebelumnya.isBolehLanjutNomorUrut(
      //       currentServerTime: serverTime,
      //       jarakAntarPaket: widget.jarakAntarPaket,
      //     );

      // if (!bolehMengerjakan && !serverTime.isAfter(widget.tanggalBerakhirTO)) {
      //   String message =
      //       'Kamu harus menunggu ${widget.jarakAntarPaket} menit setelah '
      //       'paket ${paketSebelumnya.kodePaket} selesai, sebelum bisa mengerjakan '
      //       'paket ${paketTO.kodePaket} Sobat.';

      //   if (paketSebelumnya.tanggalSiswaSubmit != null) {
      //     message += ' Kamu baru bisa mulai mengerjakan pukul '
      //         '${paketSebelumnya.tanggalSiswaSubmit!.add(Duration(minutes: widget.jarakAntarPaket)).hoursMinutesDDMMMYYYY}';
      //   }

      //   await gShowBottomDialogInfo(context, message: message);
      //   return;
      // }

      // if ((isSudahDikumpulkan || isWaktuHabis) &&
      //     !serverTime.isAfter(widget.tanggalBerakhirTO)) {
      //   gShowBottomDialogInfo(context,
      //       dialogType: DialogType.info,
      //       title: 'Belum Boleh Melihat Solusi',
      //       message:
      //           'Masa tryout belum berakhir, Kamu baru bisa melihat solusi setelah '
      //           '${widget.tanggalBerakhirTO.hoursMinutesDDMMMYYYY}');
      //   return;
      // }

      bool isSiapTryout = isPernahMengerjakan;

      if (!isPernahMengerjakan
          // hardcode by arifin
          // !isPernahMengerjakan && !isWaktuHabis
          ) {
        isSiapTryout = await gShowBottomDialog(
          ctx,
          title: 'Konfirmasi mulai mengerjakan Tryout-${paketTO.kodePaket}',
          message:
              'Pastikan kamu sudah siap dan dalam kondisi nyaman untuk mengerjakan Tryout-${paketTO.kodePaket}. '
              'Setelah Tryout-${paketTO.kodePaket} dimulai, kamu tidak dapat keluar dari halaman pengerjaan sebelum '
              'waktu habis / sudah mengumpulkan jawaban. Siap mengerjakan sekarang Sobat?',
          dialogType: DialogType.warning,
        );
      }

      if (isSiapTryout) {
        _onClickPaketTO(
          paketTO: paketTO,
          paketSelanjutnya: paketSelanjutnya,
          isTOBerakhir: serverTime.isAfter(widget.tanggalBerakhirTO),
          harusMengumpulkan: (paketTO.deadlinePengerjaan == null)
              ? false
              : !paketTO.isSelesai &&
                  serverTime.isAfter(paketTO.deadlinePengerjaan!) &&
                  widget.idJenisProduk == 25,
        );
      }
    }
  }

  Future<void> _onClickLihatKisiKisi(
      String kodePaket, List<NamaKelompokUjian>? listKelompokUjian) async {
    timer?.cancel();
    // Membuat variableTemp guna mengantisipasi rebuild saat scroll
    Widget? childWidget;
    await showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        minHeight: 10,
        maxHeight: context.dh * 0.86,
        maxWidth: min(650, context.dw),
      ),
      backgroundColor: Colors.transparent,
      builder: (context) {
        childWidget ??= KisiKisiWidget(
          kodePaket: kodePaket,
          listKelompokUjian: listKelompokUjian,
          idJenisProduk: widget.idJenisProduk,
        );
        return childWidget!;
      },
    ).then((_) {
      startTimer();
    });
  }

  Widget _buildPaketTOContent() {
    return BlocListener<LaporanTobkBloc, LaporanTobkState>(
      listener: (context, state) {
        if (state is LaporanTobkLoading) {
          context.showBlockDialog(dismissCompleter: completer);
        }

        if (state is LaporanTobkDataLoaded) {
          if (!completer.isCompleted) {
            completer.complete();
          }
          int index = state.listLaporanTryout.indexWhere((element) =>
              element.kode == widget.kodeTOB && element.nama == widget.namaTOB);
          bool isValid = index >= 0;
          if (isValid) {
            LaporanTryoutTobModel selectedTOB = state.listLaporanTryout[index];
            Navigator.of(context).pushNamed(
              Constant.kRouteLaporanTryOutNilai,
              arguments: {
                "penilaian": selectedTOB.penilaian,
                "kodeTOB": selectedTOB.kode,
                'namaTOB': selectedTOB.nama,
                'isExists': selectedTOB.isExists,
                'link': selectedTOB.link,
                'jenisTO': widget.paramsLaporan['jenisTO'],
                'showEPB': true,
                'listPilihan': selectedTOB.pilihan,
                'listNilai': selectedTOB.listNilai,
              },
            );
          } else {
            Future.delayed(Duration.zero, () {
              gShowTopFlash(
                context,
                'Maaf, belum ada laporan TOB, sobat',
                dialogType: DialogType.error,
              );
            });
          }
        }

        if (state is LaporanTobkError) {
          if (!completer.isCompleted) {
            completer.complete();
          }
          Future.delayed(Duration.zero, () {
            gShowTopFlash(
              context,
              state.errorMessage,
              dialogType: DialogType.error,
            );
          });
        }
      },
      child: BlocConsumer<TOBKBloc, TOBKState>(
        listener: (context, state) {
          if (state is TOBIsLoading) {
            context.showBlockDialog(dismissCompleter: completer);
          }

          if (state is! TOBIsLoading && !completer.isCompleted) {
            completer.complete();
          }

          if (state is TOBKSuccessMulaiTO) {
            timer?.cancel();
            // context.read<TOBKBloc>().add(const TOBKIntervalTimer(0));
            final paketTO = state.paketTO;
            _navigateToSoalTimerScreen(paketTO);
          }
        },
        builder: (context, state) {
          if (state is TOBKLoading || state is LoadedItemSyaratTOBK) {
            return const ShimmerListTiles(isWatermarked: true);
          }

          if (state is LoadedListTO) {
            listPaketTO = state.paketTO;
          }

          // if (widget.isFormatTOMerdeka) {
          //   // Hapus daftar paket di luar dari mata uji pilihan
          //   listPaketTO.removeWhere((paketTO) {
          //     bool isPilihan = !paketTO.isWajib;
          //     bool isDipilih = widget.daftarMataUjiPilihan.any((mataUji) =>
          //         paketTO.idKelompokUjian == mataUji.idKelompokUjian);
          //
          //     if (kDebugMode) {
          //       logger.log(
          //           'PAKET_TO_SCREEN-FutureBuilder: Paket ${paketTO.kodePaket}-${paketTO.idKelompokUjian}'
          //           '>> Pilihan($isPilihan) | Dipilih($isDipilih)');
          //     }
          //
          //     return isPilihan && !isDipilih;
          //   });
          //
          //   if (kDebugMode) {
          //     logger.log(
          //         'PAKET_TO_SCREEN-FutureBuilder: List Paket (removed)>> $listPaketTO');
          //   }
          // }

          var refreshWidget = CustomSmartRefresher(
            controller: (listPaketTO.isEmpty)
                ? _emptyRefreshController
                : _refreshController,
            isDark: true,
            onRefresh: _onRefreshPaketTO,
            child: (listPaketTO.isEmpty)
                ? _getIllustrationImage(widget.idJenisProduk)
                : _buildListPaketTO(listPaketTO),
          );

          return (listPaketTO.isEmpty)
              ? refreshWidget
              : WatermarkWidget(child: refreshWidget);
        },
      ),
    );
  }

  Container _buildPesanTryoutSelesai() => Container(
        margin: EdgeInsets.only(
            top: context.dp(14), left: context.dp(12), right: context.dp(12)),
        padding: EdgeInsets.symmetric(
            horizontal: context.dp(14), vertical: context.dp(12)),
        decoration: BoxDecoration(
          color: context.primaryContainer,
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
              image: AssetImage('assets/img/information.png'),
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              opacity: 0.2),
        ),
        child: RichText(
          textScaler: TextScaler.linear(context.textScale12),
          text: TextSpan(
            text: (widget.selectedTOB?.isTOBBerakhir == true)
                ? 'TryOut ini sudah selesai Sobat!\n'
                : (widget.selectedTOB?.isTOBMulai != true)
                    ? 'TryOut ini belum dimulai Sobat!\n'
                    : 'Tidak memenuhi EMWA prasyarat!\n',
            style: context.text.labelLarge
                ?.copyWith(color: context.onPrimaryContainer),
            children: [
              TextSpan(
                text: (widget.selectedTOB?.isTOBBerakhir == true)
                    ? 'Kamu hanya bisa melihat laporan dan solusi dari Tryout ini. '
                        'Klik paket untuk melihat solusi'
                    : (!widget.isTOBRunning)
                        ? '${widget.namaTOB} baru akan dimulai pada $_displayTOBMulai. '
                            'Yuk lihat kisi-kisi dan persiapkan diri kamu untuk '
                            'raih hasil yang maksimal!'
                        : 'Kamu tidak bisa mengerjakan TryOut ini karena '
                            'tidak memenuhi syarat kelulusan Empati Wajib Sobat.',
                style: context.text.labelSmall?.copyWith(
                    color: context.onPrimaryContainer,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      );

  Widget _buildListPaketTO(List<PaketTO> listPaketTO) {
    return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
            top: context.dp(10),
            bottom: context.dp(30),
            left: context.dp(12),
            right: context.dp(12)),
        itemBuilder: (_, index) {
          PaketTO paketTO = listPaketTO[index];
          // String namaMataUji = Constant
          //         .kInitialKelompokUjian[paketTO.idKelompokUjian]?['nama'] ??
          //     'Undefined';
          String namaMataUji = paketTO.namaKelompokUjian;
          bool isPernahMengerjakan = paketTO.deadlinePengerjaan != null;
          bool isSudahDikumpulkan =
              paketTO.tanggalSiswaSubmit != null || paketTO.isSelesai;
          bool isTOBBerakhir = widget.selectedTOB?.isTOBBerakhir == true;
          bool isWaktuHabis =
              (isTOBBerakhir) ? isTOBBerakhir : paketTO.isWaktuHabis;

          return GestureDetector(
            onTap: () async => await _onClickPaketListTile(
              paketTO: paketTO,
              paketSebelumnya: (index > 0) ? listPaketTO[index - 1] : null,
              paketSelanjutnya: (index < listPaketTO.length - 1)
                  ? listPaketTO[index + 1]
                  : null,
              isPernahMengerjakan: isPernahMengerjakan,
              isSudahDikumpulkan: isSudahDikumpulkan,
              isWaktuHabis: isWaktuHabis,
              isTOBBerakhir: isTOBBerakhir,
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.surfaceVariant,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(width: 0.5, color: context.hintColor),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                margin:
                                    const EdgeInsets.only(right: 8, bottom: 8),
                                padding: EdgeInsets.symmetric(
                                  horizontal: min(12, context.dp(8)),
                                  vertical: min(14, context.dp(6)),
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: context.tertiaryColor,
                                  ),
                                  color: (paketTO.isSelesai ||
                                          paketTO.isPernahMengerjakan)
                                      ? Palette.kSuccessSwatch[500]
                                      : (isTOBBerakhir)
                                          ? context.disableColor
                                          : null,
                                  borderRadius: BorderRadius.circular(
                                      min(16, context.dp(14))),
                                ),
                                child: Text(
                                  paketTO.kodePaket,
                                  style: context.text.titleMedium,
                                ),
                              ),
                              Text(
                                '(${paketTO.jumlahSoal} soal)',
                                style: context.text.bodySmall,
                              ),
                            ],
                          ),
                          (isPernahMengerjakan || isSudahDikumpulkan)
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!paketTO.isWajib)
                                      Text(namaMataUji,
                                          style: context.text.bodySmall),
                                    // hardcode by arifin
                                    // Text(
                                    //     (!isSudahDikumpulkan &&
                                    //             isWaktuHabis)
                                    //         ? 'Kamu belum mengumpulkan paket ini sobat.'
                                    //         : 'Durasi: ${paketTO.displayDurasiLengkap}',
                                    //     semanticsLabel:
                                    //         'paket-to-item-sub-title-duration',
                                    //     style: context.text.bodySmall),
                                    Text(
                                        (!isSudahDikumpulkan && !isWaktuHabis)
                                            ? 'Batas Pengerjaan:\n${paketTO.displayDeadlinePengerjaan}'
                                            : (isSudahDikumpulkan)
                                                ? 'Dikumpulkan Pada:\n${paketTO.displayTanggalSiswaSubmit}'
                                                : 'Batas Pengumpulan:\n$_displayTOBBerakhir',
                                        semanticsLabel:
                                            'paket-to-item-sub-title-date',
                                        style: context.text.bodySmall),
                                    if (isPernahMengerjakan &&
                                        !isSudahDikumpulkan) ...[
                                      SizedBox(
                                        width: (context.isMobile)
                                            ? context.dw * 0.5
                                            : context.dw * 0.3,
                                        child: Text(
                                          'Kamu belum mengumpulkan paket ini '
                                          'atau dikumpulkan otomatis oleh sistem.',
                                          style:
                                              context.text.bodySmall?.copyWith(
                                            color: context.primaryColor,
                                          ),
                                          overflow: TextOverflow.fade,
                                          // maxLines: 2,
                                        ),
                                      )
                                    ],
                                  ],
                                )
                              : (!paketTO.isWajib)
                                  ? Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(namaMataUji,
                                            style: context.text.bodySmall),
                                        Text(
                                            'Durasi: ${paketTO.displayDurasiLengkap}',
                                            semanticsLabel:
                                                'paket-to-item-sub-title-duration',
                                            style: context.text.bodySmall),
                                      ],
                                    )
                                  : Text(
                                      'Durasi: ${paketTO.displayDurasiLengkap}',
                                      semanticsLabel: 'paket-to-item-sub-title',
                                      style: context.text.bodySmall),
                        ],
                      ),
                      if (widget.isBolehLihatKisiKisi)
                        TextButton(
                            onPressed: () async => await _onClickLihatKisiKisi(
                                paketTO.kodePaket, paketTO.listKelompokUjian),
                            child: Text(
                                (context.isMobile)
                                    ? 'Lihat\nKisi-Kisi'
                                    : 'Lihat Kisi-Kisi',
                                textAlign: TextAlign.center))
                    ],
                  ),
                  if (paketTO.listKelompokUjian != null &&
                      paketTO.listKelompokUjian!.isNotEmpty) ...[
                    const Divider(thickness: 0.15, indent: 12, endIndent: 12),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(paketTO.listKelompokUjian!.length,
                          (index) {
                        final namaKelompokUjian =
                            paketTO.listKelompokUjian![index].namaKelompokUjian;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}. ${namaKelompokUjian?.capitalizeFirstLetter()}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 7),
                          ],
                        );
                      }),
                    )
                  ],
                ],
              ),
            ),
          );
        },
        itemCount: listPaketTO.length);
  }

  // Widget _buildLeadingInfo(bool isSudahDikumpulkan, bool isWaktuHabis,
  //     bool isTOBBerakhir, PaketTO paketTO) {
  //   final leadingWidget = Container(
  //     width: context.dp((!isSudahDikumpulkan && isWaktuHabis && !isTOBBerakhir)
  //         ? 64
  //         : isSudahDikumpulkan
  //             ? 70
  //             : 74),
  //     padding: EdgeInsets.symmetric(
  //         vertical:
  //             min(10, context.dp((isSudahDikumpulkan || isWaktuHabis) ? 8 : 4)),
  //         horizontal:
  //             min(6, context.dp((isSudahDikumpulkan || isWaktuHabis) ? 0 : 4))),
  //     decoration: BoxDecoration(
  //       // color: (isSudahDikumpulkan)
  //       //     ? Palette.kSuccessSwatch[500]
  //       //     : (isWaktuHabis && !isTOBBerakhir)
  //       //         ? Palette.kSecondarySwatch[600]
  //       //         : (isTOBBerakhir)
  //       //             ? context.primaryColor
  //       //             : null,
  //       border: Border.all(color: context.tertiaryColor),
  //       // hardcode by arifin
  //       // (isSudahDikumpulkan || isWaktuHabis)
  //       //     ? null
  //       //     : Border.all(color: context.tertiaryColor),
  //       borderRadius: BorderRadius.circular(14),
  //     ),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //       children: [
  //         // hardcode by request arifin
  //         // (isSudahDikumpulkan)
  //         //     ? const Icon(Icons.check_circle_outline_rounded,
  //         //         color: Colors.white70)
  //         //     : (isWaktuHabis)
  //         //         ? Icon(Icons.cancel_outlined, color: context.onPrimary)
  //         //         : Text('nomor\nurut',
  //         //             textAlign: TextAlign.center,
  //         //             style: context.text.labelSmall
  //         //                 ?.copyWith(color: context.tertiaryColor)),
  //         Text(
  //           '${paketTO.nomorUrut}',
  //           textAlign: TextAlign.center,
  //           style:
  //               context.text.titleLarge?.copyWith(color: context.tertiaryColor),
  //           // hardcode by arifin
  //           // (isSudahDikumpulkan)
  //           //     ? Colors.white70
  //           //     : (isWaktuHabis)
  //           //         ? context.onPrimary
  //           //         : context.tertiaryColor),
  //         ),
  //       ],
  //     ),
  //   );

  //   return leadingWidget;
  // }

  // Get Illustration Image Function
  BasicEmpty _getIllustrationImage(int idJenisProduk) {
    bool isProdukDibeli = widget.userData
        .isProdukDibeliSiswa(idJenisProduk, ortuBolehAkses: true);
    String imageUrl = 'ilustrasi_tobk.png'.illustration;
    String title = 'TryOut Berbasis Komputer';

    return BasicEmpty(
      isLandscape: !context.isMobile,
      imageUrl: imageUrl,
      title: title,
      subTitle: gEmptyProductSubtitle(
          namaProduk: title,
          isProdukDibeli: isProdukDibeli,
          isOrtu: widget.userData.isOrtu,
          isNotSiswa: !widget.userData.isSiswa),
      emptyMessage: gEmptyProductText(
        namaProduk: title,
        isOrtu: widget.userData.isOrtu,
        isProdukDibeli: isProdukDibeli,
      ),
    );
  }

  JenisTO _convertStringToJenisTO(String jenisTO) {
    return (jenisTO == 'US' || jenisTO == 'Ujian Sekolah')
        ? JenisTO.ujianSekolah
        : (jenisTO == 'UTBK')
            ? JenisTO.utbk
            : (jenisTO == 'STAN')
                ? JenisTO.stan
                : JenisTO.anbk;
  }

  void _onClickLaporanFAB() {
    String jenisTO = widget.paramsLaporan['jenisTO'];
    laporanTobkBloc.add(
      LoadLaporanTobk(
        jenisTO: _convertStringToJenisTO(jenisTO),
        userData: userData,
      ),
    );
  }

  void _navigateToSoalTimerScreen(PaketTO paketTO) {
    bool isTOBBerakhir = DateTime.now().isAfter(widget.tanggalBerakhirTO);
    bool isWaktuHabis = (isTOBBerakhir) ? isTOBBerakhir : paketTO.isWaktuHabis;
    bool isSelesai = (isTOBBerakhir) ? isTOBBerakhir : paketTO.isSelesai;
    _navigator.pushNamed(Constant.kRouteSoalTimerScreen, arguments: {
      'kodeTOB': paketTO.kodeTOB,
      'kodePaket': paketTO.kodePaket,
      'idJenisProduk': widget.idJenisProduk,
      'namaJenisProduk': widget.namaJenisProduk,
      'waktu': paketTO.totalWaktu,
      'tanggalSelesai': paketTO.deadlinePengerjaan,
      'tanggalSiswaSubmit': paketTO.tanggalSiswaSubmit,
      'tanggalKedaluwarsaTOB': widget.tanggalBerakhirTO,
      'isBlockingTime': paketTO.isBlockingTime,
      'isPernahMengerjakan': paketTO.isPernahMengerjakan,
      'isRandom': paketTO.isRandom,
      'isBolehLihatSolusi': isSelesai,
      'urutan': paketTO.isPernahMengerjakan && !paketTO.isSelesai
          ? (paketTO.urutanAktif ?? 1)
          : 1,
      'isNextSoal': true,
      'isSelesai': isWaktuHabis || paketTO.isSelesai,
      'jumlahSoalPaket': paketTO.jumlahSoal,
    }).then((value) => _onRefreshPaketTO());
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      tobkBloc.add(TOBKIntervalTimer(timer.tick));
    });
  }
}
