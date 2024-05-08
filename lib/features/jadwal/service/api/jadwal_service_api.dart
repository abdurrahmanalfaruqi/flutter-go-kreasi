import 'dart:developer' as logger show log;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gokreasi_new/core/helper/dio_option_helper.dart';
import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';
import 'package:gokreasi_new/core/util/app_exceptions.dart';
import 'package:gokreasi_new/core/util/injector.dart';

import '../../../../core/helper/api_helper.dart';

class JadwalServiceApi {
  final ApiHelper _apiHelper = locator<ApiHelper>();

  static final JadwalServiceApi _instance = JadwalServiceApi._internal();

  factory JadwalServiceApi() => _instance;

  JadwalServiceApi._internal();

  Future<List<dynamic>> fetchTanggalJadwal({
    required int idKelas,
    required String tahunAjaran,
  }) async {
    try {
      final response = await _apiHelper.dio.get(
        '/kbm/mobile/v1/jadwal/kbm/siswa/tanggal-kbm',
        queryParameters: {
          'id_kelas': idKelas,
          'tahun_ajaran': tahunAjaran,
        },
        options: DioOptionHelper().dioOption,
      );

      return response.data['data'];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> fetchJadwalByTanggal({
    required int idKelas,
    required String tahunAjaran,
    required String tanggal,
  }) async {
    try {
      final response = await _apiHelper.dio.get(
        '/kbm/mobile/v1/jadwal/kbm/siswa/harian',
        queryParameters: {
          'id_kelas': idKelas,
          'tahun_ajaran': tahunAjaran,
          'tanggal': tanggal,
        },
        options: DioOptionHelper().dioOption,
      );

      final statusCode = response.statusCode ?? 0;
      bool isBerhasil = statusCode >= 200 && statusCode < 300;
      if (!isBerhasil || response.data['message'].contains('kosong')) {
        throw DataException(message: response.data['message']);
      }

      return response.data['data'];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> setPresensiSiswa(Map<String, dynamic> dataPresensi) async {
    try {
      final response = await _apiHelper.dio.post(
        '/kbm/mobile/v1/presensi/kbm/siswa',
        data: dataPresensi,
        options: DioOptionHelper().dioOption,
      );

      if (kDebugMode) {
        logger
            .log('JADWAL_SERVICE_API-SetPresensiSiswa: response >> $response');
      }

      return response.data['meta']['message'];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    } catch (_) {
      rethrow;
    }
  }

  Future<dynamic> setPresensiSiswaTst(Map<String, dynamic> dataPresensi) async {
    try {
      final response = await _apiHelper.dio.post(
        '/kbm/mobile/v1/presensi/tst/siswa',
        options: DioOptionHelper().dioOption,
        data: dataPresensi,
      );

      return response.data['meta']['message'];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    } catch (e) {
      rethrow;
    }
  }
}
