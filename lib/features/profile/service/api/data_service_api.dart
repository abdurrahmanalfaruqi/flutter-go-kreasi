import 'dart:async';
import 'dart:developer' as logger show log;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gokreasi_new/core/helper/dio_option_helper.dart';
import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';
import 'package:gokreasi_new/core/util/injector.dart';

import '../../../../core/helper/api_helper.dart';

class DataServiceAPI {
  final ApiHelper _apiHelper = locator<ApiHelper>();

  Future<dynamic> fetchAbout() async {
    final response = await _apiHelper.dio.get('/about');

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }
    return response.data['data'];
  }

  Future<Map<String, dynamic>> fetchAturan({
    required String noRegistrasi,
    required String tahunAjaran,
  }) async {
    try {
      final response = await _apiHelper.dio.get(
        '/data/mobile/v1/data/tata-tertib',
        data: {
          "no_register": noRegistrasi,
          "tahun_ajaran": tahunAjaran,
        },
        options: DioOptionHelper().dioOption,
      );

      return response.data['data'][0];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }

  Future<bool> setAturanSiswa({
    required String noRegistrasi,
    required int idTataTertib,
  }) async {
    try {
      final response = await _apiHelper.dio.post(
        '/data/mobile/v1/data/tata-tertib',
        data: {
          "data": [
            {
              "no_register": noRegistrasi,
              "id_tata_tertib": idTataTertib,
              "is_setuju": true,
            }
          ]
        },
        options: DioOptionHelper().dioOption,
      );

      return response.data['meta']['code'] == 200;
    } catch (e) {
      return false;
    }
  }

  Future<dynamic> fetchKelompokUjianPilihan({
    required String noRegistrasi,
  }) async {
    final response = await _apiHelper.dio.get(
      '/data/mobile/v1/OpsiKelompokUjian',
      options: DioOptionHelper().dioOption,
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }

    return response.data['data'];
  }

  Future<dynamic> fetchListKelompokUjianPilihan(
      {required String tingkatSekolah}) async {
    // final response = await _apiHelper.dio.get('/kelompokUjian/$tingkatSekolah');

    // if (response.data['meta']['code'] != 200) {
    //   throw DataException(message: response.data['meta']['message']);
    // }

    // return response.data['data'];
    return [];
  }

  Future<dynamic> setKelompokUjianPilihan({
    required String noRegistrasi,
    required List<String> daftarIdKelompokUjian,
  }) async {
    try {
      final response = await _apiHelper.dio.post(
        '/tryout/simpanmapelpilihan',
        data: {
          'nis': noRegistrasi,
          'idmapeluji': daftarIdKelompokUjian,
        },
      );

      return (response.data['meta']['code'] == 200);
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-SetKelompokUjianPilihan: $e');
      }
      return false;
    }
  }

  Future<dynamic> deleteAccount({
    required String nomorHp,
    required String noRegistrasi,
  }) async {
    final response = await _apiHelper.dio.delete('/auth/delete/$noRegistrasi');

    return response;
  }
}
