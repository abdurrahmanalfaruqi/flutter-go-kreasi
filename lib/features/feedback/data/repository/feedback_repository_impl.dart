import 'package:dio/dio.dart';
import 'package:gokreasi_new/core/helper/api_helper.dart';
import 'package:gokreasi_new/core/helper/dio_option_helper.dart';
import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';
import 'package:gokreasi_new/features/feedback/domain/repository/feedback_repository.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  final ApiHelper _apiHelper;

  const FeedbackRepositoryImpl(this._apiHelper);

  @override
  Future<List> fetchFeedbackQuestion(Map<String, dynamic>? params) async {
    try {
      final response = await _apiHelper.dio.get(
        "/kbm/mobile/v1/feedback/pertanyaan",
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
  Future<void> saveFeedback(Map<String, dynamic>? params) async {
    try {
      await _apiHelper.dio.post(
        '/kbm/mobile/v1/feedback/simpan',
        data: params,
        options: DioOptionHelper().dioOption,
      );
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    } catch (e) {
      rethrow;
    }
  }
}
