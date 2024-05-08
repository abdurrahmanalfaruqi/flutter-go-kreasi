import 'package:gokreasi_new/core/shared/usecase/base_usecase.dart';
import 'package:gokreasi_new/features/soal/module/paket_soal/domain/repository/paket_soal_repository.dart';

class GetDaftarPaketSoalUseCase
    implements BaseUseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final PaketSoalRepository _paketSoalRepository;
  const GetDaftarPaketSoalUseCase(this._paketSoalRepository);

  @override
  Future<Map<String, dynamic>> call({Map<String, dynamic>? params}) {
    return _paketSoalRepository.fetchDaftarPaketSoal(params);
  }
}
