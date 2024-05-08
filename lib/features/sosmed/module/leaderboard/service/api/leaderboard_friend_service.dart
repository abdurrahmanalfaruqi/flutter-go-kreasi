import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';

import '../../../../../../core/helper/api_helper.dart';

class LeaderboardFriendsServiceApi {
  final ApiHelper _apiHelper = ApiHelper(
    baseUrl: kDebugMode
        ? dotenv.env["BASE_URL_DEV"] ?? ''
        : dotenv.env["BASE_URL_PROD"] ?? '',
  );

  Future<dynamic> fetchLeaderboardFriends(String userId) async {
    final response = await _apiHelper.dio.get(
      "/friend/leaderboard",
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }

    return response.data['data'];
  }
}
