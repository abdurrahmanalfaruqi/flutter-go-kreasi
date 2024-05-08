import 'dart:developer' as logger show log;
import 'package:flutter/foundation.dart';
import 'package:gokreasi_new/core/helper/api_helper.dart';
import 'package:gokreasi_new/core/helper/dio_option_helper.dart';
import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';
import 'package:gokreasi_new/core/util/injector.dart';

class PtnServiceApi {
  final ApiHelper _apiHelper = locator<ApiHelper>();

  Future<dynamic> fetchKampusImpianPilihan({
    required String noRegistrasi,
  }) async {
    if (kDebugMode) {
      logger.log(
          'PTN_SERVICE_API-FetchKampusImpianPilihan: START with params($noRegistrasi)');
    }

    final response = await _apiHelper.dio.get(
      '/ptn/api/v1/ptn-pilihan/$noRegistrasi',
    );

    if (kDebugMode) {
      logger.log(
          'PTN_SERVICE_API-FetchKampusImpianPilihan: response >> $response');
    }

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }

    return response.data;
  }

  Future<dynamic> putKampusImpian({
    required String noRegistrasi,
    required int pilihanKe,
    required int idJurusan,
    required int kodeTOB,
  }) async {
    if (kDebugMode) {
      logger.log('PTN_SERVICE_API-UpdateKampusImpian: '
          'START with params($noRegistrasi, $pilihanKe, $idJurusan)');
    }

    final response = await _apiHelper.dio.post(
      '/ptn/mobile/v1/ptn-pilihan/save',
      data: {
        "pilihan$pilihanKe": idJurusan,
        "no_register": noRegistrasi,
        "kode_tob": kodeTOB,
      },
      options: DioOptionHelper().dioOption,
    );

    if (kDebugMode) {
      logger.log('PTN_SERVICE_API-UpdateKampusImpian: response >> $response');
    }

    return response.data;
  }
}
