import 'package:dio/dio.dart';
import 'package:gokreasi_new/core/helper/api_helper.dart';
import 'package:gokreasi_new/core/helper/dio_option_helper.dart';
import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';
import 'package:gokreasi_new/features/bookmark/domain/repository/bookmark_repository.dart';

class BookMarkRepositoryImpl implements BookMarkRepository {
  final ApiHelper _apiHelper;

  const BookMarkRepositoryImpl(this._apiHelper);

  @override
  Future<List> fetchBookmark(Map<String, dynamic>? params) async {
    try {
      final response = await _apiHelper.dio.get(
        '/data/mobile/v1/data/bookmark/${params?['noRegistrasi']}',
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
  Future<bool> deleteBookmarkMapel(Map<String, dynamic>? params) async {
    try {
      final response = await _apiHelper.dio.delete(
        '/data/mobile/v1/data/bookmark/delete-kelompok-ujian',
        data: params,
        options: DioOptionHelper().dioOption,
      );

      return response.data['meta']['code'] == 200;
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }

  @override
  Future<bool> deleteBookmark(Map<String, dynamic>? params) async {
    try {
      final response = await _apiHelper.dio.delete(
        '/data/mobile/v1/data/bookmark/delete',
        data: params,
        options: DioOptionHelper().dioOption,
      );

      return response.data['meta']['code'] == 200;
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }

  @override
  Future<bool> addBookmark(Map<String, dynamic>? params) async {
    try {
      final response = await _apiHelper.dio.post(
        '/data/mobile/v1/data/bookmark/add',
        data: params,
        options: DioOptionHelper().dioOption,
      );

      return response.data['meta']['code'] == 200;
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }
}
