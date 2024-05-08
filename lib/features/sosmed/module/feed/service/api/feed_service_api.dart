import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';

import '../../../../../../core/helper/api_helper.dart';

class FeedServiceApi {
  final _apiHelper = ApiHelper(baseUrl: '');

  Future<dynamic> fetchFeed(String userId) async {
    final response = await _apiHelper.dio.get(
      "/feed/$userId",
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }
    return response.data['data'];
  }

  Future<dynamic> fetchMoreFeed(
      String userId, String accessDate, int lastIndex) async {
    final response = await _apiHelper.dio.get(
      "/feed/more/$userId/$lastIndex",
    );
    if (kDebugMode) {
      logger.log("cek data $userId $accessDate $lastIndex");
    }

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }

    return response.data['data'];
  }

  Future<void> responseFeed(String userId, String feedId, String type) async {
    final response = await _apiHelper.dio.post(
      "/feed/response",
      data: {"userId": userId, "feedId": feedId, "type": type},
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }
  }

  Future<void> deleteFeed(String feedId) async {
    final response = await _apiHelper.dio.delete(
      "/feed/status/deletefeed/$feedId",
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }
  }

  Future<void> setFeedPrivat(String feedId) async {
    final response = await _apiHelper.dio.post(
      "/feed/status/setfeedprivat",
      data: {"feedId": feedId},
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }
  }

  Future<void> setFeedPublik(String feedId) async {
    final response = await _apiHelper.dio.post(
      "/feed/status/setfeedpublik",
      data: {"feedId": feedId},
    );
    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }
  }

  Future<void> saveFeed(
      {String? userId,
      String? tob,
      String? empatiId,
      String? file64,
      String? content}) async {
    final response = await _apiHelper.dio.post(
      '/feed/upload',
      data: {
        'nis': userId,
        'tob': tob,
        'kodeEmpati': empatiId,
        'file64': file64,
        'konten': content
      },
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }
  }

  Future<dynamic> fetchComment(String userId, String feedId) async {
    final response = await _apiHelper.dio.get(
      "/feed/comment/$userId/$feedId",
    );
    if (kDebugMode) {
      logger.log("response Reply ${response.data['reply']}");
    }
    return response.data;
  }

  Future<void> saveComment(
      String userId, String feedId, String feedCreator, String text) async {
    final response = await _apiHelper.dio.post(
      "/feed/comment/add",
      data: {
        "userId": userId,
        "feedId": feedId,
        "feedCreator": feedCreator,
        "text": text
      },
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }
  }

  Future<void> deleteComment(String feedId) async {
    final response = await _apiHelper.dio.delete(
      "/feed/comment/delete/$feedId",
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }
  }
}
