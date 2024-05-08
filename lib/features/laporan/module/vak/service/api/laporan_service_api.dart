import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import 'package:gokreasi_new/core/helper/dio_option_helper.dart';
import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';
import 'package:gokreasi_new/core/util/injector.dart';

import '../../../../../../core/helper/api_helper.dart';

class LaporanServiceAPI {
  final ApiHelper _apiHelper = locator<ApiHelper>();

  Future<dynamic> fetchLaporanVak({
    required String noRegistrasi,
    required String userType,
  }) async {
    if (kDebugMode) {
      logger.log(
          'LAPORAN_VAK_SERVICE_API-FetchLaporanVak: START with params($noRegistrasi, $userType)');
    }

    final response = await _apiHelper.dio.get(
      '/laporan/mobile/v1/laporan/tvak/$noRegistrasi',
      options: DioOptionHelper().dioOption,
    );

    if (kDebugMode) {
      logger.log(
          'LAPORAN_VAK_SERVICE_API-FetchLaporanVak: response >> $response');
    }

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }
    return response.data['data'];
  }
}
