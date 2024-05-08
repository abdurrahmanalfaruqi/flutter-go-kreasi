import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import 'package:gokreasi_new/core/helper/dio_option_helper.dart';
import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';
import 'package:gokreasi_new/core/util/injector.dart';

import '../../../../../../core/helper/api_helper.dart';

class LaporanKuisServiceAPI {
  final ApiHelper _apiHelper = locator<ApiHelper>();

  Future<Map<String, dynamic>> fetchLaporanKuis({
    required String noRegistrasi,
    required String idSekolahKelas,
    required String tahunAjaran,
  }) async {
    if (kDebugMode) {
      logger.log('LAPORAN_SERVICE_API-FetchLaporanKuis: START with '
          'params($noRegistrasi, $idSekolahKelas, $tahunAjaran)');
    }
    final response = await _apiHelper.dio.get(
      '/laporan/mobile/v1/laporan/list-kuis/$noRegistrasi/${tahunAjaran.replaceAll('/', '-')}',
      options: DioOptionHelper().dioOption,
    );
    if (kDebugMode) {
      logger.log('LAPORAN_SERVICE_API-FetchLaporanKuis: Response >> $response');
    }

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }

    return response.data;
  }

  Future<Map<String, dynamic>> fetchLaporanJawabanKuis(
      {required String noRegistrasi,
      required String idSekolahKelas,
      required String tahunAjaran,
      required String kodequiz}) async {
    if (kDebugMode) {
      logger.log('LAPORAN_SERVICE_API-FetchLaporanKuis: START with '
          'params($noRegistrasi, $idSekolahKelas, $tahunAjaran)');
    }
    final response = await _apiHelper.dio.get(
        '/laporan/mobile/v1/laporan/laporan-kuis/$noRegistrasi/${tahunAjaran.replaceAll('/', '-')}/$kodequiz');

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }

    return response.data;
  }
}
