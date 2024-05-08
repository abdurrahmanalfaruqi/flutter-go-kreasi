import 'package:gokreasi_new/core/shared/usecase/base_usecase.dart';
import 'package:gokreasi_new/features/soal/module/bundel_soal/domain/repository/bundel_soal_repository.dart';

class GetDaftarBundelUseCase
    implements BaseUseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final BundelSoalRepository _bundelSoalRepository;
  const GetDaftarBundelUseCase(this._bundelSoalRepository);

  @override
  Future<Map<String, dynamic>> call({Map<String, dynamic>? params}) {
    return _bundelSoalRepository.fetchDaftarBundel(params);
  }
}

class GetDaftarBabSubBabUseCase
    implements BaseUseCase<List<dynamic>, Map<String, dynamic>> {
  final BundelSoalRepository _bundelSoalRepository;
  const GetDaftarBabSubBabUseCase(this._bundelSoalRepository);

  @override
  Future<List> call({Map<String, dynamic>? params}) {
    return _bundelSoalRepository.fetchDaftarBabSubBab(params);
  }
}
