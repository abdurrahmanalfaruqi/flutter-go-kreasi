import 'package:dio/dio.dart';
import 'package:gokreasi_new/core/helper/api_helper.dart';
import 'package:gokreasi_new/core/helper/dio_option_helper.dart';
import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';
import 'package:gokreasi_new/features/jadwal/domain/repository/jadwal_repository.dart';

class JadwalRepositoryImpl implements JadwalRepository {
  final ApiHelper _apiHelper;

  const JadwalRepositoryImpl(this._apiHelper);

  @override
  Future fetchJadwal(Map<String, dynamic>? params) async {
    try {
      final response = await _apiHelper.dio.get(
        '/kbm/mobile/v1/jadwal/kbm/siswa',
        options: DioOptionHelper().dioOption,
        data: params,
      );

      return response.data['data'];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }

  @override
  Future<List> fetchStandby(Map<String, dynamic>? params) async {
    try {
      final response = await _apiHelper.dio.get(
        '/kbm/mobile/v1/jadwal/tst/siswa',
        data: params,
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

  @override
  Future<List> fetchVideoJadwal(Map<String, dynamic>? params) async {
    try {
      final response = await _apiHelper.dio.post(
        "/buku/mobile/v1/buku/video/findbab",
        data: params,
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

  @override
  Future<bool> postRequestTST(Map<String, dynamic>? params) async {
    try {
      final response = await _apiHelper.dio.post(
        '/kbm/mobile/v1/jadwal/tst/siswa/request',
        data: params,
        options: DioOptionHelper().dioOption,
      );

      return response.data['meta']['code'] >= 200 ||
          response.data['meta']['code'] < 300;
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }
}
