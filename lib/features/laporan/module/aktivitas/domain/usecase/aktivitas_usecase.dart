import 'package:gokreasi_new/core/shared/usecase/base_usecase.dart';
import 'package:gokreasi_new/features/laporan/module/aktivitas/domain/repository/aktivitas_repository.dart';

class GetAktivitasUseCase
    implements BaseUseCase<List<dynamic>, Map<String, dynamic>> {
  final AktivitasRepository _aktivitasRepository;
  const GetAktivitasUseCase(this._aktivitasRepository);

  @override
  Future<List> call({Map<String, dynamic>? params}) {
    return _aktivitasRepository.fetchAktivitas(params);
  }
}
