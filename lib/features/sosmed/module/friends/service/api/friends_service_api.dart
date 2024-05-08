import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';
import 'package:gokreasi_new/core/util/injector.dart';

import '../../../../../../core/helper/api_helper.dart';

class FriendsServiceApi {
  final ApiHelper _apiHelper = locator<ApiHelper>();

  Future<dynamic> fetchFriend(String userId) async {
    final response = await _apiHelper.dio.get(
      "/friend/$userId",
    );

    return response.data['data'];
  }

  Future<dynamic> fetchFriendMore(String userId, int lastIndex) async {
    final response = await _apiHelper.dio.get(
      "/friend/loadmore/$userId/$lastIndex",
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }
    return response.data['data'];
  }

  Future<dynamic> getFriendFeed(String noregistrasi) async {
    final response = await _apiHelper.dio.get(
      "/friend/feed/$noregistrasi",
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }

    return response.data['data'];
  }

  Future<dynamic> deleteFriend(
      {required String asal, required String tujuan}) async {
    final response = await _apiHelper.dio.delete(
      "/friend/delete/$tujuan",
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }

    return response.data;
  }

  Future<dynamic> fetchFriendPending(
      {required String userId, required String type}) async {
    final response = await _apiHelper.dio.get(
      "/friend/pending/$type",
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }
    return response.data['data'];
  }

  Future<dynamic> fetchFriendDetail(String friendId) async {
    final response = await _apiHelper.dio.get(
      "/friend/detail/$friendId",
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }

    return response.data['data'];
  }

  Future<dynamic> searchFriend(
      {required String userId, required String searchFriends}) async {
    final response = await _apiHelper.dio.get(
      "/friend/search/$searchFriends",
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }
    return response.data['data'];
  }

  Future<dynamic> searchFriendMore(
      {required String userId,
      required String searchFriends,
      required int lastIndex}) async {
    final response = await _apiHelper.dio.get(
      "/friend/search/loadmore/$searchFriends/$lastIndex",
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }
    return response.data['data'];
  }

  Future<void> responseFriend(
      {required String sourceId,
      required String destId,
      required String status}) async {
    final response = await _apiHelper.dio.post(
      "/friend/response",
      data: {"nisAsal": sourceId, "nisTujuan": destId, "status": status},
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }
  }

  Future<void> requestFriend(
      {required String sourceId, required String destId}) async {
    final response = await _apiHelper.dio.post(
      "/friend/request",
      data: {"nisAsal": sourceId, "nisTujuan": destId},
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }
  }

  Future<dynamic> fetchFriendsTryout(
      {required String friendId,
      required String classLevelId,
      required String jenis}) async {
    final response = await _apiHelper.dio.get(
      "/friend/tryout/last/$friendId",
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }

    return response.data['data'];
  }

  Future<dynamic> fetchListCompare(
      {required String userId, required String friendId}) async {
    final response = await _apiHelper.dio.get(
      "/friend/compare/$friendId",
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }

    return response.data['data'];
  }

  Future<dynamic> fetchScoreCompare(
      {required String userId,
      required String friendId,
      required String kodeSoal,
      required String idSekolahKelas}) async {
    final response = await _apiHelper.dio.get(
      "/friend/compare/score/$kodeSoal/$friendId",
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }

    return response.data['data'];
  }

  Future<dynamic> fetchMyScore(
      {required String userId, required String idSekolahKelas}) async {
    final response = await _apiHelper.dio.get(
      "/friend/score",
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }
    return response.data;
  }
}
