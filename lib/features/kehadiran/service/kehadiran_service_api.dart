import 'dart:convert';

import 'package:gokreasi_new/core/helper/dio_option_helper.dart';
import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';
import 'package:gokreasi_new/core/util/injector.dart';

import '../../../../core/helper/api_helper.dart';

/// [KehadiranServiceApi] merupakan service class penghubung provider dengan request api.
class KehadiranServiceApi {
  final ApiHelper _apiHelper = locator<ApiHelper>();

  Future<dynamic> fetchKehadiranMingguIni({
    required String noRegistrasi,
  }) async {
    var response = await _apiHelper.dio.get(
      '/presence/getkehadiran',
      options: DioOptionHelper().dioOption,
    );

    if (response.data is String) {
      response = jsonDecode(response.data);
    }

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }

    return response.data['data'];
  }
}
