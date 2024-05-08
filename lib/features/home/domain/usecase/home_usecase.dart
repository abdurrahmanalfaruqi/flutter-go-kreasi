import 'package:gokreasi_new/core/shared/usecase/base_usecase.dart';
import 'package:gokreasi_new/features/home/domain/repository/home_repository.dart';

class GetCarouselUseCase implements BaseUseCase<List<dynamic>, Map<String, dynamic>> {
  final HomeRepository _homeRepository;
  const GetCarouselUseCase(this._homeRepository);

  @override
  Future<List> call({Map<String, dynamic>? params}) {
    return _homeRepository.fetchCarousel();
  }
}

class GetCapaianScore
    implements BaseUseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final HomeRepository _homeRepository;
  const GetCapaianScore(this._homeRepository);

  @override
  Future<Map<String, dynamic>> call({Map<String, dynamic>? params}) {
    return _homeRepository.fetchCapaianScore(params);
  }
}

class GetCapaianBar
    implements BaseUseCase<List<dynamic>, Map<String, dynamic>> {
  final HomeRepository _homeRepository;
  const GetCapaianBar(this._homeRepository);

  @override
  Future<List> call({Map<String, dynamic>? params}) {
    return _homeRepository.fetchCapaianBar(params);
  }
}

class GetFirstRankBukuSakti
    implements BaseUseCase<List<dynamic>, Map<String, dynamic>> {
  final HomeRepository _homeRepository;
  const GetFirstRankBukuSakti(this._homeRepository);

  @override
  Future<List> call({Map<String, dynamic>? params}) {
    return _homeRepository.fetchFirstRankBukuSakti(params);
  }
}

class GetLeaderBoardBukuSakti
    implements BaseUseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final HomeRepository _homeRepository;
  const GetLeaderBoardBukuSakti(this._homeRepository);

  @override
  Future<Map<String, dynamic>> call({Map<String, dynamic>? params}) {
    return _homeRepository.fetchLeaderBoardBukuSakti(params);
  }
}

class GetPembayaran
    implements BaseUseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final HomeRepository _homeRepository;
  const GetPembayaran(this._homeRepository);

  @override
  Future<Map<String, dynamic>> call({Map<String, dynamic>? params}) {
    return _homeRepository.fetchPembayaran(params);
  }
}

class GetDetailPembayaran
    implements BaseUseCase<List<dynamic>, Map<String, dynamic>> {
  final HomeRepository _homeRepository;
  const GetDetailPembayaran(this._homeRepository);

  @override
  Future<List> call({Map<String, dynamic>? params}) {
    return _homeRepository.fetchDetailPembayaran(params);
  }
}

class GetUniversitas
    implements BaseUseCase<List<dynamic>, Map<String, dynamic>> {
  final HomeRepository _homeRepository;
  const GetUniversitas(this._homeRepository);

  @override
  Future<List> call({Map<String, dynamic>? params}) {
    return _homeRepository.fetchUniversitas(params);
  }
}

class GetJurusan implements BaseUseCase<List<dynamic>, Map<String, dynamic>> {
  final HomeRepository _homeRepository;
  const GetJurusan(this._homeRepository);

  @override
  Future<List> call({Map<String, dynamic>? params}) {
    return _homeRepository.fetchJurusan(params);
  }
}

class CekTOB implements BaseUseCase<List<dynamic>, Map<String, dynamic>> {
  final HomeRepository _homeRepository;
  const CekTOB(this._homeRepository);

  @override
  Future<List> call({Map<String, dynamic>? params}) {
    return _homeRepository.cekTOB(params);
  }
}

class FetchKampusImpian
    implements BaseUseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final HomeRepository _homeRepository;
  const FetchKampusImpian(this._homeRepository);

  @override
  Future<Map<String, dynamic>> call({Map<String, dynamic>? params}) {
    return _homeRepository.getKampusImpian(params);
  }
}

class FetchKampusImpianByTOB
    implements BaseUseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final HomeRepository _homeRepository;
  const FetchKampusImpianByTOB(this._homeRepository);

  @override
  Future<Map<String, dynamic>> call({Map<String, dynamic>? params}) {
    return _homeRepository.getKampusImpianByTOB(params);
  }
}

class FetchDetailJurusan
    implements BaseUseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final HomeRepository _homeRepository;
  const FetchDetailJurusan(this._homeRepository);

  @override
  Future<Map<String, dynamic>> call({Map<String, dynamic>? params}) {
    return _homeRepository.getDetailJurusan(params);
  }
}

class GetPromotionEventUseCase
    implements BaseUseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final HomeRepository _homeRepository;
  const GetPromotionEventUseCase(this._homeRepository);

  @override
  Future<Map<String, dynamic>> call({Map<String, dynamic>? params}) {
    return _homeRepository.getPromotionEvent(params);
  }
}
