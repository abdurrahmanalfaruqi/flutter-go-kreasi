import 'dart:io';

import 'package:connection_notifier/connection_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/core/shared/bloc/log_bloc.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/pilih_anak/pilih_anak_bloc.dart';
import 'package:gokreasi_new/features/home/presentation/bloc/home/home_bloc.dart';
import 'package:gokreasi_new/features/jadwal/presentation/bloc/jadwal_kbm/jadwal_kbm_bloc.dart';
import 'package:gokreasi_new/features/jadwal/presentation/bloc/scan_qr/scan_qr_bloc.dart';
import 'package:gokreasi_new/features/laporan/module/aktivitas/presentation/bloc/laporan_aktivitas/laporan_aktivitas_bloc.dart';
import 'package:gokreasi_new/features/laporan/module/presensi/presentation/bloc/laporan_presensi/presensi_bloc.dart';
import 'package:gokreasi_new/features/laporan/module/quiz/presentation/bloc/laporan_kuis/laporan_kuis_bloc.dart';
import 'package:gokreasi_new/features/laporan/module/tobk/presentation/bloc/laporan_tobk/laporan_tobk_bloc.dart';
import 'package:gokreasi_new/features/laporan/module/vak/presentation/bloc/laporan_vak/laporan_vak_bloc.dart';
import 'package:gokreasi_new/features/leaderboard/leaderboardracing/presentation/bloc/leaderboard_racing/leaderboard_racing_bloc.dart';
import 'package:gokreasi_new/features/leaderboard/presentation/bloc/capaian/capaian_bloc.dart';
import 'package:gokreasi_new/features/leaderboard/presentation/bloc/capaian_button/capaian_button_bloc.dart';
import 'package:gokreasi_new/features/leaderboard/presentation/bloc/capaianbar/capaianbar_bloc.dart';
import 'package:gokreasi_new/features/leaderboard/presentation/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:gokreasi_new/features/profile/presentation/bloc/profile/profile_bloc.dart';
import 'package:gokreasi_new/features/profile/presentation/bloc/tata_tertib/tata_tertib_bloc.dart';
import 'package:gokreasi_new/features/ptn/module/simulasi/presentation/bloc/simulasi/simulasi_bloc.dart';
import 'package:gokreasi_new/features/rencanabelajar/presentation/bloc/rencana_belajar/rencana_belajar_bloc.dart';
import 'package:gokreasi_new/features/soal/module/bundel_soal/presentation/bloc/bundel_soal/bundel_soal_bloc.dart';
import 'package:gokreasi_new/features/soal/module/paket_soal/presentation/bloc/paket_soal/paket_soal_bloc.dart';
import 'package:gokreasi_new/core/helper/kreasi_shared_pref.dart';
import 'package:gokreasi_new/features/berita/presentation/bloc/news_bloc.dart';
import 'package:gokreasi_new/features/bookmark/domain/entity/bookmark.dart';
import 'package:gokreasi_new/features/bookmark/presentation/bloc/bookmark_bloc.dart';
import 'package:gokreasi_new/features/buku/presentation/bloc/buku/buku_bloc.dart';
import 'package:gokreasi_new/features/buku/presentation/bloc/teori_content/teori_content_bloc.dart';
import 'package:gokreasi_new/features/feedback/presentation/bloc/feedback_bloc.dart';
import 'package:gokreasi_new/features/home/presentation/bloc/carousel/carousel_bloc.dart';
import 'package:gokreasi_new/features/home/presentation/bloc/pembayaran/pembayaran_bloc.dart';
import 'package:gokreasi_new/features/home/presentation/bloc/ptn/ptn_bloc.dart';
import 'package:gokreasi_new/features/jadwal/presentation/bloc/jadwal/jadwal_bloc.dart';
import 'package:gokreasi_new/features/jadwal/presentation/bloc/standby/standby_bloc.dart';
import 'package:gokreasi_new/features/profile/domain/entity/kelompok_ujian.dart';
import 'package:gokreasi_new/features/profile/domain/entity/scanner_type.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/presentation/bloc/laporan_goa/laporan_goa_bloc.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/presentation/bloc/laporan_jawaban_tobk/laporan_jawaban_bloc.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/presentation/bloc/tobk/tobk_bloc.dart';
import 'package:gokreasi_new/features/soal/presentation/bloc/soal_bloc/soal_bloc.dart';
import 'package:gokreasi_new/features/video/presentation/bloc/jadwal_video_teori/jadwal_video_teori_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart' show FlutterNativeSplash;
import 'package:requests_inspector/requests_inspector.dart';
import 'package:upgrader/upgrader.dart';
import './core/util/injector.dart' as di;

