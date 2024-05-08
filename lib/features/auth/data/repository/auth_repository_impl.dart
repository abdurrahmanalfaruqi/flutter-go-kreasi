import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gokreasi_new/core/helper/api_helper.dart';
import 'package:gokreasi_new/core/helper/kreasi_shared_pref.dart';
import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';
import 'package:gokreasi_new/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiHelper _apiHelper;

  const AuthRepositoryImpl(this._apiHelper);

  @override
  Future<Map<String, dynamic>> loginSiswa(Map<String, dynamic>? params) async {
    try {
      String url = '/auth/api/v1/goexpert/mobile/siswa';

      Response response = await _apiHelper.dio.post(
        url,
        data: params,
        options: Options(
          headers: {
            "X-API-KEY": kDebugMode
                ? dotenv.env['X-API-KEY_DEV']
                : dotenv.env['X_API_KEY_PROD'],
          },
        ),
      );

      if ((response.data['meta']['status'] as String).toLowerCase() ==
          'gagal') {
        throw DioErrorHandler.errorFromResponse(response);
      }

      return response.data;
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }

  @override
  Future<bool> logoutSiswa(Map<String, dynamic>? params) async {
    try {
      final token = KreasiSharedPref().getTokenJWT() ?? '';
      final res = await _apiHelper.dio.post(
        '/auth/mobile/v1/logout-new/siswa',
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

      return res.data['meta']['code'] == 200;
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> logoutOrtu(Map<String, dynamic>? params) async {
    try {
      final token = KreasiSharedPref().getTokenJWT() ?? '';
      final res = await _apiHelper.dio.post(
        '/auth/mobile/v1/logout-new/ortu',
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

      return res.data['meta']['code'] == 200;
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> loginOrtu(Map<String, dynamic>? params) async {
    try {
      final res = await _apiHelper.dio.post(
        '/auth/mobile/v1/login/ortu/pilih-bundling',
        data: params,
        options: Options(
          headers: {
            "X-API-KEY": kDebugMode
                ? dotenv.env['X-API-KEY_DEV']
                : dotenv.env['X_API_KEY_PROD'],
          },
        ),
      );

      if ((res.data['meta']['status'] as String).toLowerCase() == 'gagal') {
        throw DioErrorHandler.errorFromResponse(res);
      }

      return res.data;
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> changeBundling(
      Map<String, dynamic>? params) async {
    try {
      final token = KreasiSharedPref().getTokenJWT() ?? '';
      final res = await _apiHelper.dio.post(
        '/auth/api/v1/goexpert/siswa/ganti-bundling',
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
      if (res.data['meta']['code'] != 200) {
        throw DioErrorHandler.errorFromResponse(res);
      }
      return res.data;
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getDetailSiswa(
      Map<String, dynamic>? params) async {
    try {
      final token = params?['token'];
      final res = await _apiHelper.dio.post(
        '/auth/api/v1/goexpert/siswa/detail',
        data: {
          'noreg': params?['noreg'],
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (res.data['meta']['code'] != 200) {
        throw DioErrorHandler.errorFromResponse(res);
      }

      return res.data;
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getDataSekolahSiswa(
      Map<String, dynamic>? params) async {
    try {
      final token = params?['token'];
      Map<String, dynamic> reqBody = {}
        ..['id_sekolah'] = params?['id_sekolah']
        ..['id_sekolah_kelas'] = params?['id_sekolah_kelas'];

      final res = await _apiHelper.dio.get(
        '/auth/api/v1/goexpert/siswa/sekolah',
        queryParameters: reqBody,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (res.data['meta']['code'] != 200) {
        throw DioErrorHandler.errorFromResponse(res);
      }

      return res.data;
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getGedungKomarSiswa(
      Map<String, dynamic>? params) async {
    try {
      final token = KreasiSharedPref().getTokenJWT() ?? '';
      final res = await _apiHelper.dio.get(
        '/auth/api/v1/goexpert/siswa/gedung',
        queryParameters: params,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (res.data['meta']['code'] != 200) {
        throw DioErrorHandler.errorFromResponse(res);
      }

      return res.data;
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }

  @override
  Future<void> setTargetCapaian(Map<String, dynamic>? params) async {
    try {
      final token = KreasiSharedPref().getTokenJWT() ?? '';
      await _apiHelper.dio.post(
        '/data/api/v1/data/capaian/set-target-capaian',
        data: params,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Gagal set target capaian ->> $e');
      }
    }
  }

  @override
  Future<List<dynamic>> getNamaKelasSiswa(Map<String, dynamic>? params) async {
    try {
      final token = KreasiSharedPref().getTokenJWT() ?? '';
      final res = await _apiHelper.dio.get(
        '/auth/api/v1/goexpert/siswa/kelas',
        queryParameters: params,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (res.data['meta']['code'] != 200) {
        throw DioErrorHandler.errorFromResponse(res);
      }

      return res.data['data']['data'];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }
}
