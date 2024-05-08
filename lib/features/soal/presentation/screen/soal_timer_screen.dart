// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer' as logger show log;
import 'dart:math';

import 'package:flash/flash.dart';
import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gokreasi_new/api/firebase_api.dart';
import 'package:gokreasi_new/core/config/enum.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/soal/entity/soal.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/entity/detail_bundel.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/entity/paket_to.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/presentation/bloc/tobk/tobk_bloc.dart';
import 'package:gokreasi_new/features/soal/presentation/widget/loading_overlay.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:timer_count_down/timer_controller.dart';

import '../../../../core/shared/widget/html/custom_html_widget.dart';
import '../widget/solusi_widget.dart';
import '../widget/soal_countdown_timer.dart';
import '../widget/jenis_jawaban/jawaban_essay.dart';
import '../widget/jenis_jawaban/jawaban_essay_majemuk.dart';
import '../widget/jenis_jawaban/pilihan_berganda_tabel.dart';
import '../widget/jenis_jawaban/pilihan_ganda_berbobot.dart';
import '../widget/jenis_jawaban/pilihan_berganda_kompleks.dart';
import '../widget/jenis_jawaban/pilihan_berganda_bercabang.dart';
import '../widget/jenis_jawaban/pilihan_berganda_sederhana.dart';
import '../widget/jenis_jawaban/pilihan_berganda_memasangkan.dart';
import '../widget/jenis_jawaban/pilihan_berganda_complex_terbatas.dart';
import '../../service/local/soal_service_local.dart';
import '../../module/timer_soal/presentation/provider/tob_provider.dart';
import '../../../video/presentation/widget/video_player_card.dart';
import '../../../../core/config/theme.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/util/platform_channel.dart';
import '../../../../core/shared/builder/responsive_builder.dart';
import '../../../../core/shared/screen/custom_will_pop_scope.dart';
import '../../../../core/shared/widget/loading/shimmer_widget.dart';
import '../../../../core/shared/widget/html/widget_from_html.dart';
import '../../../../core/shared/widget/watermark/watermark_widget.dart';

class SoalTimerScreen extends StatefulWidget {
  final String kodeTOB;
  final String kodePaket;
  final int idJenisProduk;
  final String namaJenisProduk;

  /// [waktuPengerjaan] dalam satuan menit.
  final int waktuPengerjaan;

  /// [tanggalSiswaSubmit] merupakan tanggal kapan siswa submit / kumpulkan.
  /// Di perlukan untuk keperluan remedial GOA.
  final DateTime? tanggalSiswaSubmit;

  /// [tanggalSelesai] merupakan tanggal seharusnya siswa selesai mengerjakan.
  final DateTime? tanggalSelesai;

  /// [tanggalKedaluwarsaTOB] merupakan tanggal berakhirnya masa TOB.
  final DateTime tanggalKedaluwarsaTOB;

  /// [isBlockingTime] true maka button kumpulkan hanya akan aktif saat waktu habis.<br>
  /// Button pindah mapel juga tidak akan aktif.
  final bool isBlockingTime;

  /// [isPernahMengerjakan] true maka jenis start: lanjutan, jika false maka jenis start: awal.
  final bool isPernahMengerjakan;

  /// [isRandom] true maka acak urutan soal.
  final bool isRandom;

  /// [isSelesai] digunakan untuk mengecek apakah TO sudah dikerjakan
  final bool isSelesai;

  final bool isRemedialGOA;
  final bool isBolehLihatSolusi;
  final int urutan;
  final bool isNextSoal;
  final List<int>? listIdBundelSoal;
  final int jumlahSoalPaket;

  const SoalTimerScreen({
    Key? key,
    required this.kodeTOB,
    required this.kodePaket,
    required this.idJenisProduk,
    required this.namaJenisProduk,
    required this.waktuPengerjaan,
    this.tanggalSelesai,
    this.tanggalSiswaSubmit,
    required this.tanggalKedaluwarsaTOB,
    required this.isBlockingTime,
    required this.isPernahMengerjakan,
    required this.isRandom,
    required this.isBolehLihatSolusi,
    required this.isRemedialGOA,
    required this.urutan,
    required this.isNextSoal,
    required this.isSelesai,
    required this.jumlahSoalPaket,
    this.listIdBundelSoal,
  }) : super(key: key);

  @override
  State<SoalTimerScreen> createState() => _SoalTimerScreenState();
}

