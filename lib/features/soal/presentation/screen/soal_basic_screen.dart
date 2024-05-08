// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'dart:developer' as logger show log;
import 'dart:math';

import 'package:flash/flash_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gokreasi_new/core/config/enum.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/bookmark/presentation/bloc/bookmark_bloc.dart';
import 'package:gokreasi_new/features/soal/presentation/provider/soal_provider.dart';
import 'package:gokreasi_new/features/soal/presentation/widget/loading_overlay.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';

import '../../../../core/shared/widget/html/custom_html_widget.dart';
import '../widget/solusi_widget.dart';
import '../widget/sobat_tips_widget.dart';
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
import '../../module/bundel_soal/domain/entity/bundel_soal.dart';
import '../../module/paket_soal/presentation/provider/paket_soal_provider.dart';
import '../../module/bundel_soal/presentation/provider/bundel_soal_provider.dart';
import '../../../video/presentation/widget/video_player_card.dart';
import '../../../../core/config/theme.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/util/data_formatter.dart';
import '../../../../core/util/platform_channel.dart';
import '../../../../core/shared/builder/responsive_builder.dart';
import '../../../../core/shared/screen/custom_will_pop_scope.dart';
import '../../../../core/shared/widget/loading/shimmer_widget.dart';
import '../../../../core/shared/widget/html/widget_from_html.dart';
import '../../../../core/shared/widget/watermark/watermark_widget.dart';

class SoalBasicScreen extends StatefulWidget {
  final OpsiUrut? opsiUrutBundel;
  final String? idBundel;
  final String? namaKelompokUjian;
  final String? kodeBab;
  final String? namaBab;
  final String kodeTOB;
  final String kodePaket;
  final String namaJenisProduk;
  final int idJenisProduk;
  final int mulaiDariSoalNomor;
  final DateTime? tanggalKedaluwarsa;
  final String diBukaDariRoute;
  final bool isPaket;
  final bool isSimpan;
  final bool isBisaBookmark;
  final bool isSelesai;
  final bool isKedaluarsa;
  final List<int>? listIdBundel;
  final int? urutan;
  final int? jumlahSoalPaket;
  final bool isBookmarked;

  const SoalBasicScreen({
    Key? key,
    this.opsiUrutBundel,
    this.idBundel,
    this.namaKelompokUjian,
    required this.kodeBab,
    this.namaBab,
    required this.kodeTOB,
    required this.kodePaket,
    required this.namaJenisProduk,
    required this.idJenisProduk,
    this.mulaiDariSoalNomor = 1,
    this.tanggalKedaluwarsa,
    required this.diBukaDariRoute,
    this.isSimpan = true,
    required this.isPaket,
    this.listIdBundel,
    this.isBisaBookmark = true,
    required this.isSelesai,
    required this.isKedaluarsa,
    this.urutan,
    this.jumlahSoalPaket,
    required this.isBookmarked,
  }) : super(key: key);

  @override
  State<SoalBasicScreen> createState() => _SoalBasicScreenState();
}

