import 'package:gokreasi_new/core/shared/usecase/base_usecase.dart';
import 'package:gokreasi_new/features/buku/domain/repository/buku_repository.dart';

class FetchDaftarBuku
    implements BaseUseCase<List<dynamic>, Map<String, dynamic>> {
  final BukuRepository _bukuRepository;
  const FetchDaftarBuku(this._bukuRepository);

  @override
  Future<List> call({Map<String, dynamic>? params}) {
    return _bukuRepository.fetchDaftarBuku(params);
  }
}

class FetchDaftarBab
    implements BaseUseCase<List<dynamic>, Map<String, dynamic>> {
  final BukuRepository _bukuRepository;
  const FetchDaftarBab(this._bukuRepository);

  @override
  Future<List> call({Map<String, dynamic>? params}) {
    return _bukuRepository.fetchDaftarBab(params);
  }
}

class FetchContent
    implements BaseUseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final BukuRepository _bukuRepository;
  const FetchContent(this._bukuRepository);

  @override
  Future<Map<String, dynamic>> call({Map<String, dynamic>? params}) {
    return _bukuRepository.fetchContent(params);
  }
}
