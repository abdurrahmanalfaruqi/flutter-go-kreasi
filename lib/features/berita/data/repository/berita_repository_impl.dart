import 'package:dio/dio.dart';
import 'package:gokreasi_new/core/helper/api_helper.dart';
import 'package:gokreasi_new/core/helper/dio_option_helper.dart';
import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';
import 'package:gokreasi_new/features/berita/domain/repository/berita_repository.dart';

class BeritaRepositoryImpl implements BeritaRepository {
  final ApiHelper _apiHelper;

  const BeritaRepositoryImpl(this._apiHelper);

  @override
  Future<List> fetchBerita(Map<String, dynamic>? params) async {
    try {
      final response = await _apiHelper.dio.get(
        '/data/api/v1/data/berita',
        options: DioOptionHelper().dioOption,
      );

      if (response.data['meta']['code'] != 200) {
        throw DioErrorHandler.errorFromResponse(response);
      }

      return response.data['data'];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }

  @override
  Future<List> fetchBeritaPopUp(Map<String, dynamic>? params) async {
    try {
      final response = await _apiHelper.dio.get(
        '/data/api/v1/data/berita-harian',
        options: DioOptionHelper().dioOption,
      );

      if (response.data['meta']['code'] != 200) {
        throw DioErrorHandler.errorFromResponse(response);
      }
      return response.data['data'];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }

  @override
  Future<void> setViewerBerita(Map<String, dynamic>? params) async {
    try {
      final response = await _apiHelper.dio.post(
        "/data/api/v1/data/berita/addviewer",
        data: params,
        options: DioOptionHelper().dioOption,
      );

      if (response.data['meta']['code'] != 200) {
        throw DioErrorHandler.errorFromResponse(response);
      }
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }
}