class _SoalBasicScreenState extends State<SoalBasicScreen>
    with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {}
  }

  @override
  void didUpdateWidget(SoalBasicScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Cek apakah isPaket atau kodePaket berubah
    if (widget.isPaket != oldWidget.isPaket ||
        widget.kodePaket != oldWidget.kodePaket) {
      _getSoal();
    }
  }

  final _scrollController = ScrollController();
  final _nomorSoalScrollController = ScrollController();
  late final NavigatorState _navigator = Navigator.of(context);

  late final BundelSoalProvider _bundelSoalProvider =
      context.watch<BundelSoalProvider>();
  late final PaketSoalProvider _paketSoalProvider =
      context.watch<PaketSoalProvider>();

  // int _jumlahFlashBottomTerbuka = 0;
  // DefaultFlashController? gPreviousBottomDialog;
  UserModel? userData;
  late BookmarkBloc bookmarkBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    bookmarkBloc = context.read<BookmarkBloc>();
    Future.delayed(const Duration(milliseconds: 1300)).then((value) =>
        PlatformChannel.setSecureScreen(Constant.kRouteSoalBasicScreen));

    if (!userData.isLogin || userData.isOrtu) {
      SoalServiceLocal().openJawabanBox();
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is LoadedUser) {
      userData = authState.user;
    }
    _getSoal(urutan: 1);
  }

  @override
  void dispose() {
    PlatformChannel.setSecureScreen('POP', true);
    if (!userData.isLogin || userData.isOrtu) {
      SoalServiceLocal().closeJawabanBox();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PlatformChannel.setSecureScreen(Constant.kRouteSoalBasicScreen);
    return Stack(
      children: [
        CustomWillPopScope(
          swipeSensitivity:
              (!widget.isSimpan && !_isSudahDikumpulkanSemua()) ? 20 : 12,
          // onWillPop: () async {
          //   if (_isLoading()) {
          //     return Future<bool>.value(true);
          //   }
          //   // if (widget.namaJenisProduk == 'e-Empati Wajib' &&
          //   //     !_isSudahDikumpulkanSemua()) {
          //   //   return await _kumpulkanJawabanEmpatiWajib();
          //   // }
          //   if (!widget.isSimpan &&
          //       widget.namaJenisProduk != 'e-Empati Wajib' &&
          //       !_isSudahDikumpulkanSemua()) {
          //     await _bottomDialog(
          //         title: 'Hi Sobat',
          //         message:
          //             'Jika ingin keluar dari halaman pengerjaan, silahkan kumpulkan jawaban kamu ya.');
          //
          //     return Future.value(false);
          //   }
          //   _saveLog();
          //   return Future.value(widget.isSimpan || _isSudahDikumpulkanSemua());
          // },
          onDragRight: () async {
            await Future.delayed(gDelayedNavigation).then(
              (_) => _navigator
                  .popUntil(ModalRoute.withName(widget.diBukaDariRoute)),
            );
            // if (widget.isSimpan || _isSudahDikumpulkanSemua() || _isLoading()) {
            //   logger.log('POP NAVIGATION >> ${_isSudahDikumpulkanSemua()}');
            //   _saveLog();
            //   _navigator.pop();
            // } else if (widget.namaJenisProduk == 'e-Empati Wajib') {
            //   // bool isSubmitJawaban = await _kumpulkanJawabanEmpatiWajib();
            //   //
            //   // logger.log('SUBMIT JAWABAN: $isSubmitJawaban');
            //   // if (isSubmitJawaban) {
            //   //   _saveLog();
            //   //   // final duration = Duration(
            //   //   //     seconds: 2, milliseconds: gDelayedNavigation.inMilliseconds);
            //   //   await Future.delayed(gDelayedNavigation).then(
            //   //     (_) => _navigator
            //   //         .popUntil(ModalRoute.withName(widget.diBukaDariRoute)),
            //   //   );
            //   // }
            //   await Future.delayed(gDelayedNavigation).then(
            //     (_) => _navigator
            //         .popUntil(ModalRoute.withName(widget.diBukaDariRoute)),
            //   );
            // } else if (widget.namaJenisProduk != 'e-Empati Wajib' &&
            //     !_isSudahDikumpulkanSemua()) {
            //   await _bottomDialog(
            //       title: 'Hi Sobat',
            //       message:
            //           'Jika ingin keluar dari halaman pengerjaan, silahkan kumpulkan jawaban kamu ya.');
            // }
          },
          child: Scaffold(
            backgroundColor: context.primaryColor,
            appBar: (context.isMobile) ? _buildAppBar() : null,
            body: ResponsiveBuilder(
              mobile: Container(
                width: context.dw,
                height: double.infinity,
                decoration: BoxDecoration(
                    color: context.background,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24))),
                child: WatermarkWidget(
                  child: Stack(
                    children: [
                      _buildListViewBody(context),
                      if (!_isLoading() &&
                          !widget.kodePaket.contains('VAK')) ...[
                        _buildSobatTipsButton(),
                      ]
                    ],
                  ),
                ),
              ),
              tablet: _buildTabletView(context),
            ),
            floatingActionButton: (!context.isMobile)
                ? null
                : (widget.idJenisProduk == 71 || widget.idJenisProduk == 72)
                    ? _buildNextPrevSoal(_isLoading())
                    : null,
            bottomNavigationBar:
                (context.isMobile) ? _buildBottomNavBar() : null,
          ),
        ),
        LoadingOverlay(
          isLoadingSimpanJawaban: (widget.isPaket)
              ? _paketSoalProvider.isLoadingSimpanJawaban
              : _bundelSoalProvider.isLoadingSimpanJawaban,
          loadingKoneksi: (widget.isPaket)
              ? _paketSoalProvider.loadingKoneksi
              : _bundelSoalProvider.loadingKoneksi,
          isLoadingJawaban: (widget.isPaket)
              ? _paketSoalProvider.isLoadingJawaban
              : _bundelSoalProvider.isLoadingJawaban,
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
            children: (_isLoading())
                ? [..._buildLoadingWidget(context)]
                : [
                    const SizedBox(height: 50),
                    _buildWacanaWidget(),
                    _buildSoalWidget(),
                    _buildJawabanWidget(),
                    if (!_isSudahDikumpulkan()) ...[
                      SizedBox(height: context.dp(40)),
                    ],
                    if (_isSudahDikumpulkan() &&
                        _checkKedaluwarsa() &&
                        widget.namaJenisProduk != 'e-VAK') ...[
                      SolusiWidget(
                        accessFrom: AccessVideoCardFrom.videoSolusi,
                        idSoal: (widget.isPaket)
                            ? _paketSoalProvider.soal.idSoal
                            : _bundelSoalProvider.soal.idSoal,
                        tipeSoal: (widget.isPaket)
                            ? _paketSoalProvider.soal.tipeSoal
                            : _bundelSoalProvider.soal.tipeSoal,
                        kunciJawaban: (widget.isPaket)
                            ? _paketSoalProvider.soal.kunciJawaban
                            : _bundelSoalProvider.soal.kunciJawaban,
                        idVideo: (widget.isPaket)
                            ? _paketSoalProvider.soal.idVideo
                            : _bundelSoalProvider.soal.idVideo,
                        userData: userData,
                        baseUrlVideo: dotenv.env['BASE_URL_VIDEO_SOAL'],
                      ),
                    ],
                  ],
          ),
        ),
      ],
    );
  }

  // void _saveLog() {
  //   if (!userData.isLogin || userData.isOrtu) {
  //     return;
  //   } else {
  //     String? jenisProduk;
  //     switch (widget.idJenisProduk) {
  //       case 65:
  //         jenisProduk = 'VAK';
  //         break;
  //       case 71:
  //         jenisProduk = 'Empati Mandiri';
  //         break;
  //       case 72:
  //         jenisProduk = 'Empati Wajib';
  //         break;
  //       case 76:
  //         jenisProduk = 'Latihan Extra';
  //         break;
  //       case 77:
  //         jenisProduk = 'Paket Intensif';
  //         break;
  //       case 78:
  //         jenisProduk = 'Paket Soal Koding';
  //         break;
  //       case 79:
  //         jenisProduk = 'Pendalaman Materi';
  //         break;
  //       case 82:
  //         jenisProduk = 'Soal Referensi';
  //         break;
  //       default:
  //         break;
  //     }
  //     gNavigatorKey.currentContext!.read<LogProvider>().saveLog(
  //           userId: gNoRegistrasi,
  //           userType: "SISWA",
  //           menu: jenisProduk,
  //           accessType: 'Keluar',
  //           info:
  //               "${(widget.namaKelompokUjian != null) ? widget.namaKelompokUjian : ''}"
  //               "${(widget.namaKelompokUjian != null) ? ', ' : ''}${widget.kodePaket}"
  //               "${(widget.namaBab != null) ? ', ' : ''}"
  //               "${(widget.namaBab != null) ? widget.namaBab : ''}",
  //         );
  //     gNavigatorKey.currentContext!
  //         .read<LogProvider>()
  //         .sendLogActivity("SISWA");
  //     // Navigator.pop(context);
  //   }
  // }

  /// This function is triggered when the user presses the back-to-top button
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  bool _isLoading() => (widget.isPaket && !_paketSoalProvider.isSoalExist)
      ? true
      : (widget.isPaket)
          ? _paketSoalProvider.isLoadingSoal
          : (_bundelSoalProvider.isSoalExist)
              ? _bundelSoalProvider.isLoadingSoal
              : true;

  bool _isBookmarked() => (_isLoading())
      ? false
      : (widget.isPaket)
          ? _paketSoalProvider.soal.isBookmarked
          : _bundelSoalProvider.soal.isBookmarked;

  /// sudah dikumpulkan [_isSudahDikumpulkan] hanya tertrigger jika success get jawaban
  /// namun berbeda jika emma/emwa juga tertrigger apabila sudah selesai
  bool _isSudahDikumpulkan() => (_isLoading())
      ? false
      : (widget.isPaket)
          ? _paketSoalProvider.soal.sudahDikumpulkan || widget.isKedaluarsa
          : _bundelSoalProvider.soal.sudahDikumpulkan || widget.isKedaluarsa;

  bool _isSudahDikumpulkanSemua() => (_isLoading())
      ? false
      : (widget.isPaket)
          ? _paketSoalProvider.isSudahDikumpulkanSemua(
              kodePaket: widget.kodePaket,
            )
          : _bundelSoalProvider.isSudahDikumpulkanSemua;

  bool _checkKedaluwarsa() {
    if (_isLoading()) return false;
    // Jika bukan paket, akan di anggap sudah kedaluwarsa
    // untuk menampilkan solusi soal.
    // if (!widget.isPaket) return true;
    // Jika paket soal sudah melewati tanggal berlaku,
    // baru siswa dapat melihat solusi-nya.
    // return _paketSoalProvider.serverTime.isAfter(widget.tanggalKedaluwarsa!);
    // Perbaikan 10 Agustus 2023
    // Keputusan rapat memunculkan solusi langsung setelah siswa menyimpan jawaban
    // baik itu EMWA maupun EMMA.
    return true;
  }

  List<Widget> _buildLoadingWidget(BuildContext context) => [
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

  /// NOTE: kumpulan function
  /// [_simpanJawaban] merupakan fungsi untuk menyimpan jawaban siswa.
  /// Soal hanya akan disimpan yang sudah dikerjakan saja, siswa dapat kembali
  /// melanjutkan mengerjakan sisanya nanti.
  Future<bool> _simpanJawaban() async {
    var completer = Completer();
    context.showBlockDialog(dismissCompleter: completer);
    bool isSuccessSubmit = false;
    Map<String, dynamic> result = {};
    if (widget.isPaket) {
      isSuccessSubmit = await _paketSoalProvider.kumpulkanJawabanSiswa(
        isKumpulkan: false,
        tahunAjaran: userData?.tahunAjaran ?? '',
        idSekolahKelas: userData?.idSekolahKelas ?? '14',
        noRegistrasi: userData?.noRegistrasi,
        tipeUser: userData?.siapa,
        idKota: userData?.idKota,
        idGedung: userData?.idGedung,
        idJenisProduk: widget.idJenisProduk,
        namaJenisProduk: widget.namaJenisProduk,
        kodeTOB: widget.kodeTOB,
        kodePaket: widget.kodePaket,
        userData: userData,
      );
    } else {
      result = await _bundelSoalProvider.olahDataJawaban(
        userData: userData,
        kodePaket: widget.kodePaket,
        idJenisProduk: widget.idJenisProduk,
        namaJenisProduk: widget.namaJenisProduk,
        kodeBab: widget.kodeBab,
        idBundle: int.tryParse(_bundelSoalProvider.soal.idBundle ?? '0'),
      );

      isSuccessSubmit = result['success'];
    }

    if (!completer.isCompleted) {
      completer.complete();
    }

    if (!isSuccessSubmit && context.mounted) {
      gShowTopFlash(
        context,
        result['message'],
        dialogType: DialogType.error,
      );
      return isSuccessSubmit;
    } else if (isSuccessSubmit && context.mounted) {
      await gShowTopFlash(
        context,
        'Yeey, Jawaban kamu berhasil disimpan Sobat',
        dialogType: DialogType.success,
      );

      // untuk men-set jawaban yg sudah dikumpulkan
      _bundelSoalProvider.getJawabanSiswaBukuSakti(
        idJenisProduk: widget.idJenisProduk,
        noRegistrasi: userData?.noRegistrasi ?? '',
        idTingkatKelas: userData?.tingkatKelas ?? '',
        tahunAjaran: userData?.tahunAjaran ?? '',
        kodePaket: widget.kodePaket,
        kodeBab: widget.kodeBab,
        opsiUrut: (widget.kodeBab == null)
            ? OpsiUrut.nomor
            : widget.opsiUrutBundel ?? OpsiUrut.bab,
        isBundle: true,
        idBundleSoal: widget.idBundel,
      );
      // _navigator.pop();
      // await Future.delayed(gDelayedNavigation).then(
      //   (_) => _navigator.popUntil(ModalRoute.withName(widget.diBukaDariRoute)),
      // );
    }
    if (!completer.isCompleted) {
      completer.complete();
    }
    return true;
  }

  /// [_kumpulkanJawaban] merupakan fungsi untuk mengumpulkan semua jawaban siswa,
  /// jika soal belum dikerjakan, maka akan dianggap kosong.
  Future<bool> _kumpulkanJawaban() async {
    bool kumpulkanConfirmed = true;
    // bool kumpulkanConfirmed =
    //     (widget.namaJenisProduk != 'e-Empati Wajib') ? false : true;
    // if (widget.namaJenisProduk != 'e-Empati Wajib') {
    //   kumpulkanConfirmed = await _bottomDialog(
    //       title: 'Apakah sobat sudah selesai mengerjakan soal?',
    //       message:
    //           'Kumpulkan jawaban berarti seluruh jawaban akan dikumpulkan, '
    //           'soal-soal yang belum dikerjakan akan dianggap kosong. Kumpulkan sekarang?',
    //       actions: (controller) => [
    //             TextButton(
    //                 onPressed: () => controller.dismiss(false),
    //                 style: TextButton.styleFrom(
    //                     foregroundColor: context.onBackground),
    //                 child: const Text('Nanti Saja')),
    //             ElevatedButton(
    //                 onPressed: () => controller.dismiss(true),
    //                 child: const Text('Kumpulkan')),
    //           ]);
    // }

    if (kumpulkanConfirmed) {
      var completer = Completer();
      // ignore: use_build_context_synchronously
      context.showBlockDialog(dismissCompleter: completer);

      if (widget.isPaket) {
        if (widget.idJenisProduk != 65) {
          Map<String, dynamic> result =
              await _paketSoalProvider.olahDataJawaban(
            userData: userData,
            kodePaket: widget.kodePaket,
            idJenisProduk: widget.idJenisProduk,
            namaJenisProduk: widget.namaJenisProduk,
            kodeBab: widget.kodeBab,
          );

          if (result['success'] && mounted) {
            await gShowTopFlash(
              context,
              'Yeey, Jawaban kamu berhasil dikumpulkan Sobat',
              dialogType: DialogType.success,
            );
          } else if (!result['success'] && mounted) {
            await gShowTopFlash(
              context,
              result['message'],
              dialogType: DialogType.error,
            );
          }
        } else {
          await _paketSoalProvider.kumpulkanJawabanSiswa(
            isKumpulkan: true,
            tahunAjaran: userData?.tahunAjaran ?? '',
            idSekolahKelas: userData?.idSekolahKelas ?? '14',
            noRegistrasi: userData?.noRegistrasi,
            tipeUser: userData?.siapa,
            idKota: userData?.idKota,
            idGedung: userData?.idGedung,
            idJenisProduk: widget.idJenisProduk,
            namaJenisProduk: widget.namaJenisProduk,
            kodeTOB: widget.kodeTOB,
            kodePaket: widget.kodePaket,
            userData: userData,
          );
        }
      }
      // if (widget.namaJenisProduk != 'e-Empati Wajib') {
      //   // final duration = Duration(
      //   //     seconds: 2, milliseconds: gDelayedNavigation.inMilliseconds);
      //   Future.delayed(gDelayedNavigation).then(
      //     (_) => _navigator.popUntil(
      //       ModalRoute.withName(widget.diBukaDariRoute),
      //     ),
      //   );
      // }
      //   Future.delayed(gDelayedNavigation).then(
      //     (_) => _navigator.popUntil(
      //       ModalRoute.withName(widget.diBukaDariRoute),
      //     ),
      //   );

      // untuk men-set jawaban yg sudah dikumpulkan
      _paketSoalProvider.getJawabanSiswaBukuSakti(
        idJenisProduk: widget.idJenisProduk,
        noRegistrasi: userData?.noRegistrasi ?? '',
        idTingkatKelas: userData?.tingkatKelas ?? '',
        tahunAjaran: userData?.tahunAjaran ?? '',
        kodePaket: widget.kodePaket,
      );

      if (!completer.isCompleted) {
        completer.complete();
      }
    }
    return kumpulkanConfirmed;
  }

  /// [_kumpulkanJawabanEmpatiWajib] merupakan fungsi untuk mengumpulkan semua
  /// jawaban siswa dari soal empati wajib, akan muncul bottom dialog untuk memilih
  /// apakah akan menyimpan soal (mengumpulkan hanya yang sudah dikerjakan)
  /// atau mengumpulkan secara menyeluruh.
  // Future<bool> _kumpulkanJawabanEmpatiWajib() async {
  //   if (!widget.isPaket) return true;
  //
  //   bool result = await _bottomDialog(
  //       title: 'Apakah sobat sudah selesai mengerjakan soal?',
  //       message:
  //           '>> Pilih kumpulkan jika Sobat mau mengumpulkan seluruh soal!\n'
  //           '>> Pilih simpan jika Sobat hanya ingin kumpulkan yang sudah dikerjakan saja!',
  //       actions: (controller) => [
  //             TextButton(
  //                 onPressed: () async {
  //                   bool selesai = await _kumpulkanJawaban();
  //                   controller.dismiss(selesai);
  //                 },
  //                 child: const Text('Kumpulkan')),
  //             ElevatedButton(
  //                 onPressed: () async {
  //                   bool selesai = await _simpanJawaban();
  //                   controller.dismiss(selesai);
  //                 },
  //                 child: const Text('Simpan')),
  //           ]);
  //
  //   logger.log('DIALOG RESULT: $result');
  //   return result;
  // }

  Future<void> _bookmarkToggle() async {
    if (widget.isPaket) {
      await _paketSoalProvider.toggleBookmark(
        idJenisProduk: widget.idJenisProduk,
        namaJenisProduk: widget.namaJenisProduk,
        kodeTOB: widget.kodeTOB,
        kodePaket: widget.kodePaket,
        idBundel: widget.idBundel,
        kodeBab: widget.kodeBab,
        namaBab: widget.namaBab,
        tanggalKedaluwarsa: (widget.tanggalKedaluwarsa != null)
            ? DataFormatter.dateTimeToString(widget.tanggalKedaluwarsa!)
            : null,
        isPaket: widget.isPaket,
        isSimpan: widget.isSimpan,
      );
      bookmarkBloc.add(AddBookmark(
          soal: _paketSoalProvider.soal,
          kodeTob: widget.kodeTOB,
          idJenisProduk: widget.idJenisProduk,
          role: userData?.isSiswa ?? false,
          noRegistrasi: userData?.noRegistrasi ?? '',
          namaJenisProduk: widget.namaJenisProduk,
          kodePaket: widget.kodePaket,
          tanggalKedaluwarsa: (widget.tanggalKedaluwarsa != null)
              ? DataFormatter.dateTimeToString(widget.tanggalKedaluwarsa!)
              : '',
          kodeBab: '',
          idBundel: widget.idBundel ?? '0',
          isPaket: true,
          namaBab: '',
          isSimpan: widget.isSimpan));
    } else {
      await _bundelSoalProvider.toggleBookmark(
          idJenisProduk: widget.idJenisProduk,
          namaJenisProduk: widget.namaJenisProduk,
          kodeTOB: widget.kodeTOB,
          kodePaket: widget.kodePaket,
          isPaket: widget.isPaket,
          isSimpan: widget.isSimpan);

      bookmarkBloc.add(AddBookmark(
        soal: _bundelSoalProvider.soal,
        kodeTob: widget.kodeTOB,
        idJenisProduk: widget.idJenisProduk,
        role: userData?.isSiswa ?? false,
        noRegistrasi: userData?.noRegistrasi ?? '',
        namaJenisProduk: widget.namaJenisProduk,
        idBundel: widget.idBundel ?? '0',
        kodeBab: widget.kodeBab ?? '',
        namaBab: widget.namaBab ?? '',
        tanggalKedaluwarsa: (widget.tanggalKedaluwarsa != null)
            ? DataFormatter.dateTimeToString(widget.tanggalKedaluwarsa!)
            : '',
        isPaket: widget.isPaket,
        isSimpan: widget.isSimpan,
        kodePaket: widget.kodePaket,
      ));
    }
  }

  Future<void> _raguRaguToggle(bool? isRagu) async {
    var completer = Completer();
    context.showBlockDialog(dismissCompleter: completer);
    if (widget.isPaket) {
      await _paketSoalProvider.toggleRaguRagu(
        tahunAjaran: userData?.tahunAjaran ?? '',
        idSekolahKelas: userData?.idSekolahKelas ?? '14',
        noRegistrasi: userData?.noRegistrasi,
        tipeUser: userData?.siapa,
        kodePaket: widget.kodePaket,
      );
      completer.complete();
    } else {
      await _bundelSoalProvider.toggleRaguRagu(
        tahunAjaran: userData?.tahunAjaran ?? '',
        idSekolahKelas: userData?.idSekolahKelas ?? '14',
        noRegistrasi: userData?.noRegistrasi,
        tipeUser: userData?.siapa,
        kodePaket: widget.kodePaket,
      );
      completer.complete();
    }
  }

  /// [_onClickSobatTips] akan menampilkan List Bab dan Sub Bab yang terkait dengan soal.
  Future<void> _onClickSobatTips(String idSoal, String idBundel) async {
    bool isBeliLengkap = userData.isProdukDibeliSiswa(59);
    bool isBeliSingkat = userData.isProdukDibeliSiswa(97);
    bool isBeliRingkas = userData.isProdukDibeliSiswa(98);

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(min(32, context.dp(24))),
        ),
      ),
      builder: (context) {
        childWidget ??= SafeArea(
          child: SobatTipsWidget(
            isBeliTeori: isBeliLengkap || isBeliSingkat || isBeliRingkas,
            getSobatTips: (widget.isPaket)
                ? _paketSoalProvider.getSobatTips(
                    idSoal: idSoal,
                    idBundel: idBundel,
                    isBeliLengkap: isBeliLengkap,
                    isBeliSingkat: isBeliSingkat,
                    isBeliRingkas: isBeliRingkas,
                    userData: userData,
                  )
                : _bundelSoalProvider.getSobatTips(
                    idSoal: idSoal,
                    idBundel: idBundel,
                    isBeliLengkap: isBeliLengkap,
                    isBeliSingkat: isBeliSingkat,
                    isBeliRingkas: isBeliRingkas,
                    userData: userData,
                  ),
            userData: userData,
          ),
        );
        return childWidget!;
      },
    );
  }

  void _getSoal({bool isRefresh = false, int? urutan}) {
    // Hack agar terhindar dari unmounted
    Future.delayed(Duration.zero).then((_) async {
      if (widget.isPaket) {
        final paketSoalProvider = context.read<PaketSoalProvider>();
        await paketSoalProvider
            .getDaftarSoal(
          isRefresh: isRefresh,
          isKedaluwarsa: (widget.tanggalKedaluwarsa != null)
              ? DateTime.now()
                  .serverTimeFromOffset
                  .isAfter(widget.tanggalKedaluwarsa!)
              : false,
          jenisProduk: widget.namaJenisProduk,
          isKumpulkan: !widget.isSimpan,
          nomorSoalAwal: widget.mulaiDariSoalNomor,
          kodePaket: widget.kodePaket,
          tahunAjaran: userData?.tahunAjaran ?? '',
          idSekolahKelas: userData?.idSekolahKelas ?? '14',
          noRegistrasi: userData?.noRegistrasi,
          tipeUser: userData?.siapa,
          listIdBundelSoal: widget.listIdBundel ?? [],
          idJenisProduk: widget.idJenisProduk,
          urutan: urutan ?? widget.urutan,
          isBookmarked: widget.isBookmarked,
        )
            .then((_) {
          paketSoalProvider.getJawabanSiswaBukuSakti(
            idJenisProduk: widget.idJenisProduk,
            noRegistrasi: userData?.noRegistrasi ?? '',
            idTingkatKelas: userData?.tingkatKelas ?? '',
            tahunAjaran: userData?.tahunAjaran ?? '',
            kodePaket: widget.kodePaket,
          );
          // if (paketSoalProvider.indexPaket == 1 && widget.isSelesai) {
          //   paketSoalProvider.getJawabanSiswaBukuSakti(
          //     idJenisProduk: widget.idJenisProduk,
          //     noRegistrasi: userData?.noRegistrasi ?? '',
          //     idTingkatKelas: userData?.tingkatKelas ?? '',
          //     tahunAjaran: userData?.tahunAjaran ?? '',
          //     kodePaket: widget.kodePaket,
          //   );
          // } else if (paketSoalProvider.indexSoal == 0) {
          //   paketSoalProvider.getJawabanSiswaByUrutan(
          //     noRegister: userData?.noRegistrasi ?? '',
          //     kodePaket: widget.kodePaket,
          //     tahunAjaran: userData?.tahunAjaran ?? '',
          //     urutan: paketSoalProvider.indexPaket,
          //     idJenisProduk: widget.idJenisProduk,
          //   );
          // }
        });
      } else {
        final bundelSoalProvider = context.read<BundelSoalProvider>();
        await bundelSoalProvider
            .getDaftarSoal(
          isRefresh: isRefresh,
          tahunAjaran: userData?.tahunAjaran ?? '',
          idSekolahKelas: userData?.idSekolahKelas ?? '14',
          noRegistrasi: userData?.noRegistrasi,
          tipeUser: userData?.siapa,
          kodePaket: widget.kodePaket,
          opsiUrut: (widget.kodeBab == null ||
                  widget.kodeBab?.isEmpty == true ||
                  widget.kodeBab == '0')
              ? OpsiUrut.nomor
              : widget.opsiUrutBundel ?? OpsiUrut.bab,
          jenisProduk: widget.namaJenisProduk,
          nomorSoalAwal: widget.mulaiDariSoalNomor,
          kodeBab: widget.kodeBab ?? '',
          idBundel: widget.idBundel!,
          isBookmarked: widget.isBookmarked,
        )
            .then((_) {
          if (bundelSoalProvider.indexPaket == 0) {
            bundelSoalProvider.getJawabanSiswaBukuSakti(
              idJenisProduk: widget.idJenisProduk,
              noRegistrasi: userData?.noRegistrasi ?? '',
              idTingkatKelas: userData?.tingkatKelas ?? '',
              tahunAjaran: userData?.tahunAjaran ?? '',
              kodePaket: widget.kodePaket,
              kodeBab: widget.kodeBab,
              opsiUrut: (widget.kodeBab == null)
                  ? OpsiUrut.nomor
                  : widget.opsiUrutBundel ?? OpsiUrut.bab,
              isBundle: true,
              idBundleSoal: widget.idBundel,
            );
          }
        });
      }
    });
  }

  Future<void> _setTempJawaban(dynamic jawabanSiswa) async {
    SoalProvider provider =
        (widget.isPaket) ? _paketSoalProvider : _bundelSoalProvider;
    if (!provider.soal.validateTipeSoal(jawabanSiswa)) {
      await gShowTopFlash(
        context,
        'Gagal menyimpan jawaban. Coba lagi ya, sobat',
        dialogType: DialogType.error,
      );
      return;
    }

    if (widget.isPaket) {
      await _paketSoalProvider.setTempJawaban(
        tahunAjaran: userData?.tahunAjaran ?? '',
        idSekolahKelas: userData?.idSekolahKelas ?? '14',
        noRegistrasi: userData?.noRegistrasi,
        tipeUser: userData?.siapa,
        kodePaket: widget.kodePaket,
        jenisProduk: widget.namaJenisProduk,
        jawabanSiswa: jawabanSiswa,
        idJenisProduk: widget.idJenisProduk,
      );
    } else {
      await _bundelSoalProvider.setTempJawaban(
        tahunAjaran: userData?.tahunAjaran ?? '',
        idSekolahKelas: userData?.idSekolahKelas ?? '14',
        noRegistrasi: userData?.noRegistrasi,
        tipeUser: userData?.siapa,
        kodePaket: widget.kodePaket,
        jenisProduk: widget.namaJenisProduk,
        jawabanSiswa: jawabanSiswa,
        idJenisProduk: widget.idJenisProduk,
      );
    }
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

  Row _buildTabletView(BuildContext context) {
    return Row(
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
                  Transform.translate(
                    offset: const Offset(-14, 0),
                    child: Row(
                      children: [
                        _buildBookmarkButton(),
                        Expanded(child: _buildAppBarTitle()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBintangDanNomorSoal(),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    child: _buildSubmitButton(),
                  ),
                  Expanded(
                    child: Container(
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
                  top: 50,
                  bottom: 18,
                  right: 24,
                  left: 24,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!_isLoading() && !widget.kodePaket.contains('VAK'))
                        _buildSobatTipsButton(),
                      const Spacer(),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildNextPrevSoal(_isLoading()),
                          _buildBottomNavBar(),
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
    );
  }

  SingleChildScrollView _buildDaftarNomorSoal() {
    return SingleChildScrollView(
      controller: _nomorSoalScrollController,
      child: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: min(18, context.dp(17)),
            vertical: min(24, context.dp(24)),
          ),
          child: Wrap(
            spacing: min(18, context.dp(16)),
            runSpacing: min(18, context.dp(16)),
            children: List.generate(
              (widget.isPaket)
                  ? _paketSoalProvider.jumlahSoal
                  : _bundelSoalProvider.jumlahSoal,
              (index) {
                Color warnaNomor = context.onBackground;
                Color warnaNomorContainer = context.background;
                Color warnaBorder = context.onBackground;
                int totalSoalBefore =
                    (widget.idJenisProduk == 71 || widget.idJenisProduk == 72)
                        ? _paketSoalProvider.totalSoalBefore(widget.kodePaket)
                        : 0;
                int nomorSoal =
                    (widget.idJenisProduk == 71 || widget.idJenisProduk == 72)
                        ? index + 1 + totalSoalBefore
                        : (widget.isPaket)
                            ? _paketSoalProvider
                                .getSoalByIndex(index)
                                .nomorSoalSiswa
                            : _bundelSoalProvider
                                .getSoalByIndex(index)
                                .nomorSoalSiswa;
                int indexNomorSoal = (widget.isPaket)
                    ? _paketSoalProvider.indexSoal
                    : _bundelSoalProvider.indexSoal;

                // Bool value
                bool isRagu = (widget.isPaket)
                    ? _paketSoalProvider.getSoalByIndex(index).isRagu
                    : _bundelSoalProvider.getSoalByIndex(index).isRagu;
                bool isSudahDikumpulkan = (widget.isPaket)
                    ? _paketSoalProvider.getSoalByIndex(index).sudahDikumpulkan
                    : _bundelSoalProvider
                        .getSoalByIndex(index)
                        .sudahDikumpulkan;
                dynamic jawabanSiswa = (widget.isPaket)
                    ? _paketSoalProvider.getSoalByIndex(index).jawabanSiswa
                    : _bundelSoalProvider.getSoalByIndex(index).jawabanSiswa;

                if (jawabanSiswa != null) {
                  warnaNomorContainer = const Color(0xff32CD32);
                }
                if (isRagu && !isSudahDikumpulkan) {
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
                return InkWell(
                  onTap: () {
                    (widget.isPaket)
                        ? _paketSoalProvider.jumpToSoalNomor(index)
                        : _bundelSoalProvider.jumpToSoalNomor(index);

                    if (context.isMobile) {
                      Navigator.pop(context);
                    }

                    _scrollToTop();
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
                          color: warnaNomorContainer),
                      child: FittedBox(
                        child: Text('$nomorSoal',
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

  /// NOTE: kumpulan Widget

  Widget _buildBookmarkButton() {
    bool isBookmarked = (_isLoading())
        ? false
        : (widget.isPaket)
            ? _paketSoalProvider.soal.isBookmarked
            : _bundelSoalProvider.soal.isBookmarked;

    return widget.isBisaBookmark
        ? IconButton(
            onPressed: (_isLoading() || isBookmarked) ? null : _bookmarkToggle,
            icon: Icon(
              (!_isLoading() && _isBookmarked())
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: context.onPrimary,
            ),
          )
        : SizedBox(width: min(16, context.dp(14)));
  }

  AppBar _buildAppBar() => AppBar(
        elevation: 0,
        titleSpacing: 0,
        toolbarHeight: 60,
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        leadingWidth: widget.isBisaBookmark ? null : context.dp(14),
        leading: _buildBookmarkButton(),
        title: _buildAppBarTitle(),
        bottom: _buildBintangDanNomorSoal(),
        actions: [
          Padding(
              padding: EdgeInsets.only(
                top: context.dp(12),
                left: context.dp(12),
                right: context.dp(14),
              ),
              child: _buildSubmitButton()),
        ],
      );

  /// tombol [_buildSubmitButton] akan selalu terlihat jika bundle soal
  /// namun jika emma dan emwa akan terlihat di akhir soal dari paket
  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: (_isLoading() || _isSudahDikumpulkan())
          ? null
          :

          /// temporary hardcode submit soal basic
          // (widget.namaJenisProduk == 'e-Empati Wajib')
          //     ? () async {
          //         // submit emwa
          //         bool isSubmitJawaban = await _kumpulkanJawabanEmpatiWajib();

          //         logger.log('IS SUBMIT JAWABAN: $isSubmitJawaban');
          //         if (isSubmitJawaban) {
          //           // final duration = Duration(
          //           //     seconds: 2,
          //           //     milliseconds: gDelayedNavigation.inMilliseconds);
          //           await Future.delayed(gDelayedNavigation).then(
          //             (_) => _navigator.popUntil(
          //                 ModalRoute.withName(widget.diBukaDariRoute)),
          //           );
          //         }
          //       }
          //     :
          widget.isSimpan
              // submit bundle
              ? () async => await _simpanJawaban()
              // submit emwa, vak, emma
              : () async => await _kumpulkanJawaban(),
      style: ElevatedButton.styleFrom(
        backgroundColor: context.secondaryColor,
        foregroundColor: context.onSecondary,
        minimumSize:
            (context.isMobile) ? Size(context.dp(90), context.dp(64)) : null,
        padding: (context.isMobile)
            ? null
            : const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        textStyle: context.text.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.dp(8)),
        ),
      ),
      child: Text(widget.isSimpan ? 'Simpan' : 'Kumpulkan',
          textAlign: TextAlign.center),
    );
  }

  Column _buildAppBarTitle() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          (_isLoading())
              ? ShimmerWidget(
                  width: min(82, context.dp(65)),
                  height: min(32, context.dp(20)))
              : Text(
                  (widget.isPaket || (widget.opsiUrutBundel == OpsiUrut.nomor))
                      ? widget.kodePaket
                      : widget.namaKelompokUjian!,
                  style: context.text.labelLarge?.copyWith(
                    color: context.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          (_isLoading())
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: ShimmerWidget(
                      width: min(140, context.dp(100)),
                      height: min(20, context.dp(14))),
                )
              : Text(
                  (widget.idJenisProduk == 71 || widget.idJenisProduk == 72)
                      ? (_paketSoalProvider
                              .getCurrentMataUji(widget.kodePaket)
                              ?.namaKelompokUjian ??
                          '')
                      : widget.isPaket
                          ? _paketSoalProvider.soal.namaKelompokUjian
                          : (widget.opsiUrutBundel == OpsiUrut.nomor ||
                                  widget.namaBab == null)
                              ? _bundelSoalProvider.soal.namaKelompokUjian
                              : 'Bab ${widget.namaBab}',
                  style: context.text.labelSmall
                      ?.copyWith(color: context.onPrimary))
        ],
      );

  PreferredSize _buildBintangDanNomorSoal() {
    int totalSoalBefore =
        (widget.idJenisProduk == 71 || widget.idJenisProduk == 72)
            ? _paketSoalProvider.totalSoalBefore(widget.kodePaket)
            : 0;

    Widget numberingWidget = (_isLoading())
        ? ShimmerWidget.rounded(
            width: context.dp(30),
            height: context.dp(8),
            borderRadius: BorderRadius.circular(8),
          )
        : Text(
            'No ${(widget.idJenisProduk == 71 || widget.idJenisProduk == 72) ? _paketSoalProvider.indexSoal + 1 + totalSoalBefore : (widget.isPaket) ? _paketSoalProvider.soal.nomorSoalSiswa : _bundelSoalProvider.soal.nomorSoalSiswa}'
            '/${(widget.idJenisProduk == 71 || widget.idJenisProduk == 72) ? widget.jumlahSoalPaket : (widget.isPaket) ? _paketSoalProvider.jumlahSoal : _bundelSoalProvider.jumlahSoal}',
            style: (context.isMobile)
                ? null
                : const TextStyle(
                    color: Colors.white,
                  ),
          );
    return PreferredSize(
      preferredSize: Size(context.dw, context.dp(80)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: (context.isMobile) ? context.dp(14) : 0),
            child: Row(
              children: [
                ..._buildTingkatKesulitanSoal((_isLoading())
                    ? 0
                    : (widget.isPaket)
                        ? _paketSoalProvider.soal.tingkatKesulitan
                        : _bundelSoalProvider.soal.tingkatKesulitan),
                const Spacer(),
                if (context.isMobile) ...[
                  TextButton.icon(
                    onPressed: _onClickNomorSoal,
                    icon: const Icon(Icons.arrow_drop_down_sharp),
                    label: numberingWidget,
                    style: TextButton.styleFrom(
                        foregroundColor: context.onPrimary,
                        padding: EdgeInsets.zero,
                        textStyle: context.text.titleMedium,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                  )
                ] else ...[
                  numberingWidget,
                ],
              ],
            ),
          ),
          if (context.isMobile) ...[_buildRunningTextHakCipta()],
        ],
      ),
    );
  }

  List<Widget> _buildTingkatKesulitanSoal(int tingkatKesulitan) =>
      List.generate(
        5,
        (index) => Icon(
          index < tingkatKesulitan
              ? Icons.star_rounded
              : Icons.star_border_rounded,
          size: (context.isMobile) ? 28 : 32,
          color: context.onPrimary,
        ),
      );

  Widget _buildWacanaWidget() {
    bool wacanaExist = (widget.isPaket)
        ? _paketSoalProvider.soal.wacana != null
        : _bundelSoalProvider.soal.wacana != null;

    String? wacana = (!wacanaExist)
        ? null
        : (widget.isPaket)
            ? _paketSoalProvider.soal.wacana
            : _bundelSoalProvider.soal.wacana;

    return (!wacanaExist || wacana == null)
        ? const SizedBox.shrink()
        : Padding(
            padding: EdgeInsets.symmetric(horizontal: context.dp(8)),
            child: (wacana.contains('table'))
                ? WidgetFromHtml(htmlString: wacana)
                : CustomHtml(htmlString: wacana),
          );
  }

  Widget _buildSoalWidget() {
    String textSoal = (widget.isPaket)
        ? _paketSoalProvider.soal.textSoal
        : _bundelSoalProvider.soal.textSoal;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.dp(8)),
      child: (textSoal.contains('table'))
          ? WidgetFromHtml(htmlString: textSoal)
          : CustomHtml(htmlString: textSoal),
    );
  }

  Widget _buildSobatTipsButton() => Row(
        children: [
          const Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: (context.isMobile) ? 25 : 0,
              vertical: 10,
            ),
            child: ElevatedButton(
              onPressed: () => _onClickSobatTips(
                (widget.isPaket)
                    ? _paketSoalProvider.soal.idSoal
                    : _bundelSoalProvider.soal.idSoal,
                (widget.isPaket)
                    ? _paketSoalProvider.soal.idBundle!
                    : widget.idBundel!,
              ),
              style: ElevatedButton.styleFrom(
                elevation: 5,
                textStyle: context.text.labelMedium,
                backgroundColor: context.secondaryColor,
                foregroundColor: context.onSecondary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(300)),
                padding: EdgeInsets.symmetric(
                  horizontal: min(24, context.dp(8)),
                  vertical: min(16, context.dp(4)),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Sobat Tips',
                    style: TextStyle(fontSize: 10),
                  ),
                  SizedBox(width: min(16, context.dp(8))),
                  const Icon(
                    Icons.help_outline_rounded,
                    size: 15,
                  )
                ],
              ),
            ),
          ),
        ],
      );

  Container _buildBottomNavBar() => Container(
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
            if (!_isSudahDikumpulkan())
              Checkbox(
                value: (_isLoading())
                    ? false
                    : (widget.isPaket)
                        ? _paketSoalProvider.soal.isRagu
                        : _bundelSoalProvider.soal.isRagu,
                onChanged: (_isLoading()) ? null : _raguRaguToggle,
                activeColor: context.secondaryColor,
                checkColor: context.onSecondary,
              ),
            if (!_isSudahDikumpulkan())
              Text(
                'Ragu',
                style: (context.isMobile)
                    ? context.text.labelLarge
                    : context.text.labelMedium,
              ),
            const Spacer(),
            (_isLoading())
                ? ShimmerWidget.rounded(
                    width: context.dp(24),
                    height: context.dp(24),
                    borderRadius: BorderRadius.circular(context.dp(8)),
                  )
                : IconButton(
                    onPressed: ((widget.isPaket)
                            ? _paketSoalProvider.isFirstSoal
                            : _bundelSoalProvider.isFirstSoal)
                        ? null
                        : () {
                            if (widget.isPaket) {
                              _paketSoalProvider.setPrevSoal(
                                noRegister: userData?.noRegistrasi ?? '',
                                tahunAjaran: userData?.tahunAjaran ?? '',
                                idJenisProduk: widget.idJenisProduk,
                              );
                            } else {
                              _bundelSoalProvider.setPrevSoal(
                                noRegister: userData?.noRegistrasi ?? '',
                                tahunAjaran: userData?.tahunAjaran ?? '',
                                idJenisProduk: widget.idJenisProduk,
                              );
                            }
                            _scrollToTop();
                          },
                    icon: const Icon(Icons.chevron_left_rounded)),
            if (_isLoading()) const SizedBox(width: 8),
            (_isLoading())
                ? ShimmerWidget.rounded(
                    width: context.dp(24),
                    height: context.dp(24),
                    borderRadius: BorderRadius.circular(context.dp(8)),
                  )
                : IconButton(
                    onPressed: ((widget.isPaket)
                            ? _paketSoalProvider.isLastSoal
                            : _bundelSoalProvider.isLastSoal)
                        ? null
                        : () {
                            if (widget.isPaket) {
                              _paketSoalProvider.setNextSoal(
                                noRegister: userData?.noRegistrasi ?? '',
                                tahunAjaran: userData?.tahunAjaran ?? '',
                                idJenisProduk: widget.idJenisProduk,
                              );
                            } else {
                              _bundelSoalProvider.setNextSoal(
                                noRegister: userData?.noRegistrasi ?? '',
                                tahunAjaran: userData?.tahunAjaran ?? '',
                                idJenisProduk: widget.idJenisProduk,
                              );
                            }
                            _scrollToTop();
                          },
                    icon: const Icon(Icons.chevron_right_rounded))
          ],
        ),
      );

  Widget _buildJawabanWidget() {
    if (kDebugMode) {
      logger.log('SOAL_BASIC_SCREEN-BuildJawabanWidget: '
          '${(widget.isPaket) ? _paketSoalProvider.soal.jawabanSiswa : _bundelSoalProvider.jsonSoalJawaban}');
    }
    switch ((widget.isPaket)
        ? _paketSoalProvider.soal.tipeSoal
        : _bundelSoalProvider.soal.tipeSoal) {
      case 'PGB':
        Map<String, dynamic> mapData = {};
        if (!widget.isPaket) {
          for (var item in _bundelSoalProvider.jsonSoalJawaban['opsi']) {
            mapData.addAll(item);
          }
        } else {
          for (var item in _paketSoalProvider.jsonSoalJawaban['opsi']) {
            mapData.addAll(item);
          }
        }

        mapData.removeWhere(
            (_, value) => (value['text'] as String).trim().isEmpty);

        return PilihanGandaBerbobot(
          jsonOpsiJawaban: mapData,
          jawabanSebelumnya: (widget.isPaket)
              ? _paketSoalProvider.soal.jawabanSiswa
              : _bundelSoalProvider.soal.jawabanSiswa,
          kunciJawaban: (widget.isPaket)
              ? _paketSoalProvider.soal.kunciJawaban
              : _bundelSoalProvider.soal.kunciJawaban,
          isBolehLihatKunci:
              _isSudahDikumpulkan() && widget.idJenisProduk != 65,
          onClickPilihJawaban: _isSudahDikumpulkan()
              ? null
              : (pilihanJawaban) async => await _setTempJawaban(pilihanJawaban),
        );
      case 'PBK':
        List<String>? jawabanSiswaSebelumnya, kunciJawaban;
        List<dynamic>? jawabanSiswa = (widget.isPaket)
            ? _paketSoalProvider.soal.jawabanSiswa
            : _bundelSoalProvider.soal.jawabanSiswa;
        List<dynamic>? kunci = (widget.isPaket)
            ? _paketSoalProvider.soal.kunciJawaban
            : _bundelSoalProvider.soal.kunciJawaban;
        if (jawabanSiswa != null && jawabanSiswa.isNotEmpty) {
          jawabanSiswaSebelumnya = jawabanSiswa.cast<String>();
        }
        if (kunci != null && kunci.isNotEmpty) {
          kunciJawaban = kunci.cast<String>();
        }
        Map<String, dynamic> mapData = {};
        if (!widget.isPaket) {
          for (var item in _bundelSoalProvider.jsonSoalJawaban['opsi']) {
            mapData.addAll(item);
          }
        } else {
          for (var item in _paketSoalProvider.jsonSoalJawaban['opsi']) {
            mapData.addAll(item);
          }
        }

        return PilihanBergandaKompleks(
          jsonOpsiJawaban: mapData,
          jawabanSebelumnya: jawabanSiswaSebelumnya,
          kunciJawaban: kunciJawaban,
          max: (widget.isPaket)
              ? _paketSoalProvider.jsonSoalJawaban['kunci'].length
              : _bundelSoalProvider.jsonSoalJawaban['kunci'].length,
          isBolehLihatKunci:
              _isSudahDikumpulkan() && widget.idJenisProduk != 65,
          onClickPilihJawaban: _isSudahDikumpulkan()
              ? null
              : (listPilihanJawaban) async =>
                  await _setTempJawaban(listPilihanJawaban),
        );
      case 'PBCT':
        List<String>? jawabanSiswaSebelumnya, kunciJawaban;
        List<dynamic>? jawabanSiswa = (widget.isPaket)
            ? _paketSoalProvider.soal.jawabanSiswa
            : _bundelSoalProvider.soal.jawabanSiswa;
        List<dynamic>? kunci = (widget.isPaket)
            ? _paketSoalProvider.soal.kunciJawaban
            : _bundelSoalProvider.soal.kunciJawaban;

        if (jawabanSiswa != null && jawabanSiswa.isNotEmpty) {
          jawabanSiswaSebelumnya = jawabanSiswa.cast<String>();
        }
        if (kunci != null && kunci.isNotEmpty) {
          kunciJawaban = kunci.cast<String>();
        }
        Map<String, dynamic> jsonSoalJawaban = {};
        if (widget.isPaket) {
          for (var item in _paketSoalProvider.jsonSoalJawaban['opsi']) {
            jsonSoalJawaban.addAll(item);
          }
        } else {
          for (var item in _bundelSoalProvider.jsonSoalJawaban['opsi']) {
            jsonSoalJawaban.addAll(item);
          }
        }

        return PilihanBergandaComplexTerbatas(
          jsonOpsiJawaban: jsonSoalJawaban,
          jawabanSebelumnya: jawabanSiswaSebelumnya,
          kunciJawaban: kunciJawaban,
          max: (widget.isPaket)
              ? _paketSoalProvider.jsonSoalJawaban['max']
              : _bundelSoalProvider.jsonSoalJawaban['max'],
          isBolehLihatKunci:
              _isSudahDikumpulkan() && widget.idJenisProduk != 65,
          onClickPilihJawaban: _isSudahDikumpulkan()
              ? null
              : (listPilihanJawaban) async =>
                  await _setTempJawaban(listPilihanJawaban),
        );
      case 'PBM':
        List<int>? jawabanSiswaSebelumnya;
        List<dynamic>? jawabanSiswa = (widget.isPaket)
            ? _paketSoalProvider.soal.jawabanSiswa
            : _bundelSoalProvider.soal.jawabanSiswa;

        if (jawabanSiswa != null && jawabanSiswa.isNotEmpty) {
          jawabanSiswaSebelumnya = jawabanSiswa.cast<int>();
        }

        return PilihanBergandaMemasangkan(
          jsonPernyataanOpsi: (widget.isPaket)
              ? _paketSoalProvider.jsonSoalJawaban
              : _bundelSoalProvider.jsonSoalJawaban,
          jawabanSebelumnya: jawabanSiswaSebelumnya,
          onSimpanJawaban: _isSudahDikumpulkan()
              ? null
              : (listJawaban) async => await _setTempJawaban(listJawaban),
        );
      case 'PBT':
        List<int>? jawabanSiswaSebelumnya;
        List<int> kunciJawabanCast = [];
        List<dynamic>? jawabanSiswa = (widget.isPaket)
            ? _paketSoalProvider.soal.jawabanSiswa
            : _bundelSoalProvider.soal.jawabanSiswa;
        List? kunciJawaban = (widget.isPaket)
            ? _paketSoalProvider.soal.kunciJawaban
            : _bundelSoalProvider.soal.kunciJawaban;

        if (jawabanSiswa != null && jawabanSiswa.isNotEmpty) {
          jawabanSiswaSebelumnya = jawabanSiswa.cast<int>();
        }
        if (kunciJawaban != null && kunciJawaban.isNotEmpty) {
          kunciJawabanCast = kunciJawaban.cast<int>();
        }
        return PilihanBergandaTabel(
          jsonTabelJawaban: (widget.isPaket)
              ? _paketSoalProvider.jsonSoalJawaban
              : _bundelSoalProvider.jsonSoalJawaban,
          jawabanSebelumnya: jawabanSiswaSebelumnya,
          // Jika produk merupakan VAK tidak perlu bisa melihat solusi.
          bolehLihatSolusi: _isSudahDikumpulkan() && widget.idJenisProduk != 65,
          kunciJawaban: kunciJawabanCast,
          onSelectJawaban: _isSudahDikumpulkan()
              ? null
              : (listJawaban) async => await _setTempJawaban(listJawaban),
        );
      case 'PBB':
        Map? jawabanSiswa = (widget.isPaket)
            ? _paketSoalProvider.soal.jawabanSiswa
            : _bundelSoalProvider.soal.jawabanSiswa;

        return PilihanBergandaBercabang(
          jsonOpsiJawaban: (widget.isPaket)
              ? _paketSoalProvider.jsonSoalJawaban
              : _bundelSoalProvider.jsonSoalJawaban,
          jawabanSebelumnya: (jawabanSiswa != null)
              ? Map<String, dynamic>.from(jawabanSiswa)
              : null,
          onSimpanJawaban: _isSudahDikumpulkan()
              ? null
              : (jawabanAlasan) async => await _setTempJawaban(jawabanAlasan),
        );
      case 'ESSAY':
        return JawabanEssay(
          soalProvider:
              (widget.isPaket) ? _paketSoalProvider : _bundelSoalProvider,
          nomorSoal: (widget.isPaket)
              ? _paketSoalProvider.soal.nomorSoal
              : _bundelSoalProvider.soal.nomorSoal,
          onSimpanJawaban: _isSudahDikumpulkan()
              ? null
              : (isiJawaban) async => await _setTempJawaban(isiJawaban),
        );
      case 'ESSAY MAJEMUK':
        return JawabanEssayMajemuk(
          soalProvider:
              (widget.isPaket) ? _paketSoalProvider : _bundelSoalProvider,
          nomorSoal: (widget.isPaket)
              ? _paketSoalProvider.soal.nomorSoal
              : _bundelSoalProvider.soal.nomorSoal,
          jsonSoalJawaban: (widget.isPaket)
              ? _paketSoalProvider.jsonSoalJawaban
              : _bundelSoalProvider.jsonSoalJawaban,
          onSimpanJawaban: _isSudahDikumpulkan()
              ? null
              : (isiJawaban) async => await _setTempJawaban(isiJawaban),
        );
      default:
        return PilihanBergandaSederhana(
          jsonOpsiJawaban: (widget.isPaket)
              ? _paketSoalProvider.jsonSoalJawaban
              : _bundelSoalProvider.jsonSoalJawaban,
          jawabanSebelumnya: (widget.isPaket)
              ? _paketSoalProvider.soal.jawabanSiswa
              : _bundelSoalProvider.soal.jawabanSiswa,
          kunciJawaban: (widget.isPaket)
              ? _paketSoalProvider.soal.kunciJawaban
              : _bundelSoalProvider.soal.kunciJawaban,
          isBolehLihatKunci:
              _isSudahDikumpulkan() && widget.idJenisProduk != 65,
          onClickPilihJawaban: _isSudahDikumpulkan()
              ? null
              : (pilihanJawaban) async => _setTempJawaban(pilihanJawaban),
        );
    }
  }

  // Future<bool> _bottomDialog(
  //     {String title = 'Go Expert',
  //     required String message,
  //     List<Widget> Function(FlashController controller)? actions}) async {
  //   if (gPreviousBottomDialog?.isDisposed == false) {
  //     gPreviousBottomDialog?.dismiss(false);
  //   }
  //   gPreviousBottomDialog = DefaultFlashController<bool>(
  //     context,
  //     persistent: true,
  //     barrierColor: Colors.black12,
  //     barrierBlur: 0,
  //     barrierDismissible: true,
  //     onBarrierTap: () => Future.value(false),
  //     barrierCurve: Curves.easeInOutCubic,
  //     transitionDuration: const Duration(milliseconds: 300),
  //     builder: (context, controller) {
  //       return DefaultTextStyle(
  //         style: TextStyle(color: context.onBackground),
  //         child: FlashBar(
  //           useSafeArea: true,
  //           controller: controller,
  //           shape: const RoundedRectangleBorder(
  //             borderRadius: BorderRadius.all(Radius.circular(24)),
  //           ),
  //           clipBehavior: Clip.hardEdge,
  //           margin: (context.isMobile)
  //               ? const EdgeInsets.all(14)
  //               : EdgeInsets.symmetric(
  //                   horizontal: context.dw * .2,
  //                 ),
  //           backgroundColor: context.background,
  //           title: Text(title),
  //           content: Text(message),
  //           titleTextStyle: context.text.titleMedium,
  //           contentTextStyle: context.text.bodySmall,
  //           indicatorColor: context.secondaryColor,
  //           icon: const Icon(Icons.info_outline),
  //           actions: (actions != null)
  //               ? actions(controller)
  //               : [
  //                   TextButton(
  //                       onPressed: () => controller.dismiss(false),
  //                       style: TextButton.styleFrom(
  //                           foregroundColor: context.onBackground),
  //                       child: const Text('Mengerti'))
  //                 ],
  //         ),
  //       );
  //     },
  //   );

  //   bool? result = await gPreviousBottomDialog?.show();

  //   return result ?? false;
  // }

  Future<void> _onClickNextKelompokUjian({
    required int urutan,
  }) async {
    var completer = Completer();
    context.showBlockDialog(dismissCompleter: completer);
    if (widget.idJenisProduk == 65) {
      await _paketSoalProvider.olahDataJawaban(
        namaJenisProduk: widget.namaJenisProduk,
        userData: userData,
        kodePaket: widget.kodePaket,
        idJenisProduk: widget.idJenisProduk,
        kodeBab: widget.kodeBab,
      );
    }

    _getSoal(urutan: urutan);

    _scrollToTop();
    completer.complete();
  }

  Widget _buildNextPrevSoal(bool isLoading) {
    return Padding(
      padding: EdgeInsets.only(
        left: (context.isMobile) ? 35 : 0,
        right: 8,
        bottom: (context.isMobile) ? 0 : 30,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          (!isLoading &&
                  _paketSoalProvider.getMataUjiSebelumnya(widget.kodePaket) !=
                      null)
              ? GestureDetector(
                  onTap: () {
                    _onClickNextKelompokUjian(
                        urutan: _paketSoalProvider.indexPaket -= 1);
                  },
                  child: Container(
                    width: 120,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
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
                          style: context.text.labelSmall,
                          children: [
                            TextSpan(
                                text: _paketSoalProvider
                                    .getMataUjiSebelumnya(widget.kodePaket)!
                                    .namaKelompokUjian,
                                style: context.text.labelMedium?.copyWith(
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
                  _paketSoalProvider.getMataUjiSelanjutnya(widget.kodePaket) !=
                      null)
              ? GestureDetector(
                  onTap: () {
                    _onClickNextKelompokUjian(
                        urutan: _paketSoalProvider.indexPaket += 1);
                  },
                  child: Container(
                    width: 120,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
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
                          style: context.text.labelSmall,
                          children: [
                            TextSpan(
                                text: _paketSoalProvider
                                    .getMataUjiSelanjutnya(widget.kodePaket)!
                                    .namaKelompokUjian,
                                style: context.text.labelMedium?.copyWith(
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
      'soalProvider':
          (widget.isPaket) ? _paketSoalProvider : _bundelSoalProvider,
      'noRegistrasi': userData?.noRegistrasi ?? '',
      'idJenisProduk': widget.idJenisProduk,
      'namaJenisProduk': widget.namaJenisProduk,
      'idSoal': int.parse(
          ((widget.isPaket) ? _paketSoalProvider : _bundelSoalProvider)
              .soal
              .idSoal),
      'idBundel': int.parse(widget.idBundel ?? '0'),
      'kodePaket': widget.kodePaket,
      'stackTrace': '-',
    });
  }

  Widget _buildReportProblem() {
    final soalProvider =
        (widget.isPaket) ? _paketSoalProvider : _bundelSoalProvider;
    bool isReportSubmitted = soalProvider.soal.isReportSubmitted;
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

  Widget _buildRunningTextHakCipta() => ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: context.dw,
          maxHeight: 40,
        ),
        child: Visibility(
          visible: !_isLoading(),
          child: Container(
            color: (context.isMobile) ? Colors.transparent : context.primaryColor,
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
