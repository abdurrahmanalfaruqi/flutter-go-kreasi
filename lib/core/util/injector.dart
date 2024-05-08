import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:gokreasi_new/core/config/constant.dart';
import 'package:gokreasi_new/core/helper/api_helper.dart';
import 'package:gokreasi_new/features/auth/data/repository/auth_repository_impl.dart';
import 'package:gokreasi_new/features/auth/domain/repository/auth_repository.dart';
import 'package:gokreasi_new/features/auth/domain/usecase/auth_usecase.dart';
import 'package:gokreasi_new/features/berita/data/repository/berita_repository_impl.dart';
import 'package:gokreasi_new/features/berita/domain/repository/berita_repository.dart';
import 'package:gokreasi_new/features/berita/domain/usecase/berita_usecase.dart';
import 'package:gokreasi_new/features/bookmark/data/repository/bookmark_repository_impl.dart';
import 'package:gokreasi_new/features/bookmark/domain/repository/bookmark_repository.dart';
import 'package:gokreasi_new/features/bookmark/domain/usecase/bookmark_usecase.dart';
import 'package:gokreasi_new/features/bookmark/presentation/bloc/bookmark_bloc.dart';
import 'package:gokreasi_new/features/bookmark/service/api/bookmark_service_api.dart';
import 'package:gokreasi_new/features/buku/data/repository/buku_repository_impl.dart';
import 'package:gokreasi_new/features/buku/domain/repository/buku_repository.dart';
import 'package:gokreasi_new/features/buku/domain/usecase/buku_usecase.dart';
import 'package:gokreasi_new/features/feedback/data/repository/feedback_repository_impl.dart';
import 'package:gokreasi_new/features/feedback/domain/repository/feedback_repository.dart';
import 'package:gokreasi_new/features/feedback/domain/usecase/feedback_usecase.dart';
import 'package:gokreasi_new/features/home/data/repository/home_repository_impl.dart';
import 'package:gokreasi_new/features/home/domain/repository/home_repository.dart';
import 'package:gokreasi_new/features/home/domain/usecase/home_usecase.dart';
import 'package:gokreasi_new/features/home/presentation/bloc/ptn/ptn_bloc.dart';
import 'package:gokreasi_new/features/home/service/home_service_api.dart';
import 'package:gokreasi_new/features/jadwal/data/repository/jadwal_repository_impl.dart';
import 'package:gokreasi_new/features/jadwal/domain/repository/jadwal_repository.dart';
import 'package:gokreasi_new/features/jadwal/domain/usecase/jadwal_usecase.dart';
import 'package:gokreasi_new/features/laporan/module/aktivitas/data/repository/aktivitas_repository_impl.dart';
import 'package:gokreasi_new/features/laporan/module/aktivitas/domain/repository/aktivitas_repository.dart';
import 'package:gokreasi_new/features/laporan/module/aktivitas/domain/usecase/aktivitas_usecase.dart';
import 'package:gokreasi_new/features/ptn/module/ptnclopedia/service/api/ptn_service_api.dart';
import 'package:gokreasi_new/features/soal/module/bundel_soal/data/repository/bundel_soal_repository_impl.dart';
import 'package:gokreasi_new/features/soal/module/bundel_soal/domain/repository/bundel_soal_repository.dart';
import 'package:gokreasi_new/features/soal/module/bundel_soal/domain/usecase/bundel_soal_usecase.dart';
import 'package:gokreasi_new/features/soal/module/paket_soal/data/repository/paket_soal_repository_impl.dart';
import 'package:gokreasi_new/features/soal/module/paket_soal/domain/repository/paket_soal_repository.dart';
import 'package:gokreasi_new/features/soal/module/paket_soal/domain/usecase/paket_soal_usecase.dart';
import 'package:gokreasi_new/features/video/data/repository/video_repository_impl.dart';
import 'package:gokreasi_new/features/video/domain/repository/video_repository.dart';
import 'package:gokreasi_new/features/video/domain/usecase/video_usecase.dart';
import 'package:image_picker/image_picker.dart';

