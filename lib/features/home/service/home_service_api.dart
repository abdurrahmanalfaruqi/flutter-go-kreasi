import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gokreasi_new/core/config/constant.dart';
import 'package:gokreasi_new/core/helper/kreasi_shared_pref.dart';
import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';

import '../../../core/helper/api_helper.dart';

class HomeServiceAPI {
  final ApiHelper _apiHelper = ApiHelper(
    baseUrl: kDebugMode
        ? dotenv.env["BASE_URL_DEV"] ?? ''
        : dotenv.env["BASE_URL_PROD"] ?? '',
  );

  static final HomeServiceAPI _instance = HomeServiceAPI._internal();

  factory HomeServiceAPI() => _instance;

  HomeServiceAPI._internal();

  Future<Map<String, dynamic>> getSekolahKelas() async {
    try {
      String? token = KreasiSharedPref().getTokenJWT();
      Response res = await _apiHelper.dio.get(
        Constant.getSekolahKelas,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "X-API-KEY": kDebugMode
                ? dotenv.env['X-API-KEY_DEV']
                : dotenv.env['X_API_KEY_PROD'],
          },
        ),
      );

      return res.data;
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getOpsiMapelPilihan(
      String idSekolahKelas) async {
    try {
      String? token = KreasiSharedPref().getTokenJWT();
      Response res = await _apiHelper.dio.get(
        '${Constant.getOpsiMapelPilihan}$idSekolahKelas',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "X-API-KEY": kDebugMode
                ? dotenv.env['X-API-KEY_DEV']
                : dotenv.env['X_API_KEY_PROD'],
          },
        ),
      );

      return res.data;
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    } catch (_) {
      rethrow;
    }
  }

  Future<List<dynamic>?> getCurrentMapelSiswa(String noRegistrasi) async {
    try {
      String? token = KreasiSharedPref().getTokenJWT();
      final res = await _apiHelper.dio.get(
        '${Constant.getCurrentMapelPilihan}$noRegistrasi',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "X-API-KEY": kDebugMode
                ? dotenv.env['X-API-KEY_DEV']
                : dotenv.env['X_API_KEY_PROD'],
          },
        ),
      );
      return res.data['data'];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> saveMapelPilihan(Map<String, dynamic> params) async {
    try {
      String? token = KreasiSharedPref().getTokenJWT();
      final res = await _apiHelper.dio.post(
        Constant.saveMapelPilihan,
        data: params,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "X-API-KEY": kDebugMode
                ? dotenv.env['X-API-KEY_DEV']
                : dotenv.env['X_API_KEY_PROD'],
          },
        ),
      );

      return res.data['data'] != null;
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    } catch (_) {
      rethrow;
    }
  }
}
