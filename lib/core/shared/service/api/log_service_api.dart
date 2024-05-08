import 'dart:async';
import 'package:gokreasi_new/core/helper/api_helper.dart';
import 'package:gokreasi_new/core/helper/dio_option_helper.dart';
import 'package:gokreasi_new/core/util/injector.dart';

// import '../../../helper/api_helper.dart';
// import '../../../util/app_exceptions.dart';

class LogServiceAPI {
  final ApiHelper _apiHelper = locator<ApiHelper>();

  Future<int?> setLog(
      {required String userType,
      required List<Map<String, dynamic>> listLog,
      required String platform,
      int? lastid}) async {
    final dynamic response;
    int lastindex = listLog.length - 1;

    if (lastid == null) {
      final responsedata = await _apiHelper.dio.post(
          '/laporan/mobile/v1/laporan/log-aktivitas-siswa-create',
          options: DioOptionHelper().dioOption,
          data: {
            "noRegister": int.parse(listLog[lastindex]['nis']),
            "menu": listLog[lastindex]['menu'],
            "keterangan": listLog[lastindex]['keterangan']
          });
      response = responsedata.data;
      return response['data']['id'];
    } else {
      final responsedata = await _apiHelper.dio.put(
          '/laporan/mobile/v1/laporan/log-aktivitas-siswa-update',
          options: DioOptionHelper().dioOption,
          data: {
            "noRegister": int.parse(listLog[lastindex]['nis']),
            "id": lastid
          });
      response = responsedata.data;
      return null;
    }
  }
}
