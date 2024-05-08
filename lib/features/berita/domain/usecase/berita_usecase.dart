import 'package:gokreasi_new/core/shared/usecase/base_usecase.dart';
import 'package:gokreasi_new/features/berita/domain/repository/berita_repository.dart';

class FetchBeritaUseCase
    implements BaseUseCase<List<dynamic>, Map<String, dynamic>> {
  final BeritaRepository _beritaRepository;
  const FetchBeritaUseCase(this._beritaRepository);

  @override
  Future<List> call({Map<String, dynamic>? params}) {
    return _beritaRepository.fetchBerita(params);
  }
}

class FetchBeritaPopUpUseCase
    implements BaseUseCase<List<dynamic>, Map<String, dynamic>> {
  final BeritaRepository _beritaRepository;
  const FetchBeritaPopUpUseCase(this._beritaRepository);

  @override
  Future<List> call({Map<String, dynamic>? params}) {
    return _beritaRepository.fetchBeritaPopUp(params);
  }
}

class SetBeritaViewerUseCase
    implements BaseUseCase<void, Map<String, dynamic>> {
  final BeritaRepository _beritaRepository;
  const SetBeritaViewerUseCase(this._beritaRepository);

  @override
  Future<void> call({Map<String, dynamic>? params}) {
    return _beritaRepository.setViewerBerita(params);
  }
}
