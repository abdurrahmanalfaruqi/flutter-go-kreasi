import 'dart:developer' as logger show log;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';
import 'package:gokreasi_new/core/util/injector.dart';

import '../../../core/helper/api_helper.dart';

/// [ProfilePictureServiceApi] merupakan service class penghubung provider dengan request api.
class ProfilePictureServiceApi {
  final ApiHelper _apiHelper = locator<ApiHelper>();

  static final ProfilePictureServiceApi _instance =
      ProfilePictureServiceApi._internal();

  factory ProfilePictureServiceApi() => _instance;

  ProfilePictureServiceApi._internal();

  Future<String?> fetchProfilePicture({
    required String namaLengkap,
    required String noRegistrasi,
  }) async {
    try {
      final response = await _apiHelper.dio.get(
        '/data/api/v1/profile-picture/$noRegistrasi',
      );

      if (response.data == null ||
          response.data['meta']['code'] == false ||
          response.data['data'] == null) {
        return null;
      }

      return response.data['data']?['data']?['profile_picture'];
    } catch (e) {
      return null;
    }
  }

  Future<bool> setProfilePicture({
    required String noRegistrasi,
    required String photoUrl,
    bool isAvatar = true,
  }) async {
    try {
      final response = await _apiHelper.dio.patch(
        '/data/api/v1/profile-picture/update/$noRegistrasi',
        data: {
          'profile_picture': photoUrl,
          // 'isAvatar': isAvatar,
        },
      );

      if (kDebugMode) {
        logger.log('PROFILE_PICTURE-SetProfilePicture: response >> $response');
      }

      if (response.data['_meta']?['status'] != 'success') {
        throw false;
      }

      int statusCode = response.statusCode ?? 0;
      return statusCode >= 200 && statusCode < 300;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> uploadToAWS({
    required File imageFile,
    required String noRegistrasi,
  }) async {
    try {
      // String extension = imageFile.path.split('/').last.split('.').last;
      // String fileName = '$noRegistrasi.$extension';

      String fileName = imageFile.path.split('/').last;

      FormData data = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
        "context": "student-profile",
      });

      final res = await _apiHelper.dio.post(
        '/v1/file/upload/image',
        data: data,
      );

      return res.data;
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    } catch (e) {
      rethrow;
    }
  }
}