import 'core/config/route.dart';
import 'core/config/theme.dart';
import 'core/config/global.dart';
import 'core/config/extensions.dart';
import 'core/shared/screen/splash_screen.dart';
import 'features/soal/entity/detail_jawaban.dart';
import 'core/shared/widget/image/logo_image_widget.dart';
import 'features/soal/presentation/provider/solusi_provider.dart';
import 'features/video/presentation/provider/video_provider.dart';
import 'features/ptn/module/ptnclopedia/entity/kampus_impian.dart';
import 'features/profile/presentation/provider/profile_provider.dart';
import 'features/kehadiran/presentation/provider/kehadiran_provider.dart';
import 'features/home/presentation/provider/profile_picture_provider.dart';
import 'features/notifikasi/presentation/provider/notifikasi_provider.dart';
import 'features/sosmed/module/feed/presentation/provider/feed_provider.dart';
import 'features/soal/module/timer_soal/presentation/provider/tob_provider.dart';
import 'features/sosmed/module/friends/presentation/provider/friends_provider.dart';
import 'features/rencanabelajar/service/notifikasi/local_notification_service.dart';
import 'features/rencanabelajar/presentation/provider/rencana_belajar_provider.dart';
import 'features/sosmed/module/leaderboard/provider/leaderboard_friends_provider.dart';
import 'features/soal/module/paket_soal/presentation/provider/paket_soal_provider.dart';
import 'features/ptn/module/simulasi/presentation/provider/simulasi_hasil_provider.dart';
import 'features/ptn/module/simulasi/presentation/provider/simulasi_nilai_provider.dart';
import 'features/laporan/module/tobk/presentation/provider/laporan_tryout_provider.dart';
import 'features/soal/module/bundel_soal/presentation/provider/bundel_soal_provider.dart';
import 'features/ptn/module/simulasi/presentation/provider/simulasi_pilihan_provider.dart';

void main() async {
  // Untuk membuat Splash Screen tetap berjalan, hingga diberhentikan.
  WidgetsFlutterBinding.ensureInitialized();

  // Only call clearSavedSettings() during testing to reset internal values.
  await Upgrader.clearSavedSettings();

  // Setting status bar transparent dan Device Orientation
  gSetStatusBarColor();
  // gSetDeviceOrientations();

  //inisialisasi notifikasi :

  await LocalNotificationService().init();
  // LocalNotificationService().requestIOSPermissions;

  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // const option = FirebaseOptions(
  //   projectId: '-',
  //   messagingSenderId: '-',
  //   apiKey: '-',
  //   appId: '-',
  // );

  // await Firebase.initializeApp(name: 'NameApp_Firebase', options: option);
  await _storagePermission();
  // Initialized Hive
  await Hive.initFlutter();
  _registerHiveAdapter();

  // Http Overrides
  HttpOverrides.global = MyHttpOverrides();

  // To load the .env file contents into dotenv.
  await dotenv.load(fileName: ".env");

  await KreasiSharedPref().init();
  di.init();

  //...run app
  runApp(const RequestsInspector(
    enabled: kDebugMode,
    showInspectorOn: ShowInspectorOn.Both,
    child: MyApp(),
  ));
}

Future<void> _storagePermission() async {
  await gRequestPermission(
    Permission.storage,
    withDialog: false,
    title: 'Storage Permission',
    message: 'GO Expert membutuhkan akses ke penyimpanan, sobat',
  );
}

