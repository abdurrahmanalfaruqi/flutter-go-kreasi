import 'package:dio/dio.dart';
import 'package:gokreasi_new/core/helper/api_helper.dart';
import 'package:gokreasi_new/core/helper/dio_option_helper.dart';
import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';
import 'package:gokreasi_new/features/video/domain/repository/video_repository.dart';

class VideoRepositoryImpl implements VideoRepository {
  final ApiHelper _apiHelper;

  const VideoRepositoryImpl(this._apiHelper);
  @override
  Future<List> fetchVideoJadwalMapel(Map<String, dynamic>? params) async {
    try {
      final response = await _apiHelper.dio.post(
        '/buku/mobile/v1/buku/video/getmapel',
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
  Future<List> fetchVideoExtra(Map<String, dynamic>? params) async {
    try {
      final response = await _apiHelper.dio.post(
        "/buku/mobile/v1/buku/video/video-ekstra",
        data: params,
        options: DioOptionHelper().dioOption,
      );

      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }
}
