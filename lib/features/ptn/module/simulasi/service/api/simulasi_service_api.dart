import 'dart:developer' as logger show log;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gokreasi_new/core/helper/dio_option_helper.dart';
import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';
import 'package:gokreasi_new/core/util/injector.dart';

import '../../../../../../core/helper/api_helper.dart';

class SimulasiServiceAPI {
  final ApiHelper _apiHelper = locator<ApiHelper>();

  static final SimulasiServiceAPI _instance = SimulasiServiceAPI._internal();

  factory SimulasiServiceAPI() => _instance;

  SimulasiServiceAPI._internal();

  /// [fetchNilai] is used to fetch the student's score.
  ///
  /// Args:
  ///   noRegistrasi (String): NIS
  ///   idSekolahKelas (String): The id of the school class.
  ///
  /// Returns:
  ///   The response is a Map<String, dynamic>
  Future<List<dynamic>> fetchNilai({
    required String noRegistrasi,
    required List<int>? listIdProduk,
    required int idTingkatKelas,
  }) async {
    if (kDebugMode) {
      logger.log(
          'SIMULASI_SERVICE_API-FetchNilai: START with params($noRegistrasi)');
    }

    try {
      final response = await _apiHelper.dio.get(
        '/laporan/mobile/v1/tobk/utbk/all',
        data: {
          "no_register": noRegistrasi,
          "id_tingkat_kelas": idTingkatKelas,
          "list_id_produk": listIdProduk,
        },
        options: DioOptionHelper().dioOption,
      );

      // if (response.data['meta']['code'] != 200) {
      //   throw DataException(message: response.data['meta']['message']);
      // }

      return response.data['data'];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    } catch (e) {
      rethrow;
    }
  }

  /// [fetchPilihan] is used to fetch the data of the selected college.
  ///
  /// Args:
  ///   noRegistrasi (String): The registration number of the student
  ///
  /// Returns:
  ///   A Future<dynamic>
  Future<List<dynamic>> fetchPilihan({
    required String noRegistrasi,
  }) async {
    try {
      final response = await _apiHelper.dio.get(
        '/data/api/v1/snbt/siswa',
        options: DioOptionHelper().dioOption,
        queryParameters: {
          "no_register": noRegistrasi,
        },
      );

      return response.data['data'];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> fetchUniversitas({
    required String idSekolahKelas,
  }) async {
    if (kDebugMode) {
      logger.log('SIMULASI_SERVICE_API-FetchUniversitas: START with '
          'params($idSekolahKelas)');
    }

    final response = await _apiHelper.dio.post(
      '/simulasi/pilihan/universitas',
    );

    if (kDebugMode) {
      logger
          .log('SIMULASI_SERVICE_API-FetchUniversitas: Response >> $response');
    }

    // if (response.data['meta']['code'] != 200) {
    //   throw DataException(message: response.data['meta']['message']);
    // }

    return response.data['data'];
  }

  Future<List<dynamic>> fetchSimulasi({
    required String noRegistrasi,
    required int nilaiAkhir,
  }) async {
    try {
      final response = await _apiHelper.dio.post(
        '/data/api/v1/snbt',
        options: DioOptionHelper().dioOption,
        data: {
          "nilai_akhir": nilaiAkhir,
          "no_register": noRegistrasi,
        },
      );

      if (kDebugMode) {
        logger.log('SIMULASI_SERVICE_API-FetchSimulasi: Response >> $response');
      }

      return response.data['data'];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setPilihan({
    required String noRegistrasi,
    required String prioritas,
    required String status,
    required String idJurusan,
  }) async {
    if (kDebugMode) {
      logger.log('SIMULASI_SERVICE_API-SetPilihan: START with '
          'params($noRegistrasi, $prioritas, $status, $idJurusan)');
    }

    await _apiHelper.dio.post(
      '/simulasi/pilihan/simpan',
      data: {
        'noregistrasi': noRegistrasi,
        'prioritas': prioritas,
        'status': status,
        'idJurusan': idJurusan,
      },
    );

    // if (response.data['status']) {
    //   gShowTopFlash(
    //       gNavigatorKey.currentState!.context, 'Data pilihan berhasil disimpan',
    //       dialogType: DialogType.success);
    // } else {
    //   gShowBottomDialogInfo(gNavigatorKey.currentState!.context,
    //       title: 'Set Pilihan PTN', message: response.data['meta']['message']);
    // }
  }

  Future<bool> saveNilai({
    required String noRegister,
    required int kodeTOB,
    required int nilaiAkhir,
    required String detailNilai,
  }) async {
    try {
      final res = await _apiHelper.dio.post(
        '/data/api/v1/snbt/nilai',
        options: DioOptionHelper().dioOption,
        data: {
          "no_register": noRegister,
          "kode_tob": kodeTOB,
          "nilai_akhir": nilaiAkhir,
          "detail_nilai": detailNilai,
        },
      );

      return res.data['meta']?['code'] == 200;
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> savePTN(Map<String, dynamic> params) async {
    try {
      final res = await _apiHelper.dio.post(
        '/data/api/v1/snbt/ptn',
        options: DioOptionHelper().dioOption,
        data: params,
      );

      return res.data['meta']?['code'] == 200;
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    } catch (e) {
      rethrow;
    }
  }
}
