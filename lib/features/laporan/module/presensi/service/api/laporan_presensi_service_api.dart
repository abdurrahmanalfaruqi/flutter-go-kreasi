import 'package:dio/dio.dart';
import 'package:gokreasi_new/core/helper/dio_option_helper.dart';
import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';
import 'package:gokreasi_new/core/util/injector.dart';

import '../../../../../../core/helper/api_helper.dart';

class LaporanPresensiServiceAPI {
  final ApiHelper _apiHelper = locator<ApiHelper>();

  Future<List<dynamic>> fetchPresensiByTanggal({
    required String noRegistrasi,
    required String tanggal,
  }) async {
    try {
      final response = await _apiHelper.dio.get(
        '/laporan/mobile/v1/presensi/kbm/siswa/harian/'
        '$noRegistrasi/$tanggal',
        options: DioOptionHelper().dioOption,
      );

      return response.data['data'];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    } catch (e) {
      rethrow;
    }
  }
}