final GetIt locator = GetIt.instance;

void init() {
  locator.registerFactory(() => PtnBloc(locator()));
  locator.registerFactory(() => BookmarkBloc(locator()));

  locator.registerLazySingleton<ImagePicker>(() => ImagePicker());

  locator.registerLazySingleton<HomeServiceAPI>(() => HomeServiceAPI());
  locator.registerLazySingleton<PtnServiceApi>(() => PtnServiceApi());
  locator.registerLazySingleton<BookmarkServiceAPI>(() => BookmarkServiceAPI());

  locator.registerSingleton<ApiHelper>(ApiHelper(
    baseUrl: kDebugMode
        ? dotenv.env["BASE_URL_DEV"] ?? ''
        : dotenv.env["BASE_URL_PROD"] ?? '',
  ));

  locator.registerLazySingleton<ApiHelper>(
    () => ApiHelper(baseUrl: dotenv.env['BASE_URL_SUPERAPPS'] ?? ''),
    instanceName: Constant.kBaseUrlSMBA,
  );

  // repository
  locator.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
        locator(),
      ));
  locator.registerLazySingleton<BeritaRepository>(() => BeritaRepositoryImpl(
        locator(),
      ));
  locator.registerLazySingleton<BookMarkRepository>(
    () => BookMarkRepositoryImpl(locator()),
  );
  locator.registerLazySingleton<BukuRepository>(() => BukuRepositoryImpl(
        locator(),
      ));
  locator.registerLazySingleton<FeedbackRepository>(
    () => FeedbackRepositoryImpl(locator()),
  );
  locator.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(locator()),
  );
  locator.registerLazySingleton<JadwalRepository>(
    () => JadwalRepositoryImpl(locator()),
  );
  locator.registerLazySingleton<VideoRepository>(
    () => VideoRepositoryImpl(locator()),
  );
  locator.registerLazySingleton<AktivitasRepository>(
    () => AktivitasRepositoryImpl(locator()),
  );
  locator.registerLazySingleton<BundelSoalRepository>(
    () => BundelSoalRepositoryImpl(locator()),
  );
  locator.registerLazySingleton<PaketSoalRepository>(
    () => PaketSoalRepositoryImpl(locator()),
  );

  // usecase
  locator.registerLazySingleton<LoginSiswaUseCase>(
    () => LoginSiswaUseCase(locator()),
  );
  locator.registerLazySingleton<LogoutSiswaUseCase>(
    () => LogoutSiswaUseCase(locator()),
  );
  locator.registerLazySingleton<LoginOrtuUseCase>(
    () => LoginOrtuUseCase(locator()),
  );
  locator.registerLazySingleton<LogoutOrtuUseCase>(
    () => LogoutOrtuUseCase(locator()),
  );
  locator.registerLazySingleton<ChangeBundlingUseCase>(
    () => ChangeBundlingUseCase(locator()),
  );
  locator.registerLazySingleton<FetchBeritaUseCase>(
    () => FetchBeritaUseCase(locator()),
  );
  locator.registerLazySingleton<FetchBookMarkUseCase>(
    () => FetchBookMarkUseCase(locator()),
  );
  locator.registerLazySingleton<DeleteBookMarkMapelUseCase>(
    () => DeleteBookMarkMapelUseCase(locator()),
  );
  locator.registerLazySingleton<DeleteBookMarkUseCase>(
    () => DeleteBookMarkUseCase(locator()),
  );
  locator.registerLazySingleton<AddBookMarkUseCase>(
    () => AddBookMarkUseCase(locator()),
  );
  locator.registerLazySingleton<FetchDaftarBuku>(
    () => FetchDaftarBuku(locator()),
  );
  locator.registerLazySingleton<FetchDaftarBab>(
    () => FetchDaftarBab(locator()),
  );
  locator.registerLazySingleton<FetchContent>(
    () => FetchContent(locator()),
  );
  locator.registerLazySingleton<GetFeedbackQuestionUseCase>(
    () => GetFeedbackQuestionUseCase(locator()),
  );
  locator.registerLazySingleton<SetFeedback>(
    () => SetFeedback(locator()),
  );
  locator.registerLazySingleton<GetCarouselUseCase>(
    () => GetCarouselUseCase(locator()),
  );
  locator.registerLazySingleton<GetCapaianScore>(
    () => GetCapaianScore(locator()),
  );
  locator.registerLazySingleton<GetCapaianBar>(
    () => GetCapaianBar(locator()),
  );
  locator.registerLazySingleton<GetFirstRankBukuSakti>(
    () => GetFirstRankBukuSakti(locator()),
  );
  locator.registerLazySingleton<GetLeaderBoardBukuSakti>(
    () => GetLeaderBoardBukuSakti(locator()),
  );
  locator.registerLazySingleton<GetPembayaran>(
    () => GetPembayaran(locator()),
  );
  locator.registerLazySingleton<GetDetailPembayaran>(
    () => GetDetailPembayaran(locator()),
  );
  locator.registerLazySingleton<GetUniversitas>(
    () => GetUniversitas(locator()),
  );
  locator.registerLazySingleton<GetJurusan>(
    () => GetJurusan(locator()),
  );
  locator.registerLazySingleton<CekTOB>(
    () => CekTOB(locator()),
  );
  locator.registerLazySingleton<FetchKampusImpian>(
    () => FetchKampusImpian(locator()),
  );
  locator.registerLazySingleton<FetchKampusImpianByTOB>(
    () => FetchKampusImpianByTOB(locator()),
  );
  locator.registerLazySingleton<FetchDetailJurusan>(
    () => FetchDetailJurusan(locator()),
  );
  locator.registerLazySingleton<GetJadwalUseCase>(
    () => GetJadwalUseCase(locator()),
  );
  locator.registerLazySingleton<GetStandByUseCase>(
    () => GetStandByUseCase(locator()),
  );
  locator.registerLazySingleton<GetVideoJadwalMapel>(
    () => GetVideoJadwalMapel(locator()),
  );
  locator.registerLazySingleton<GetVideoJadwalUseCase>(
    () => GetVideoJadwalUseCase(locator()),
  );
  locator.registerLazySingleton<PostRequestTSTUseCase>(
    () => PostRequestTSTUseCase(locator()),
  );
  locator.registerLazySingleton<GetVideoExtra>(
    () => GetVideoExtra(locator()),
  );
  locator.registerLazySingleton<GetDetailSiswa>(
    () => GetDetailSiswa(locator()),
  );
  locator.registerLazySingleton<GetDataSekolahSiswa>(
    () => GetDataSekolahSiswa(locator()),
  );
  locator.registerLazySingleton<GetGedungKomarSiswa>(
    () => GetGedungKomarSiswa(locator()),
  );
  locator.registerLazySingleton<SetTargetCapaian>(
    () => SetTargetCapaian(locator()),
  );
  locator.registerLazySingleton<GetNamaKelasSiswa>(
    () => GetNamaKelasSiswa(locator()),
  );
  locator.registerLazySingleton<FetchBeritaPopUpUseCase>(
    () => FetchBeritaPopUpUseCase(locator()),
  );
  locator.registerLazySingleton<SetBeritaViewerUseCase>(
    () => SetBeritaViewerUseCase(locator()),
  );
  locator.registerLazySingleton<GetAktivitasUseCase>(
    () => GetAktivitasUseCase(locator()),
  );
  locator.registerLazySingleton<GetDaftarBundelUseCase>(
    () => GetDaftarBundelUseCase(locator()),
  );
  locator.registerLazySingleton<GetDaftarBabSubBabUseCase>(
    () => GetDaftarBabSubBabUseCase(locator()),
  );
  locator.registerLazySingleton<GetDaftarPaketSoalUseCase>(
    () => GetDaftarPaketSoalUseCase(locator()),
  );
  locator.registerLazySingleton<GetPromotionEventUseCase>(
    () => GetPromotionEventUseCase(locator()),
  );
}
