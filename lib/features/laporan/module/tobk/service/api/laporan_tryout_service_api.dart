import 'dart:developer' as logger show log;
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gokreasi_new/core/config/enum.dart';
import 'package:gokreasi_new/core/helper/dio_option_helper.dart';
import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';
import 'package:gokreasi_new/core/util/injector.dart';
import '../../../../../../core/helper/api_helper.dart';

class LaporanTryoutServiceAPI {
  final ApiHelper _apiHelper = locator<ApiHelper>();

  static final LaporanTryoutServiceAPI _instance =
      LaporanTryoutServiceAPI._internal();

  factory LaporanTryoutServiceAPI() => _instance;

  LaporanTryoutServiceAPI._internal();

  Future<dynamic> fetchLaporanTryout({
    required String noRegistrasi,
    required JenisTO jenisTO,
    required List<int>? listIdProduk,
    required int idTingkatKelas,
  }) async {
    try {
      Response response;
      switch (jenisTO) {
        case JenisTO.utbk:
          response = await _apiHelper.dio.get(
            '/laporan/mobile/v1/tobk/utbk/all',
            data: {
              "no_register": noRegistrasi,
              "id_tingkat_kelas": idTingkatKelas,
              "list_id_produk": listIdProduk,
            },
            options: DioOptionHelper().dioOption,
          );
          break;
          
        case JenisTO.ujianSekolah:
          response = await _apiHelper.dio.get(
            '/laporan/mobile/v1/tobk/ujian-sekolah/all',
            data: {
              "no_register": noRegistrasi,
              "id_tingkat_kelas": idTingkatKelas,
              "list_id_produk": listIdProduk,
            },
            options: DioOptionHelper().dioOption,
          );
          break;

        case JenisTO.stan:
          response = await _apiHelper.dio.get(
            '/laporan/mobile/v1/tobk/stan/all',
            data: {
              "no_register": noRegistrasi,
              "id_tingkat_kelas": idTingkatKelas,
              "list_id_produk": listIdProduk,
            },
            options: DioOptionHelper().dioOption,
          );
          break;

        default:
          response = await _apiHelper.dio.get(
            '/laporan/mobile/v1/tobk/anbk/all',
            data: {
              "no_register": noRegistrasi,
              "id_tingkat_kelas": idTingkatKelas,
              "list_id_produk": listIdProduk,
            },
            options: DioOptionHelper().dioOption,
          );
      }

      if (response.data['meta']['code'] != 200) {
        throw DioErrorHandler.errorFromResponse(response);
      }

      return response.data['data'];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    } catch (e) {
      rethrow;
    }
  }

  // Future<dynamic> fetchLaporanListTryout({
  //   required String userId,
  //   required String userClassLevelId,
  //   required String jenisTO,
  //   required String jenis,
  // }) async {
  //   if (kDebugMode) {
  //     logger.log("LAPORAN TRYOUT SERVICE: execute fetchLaporanTryout()");
  //   }
  //   final response = await _apiHelper.dio.post(
  //     '/tryout/laporan/list',
  //   );
  //   if (response.data['meta']['code'] != 200) {
  //     throw DataException(message: response.data['meta']['message']);
  //   }

  //   return response.data['data'];
  // }

  Future<dynamic> fetchLaporanNilai({
    required String userId,
    required String userClassLevelId,
    required String userType,
    required String kodeTOB,
    required String penilaian,
    required String pilihan1,
    required String pilihan2,
  }) async {
    final response = await _apiHelper.dio.post(
      '/laporan/api/v1/laporan/tobk-utbk/detail/detail',
      data: {
        "c_no_register": userId,
        "c_kode_tob": int.parse(kodeTOB),
      },
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }
    return response.data['data'];
  }

  Future<dynamic> fetchLaporanJawaban({
    required String kodeTOB,
    required String noRegister,
    required String tingkatKelas,
    required String jenisTOB,
  }) async {
    final response = await _apiHelper.dio.get(
      '/laporan/mobile/v1/tobk/hasil-jawaban/$kodeTOB',
      queryParameters: {
        "no_register": noRegister,
        "tingkat_kelas": tingkatKelas,
        "jenis_tob": jenisTOB,
      },
      options: DioOptionHelper().dioOption,
    );

    if (response.statusCode != null && response.statusCode! > 300) {
      throw DioErrorHandler.errorFromResponse(response);
    }
    return response.data;
  }

  Future<void> uploadFeed({
    String? userId,
    String? content,
    String? file64,
  }) async {
    final response = await _apiHelper.dio.post(
      '/upload/feed',
      data: {
        "nis": userId,
        "text": content,
        "file64": file64,
      },
    );
    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }
  }

  // Request token key to get url video stream.
  Future<dynamic> fetchEpbToken() async {
    final response = await _apiHelper.dio.get('');
    if (kDebugMode) {
      logger.log("cek nilai : $response");
    }
    Map<String, dynamic> data = jsonDecode(response.data.body);
    return data['message'];
  }

  Future<dynamic> fetchJenisTO({required String noregister}) async {
    try {
      final response = await _apiHelper.dio.post(
        '/laporan/api/v1/laporan/tobk/getlistjenistobk',
        data: {
          "c_no_register": noregister,
        },
      );
      if (response.data['meta']['code'] != 200) {
        throw DioErrorHandler.errorFromResponse(response);
      }
      return response.data['data'];
    } catch (e) {
      rethrow;
    }
  }
}