class _SoalTimerScreenState extends State<SoalTimerScreen>
    with WidgetsBindingObserver {
  final _scrollController = ScrollController();
  final _nomorSoalScrollController = ScrollController();
  late final NavigatorState _navigator = Navigator.of(context);
  final CountdownController _countdownController =
      CountdownController(autoStart: true);

  late final TOBProvider _tobProvider = context.watch<TOBProvider>();

  // DefaultFlashController? _previousDialog;
  bool get _isLoading =>
      _tobProvider.isLoadingSoal || !_tobProvider.isSoalExist;

  /// Untuk e-GOA(12) dan e-VAK(65) tidak boleh melihat solusi.
  late bool isBolehLihatSolusi = widget.isBolehLihatSolusi &&
      widget.idJenisProduk != 12 &&
      widget.idJenisProduk != 65;

  // late final String _displayBatasPengumpulan = DataFormatter.dateTimeToString(
  //     widget.tanggalKedaluwarsaTOB.add(const Duration(hours: 1)),
  //     '[HH:mm] dd MMM yyyy');
  UserModel? userData;
  List<PaketTO> listPaketTO = [];

  Timer? countdownTimer;
  Duration myDuration = const Duration();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused && !isBolehLihatSolusi) {
      FirebaseApi().showNotification(
        title: "Terdeteksi meninggalkan ujian yang sedang berlangsung",
        body: "Sesuai aturan, segera kembali ke halaman ujian !!.",
      );

      Future.delayed(Duration.zero, () async {
        await _tobProvider.olahDataJawaban(
          namaJenisProduk: widget.namaJenisProduk,
          userData: userData,
          kodePaket: widget.kodePaket,
          idJenisProduk: widget.idJenisProduk,
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(const Duration(milliseconds: 1300)).then((value) =>
        PlatformChannel.setSecureScreen(Constant.kRouteSoalTimerScreen));

    // if (!_authOtpProvider.isLogin || _authOtpProvider.isOrtu) {
    //   SoalServiceLocal().openJawabanBox();
    // }

    _getSoal();
    final authState = context.read<AuthBloc>().state;
    if (authState is LoadedUser) {
      userData = authState.user;
    }
    final tobkBloc = context.read<TOBKBloc>().state;
    if (tobkBloc is LoadedListTO) {
      listPaketTO = tobkBloc.paketTO;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    PlatformChannel.setSecureScreen('POP', true);
    if (!userData.isLogin || userData.isOrtu) {
      SoalServiceLocal().closeJawabanBox();
    }

    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) =>
      (mounted) ? super.setState(() => fn()) : fn();

  @override
  Widget build(BuildContext context) {
    PlatformChannel.setSecureScreen(Constant.kRouteSoalTimerScreen);

    if (kDebugMode) {
      logger.log('SOAL_TIMER_SCREEN-Build: $isBolehLihatSolusi | | ');
    }
    // TODO: coba olah durasi-nya dari sini. dan edit soal_countdown_timer.dart
    return Stack(
      children: [
        CustomWillPopScope(
          swipeSensitivity: (_isSudahDikumpulkan()) ? 12 : 20,
          onWillPop: () async {
            if (!_isSudahDikumpulkan() && !_isLoading) {
              _bottomDialog();
            }
            return Future.value(_isSudahDikumpulkan());
          },
          onDragRight: () {
            if (_isSudahDikumpulkan() || _isLoading) {
              _navigator.pop();
            } else {
              _bottomDialog();
            }
          },
          child: Scaffold(
              backgroundColor: context.primaryColor,
              appBar: (context.isMobile) ? _buildAppBar(_isLoading) : null,
              body: ResponsiveBuilder(
                mobile: Container(
                  width: context.dw,
                  height: double.infinity,
                  decoration: BoxDecoration(
                      color: context.background,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24))),
                  child: WatermarkWidget(
                    child: _buildListViewBody(context),
                  ),
                ),
                tablet: Row(
                  children: [
                    Expanded(
                      flex: (context.dw > 1100) ? 3 : 4,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 12,
                            left: 24,
                            right: 24,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // _buildAppBar
                              _buildAppBarTitle(_isLoading),
                              const SizedBox(height: 12),
                              if (!_isLoading && widget.isBolehLihatSolusi)
                                _buildTimerDanNomorSoal(_isLoading),
                              if (_isLoading)
                                ShimmerWidget.rectangle(
                                  width: min(100, context.dp(82)),
                                  height: min(32, context.dp(24)),
                                ),
                              if (!_isLoading && !widget.isBolehLihatSolusi)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Transform.translate(
                                      offset: const Offset(-14, 0),
                                      child: SoalCountdownTimer(
                                        onEndTimer: _onEndTimer,
                                        kodePaket: widget.kodePaket,
                                        isBlockingTime: widget.isBlockingTime,
                                        countdownController:
                                            _countdownController,
                                        onTick: (sisaWaktu) {
                                          _tobProvider.sisaWaktu = Duration(
                                              seconds: sisaWaktu.toInt());
                                        },
                                      ),
                                    ),
                                    Builder(builder: (context) {
                                      int totalPaketBefore = _tobProvider
                                          .totalSoalBefore(widget.kodePaket);
                                      return Text(
                                        'No ${(_tobProvider.indexSoal + 1) + totalPaketBefore}/${widget.jumlahSoalPaket}',
                                        style: (context.isMobile)
                                            ? null
                                            : const TextStyle(
                                                color: Colors.white,
                                              ),
                                      );
                                    })
                                  ],
                                ),
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                child: _buildSubmitButton(_isLoading),
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.topCenter,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28),
                                    color: context.onPrimary,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Scrollbar(
                                      controller: _nomorSoalScrollController,
                                      thickness: 8,
                                      trackVisibility: true,
                                      thumbVisibility: true,
                                      radius: const Radius.circular(14),
                                      child: _buildDaftarNomorSoal(),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Container(
                        color: context.onPrimary,
                        child: Stack(
                          children: [
                            _buildListViewBody(context),
                            Positioned(
                              bottom: 18,
                              right: 24,
                              left: 24,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // hardcode by arifin
                                  // if (!_isLoading && isBolehLihatSolusi)
                                  //   _buildSobatTipsButton(),
                                  if (!_isLoading && isBolehLihatSolusi)
                                    const SizedBox(height: 14),
                                  Column(
                                    children: [
                                      (widget.idJenisProduk == 16)
                                          ? Container()
                                          : (!widget.isBlockingTime ||
                                                  isBolehLihatSolusi)
                                              ? _buildButtonNextPrevBundleSoal(
                                                  _isLoading)
                                              : Container(),
                                      const SizedBox(height: 30),
                                      (widget.idJenisProduk != 16)
                                          ? (widget.isBlockingTime &&
                                                  !isBolehLihatSolusi)
                                              ? _buildBottomNavBarTOBK(
                                                  _isLoading)
                                              : _buildBottomNavBarPaketTimer(
                                                  _isLoading)
                                          : _buildBottomNavBarPaketTimer(
                                              _isLoading),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: (context.isMobile)
                  ? (widget.idJenisProduk != 16)
                      ? (widget.isBlockingTime && !isBolehLihatSolusi)
                          ? _buildBottomNavBarTOBK(_isLoading)
                          : _buildBottomNavBarPaketTimer(_isLoading)
                      : _buildBottomNavBarPaketTimer(_isLoading)
                  : null,
              floatingActionButton: (context.isMobile)
                  ? (widget.idJenisProduk == 16)
                      ? null
                      : (!widget.isBlockingTime || isBolehLihatSolusi)
                          ? _buildButtonNextPrevBundleSoal(_isLoading)
                          : null
                  : null),
        ),
        LoadingOverlay(
          isLoadingSimpanJawaban: _tobProvider.isLoadingSimpanJawaban,
          isLoadingJawaban: _tobProvider.isLoadingJawaban,
          loadingKoneksi: _tobProvider.loadingKoneksi,
        ),
      ],
    );
  }

  ListView _buildListViewBody(BuildContext context) {
    return ListView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      children: [
        if (!context.isMobile) ...[
          _buildRunningTextHakCipta(),
        ],
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: min(24, context.dp(16)),
            vertical: min(20, context.dp(14)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isLoading) ...[
                ..._buildLoadingWidget(context)
              ] else ...[
                _buildRatingDanRagu(),
                _buildWacanaWidget(),
                _buildSoalWidget(),
                _buildJawabanWidget(),
                if (!isBolehLihatSolusi) SizedBox(height: context.dp(40)),
                if (isBolehLihatSolusi && !_isLoading) ...[
                  SolusiWidget(
                    idSoal: _tobProvider.soal.idSoal,
                    tipeSoal: _tobProvider.soal.tipeSoal,
                    idVideo: _tobProvider.soal.idVideo,
                    kunciJawaban: _tobProvider.soal.kunciJawaban,
                    accessFrom: AccessVideoCardFrom.videoSolusi,
                    userData: userData,
                    baseUrlVideo: dotenv.env['BASE_URL_VIDEO_SOAL'],
                  ),
                ],
                if (widget.idJenisProduk == 12 && _isSudahDikumpulkan()) ...[
                  _buildSubtestLulusGOA(),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// [_isLulusCurrentSubtest] digunakan khusus GOA. Dan untuk mengetahui apakah subtest saat ini lulus.
  bool _isLulusCurrentSubtest() => (widget.idJenisProduk != 12)
      ? true
      : _tobProvider.getCurrentMataUji(widget.kodePaket)?.isLulus == true;

  /// [_isSudahDikumpulkan] digunakan untuk disable soal.
  bool _isSudahDikumpulkan() => (_isLoading)
      ? false
      : (widget.idJenisProduk == 12)
          ? _isLulusCurrentSubtest()
          : widget.isBolehLihatSolusi;

  /// This function is triggered when the user presses the back-to-top button
  void _scrollToTop() {
    if (_tobProvider.isLoadingSimpanJawaban) return;

    try {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      logger.log('Error scroll to top $e');
    }
  }

  /// NOTE: kumpulan function
  /// [_kumpulkanJawaban] merupakan fungsi untuk mengumpulkan semua jawaban siswa,
  /// jika soal belum dikerjakan, maka akan dianggap kosong.
  Future<void> _kumpulkanJawaban({
    bool isOutOfTime = false,
  }) async {
    await _tobProvider
        .olahDataJawaban(
      namaJenisProduk: widget.namaJenisProduk,
      userData: userData,
      kodePaket: widget.kodePaket,
      idJenisProduk: widget.idJenisProduk,
    )
        .then((res) async {
      if (res['success']) {
        await _tobProvider.submitJawabanSiswa(
          isOutOfTime: isOutOfTime,
          userData: userData,
          kodePaket: widget.kodePaket,
          idJenisProduk: widget.idJenisProduk,
          kodeTOB: widget.kodeTOB,
        );
      } else {
        await gShowTopFlash(
          context,
          res['message'],
          dialogType: DialogType.error,
        );
      }
    });

    // if (widget.idJenisProduk == 12 || widget.idJenisProduk == 80) {
    //   await _tobProvider.kumpulkanJawabanGOA(
    //     tahunAjaran: userData?.tahunAjaran ?? '',
    //     tingkatKelas: userData?.tingkatKelas ?? '',
    //     idSekolahKelas: userData?.idSekolahKelas ?? '14',
    //     idKota: userData?.idKota ?? '',
    //     idGedung: userData?.idGedung ?? '',
    //     noRegistrasi: userData?.noRegistrasi,
    //     tipeUser: userData?.siapa,
    //     idJenisProduk: widget.idJenisProduk,
    //     namaJenisProduk: widget.namaJenisProduk,
    //     kodeTOB: widget.kodeTOB,
    //     kodePaket: widget.kodePaket,
    //   );
    // } else {

    // }

    await Future.delayed(gDelayedNavigation);
    _navigator.pop();
  }

  Future<void> _raguRaguToggle(bool? isRagu) async {
    var completer = Completer();
    context.showBlockDialog(dismissCompleter: completer);
    await _tobProvider.toggleRaguRagu(
      tahunAjaran: userData?.tahunAjaran ?? '',
      idSekolahKelas: userData?.idSekolahKelas ?? '',
      noRegistrasi: userData?.noRegistrasi,
      tipeUser: userData?.siapa,
      kodePaket: widget.kodePaket,
      kodeTOB: widget.kodeTOB,
      jenisProduk: widget.namaJenisProduk,
      userData: userData,
      urutan: _tobProvider.indexPaket,
      idJenisProduk: widget.idJenisProduk,
    );
    completer.complete();
  }

  Future<void> _onClickNextKelompokUjian({
    required int urutan,
  }) async {
    var completer = Completer();
    context.showBlockDialog(dismissCompleter: completer);
    // _tobProvider.indexPaket++;
    if (!isBolehLihatSolusi) {
      await _tobProvider.olahDataJawaban(
        namaJenisProduk: widget.namaJenisProduk,
        userData: userData,
        kodePaket: widget.kodePaket,
        idJenisProduk: widget.idJenisProduk,
      );
    }

    // jika tobk maka membawa payload urutan
    // selain itu (racing, kuis, goa) membawa payload listIdBundelSoal
    _getSoal(urutan: urutan);

    _scrollToTop();
    completer.complete();
  }

  // void _blockingTimeNextKelompokUjian() {
  //   var listDetailBundel =
  //       _tobProvider.getListDetailWaktuByKodePaket(widget.kodePaket);
  //   var mataUjiSekarang = listDetailBundel.isNotEmpty
  //       ? listDetailBundel[_tobProvider.indexCurrentMataUji]
  //       : null;

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(
  //         'Tunggu Mata Uji ${mataUjiSekarang?.namaKelompokUjian ?? 'Undefined'} selesai ya Sobat!',
  //         style: context.text.bodyMedium
  //             ?.copyWith(color: context.onPrimaryContainer),
  //       ),
  //       duration: const Duration(milliseconds: 1200),
  //       backgroundColor: context.primaryContainer,
  //       behavior: SnackBarBehavior.floating,
  //       margin: EdgeInsets.all(context.dp(16)),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  //     ),
  //   );
  // }

  // /// [_onClickSobatTips] akan menampilkan List Bab dan Sub Bab yang terkait dengan soal.
  // Future<void> _onClickSobatTips(String idSoal, String idBundel) async {
  //   bool isBeliLengkap = userData.isProdukDibeliSiswa(59);
  //   bool isBeliSingkat = userData.isProdukDibeliSiswa(97);
  //   bool isBeliRingkas = userData.isProdukDibeliSiswa(98);

  //   // Membuat variableTemp guna mengantisipasi rebuild saat scroll
  //   Widget? childWidget;
  //   await showModalBottomSheet(
  //     context: context,
  //     isDismissible: true,
  //     isScrollControlled: true,
  //     constraints: BoxConstraints(
  //       minHeight: 10,
  //       maxHeight: context.dh * 0.86,
  //       maxWidth: min(650, context.dw),
  //     ),
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  //     ),
  //     builder: (_) {
  //       childWidget ??= SobatTipsWidget(
  //         isBeliTeori: isBeliLengkap || isBeliSingkat || isBeliRingkas,
  //         getSobatTips: _tobProvider.getSobatTips(
  //           idSoal: idSoal,
  //           idBundel: idBundel,
  //           isBeliLengkap: isBeliLengkap,
  //           isBeliSingkat: isBeliSingkat,
  //           isBeliRingkas: isBeliRingkas,
  //           userData: userData,
  //         ),
  //         userData: userData,
  //       );
  //       return childWidget!;
  //     },
  //   );
  // }

  void _getSoal({
    bool isRefresh = false,
    int? urutan,
    List<int>? listIdBundleSoal,
  }) {
    // Hack agar terhindar dari unmounted
    Future.delayed(Duration.zero).then((_) async {
      await context.read<TOBProvider>().getDaftarSoalTO(
            isRefresh: isRefresh,
            kodeTOB: widget.kodeTOB,
            kodePaket: widget.kodePaket,
            idJenisProduk: widget.idJenisProduk,
            namaJenisProduk: widget.namaJenisProduk,
            isAwalMulai: widget.tanggalSelesai == null,
            tanggalSelesai: widget.tanggalSelesai,
            tanggalSiswaSubmit: widget.tanggalSiswaSubmit,
            tanggalKedaluwarsaTOB: widget.tanggalKedaluwarsaTOB,
            totalWaktu: widget.waktuPengerjaan,
            isBlockingTime: widget.isBlockingTime,
            isRandom: widget.isRandom,
            isTOBBerakhir: _isSudahDikumpulkan(),
            tahunAjaran: userData?.tahunAjaran ?? '',
            idSekolahKelas: userData?.idSekolahKelas ?? '',
            noRegistrasi: userData?.noRegistrasi,
            tipeUser: userData?.siapa,
            isRemedialGOA: widget.isRemedialGOA,
            urutan: urutan ?? widget.urutan,
            listIdBundleSoal: listIdBundleSoal ?? widget.listIdBundelSoal,
            listPaketTO: listPaketTO,
            isNextPaket: widget.isNextSoal,
            userData: userData,
          );

      if (_tobProvider.indexSoal != 0) return;

      await context.read<TOBProvider>().getJawabanSiswaByUrutan(
            noRegister: userData?.noRegistrasi ?? '',
            kodePaket: widget.kodePaket,
            tahunAjaran: userData?.tahunAjaran ?? '',
            urutan: _tobProvider.indexPaket,
            idJenisProduk: widget.idJenisProduk,
            isSelesai: widget.isSelesai,
          );

      if (widget.idJenisProduk != 25 && widget.isSelesai) {
        await context.read<TOBProvider>().getJawabanPaketTimer(
              noRegistrasi: userData?.noRegistrasi ?? '',
              idJenisProduk: widget.idJenisProduk,
              idTingkatKelas: int.parse(userData?.tingkatKelas ?? '0'),
              tahunAjaran: userData?.tahunAjaran ?? '',
              kodePaket: widget.kodePaket,
            );
      }
    });
  }

  /// [_setTempJawaban] digunakan untuk submit per soal
  /// dan useBlock digunakan untuk menampilkan loading
  Future<void> _setTempJawaban({
    required dynamic jawabanSiswa,
  }) async {
    if (!_tobProvider.soal.validateTipeSoal(jawabanSiswa)) {
      await gShowBottomDialogInfo(
        context,
        message: 'Gagal menyimpan jawaban. Coba lagi ya, sobat',
        dialogType: DialogType.error,
      );
      return;
    }

    await _tobProvider.setTempJawaban(
      tahunAjaran: userData?.tahunAjaran ?? '',
      idSekolahKelas: userData?.idSekolahKelas ?? '14',
      kodePaket: widget.kodePaket,
      kodeTOB: widget.kodeTOB,
      jenisProduk: widget.namaJenisProduk,
      jawabanSiswa: jawabanSiswa,
      userData: userData,
      urutan: _tobProvider.indexPaket,
      idJenisProduk: widget.idJenisProduk,
    );
  }

  void _onClickNomorSoal() {
    // Membuat variableTemp guna mengantisipasi rebuild saat scroll
    Widget? childWidget;
    showModalBottomSheet(
      context: context,
      constraints: BoxConstraints(maxHeight: context.dh * 0.86),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        childWidget ??= _buildDaftarNomorSoal();
        return childWidget!;
      },
    );
  }

  SingleChildScrollView _buildDaftarNomorSoal() {
    return SingleChildScrollView(
      controller: _nomorSoalScrollController,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: min(18, context.dp(17)),
          vertical: min(24, context.dp(24)),
        ),
        child: Consumer<TOBProvider>(
          builder: (context, tobProvider, _) => Wrap(
            spacing: min(18, context.dp(16)),
            runSpacing: min(18, context.dp(16)),
            children: List.generate(
              tobProvider.jumlahSoal,
              (index) {
                Soal itemSoal = tobProvider.getSoalByIndex(index);
                Color warnaNomor = context.onBackground;
                Color warnaNomorContainer = context.background;
                Color warnaBorder = context.onBackground;
                int nomorSoal = index + 1;
                int indexNomorSoal = tobProvider.indexSoal;
                int totalPaketBefore =
                    _tobProvider.totalSoalBefore(widget.kodePaket);

                bool isSudahDikumpulkan = itemSoal.sudahDikumpulkan ||
                    DateTime.now()
                        .serverTimeFromOffset
                        .isAfter(widget.tanggalKedaluwarsaTOB);
                if (itemSoal.jawabanSiswa != null) {
                  warnaNomorContainer = const Color(0xff32CD32);
                }
                if (itemSoal.isRagu
                    // hardcode by arifin
                    // && !isSudahDikumpulkan
                    ) {
                  warnaNomorContainer = Palette.kSecondarySwatch[400]!;
                  warnaBorder = context.secondaryColor;
                }
                if (isSudahDikumpulkan) {
                  warnaNomorContainer = context.disableColor;
                  warnaNomor = context.disableColor;
                }

                if (index == indexNomorSoal) {
                  warnaNomor = context.onTertiary;
                  warnaNomorContainer = context.tertiaryColor;
                }

                // var listDetailBundel =
                //     tobProvider.getListDetailWaktuByKodePaket(widget.kodePaket);
                // var mataUjiSekarang = listDetailBundel.isNotEmpty
                //     ? listDetailBundel[tobProvider.indexCurrentMataUji]
                //     : null;
                // hardcode by arifin
                // bool isBolehPindahSoal =
                //     !widget.isBlockingTime || _isSudahDikumpulkan();

                logger.log('TIMER SOAL-ClickNomor: Nomor >> $nomorSoal');
                logger.log(
                    'TIMER SOAL-ClickNomor: blocking time >> ${widget.isBlockingTime}');
                logger.log(
                    'TIMER SOAL-ClickNomor: boleh lihat solusi >> ${widget.isBlockingTime}');
                // hardcode by arifin
                // if (widget.isBlockingTime &&
                //     mataUjiSekarang != null &&
                //     !_isSudahDikumpulkan()) {
                //   isBolehPindahSoal =
                //       index >= mataUjiSekarang.indexSoalPertama &&
                //           index <= mataUjiSekarang.indexSoalTerakhir;

                //   if (!isBolehPindahSoal) {
                //     warnaNomorContainer = context.disableColor;
                //     warnaNomor = context.disableColor;
                //   }
                // }

                return InkWell(
                  onTap: () {
                    // hardcode by arifin
                    // if (isBolehPindahSoal) {
                    tobProvider.jumpToSoalNomor(index);

                    if (context.isMobile) {
                      Navigator.pop(context);
                    }

                    // muncul snackbar ketika masih loading simpan jawaban
                    if (_tobProvider.isLoadingSimpanJawaban) {
                      ScaffoldMessenger.of(gNavigatorKey.currentState!.context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              'Tunggu sebentar ya, sobat.\nKoneksi internet terganggu',
                              style: context.text.bodyMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                            duration: const Duration(milliseconds: 1200),
                            backgroundColor: Colors.black,
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.all(context.dp(16)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        );
                    } else {
                      _scrollToTop();
                    }

                    // hardcode by arifin
                    // }
                    // else {
                    //   if (context.isMobile) {
                    //     Navigator.pop(context);
                    //   }
                    //   ScaffoldMessenger.of(gNavigatorKey.currentState!.context)
                    //     ..hideCurrentSnackBar()
                    //     ..showSnackBar(
                    //       SnackBar(
                    //         content: Text(
                    //           (mataUjiSekarang != null &&
                    //                   index < mataUjiSekarang.indexSoalPertama)
                    //               ? 'Mata Uji ${listDetailBundel[tobProvider.indexCurrentMataUji - 1].namaKelompokUjian} sudah selesai sobat!'
                    //               : 'Tunggu Mata Uji ${mataUjiSekarang?.namaKelompokUjian ?? 'Undefined'} selesai ya Sobat!',
                    //           style: context.text.bodyMedium
                    //               ?.copyWith(color: context.onPrimaryContainer),
                    //         ),
                    //         duration: const Duration(seconds: 2),
                    //         backgroundColor: context.primaryContainer,
                    //         behavior: SnackBarBehavior.floating,
                    //         margin: EdgeInsets.all(context.dp(16)),
                    //         shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(14)),
                    //       ),
                    //     );
                    // }
                  },
                  borderRadius: BorderRadius.circular(3000),
                  child: Container(
                      width: min(48, context.dp(46)),
                      height: min(48, context.dp(46)),
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(min(6, context.dp(4))),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: warnaBorder),
                        color: warnaNomorContainer,
                      ),
                      child: FittedBox(
                        child: Text('${nomorSoal + totalPaketBefore}',
                            style: TextStyle(color: warnaNomor)),
                      )),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// [_onEndTimer] hanya berjalan ketika widget timer visible. Ketika boleh lihat solusi maka function
  /// ini tidak berjalan. Namun di dalam function ini ada 2 pengecekan TO GOA atau bukan.
  /// Khusus GOA maka pindah subtest by urutan yang belum lulus. Kalau sudah lulus maka langsung submit.
  /// Namun jika bukan GOA maka pengecekannya adalah di subtest terakhir atau bukan. Kalau iya maka langsung submit,
  /// jika tidak maka next subtest.
  void _onEndTimer() async {
    if (widget.isBolehLihatSolusi) return;

    if (widget.idJenisProduk == 12) {
      var listDetailBundel =
          _tobProvider.getListDetailWaktuByKodePaket(widget.kodePaket);
      DetailBundel? currentDetailBundel = (listDetailBundel.isEmpty)
          ? null
          : listDetailBundel
              .firstWhere((sub) => sub.isLulus == false || sub.isLulus == null);
      int? urutanAktifGOA = (currentDetailBundel?.urutan !=
              _tobProvider.getCurrentMataUji(widget.kodePaket)?.urutan)
          ? currentDetailBundel?.urutan
          : null;

      if (urutanAktifGOA != null) {
        Future.delayed(const Duration(seconds: 2), () {
          _onClickNextKelompokUjian(
              urutan: _tobProvider.indexPaket = urutanAktifGOA);
        });
      } else {
        await _kumpulkanJawaban(isOutOfTime: true);
      }

      return;
    }

    bool isLastBundleSoal = _tobProvider.isLastSubtest(widget.kodePaket);

    if (!isLastBundleSoal) {
      Future.delayed(Duration.zero, () async {
        await gShowTopFlash(
          context,
          'Yaah waktu sudah habis Sobat, jawaban kamu akan dikumpulkan secara otomatis. '
          'Dan kamu akan lanjut ke sub-test selanjutnya',
          dialogType: DialogType.info,
        );
      });

      Future.delayed(const Duration(seconds: 2), () {
        _onClickNextKelompokUjian(urutan: _tobProvider.indexPaket += 1);
      });
      return;
    }

    await _kumpulkanJawaban(isOutOfTime: true);
  }

  List<Widget> _buildLoadingWidget(BuildContext context) => [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShimmerWidget.rounded(
                width: context.dp(120),
                height: context.dp(24),
                borderRadius: BorderRadius.circular(12)),
            ShimmerWidget.rounded(
                width: context.dp(68),
                height: context.dp(24),
                borderRadius: BorderRadius.circular(12)),
          ],
        ),
        SizedBox(height: context.dp(12)),
        ShimmerWidget.rounded(
            width: context.dp(342),
            height: context.dp(240),
            borderRadius: BorderRadius.circular(24)),
        SizedBox(height: context.dp(24)),
        ShimmerWidget.rounded(
            width: context.dp(342),
            height: context.dp(52),
            borderRadius: BorderRadius.circular(12)),
        SizedBox(height: context.dp(12)),
        ShimmerWidget.rounded(
            width: context.dp(342),
            height: context.dp(52),
            borderRadius: BorderRadius.circular(12)),
        SizedBox(height: context.dp(12)),
        ShimmerWidget.rounded(
            width: context.dp(342),
            height: context.dp(52),
            borderRadius: BorderRadius.circular(12)),
        SizedBox(height: context.dp(12)),
        ShimmerWidget.rounded(
            width: context.dp(342),
            height: context.dp(52),
            borderRadius: BorderRadius.circular(12)),
        SizedBox(height: context.dp(12)),
      ];

  /// NOTE: kumpulan Widget
  AppBar _buildAppBar(bool isLoading) {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      toolbarHeight: (context.isMobile) ? 60 : 120,
      centerTitle: false,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      leadingWidth: context.dp(18),
      leading: SizedBox(width: context.dp(18)),
      title: _buildAppBarTitle(isLoading),
      bottom: _buildTimerDanNomorSoal(isLoading),
      actions: [
        Padding(
          padding: EdgeInsets.only(
              top: context.dp(12), left: context.dp(12), right: context.dp(12)),
          child: _buildSubmitButton(isLoading),
        )
      ],
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    bool isLastBundleSoal = _tobProvider.isLastSubtest(widget.kodePaket);
    bool isBolehKumpulkan = !isBolehLihatSolusi &&
        DateTime.now().serverTimeFromOffset.isBefore(
            widget.tanggalKedaluwarsaTOB.add(const Duration(hours: 1)));

    return (isLoading)
        ? ShimmerWidget.rounded(
            width: (context.isMobile) ? context.dp(100) : double.infinity,
            height: min(42, context.dp(32)),
            borderRadius: BorderRadius.circular(context.dp(8)),
          )
        : Visibility(
            visible: (widget.idJenisProduk == 16) ? true : isLastBundleSoal,
            child: ElevatedButton(
              onPressed: (isBolehKumpulkan &&
                      (widget.isRemedialGOA || !widget.isSelesai))
                  ? () async {
                      int totalSoalRagu = 0;
                      bool isJawabanKosongSemua = false;
                      // untuk cek apakah ada soal yg masih ragu
                      if (widget.isBlockingTime) {
                        totalSoalRagu =
                            await _tobProvider.getJawabanSiswaByUrutan(
                          kodePaket: widget.kodePaket,
                          noRegister: userData?.noRegistrasi ?? '',
                          urutan: _tobProvider.indexPaket,
                          tahunAjaran: userData?.tahunAjaran ?? '',
                          idJenisProduk: widget.idJenisProduk,
                        );
                      } else {
                        final resJawabanAll =
                            await _tobProvider.getJawabanSiswaAll(
                          kodePaket: widget.kodePaket,
                          noRegister: userData?.noRegistrasi ?? '',
                          tahunAjaran: userData?.tahunAjaran ?? '',
                          idJenisProduk: widget.idJenisProduk,
                        );

                        totalSoalRagu = resJawabanAll['totalSoalRagu'];
                        isJawabanKosongSemua = resJawabanAll['isJawabanKosong'];
                      }

                      bool kumpulkanConfirmed = false;

                      String title = '';
                      String message =
                          'Kumpulkan jawaban berarti seluruh jawaban akan dikumpulkan, '
                          'soal-soal yang belum dikerjakan akan dianggap kosong. '
                          'Kumpulkan sekarang?';

                      if (totalSoalRagu > 0) {
                        title =
                            'Terdapat $totalSoalRagu soal yang sobat masih ragu. Apakah sobat tetap akan mengumpulkan jawaban?';
                      } else if (isJawabanKosongSemua &&
                          !widget.isBlockingTime) {
                        title =
                            'Terdapat soal yang masih belum dijawab. Apakah sobat tetap akan mengumpulkan jawaban?';
                      } else {
                        title = 'Apakah sobat sudah selesai mengerjakan soal?';
                      }

                      kumpulkanConfirmed = await _bottomDialog(
                        title: title,
                        message: message,
                        actions: (controller) => [
                          TextButton(
                              onPressed: () => controller.dismiss(false),
                              style: TextButton.styleFrom(
                                  foregroundColor: context.onBackground),
                              child: const Text('Nanti Saja')),
                          TextButton(
                              onPressed: () => controller.dismiss(true),
                              child: const Text('Kumpulkan Saja')),
                        ],
                      );

                      if (!kumpulkanConfirmed) return;

                      await _kumpulkanJawaban();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.secondaryColor,
                foregroundColor: context.onSecondary,
                minimumSize: (context.isMobile)
                    ? Size(context.dp(114), context.dp(64))
                    : null,
                padding: (context.isMobile)
                    ? null
                    : const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                textStyle: context.text.labelLarge,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.dp(8)),
                ),
              ),
              child: const Text('Kumpulkan', textAlign: TextAlign.center),
            ),
          );
  }

  Column _buildAppBarTitle(bool isLoading) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (context.isMobile) const SizedBox(height: 14),
          Text('Mata Uji Saat Ini',
              style:
                  context.text.labelSmall?.copyWith(color: context.onPrimary)),
          (isLoading)
              ? ShimmerWidget.rectangle(
                  width: context.dp(30),
                  height: context.dp(8),
                  borderRadius: BorderRadius.circular(8),
                )
              : Text(_tobProvider.soal.namaKelompokUjian,
                  style: context.text.labelLarge?.copyWith(
                    color: context.onPrimary,
                    fontWeight: FontWeight.bold,
                  ))
        ],
      );

  PreferredSize _buildTimerDanNomorSoal(bool isLoading) {
    int totalPaketBefore = _tobProvider.totalSoalBefore(widget.kodePaket);
    Widget numberingWidget = Text(
      'No ${(_tobProvider.indexSoal + 1) + totalPaketBefore}/${widget.jumlahSoalPaket}',
      style: (context.isMobile)
          ? null
          : const TextStyle(
              color: Colors.white,
            ),
    );
    return PreferredSize(
      preferredSize: Size(double.infinity, context.dp(80)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: (context.isMobile) ? context.dp(12) : 0,
            ),
            child: Row(
              children: [
                if (!isLoading && widget.isBolehLihatSolusi)
                  ..._buildTingkatKesulitanSoal(
                      _tobProvider.soal.tingkatKesulitan),
                if (isLoading)
                  ShimmerWidget.rectangle(
                      width: context.dp(82), height: context.dp(24)),
                if (!isLoading && !widget.isBolehLihatSolusi)
                  SoalCountdownTimer(
                    onEndTimer: _onEndTimer,
                    kodePaket: widget.kodePaket,
                    isBlockingTime: widget.isBlockingTime,
                    countdownController: _countdownController,
                    onTick: (sisaWaktu) {
                      _tobProvider.sisaWaktu =
                          Duration(seconds: sisaWaktu.toInt());
                    },
                  ),
                const Spacer(),
                if (context.isMobile) ...[
                  TextButton.icon(
                    onPressed: _onClickNomorSoal,
                    icon: const Icon(Icons.arrow_drop_down_sharp),
                    label: (isLoading)
                        ? ShimmerWidget.rounded(
                            width: context.dp(84),
                            height: context.dp(24),
                            borderRadius: BorderRadius.circular(8),
                          )
                        : numberingWidget,
                    style: TextButton.styleFrom(
                        foregroundColor: context.onPrimary,
                        padding: EdgeInsets.zero,
                        textStyle: context.text.titleMedium,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                  )
                ] else ...[
                  numberingWidget,
                ]
              ],
            ),
          ),
          if (context.isMobile) ...[_buildRunningTextHakCipta()],
        ],
      ),
    );
  }

  Widget _buildRatingDanRagu() => (_isSudahDikumpulkan())
      ? SizedBox(height: min(36, context.dp(18)))
      : Row(
          children: [
            ..._buildTingkatKesulitanSoal(_tobProvider.soal.tingkatKesulitan),
            const Spacer(),
            Checkbox(
              value: _tobProvider.soal.isRagu,
              onChanged: _raguRaguToggle,
              activeColor: context.secondaryColor,
              checkColor: context.onSecondary,
            ),
            Text('Ragu', style: context.text.labelLarge),
            SizedBox(width: context.dp(4)),
          ],
        );

  List<Widget> _buildTingkatKesulitanSoal(int tingkatKesulitan) =>
      List.generate(
        5,
        (index) => Icon(
          Icons.star_rounded,
          size: 28,
          color: index < tingkatKesulitan
              ? context.secondaryColor
              : context.disableColor,
        ),
      );

  Widget _buildSoalWidget() {
    final textSoal = _tobProvider.soal.textSoal;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.dp(8)),
      child: (textSoal.contains('table'))
          ? WidgetFromHtml(htmlString: textSoal)
          : CustomHtml(htmlString: textSoal),
    );
  }

  Widget _buildWacanaWidget() {
    bool wacanaExist = _tobProvider.soal.wacana != null;

    String? wacana = (!wacanaExist) ? null : _tobProvider.soal.wacana;

    return (!wacanaExist || wacana == null)
        ? const SizedBox.shrink()
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: context.dp(8)),
            child: (wacana.contains('table'))
                ? WidgetFromHtml(htmlString: wacana)
                : CustomHtml(htmlString: wacana),
          );
  }

  // ElevatedButton _buildSobatTipsButton() => ElevatedButton(
  //       onPressed: () =>
  //           _onClickSobatTips(_tobProvider.soal.idSoal, "idbundel"),
  //       style: ElevatedButton.styleFrom(
  //         elevation: 5,
  //         textStyle: context.text.labelMedium,
  //         backgroundColor: context.secondaryColor,
  //         foregroundColor: context.onSecondary,
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(300)),
  //         padding: EdgeInsets.only(
  //             left: min(24, context.dp(12)),
  //             right: min(16, context.dp(8)),
  //             top: min(16, context.dp(8)),
  //             bottom: min(16, context.dp(8))),
  //       ),
  //       child: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           const Text('Sobat Tips'),
  //           SizedBox(width: min(16, context.dp(8))),
  //           const Icon(Icons.help_outline_rounded)
  //         ],
  //       ),
  //     );

  Container _buildBottomNavBarTOBK(bool isLoading) {
    return Container(
      width: (context.isMobile) ? context.dw : double.infinity,
      padding: (context.isMobile)
          ? EdgeInsets.only(
              top: min(14, context.dp(8)),
              left: min(14, context.dp(8)),
              right: min(14, context.dp(8)),
              bottom: min(14, context.dp(8)) + min(20, context.bottomBarHeight),
            )
          : EdgeInsets.all(min(14, context.dp(8))),
      decoration: BoxDecoration(
        color: context.background,
        borderRadius: (context.isMobile) ? null : BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: context.disableColor,
            blurRadius: 8,
            offset:
                (context.isMobile) ? const Offset(0, -2) : const Offset(2, 2),
          )
        ],
      ),
      child: Row(
        children: [
          if ((_tobProvider.indexSoal + 1) != _tobProvider.jumlahSoal &&
              !isLoading) ...[
            const Spacer(),
          ],
          if (isLoading)
            ShimmerWidget.rectangle(
              width: (context.isMobile) ? (context.dw / 2.2) : context.dp(100),
              height: min(42, context.dp(36)),
            ),
          // const Spacer(),
          (isLoading)
              ? ShimmerWidget.rounded(
                  width: context.dp(24),
                  height: context.dp(24),
                  borderRadius: BorderRadius.circular(context.dp(8)),
                )
              : IconButton(
                  onPressed: (_tobProvider.isFirstSoal)
                      ? null
                      : () {
                          _scrollToTop();
                          _tobProvider.setPrevSoal(
                            kodePaket: widget.kodePaket,
                            noRegister: userData?.noRegistrasi ?? '',
                            tahunAjaran: userData?.tahunAjaran ?? '',
                            urutan: _tobProvider.indexPaket,
                            idJenisProduk: widget.idJenisProduk,
                          );
                        },
                  icon: const Icon(Icons.chevron_left_rounded)),
          if (isLoading) const SizedBox(width: 8),
          (isLoading)
              ? Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: ShimmerWidget.rounded(
                    width: context.dp(24),
                    height: context.dp(24),
                    borderRadius: BorderRadius.circular(context.dp(8)),
                  ),
                )
              : IconButton(
                  onPressed: (_tobProvider.isLastSoal)
                      ? null
                      : () {
                          _scrollToTop();
                          _tobProvider.setNextSoal(
                            kodePaket: widget.kodePaket,
                            noRegister: userData?.noRegistrasi ?? '',
                            tahunAjaran: userData?.tahunAjaran ?? '',
                            urutan: _tobProvider.indexPaket,
                            idJenisProduk: widget.idJenisProduk,
                          );
                        },
                  icon: const Icon(Icons.chevron_right_rounded)),
          const Spacer(),
          if (!isLoading &&
              _tobProvider.getMataUjiSelanjutnya(widget.kodePaket) != null)
            Visibility(
              visible: (_tobProvider.indexSoal + 1) == _tobProvider.jumlahSoal,
              child: TextButton(
                onPressed: () {
                  if (_tobProvider.waktuPengerjaan.inSeconds != 0) {
                    final sisaWaktu = _tobProvider.sisaWaktu.inSeconds;
                    int hours = (sisaWaktu / 3600).floor();
                    int minutes = ((sisaWaktu % 3600) / 60).floor();
                    int seconds = (sisaWaktu % 60).floor();

                    String displayTime =
                        '${(minutes < 10) ? '0$minutes' : minutes} : ${(seconds < 10) ? '0$seconds' : seconds}';
                    if (_tobProvider.waktuPengerjaan.inHours >= 1) {
                      displayTime =
                          '$hours : ${(minutes < 10) ? '0$minutes' : minutes} : ${(seconds < 10) ? '0$seconds' : seconds}';
                    }

                    Future.delayed(Duration.zero, () async {
                      await gShowTopFlash(context,
                          'Masih tersisa waktu $displayTime, silahkan dicek kembali jawaban sobat. Sebelum bisa lanjut ke sub-test selanjutnya.',
                          dialogType: DialogType.info,
                          duration: const Duration(seconds: 3));
                    });
                    //  sisaWa
                  }
                },
                // hardcode by arifin
                // (widget.isBlockingTime && !_isSudahDikumpulkan())
                //     ? _blockingTimeNextKelompokUjian
                //     : _onClickNextKelompokUjian,
                style: TextButton.styleFrom(
                  foregroundColor: context.onBackground,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: (context.isMobile)
                            ? context.dw / 1.8
                            : context.dp(100),
                      ),
                      child: RichText(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textScaler: TextScaler.linear(context.textScale12),
                        textAlign: TextAlign.end,
                        text: TextSpan(
                          text: 'Selanjutnya\n',
                          style: context.text.labelMedium,
                          children: [
                            TextSpan(
                                text: _tobProvider
                                    .getMataUjiSelanjutnya(widget.kodePaket)!
                                    .namaKelompokUjian,
                                style: context.text.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded)
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Container _buildBottomNavBarPaketTimer(bool isLoading) => Container(
        width: (context.isMobile) ? context.dw : double.infinity,
        padding: (context.isMobile)
            ? EdgeInsets.only(
                top: min(14, context.dp(8)),
                left: min(14, context.dp(8)),
                right: min(14, context.dp(8)),
                bottom:
                    min(14, context.dp(8)) + min(20, context.bottomBarHeight),
              )
            : EdgeInsets.all(min(14, context.dp(8))),
        decoration: BoxDecoration(
          color: context.background,
          borderRadius: (context.isMobile) ? null : BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: context.disableColor,
              blurRadius: 8,
              offset:
                  (context.isMobile) ? const Offset(0, -2) : const Offset(2, 2),
            )
          ],
        ),
        child: Row(
          children: [
            if (!isLoading) ...[
              const Spacer(),
            ],
            (isLoading)
                ? ShimmerWidget.rounded(
                    width: context.dp(24),
                    height: context.dp(24),
                    borderRadius: BorderRadius.circular(context.dp(8)),
                  )
                : IconButton(
                    onPressed: (_tobProvider.isFirstSoal)
                        ? null
                        : () {
                            _scrollToTop();
                            _tobProvider.setPrevSoal(
                              kodePaket: widget.kodePaket,
                              noRegister: userData?.noRegistrasi ?? '',
                              tahunAjaran: userData?.tahunAjaran ?? '',
                              urutan: _tobProvider.indexPaket,
                              idJenisProduk: widget.idJenisProduk,
                            );
                          },
                    icon: const Icon(Icons.chevron_left_rounded)),
            if (isLoading) const SizedBox(width: 8),
            (isLoading)
                ? Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: ShimmerWidget.rounded(
                      width: context.dp(24),
                      height: context.dp(24),
                      borderRadius: BorderRadius.circular(context.dp(8)),
                    ),
                  )
                : IconButton(
                    onPressed: (_tobProvider.isLastSoal)
                        ? null
                        : () async {
                            _scrollToTop();
                            _tobProvider.setNextSoal(
                              kodePaket: widget.kodePaket,
                              noRegister: userData?.noRegistrasi ?? '',
                              tahunAjaran: userData?.tahunAjaran ?? '',
                              urutan: _tobProvider.indexPaket,
                              idJenisProduk: widget.idJenisProduk,
                            );
                          },
                    icon: const Icon(Icons.chevron_right_rounded)),
            const Spacer(),
          ],
        ),
      );

  Widget _buildJawabanWidget() {
    switch (_tobProvider.soal.tipeSoal) {
      case 'PGB':
        Map<String, dynamic> mapData = {};
        for (var item in _tobProvider.jsonSoalJawaban['opsi']) {
          mapData.addAll(item);
        }
        return PilihanGandaBerbobot(
          jsonOpsiJawaban: mapData,
          jawabanSebelumnya: _tobProvider.soal.jawabanSiswa,
          kunciJawaban: _tobProvider.soal.kunciJawaban,
          isBolehLihatKunci: isBolehLihatSolusi,
          onClickPilihJawaban: (_isSudahDikumpulkan())
              ? null
              : (pilihanJawaban) async =>
                  await _setTempJawaban(jawabanSiswa: pilihanJawaban),
        );
      case 'PBK':
        List<String>? jawabanSiswaSebelumnya, kunciJawaban;
        List<dynamic>? jawabanSiswa =
            (_tobProvider.soal.jawabanSiswa is! List<dynamic>)
                ? null
                : _tobProvider.soal.jawabanSiswa;
        List<dynamic>? kunci =
            (_tobProvider.soal.kunciJawaban is! List<dynamic>)
                ? null
                : _tobProvider.soal.kunciJawaban;

        if (jawabanSiswa != null && jawabanSiswa.isNotEmpty) {
          jawabanSiswaSebelumnya = jawabanSiswa.cast<String>();
        }
        if (kunci != null && kunci.isNotEmpty) {
          kunciJawaban = kunci.cast<String>();
        }

        Map<String, dynamic> mapData = {};
        for (var item in _tobProvider.jsonSoalJawaban['opsi']) {
          mapData.addAll(item);
        }

        return PilihanBergandaKompleks(
          jsonOpsiJawaban: mapData,
          jawabanSebelumnya: jawabanSiswaSebelumnya,
          kunciJawaban: kunciJawaban,
          max: _tobProvider.jsonSoalJawaban['kunci'].length,
          isBolehLihatKunci: isBolehLihatSolusi,
          onClickPilihJawaban: (_isSudahDikumpulkan())
              ? null
              : (listPilihanJawaban) async =>
                  await _setTempJawaban(jawabanSiswa: listPilihanJawaban),
        );
      case 'PBCT':
        List<String>? jawabanSiswaSebelumnya, kunciJawaban;
        List<dynamic>? jawabanSiswa =
            (_tobProvider.soal.jawabanSiswa is! List<dynamic>)
                ? null
                : _tobProvider.soal.jawabanSiswa;
        List<dynamic>? kunci =
            (_tobProvider.soal.kunciJawaban is! List<dynamic>)
                ? null
                : _tobProvider.soal.kunciJawaban;

        if (jawabanSiswa != null && jawabanSiswa.isNotEmpty) {
          jawabanSiswaSebelumnya = jawabanSiswa.cast<String>();
        }
        if (kunci != null && kunci.isNotEmpty) {
          kunciJawaban = kunci.cast<String>();
        }

        Map<String, dynamic> mapData = {};
        for (var item in _tobProvider.jsonSoalJawaban['opsi']) {
          mapData.addAll(item);
        }

        return PilihanBergandaComplexTerbatas(
          jsonOpsiJawaban: mapData,
          jawabanSebelumnya: jawabanSiswaSebelumnya,
          kunciJawaban: kunciJawaban,
          isBolehLihatKunci: isBolehLihatSolusi,
          max: _tobProvider.jsonSoalJawaban['max'],
          onClickPilihJawaban: (_isSudahDikumpulkan())
              ? null
              : (listPilihanJawaban) async => await _setTempJawaban(
                    jawabanSiswa: listPilihanJawaban,
                  ),
        );
      case 'PBM':
        List<int>? jawabanSiswaSebelumnya;
        List<dynamic>? jawabanSiswa =
            (_tobProvider.soal.jawabanSiswa is! List<dynamic>)
                ? null
                : _tobProvider.soal.jawabanSiswa;

        if (jawabanSiswa != null && jawabanSiswa.isNotEmpty) {
          jawabanSiswaSebelumnya = jawabanSiswa.cast<int>();
        }

        return PilihanBergandaMemasangkan(
          jsonPernyataanOpsi: _tobProvider.jsonSoalJawaban,
          jawabanSebelumnya: jawabanSiswaSebelumnya,
          onSimpanJawaban: (_isSudahDikumpulkan())
              ? null
              : (listJawaban) async =>
                  await _setTempJawaban(jawabanSiswa: listJawaban),
        );
      case 'PBT':
        List<int>? jawabanSiswaSebelumnya;
        List<int> kunciJawabanCast = [];
        List? jawabanSiswa = (_tobProvider.soal.jawabanSiswa is! List)
            ? null
            : _tobProvider.soal.jawabanSiswa;
        List? kunciJawaban = (_tobProvider.soal.kunciJawaban is! List<dynamic>)
            ? null
            : _tobProvider.soal.kunciJawaban;

        if (jawabanSiswa != null && jawabanSiswa.isNotEmpty) {
          jawabanSiswaSebelumnya = jawabanSiswa.cast<int>();
        }
        if (kunciJawaban != null && kunciJawaban.isNotEmpty) {
          kunciJawabanCast = kunciJawaban.cast<int>();
        }

        return PilihanBergandaTabel(
          jsonTabelJawaban: _tobProvider.jsonSoalJawaban,
          jawabanSebelumnya: jawabanSiswaSebelumnya,
          bolehLihatSolusi: _isSudahDikumpulkan(),
          kunciJawaban: kunciJawabanCast,
          onSelectJawaban: (_isSudahDikumpulkan())
              ? null
              : (listJawaban) async =>
                  await _setTempJawaban(jawabanSiswa: listJawaban),
        );
      case 'PBB':
        Map<String, dynamic>? jawabanSiswaSebelumnya =
            (_tobProvider.soal.jawabanSiswa != null)
                ? Map<String, dynamic>.from(_tobProvider.soal.jawabanSiswa)
                : null;

        return PilihanBergandaBercabang(
          jsonOpsiJawaban: _tobProvider.jsonSoalJawaban,
          jawabanSebelumnya: jawabanSiswaSebelumnya,
          onSimpanJawaban: (_isSudahDikumpulkan())
              ? null
              : (jawabanAlasan) async =>
                  await _setTempJawaban(jawabanSiswa: jawabanAlasan),
        );
      case 'ESSAY':
        return JawabanEssay(
          soalProvider: _tobProvider,
          nomorSoal: _tobProvider.soal.nomorSoal,
          onSimpanJawaban: (_isSudahDikumpulkan())
              ? null
              : (isiJawaban) async =>
                  await _setTempJawaban(jawabanSiswa: isiJawaban),
        );
      case 'ESSAY MAJEMUK':
        return JawabanEssayMajemuk(
          soalProvider: _tobProvider,
          nomorSoal: _tobProvider.soal.nomorSoal,
          jsonSoalJawaban: _tobProvider.jsonSoalJawaban,
          onSimpanJawaban: (_isSudahDikumpulkan())
              ? null
              : (isiJawaban) async =>
                  await _setTempJawaban(jawabanSiswa: isiJawaban),
        );
      default:
        return PilihanBergandaSederhana(
          jsonOpsiJawaban: _tobProvider.jsonSoalJawaban,
          jawabanSebelumnya: _tobProvider.soal.jawabanSiswa,
          kunciJawaban: _tobProvider.soal.kunciJawaban,
          isBolehLihatKunci: isBolehLihatSolusi,
          onClickPilihJawaban: (_isSudahDikumpulkan())
              ? null
              : (pilihanJawaban) async =>
                  _setTempJawaban(jawabanSiswa: pilihanJawaban),
        );
    }
  }

  Future<bool> _bottomDialog(
      {String title = 'Perhatian!!',
      String message =
          'Kumpulkan jawaban kamu jika ingin keluar dari halaman ini. '
              'Pengumpulan hanya dapat dilakukan satu kali saja. '
              'Soal yang belum dijawab akan dianggap kosong',
      List<Widget> Function(FlashController controller)? actions}) async {
    if (gPreviousBottomDialog?.isDisposed == false) {
      gPreviousBottomDialog?.dismiss(false);
    }
    gPreviousBottomDialog = DefaultFlashController<bool>(
      context,
      persistent: true,
      barrierColor: Colors.black54,
      barrierBlur: 2,
      barrierDismissible: true,
      onBarrierTap: () => Future.value(false),
      barrierCurve: Curves.easeInOutCubic,
      transitionDuration: const Duration(milliseconds: 300),
      builder: (context, controller) {
        return FlashBar(
          useSafeArea: true,
          controller: controller,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          clipBehavior: Clip.hardEdge,
          margin: (context.isMobile)
              ? const EdgeInsets.all(14)
              : EdgeInsets.symmetric(
                  horizontal: context.dw * .2,
                ),
          backgroundColor: context.background,
          title: Text(title),
          content: Text(message),
          titleTextStyle: context.text.titleMedium,
          contentTextStyle: context.text.bodySmall,
          indicatorColor: context.secondaryColor,
          icon: const Icon(Icons.info_outline),
          actions: (actions != null)
              ? actions(controller)
              : [
                  TextButton(
                      onPressed: () => controller.dismiss(false),
                      style: TextButton.styleFrom(
                          foregroundColor: context.onBackground),
                      child: const Text('Mengerti'))
                ],
        );
      },
    );

    bool? result = await gPreviousBottomDialog?.show();

    return result ?? false;
  }

  Widget _buildButtonNextPrevBundleSoal(bool isLoading) {
    return Padding(
      padding: EdgeInsets.only(
        left: (context.isMobile) ? 35 : 0,
        // bottom: (context.isMobile) ? 0 : 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          (!isLoading &&
                  _tobProvider.getMataUjiSebelumnya(widget.kodePaket) != null)
              ? GestureDetector(
                  onTap: () {
                    _onClickNextKelompokUjian(
                        urutan: _tobProvider.indexPaket -= 1);
                  },
                  child: Container(
                    width: 140,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: context.secondaryColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Builder(builder: (context) {
                      return RichText(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textScaler: TextScaler.linear(context.textScale12),
                        text: TextSpan(
                          text: 'Sebelumnya\n',
                          style: context.text.labelMedium,
                          children: [
                            TextSpan(
                                text: _tobProvider
                                    .getMataUjiSebelumnya(widget.kodePaket)!
                                    .namaKelompokUjian,
                                style: context.text.labelLarge?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ))
                          ],
                        ),
                      );
                    }),
                  ),
                )
              : const SizedBox(),
          (!isLoading &&
                  _tobProvider.getMataUjiSelanjutnya(widget.kodePaket) != null)
              ? GestureDetector(
                  onTap: () {
                    _onClickNextKelompokUjian(
                        urutan: _tobProvider.indexPaket += 1);
                  },
                  child: Container(
                    width: 140,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: context.secondaryColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Builder(builder: (context) {
                      return RichText(
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textScaler: TextScaler.linear(context.textScale12),
                        text: TextSpan(
                          text: 'Selanjutnya\n',
                          style: context.text.labelMedium,
                          children: [
                            TextSpan(
                                text: _tobProvider
                                    .getMataUjiSelanjutnya(widget.kodePaket)!
                                    .namaKelompokUjian,
                                style: context.text.labelLarge?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ))
                          ],
                        ),
                      );
                    }),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  void _navigateToReportProblem() {
    _navigator.pushNamed(Constant.kRouteReportProblem, arguments: {
      'soalProvider': _tobProvider,
      'noRegistrasi': userData?.noRegistrasi ?? '',
      'idJenisProduk': widget.idJenisProduk,
      'namaJenisProduk': widget.namaJenisProduk,
      'idSoal': int.parse(_tobProvider.soal.idSoal),
      'kodePaket': widget.kodePaket,
      'stackTrace': '-',
    });
  }

  Widget _buildReportProblem() {
    bool isReportSubmitted = _tobProvider.soal.isReportSubmitted;
    return Column(
      children: [
        Material(
          color:
              (isReportSubmitted) ? context.disableColor : context.primaryColor,
          borderRadius: BorderRadius.circular(300),
          child: InkWell(
            onTap: (isReportSubmitted) ? null : _navigateToReportProblem,
            borderRadius: BorderRadius.circular(300),
            child: Container(
              constraints: BoxConstraints(minWidth: context.dw),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(300),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(-1, -1),
                      blurRadius: 4,
                      spreadRadius: 1,
                      color: (isReportSubmitted)
                          ? context.disableColor.withOpacity(0.1)
                          : context.primaryColor.withOpacity(0.1),
                    ),
                    BoxShadow(
                      offset: const Offset(1, 1),
                      blurRadius: 4,
                      spreadRadius: 1,
                      color: (isReportSubmitted)
                          ? context.disableColor.withOpacity(0.1)
                          : context.primaryColor.withOpacity(0.1),
                    )
                  ]),
              child: Text(
                'Laporkan Masalah',
                textAlign: TextAlign.center,
                style: context.text.labelMedium
                    ?.copyWith(color: context.background),
              ),
            ),
          ),
        ),
        SizedBox(height: context.dp(52)),
      ],
    );
  }

  Widget _buildSubtestLulusGOA() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: EdgeInsets.only(bottom: context.dp(18)),
        decoration: BoxDecoration(
          color: Colors.green[500],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                  text: 'Sobat sudah lulus sub-test ini\n\n',
                  style: context.text.labelLarge?.copyWith(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  )),
              TextSpan(
                text:
                    'Sobat tidak perlu menjawab soal ini karena sudah lulus ${_tobProvider.soal.namaKelompokUjian}, '
                    'abaikan waktu yang berjalan',
                style: context.text.labelMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 12,
                ),
              )
            ],
          ),
        ),
      );

  Widget _buildRunningTextHakCipta() => ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: context.dw,
          maxHeight: 40,
        ),
        child: Visibility(
          visible: !_isLoading,
          child: Container(
            color:
                (context.isMobile) ? Colors.transparent : context.primaryColor,
            child: Marquee(
              text: gPesanHakCipta,
              style: context.text.labelMedium?.copyWith(
                color: Colors.white,
              ),
              blankSpace: 150,
              velocity: 100,
            ),
          ),
        ),
      );
}
