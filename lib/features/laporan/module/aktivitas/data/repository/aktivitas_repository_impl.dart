import 'package:dio/dio.dart';
import 'package:gokreasi_new/core/helper/api_helper.dart';
import 'package:gokreasi_new/core/helper/dio_option_helper.dart';
import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';
import 'package:gokreasi_new/features/laporan/module/aktivitas/domain/repository/aktivitas_repository.dart';

class AktivitasRepositoryImpl implements AktivitasRepository {
  final ApiHelper _apiHelper;

  const AktivitasRepositoryImpl(this._apiHelper);

  @override
  Future<List> fetchAktivitas(Map<String, dynamic>? params) async {
    try {
      final type = params?['type'];
      final userId = params?['user_id'];
      final response = await _apiHelper.dio.get(
        '/laporan/mobile/v1/laporan/abs/$type/$userId',
        options: DioOptionHelper().dioOption,
      );
      if (response.data['meta']['code'] != 200) {
        throw DioErrorHandler.errorFromResponse(response);
      }

      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }
}
