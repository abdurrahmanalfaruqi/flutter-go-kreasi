import 'dart:developer' as logger;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../core/config/global.dart';
import '../../../../core/helper/api_helper.dart';
import '../../../../core/util/app_exceptions.dart';

/// [AuthServiceApi] merupakan service class penghubung provider dengan request api.
class AuthServiceApi {
  // final Dio dio = Dio(BaseOptions(
  //   connectTimeout: const Duration(seconds: 60),
  //   receiveTimeout: const Duration(seconds: 60),
  //   baseUrl: 'https://auth-service.gobimbelonline.net',
  // ));
  final ApiHelper _apiHelper = ApiHelper(
    baseUrl: kDebugMode
        ? dotenv.env["BASE_URL_DEV"] ?? ''
        : dotenv.env["BASE_URL_PROD"] ?? '',
    connectTimeout: const Duration(seconds: 15),
  );

  Future<String?> fetchImei({
    String? noRegistrasi,
    String? siapa,
  }) async {
    if (noRegistrasi == null || siapa == null) {
      return null;
    }
    logger.log('FETCH IMEI START');

    try {
      final response = await _apiHelper.dio.get(
        "/auth/mobile/v1/auth/imei/$siapa/$noRegistrasi",
        options: Options(
          headers: {
            "X-API-KEY": kDebugMode
                ? dotenv.env['X-API-KEY_DEV']
                : dotenv.env['X_API_KEY_PROD'],
          },
        ),
      );

      if (kDebugMode) logger.log('FETCH IMEI: response >> ${response.data}');

      return (response.data['meta']['code'] == 200)
          ? response.data['data']
          : null;
    } catch (e) {
      return null;
    }
  }

  /// [resendOTP] service untuk request pengiriman ulang OTP kepada user.
  Future<dynamic> resendOTP({
    required String userPhoneNumber,
    required String otpCode,
    required String via,
  }) async {
    try {
      final response = await _apiHelper.dio.post(
        '/mobile/v1/login/otp/$via',
        data: {'noHP': userPhoneNumber, 'otp': otpCode},
      );
      if (response.data['meta']['code'] != 200) {
        throw DataException(message: response.data['message'] ?? gPesanError);
      }
      return response.data['waktu'];
    } catch (e) {
      throw DataException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> cekValidasiRegistrasi({
    required String noRegistrasi,
    required String nomorHp,
    required String userType,
    String? otp,
    String? kirimOtpVia,
    String? nama,
    String? email,
    String? tanggalLahir,
    String? idSekolahKelas,
    String? namaSekolahKelas,
  }) async {
    try {
      final response = await _apiHelper.dio.post(
        'mobile/v1/auth/registrasi/validasi',
        data: {
          'registeredNumber': nomorHp,
          'otp': otp,
          'via': kirimOtpVia,
          'noRegistrasi': noRegistrasi,
          'nama': nama,
          'email': email,
          'tanggalLahir': tanggalLahir,
          'idSekolahKelas': idSekolahKelas,
          'namaSekolahKelas': namaSekolahKelas,
          'jenis': userType.toUpperCase(),
          'imei': gDeviceID
        },
      );

      if (kDebugMode) {
        logger.log(
            'AUTH_SERVICE_API-CekValidasiRegistrasi: response >> $response');
      }

      if (response.data['meta']['code'] != 200) {
        throw DataException(message: response.data['message'] ?? gPesanError);
      }

      return response.data;
    } catch (e) {
      throw DataException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> simpanRegistrasi({
    required String imei,
    String? jwtSwitchOrtu,
  }) async {
    try {
      Map<String, dynamic> bodyParams = {'imei': imei};
      final Map<String, dynamic> additionalInfo = await gGetDeviceInfo();
      bodyParams.addAll(additionalInfo);

      final response = await _apiHelper.dio.post(
        'mobile/v1/auth/registrasi/simpan',
        data: bodyParams,
      );

      if (kDebugMode) {
        logger.log('AUTH_SERVICE_API-SimpanRegistrasi: response >> $response');
      }
      return response.data;
    } catch (e) {
      throw DataException(message: e.toString());
    }
  }

  Future<bool> simpanLogin({
    required String noRegistrasi,
    required String nomorHp,
    required String imei,
    required String siapa,
    String? jwtSwitchOrtu,
  }) async {
    try {
      Map<String, dynamic> bodyParams = {
        'noRegistrasi': noRegistrasi,
        'registeredNumber': nomorHp,
        'imei': imei,
        'siapa': siapa
      };
      final Map<String, dynamic> additionalInfo = await gGetDeviceInfo();
      bodyParams.addAll(additionalInfo);
      final response = await _apiHelper.dio.post(
        'mobile/v1//auth/login/update',
        data: bodyParams,
      );

      if (kDebugMode) {
        logger.log('AUTH_SERVICE_API-SimpanLogin: response >> $response');
      }
      return response.data['status'];
    } catch (e) {
      throw DataException(message: e.toString());
    }
  }

  Future<dynamic> fetchDefaultTahunAjaran() async {
    try {
      final response = await _apiHelper.dio.get('/auth/tahun_ajaran');

      return response.data['data'];
    } catch (e) {
      throw DataException(message: e.toString());
    }
  }

  // Future<Map<String, dynamic>> changeBundling({
  //   required String noRegistrasi,
  //   required int idBundle,
  //   required List<Map<String, dynamic>> daftarBundle,
  // }) async {
  //   try {
  //     final token = KreasiSharedPref().getTokenJWT() ?? '';
  //     final res = await _apiHelper.dio.post(
  //       '/auth/mobile/v1/login/ganti-bundling',
  //       data: {
  //         "noreg": noRegistrasi,
  //         "id_bundling": idBundle,
  //         "daftar_bundling": daftarBundle,
  //       },
  //       options: Options(
  //         headers: {
  //           "Authorization": "Bearer $token",
  //           "X-API-KEY": kDebugMode
  //               ? dotenv.env['X-API-KEY_DEV']
  //               : dotenv.env['X_API_KEY_PROD'],
  //         },
  //       ),
  //     );
  //     if (res.data['meta']['code'] != 200) {
  //       throw DataException(message: res.data['meta']['message']);
  //     }
  //     return res.data;
  //   } catch (e) {
  //     if (e is DioException) {
  //       throw DataException(message: e.response?.data['meta']?['message']);
  //     }
  //     rethrow;
  //   }
  // }

  Future<List<dynamic>?> getAnakList(Map<String, dynamic> params) async {
    try {
      final res = await _apiHelper.dio.post(
        '/auth/mobile/v1/login/ortu/get-anak-new',
        data: params,
        options: Options(
          headers: {
            "X-API-KEY": kDebugMode
                ? dotenv.env['X-API-KEY_DEV']
                : dotenv.env['X_API_KEY_PROD'],
          },
        ),
      );

      return res.data['data']?['daftar_anak'];
    } catch (e) {
      if (e is DioException) {
        throw DataException(message: e.response?.data['meta']?['message'] ?? gPesanError);
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getBundlingAnak(
      Map<String, dynamic> params) async {
    try {
      final res = await _apiHelper.dio.post(
        '/auth/mobile/v1/login/ortu/get-bundling',
        data: params,
        options: Options(
          headers: {
            "X-API-KEY": kDebugMode
                ? dotenv.env['X-API-KEY_DEV']
                : dotenv.env['X_API_KEY_PROD'],
          },
        ),
      );

      return res.data['data'];
    } catch (e) {
      if (e is DioException) {
        throw DataException(message: e.response?.data['meta']?['message'] ?? gPesanError);
      }
      rethrow;
    }
  }
}