void _registerHiveAdapter() {
  Hive.registerAdapter(DetailJawabanAdapter());
  Hive.registerAdapter(BookmarkMapelAdapter());
  Hive.registerAdapter(BookmarkSoalAdapter());
  Hive.registerAdapter(ScannerTypeAdapter());
  Hive.registerAdapter(KelompokUjianAdapter());
  Hive.registerAdapter(KampusImpianAdapter());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  // final LocalNotificationService _notificationService = LocalNotificationService();

  @override
  void initState() {
    super.initState();
    gNavigatorKey = _navigatorKey;
    // if (gPayload.isNotEmpty) {
    //   _notificationService.bukaScreen();
    // }
    // HiveHelper.openBox<KampusImpian>(boxName: HiveHelper.kKampusImpianBox);
    // HiveHelper.openBox<KampusImpian>(
    //     boxName: HiveHelper.kRiwayatKampusImpianBox);
  }

  @override
  Widget build(BuildContext context) {
    // Kapanpun initialization selesai, menghentikan splash screen:
    // FlutterNativeSplash.remove();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SimulasiPilihanProvider>(
          create: (_) => SimulasiPilihanProvider(),
        ),
        ChangeNotifierProvider<SimulasiNilaiProvider>(
          create: (_) => SimulasiNilaiProvider(),
        ),
        ChangeNotifierProvider<SimulasiHasilProvider>(
          create: (_) => SimulasiHasilProvider(),
        ),
        ChangeNotifierProvider<FeedProvider>(
          create: (_) => FeedProvider(),
        ),
        ChangeNotifierProvider<FriendsProvider>(
          create: (_) => FriendsProvider(),
        ),
        ChangeNotifierProvider<LeaderboardFriendsProvider>(
          create: (_) => LeaderboardFriendsProvider(),
        ),
        ChangeNotifierProvider<RencanaBelajarProvider>(
          create: (_) => RencanaBelajarProvider(),
        ),
        ChangeNotifierProvider<LaporanTryoutProvider>(
          create: (_) => LaporanTryoutProvider(),
        ),
        ChangeNotifierProvider<ProfilePictureProvider>(
          create: (_) => ProfilePictureProvider(),
        ),
        ChangeNotifierProvider<KehadiranProvider>(
          create: (_) => KehadiranProvider(),
        ),
        ChangeNotifierProvider<BundelSoalProvider>(
          create: (_) => BundelSoalProvider(),
        ),
        ChangeNotifierProvider<PaketSoalProvider>(
          create: (_) => PaketSoalProvider(),
        ),
        ChangeNotifierProvider<TOBProvider>(
          create: (_) => TOBProvider(),
        ),
        ChangeNotifierProvider<SolusiProvider>(
          create: (_) => SolusiProvider(),
        ),
        ChangeNotifierProvider<VideoProvider>(
          create: (_) => VideoProvider(),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(),
        ),
        // BlocProvider<DataBloc>(create: (context) => di.locator<DataBloc>()),
        BlocProvider<LogBloc>(create: (context) => LogBloc()),
        BlocProvider<TOBKBloc>(create: (context) => TOBKBloc()),
        BlocProvider<SoalBloc>(create: (context) => SoalBloc()),
        BlocProvider<PtnBloc>(create: (context) => di.locator<PtnBloc>()),
        BlocProvider<LeaderboardBloc>(create: (context) => LeaderboardBloc()),
        BlocProvider<CapaianBloc>(create: (context) => CapaianBloc()),
        BlocProvider<CapaianBarBloc>(create: (context) => CapaianBarBloc()),
        BlocProvider<BookmarkBloc>(create: (context) => di.locator<BookmarkBloc>()),
        BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
        BlocProvider<PaketSoalBloc>(create: (context) => PaketSoalBloc()),
        BlocProvider<BundelSoalBloc>(create: (context) => BundelSoalBloc()),
        BlocProvider<LaporanTobkBloc>(create: (context) => LaporanTobkBloc()),
        BlocProvider<BukuBloc>(create: (context) => BukuBloc()),
        BlocProvider<LaporanJawabanBloc>(create: (context) => LaporanJawabanBloc()),
        BlocProvider<LaporanVakBloc>(create: (context) => LaporanVakBloc()),
        BlocProvider<JadwalVideoTeoriBloc>(create: (context) => JadwalVideoTeoriBloc()),
        BlocProvider<LaporanKuisBloc>(create: (context) => LaporanKuisBloc()),
        BlocProvider<PembayaranBloc>(create: (context) => PembayaranBloc()),
        BlocProvider<LaporanGoaBloc>(create: (context) => LaporanGoaBloc()),
        BlocProvider<LaporanAktivitasBloc>(create: (context) => LaporanAktivitasBloc()),
        BlocProvider<CarouselBloc>(create: (context) => CarouselBloc()),
        BlocProvider<TataTertibBlocBloc>(create: (context) => TataTertibBlocBloc()),
        BlocProvider<JadwalBloc>(create: (context) => JadwalBloc()),
        BlocProvider<StandbyBloc>(create: (context) => StandbyBloc()),
        BlocProvider<PresensiBloc>(create: (context) => PresensiBloc()),
        BlocProvider<NewsBloc>(create: (context) => NewsBloc()),
        BlocProvider<FeedbackBloc>(create: (context) => FeedbackBloc()),
        BlocProvider<RencanaBelajarBloc>(create: (context) => RencanaBelajarBloc()),
        BlocProvider<ProfileBloc>(create: (context) => ProfileBloc()),
        BlocProvider<PilihAnakBloc>(create: (context) => PilihAnakBloc()),
        BlocProvider<CapaianButtonBloc>(create: (context) => CapaianButtonBloc()),
        BlocProvider<ScanQrBloc>(create: (context) => ScanQrBloc()),
        BlocProvider<TeoriContentBloc>(create: (context) => TeoriContentBloc()),
        BlocProvider<SimulasiBloc>(create: (context) => SimulasiBloc()),
        BlocProvider<HomeBloc>(create: (context) => HomeBloc()),
        BlocProvider<LeaderboardRacingBloc>(
            create: (context) => LeaderboardRacingBloc()),
        BlocProvider<JadwalKBMBloc>(create: (context) => JadwalKBMBloc()),
      ],
      child: ConnectionNotifier(
        connectionNotificationOptions: ConnectionNotificationOptions(
          alignment: AlignmentDirectional.bottomCenter,
          height: 50,
          connectedContent: _buildConnectionText(true),
          disconnectedContent: _buildConnectionText(false),
        ),
        child: MaterialApp(
          title: 'GO Expert',
          themeMode: ThemeMode.light,
          theme: CustomTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          onGenerateRoute: MyRouter.generateRoute,
          navigatorKey: _navigatorKey,
          // ignore: prefer_const_constructors
          locale: Locale('in', 'ID'),
          // ignore: prefer_const_literals_to_create_immutables, prefer_const_constructors
          supportedLocales: [Locale('in', 'ID')],
          // ignore: prefer_const_literals_to_create_immutables
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          builder: (context, child) {
            ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
              return buildErrorUI(context, errorDetails);
            };

            // if (!context.isMobile) {
            //   gSetDeviceOrientations(isLandscape: true);
            // }

            // Men-setting text scale factor Media Query.
            // Jika ini dihapus, maka text scale factor akan mengikuti System.
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(context.textScale14)),
              child: child!,
            );
          },
          home: const SplashScreen(),
        ),
      ),
    );
  }

  Widget buildErrorUI(BuildContext context, FlutterErrorDetails error) {
    if (kDebugMode) {
      print('error detail ${error.summary}');
      print('error stacktrace ${error.stack}');
    }
    Widget errorWidget = Container(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const LogoImageWidget(height: 80.0),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
            child: Text(
              'Terjadi kesalahan di dalam Go Expert.',
              textAlign: TextAlign.center,
              style: context.text.bodyLarge,
            ),
          ),
          Text(
            '${kDebugMode ? error.summary : 'Maaf atas ketidaknyamanan ini, kami akan memperbaiki secepatnya. Mohon hubungi petugas kami.'}',
            textAlign: TextAlign.center,
            style: context.text.labelSmall?.copyWith(color: context.hintColor),
          ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraint) => (constraint.maxHeight > (context.dh * 0.9))
          ? Scaffold(body: Center(child: errorWidget))
          : SizedBox(
              width: constraint.maxWidth,
              height: constraint.maxHeight,
              child: SingleChildScrollView(child: errorWidget),
            ),
    );
  }

  Widget _buildConnectionText(bool isConnected) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: (isConnected) ? Colors.green : context.errorColor,
        ),
        child: Text(
          (isConnected) ? 'Kembali Online' : 'Koneksi Internet Terputus',
          textAlign: TextAlign.center,
          style: context.text.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        ),
      );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
