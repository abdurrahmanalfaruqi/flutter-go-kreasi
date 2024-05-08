import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';
import 'package:gokreasi_new/core/util/injector.dart';

import '../../../../../core/helper/api_helper.dart';

class NotificationServiceApi {
  final ApiHelper _apiHelper = locator<ApiHelper>();

  Future<dynamic> fetchNotification(String userId) async {
    final response = await _apiHelper.dio.get(
      "/notif",
    );
    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }
    return response.data['data'];
  }

  Future<void> deleteNotification(String notifId) async {
    final response = await _apiHelper.dio.delete(
      "/notif/delete/$notifId",
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }
  }
}
