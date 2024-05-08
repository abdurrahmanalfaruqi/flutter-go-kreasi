import 'package:gokreasi_new/core/shared/usecase/base_usecase.dart';
import 'package:gokreasi_new/features/jadwal/domain/repository/jadwal_repository.dart';

class GetJadwalUseCase implements BaseUseCase<dynamic, Map<String, dynamic>> {
  final JadwalRepository _jadwalRepository;
  const GetJadwalUseCase(this._jadwalRepository);

  @override
  Future call({Map<String, dynamic>? params}) {
    return _jadwalRepository.fetchJadwal(params);
  }
}

class GetStandByUseCase
    implements BaseUseCase<List<dynamic>, Map<String, dynamic>> {
  final JadwalRepository _jadwalRepository;
  const GetStandByUseCase(this._jadwalRepository);

  @override
  Future<List> call({Map<String, dynamic>? params}) {
    return _jadwalRepository.fetchStandby(params);
  }
}

class GetVideoJadwalUseCase
    implements BaseUseCase<List<dynamic>, Map<String, dynamic>> {
  final JadwalRepository _jadwalRepository;
  const GetVideoJadwalUseCase(this._jadwalRepository);

  @override
  Future<List> call({Map<String, dynamic>? params}) {
    return _jadwalRepository.fetchVideoJadwal(params);
  }
}

class PostRequestTSTUseCase implements BaseUseCase<bool, Map<String, dynamic>> {
  final JadwalRepository _jadwalRepository;

  const PostRequestTSTUseCase(this._jadwalRepository);
  @override
  Future<bool> call({Map<String, dynamic>? params}) {
    return _jadwalRepository.postRequestTST(params);
  }
}
