// import 'dart:convert';
import 'dart:developer' as logger show log;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gokreasi_new/core/helper/dio_option_helper.dart';
import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';
import 'package:gokreasi_new/core/util/injector.dart';

import '../../../../core/helper/api_helper.dart';

// $route['v4/rencanabelajar/list/menu'] = 'v4/rencanabelajar_controller/getListMenu';
// $route['v4/rencanabelajar/list/rencana'] = 'v4/rencanabelajar_controller/getListRencanaBelajar';
// $route['v4/rencanabelajar/simpanrencanabelajar'] = 'v4/rencanabelajar_controller/simpanrencanabelajar';
class RencanaBelajarServiceAPI {
  final ApiHelper _apiHelper = locator<ApiHelper>();

  Future<Map<String, dynamic>> fetchListMenu() async {
    if (kDebugMode) {
      logger.log('RENCANA_SERVICE_API-FetchListMenu: START');
    }
    Map<String, Object> result;
    try {
      final response = await _apiHelper.dio.get(
        '/kbm/mobile/v1/rencana-belajar/menu',
        options: DioOptionHelper().dioOption,
      );

      //    if (response.data['meta']['code'] != 200) {
      //   throw DataException(message: response.data['meta']['message']);
      // }

      return response.data;
    } on Exception catch (e) {
      if (kDebugMode) {
        logger.log('Exception-FetchListMenu: $e');
      }
      result = {'status': false, 'message': "Terjadi kesalahan"};
    } catch (error) {
      if (kDebugMode) {
        logger.log('FatalException-FetchListMenu: $error');
      }
      result = {'status': false, 'message': error};
    }

    return result;
  }

  Future<Map<String, dynamic>> fetchDataRencanaBelajar({
    required String noRegistrasi,
  }) async {
    if (kDebugMode) {
      logger.log('RENCANA_SERVICE_API-FetchDataRencanaBelajar: '
          'START with params($noRegistrasi)');
    }
    Map<String, Object> result;
    try {
      var response = await _apiHelper.dio.get(
        '/kbm/mobile/v1/rencana-belajar/$noRegistrasi',
        options: DioOptionHelper().dioOption,
      );

      // if (response.data['meta']['code'] != 200) {
      //   throw DataException(message: response.data['meta']['message']);
      // }

      return response.data;
    } on Exception catch (_) {
      result = {'status': false, 'message': "Terjadi kesalahan"};
    } catch (error) {
      result = {'status': false, 'message': error};
    }

    return result;
  }

  Future<int?> simpanRencanaBelajar({
    required String noRegistrasi,
    String? idRencana,
    required String menu,
    required String keterangan,
    required String awalRencanaDate,
    required String akhirRencanaDate,
    required String jenisSimpan,
    required Map<String, dynamic> argument,
    required bool isSelesai,
  }) async {
    try {
      argument.putIfAbsent('keterangan', () => keterangan);

      final response = await _apiHelper.dio.post(
        '/kbm/mobile/v1/rencana-belajar/simpan',
        options: DioOptionHelper().dioOption,
        data: {
          'no_register': noRegistrasi,
          'id_rencana_belajar': idRencana,
          'label': menu,
          'keterangan': keterangan,
          'tanggal_awal': awalRencanaDate,
          'tanggal_akhir': akhirRencanaDate,
          'data': argument,
          'is_selesai': isSelesai,
        },
      );

      if (response.data['meta']['code'] != 200) {
        throw DioErrorHandler.errorFromResponse(response);
      }

      return response.data['data']?['id_rencana_belajar'];
    } on DioException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-SimpanRencanaBelajar: $e');
      }
      rethrow;
    } catch (error) {
      if (kDebugMode) {
        logger.log('FatalException-SimpanRencanaBelajar: $error');
      }
      rethrow;
    }
  }
}
