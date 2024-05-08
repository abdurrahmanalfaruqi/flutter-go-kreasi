import 'dart:developer' as logger show log;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gokreasi_new/core/config/constant.dart';
import 'package:gokreasi_new/core/helper/dio_option_helper.dart';
import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';
import 'package:gokreasi_new/core/util/injector.dart';

import '../../../../core/helper/api_helper.dart';

class VideoServiceApi {
  final ApiHelper _apiHelper = locator<ApiHelper>();
  final ApiHelper _smbaBaseurl =
      locator.get<ApiHelper>(instanceName: Constant.kBaseUrlSMBA);

  Future<List> fetchVideoTeori({
    required String noRegistrasi,
    required String kodeBab,
    required String levelTeori,
    required String kelengkapan,
    required String idTeoriBab,
    required String jenisBuku,
    required String namaMatapelajaran,
  }) async {
    if (kDebugMode) {
      logger.log('VIDEO_SERVICE_API-FetchVideoTeori: START with '
          'params($noRegistrasi, $kodeBab, $jenisBuku, nama $namaMatapelajaran)');
    }

    final response = await _apiHelper.dio.post(
      "/buku/mobile/v1/buku/teori/findvideoteori",
      data: {
        "kode_bab": kodeBab,
        "nama_kelompok_ujian": namaMatapelajaran,
        "kode_teori": int.parse(idTeoriBab)
      },
      options: DioOptionHelper().dioOption,
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }

    return response.data['data'] ?? [];
  }

  Future<dynamic> fetchVideoSoal({required int idVideo}) async {
    final response = await _apiHelper.dio.get(
      "/solusi/getvideo/$idVideo",
      options: DioOptionHelper().dioOption,
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }

    return response.data['data'];
  }

  Future<List<dynamic>> fetchVideoTeaser({
    required String idSekolahKelas,
    required String userType,
  }) async {
    try {
      final response = await _smbaBaseurl.dio.get(
        "/api/v1/smba/video-teaser",
        options: DioOptionHelper().dioOption,
      );

      return response.data['data'];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<List> fetchVideoJadwalMapel({
    String? noRegistrasi,
    required int jenisProduk,
    required List<int> listIdProduk,
  }) async {
    final response = await _apiHelper.dio.post(
      '/buku/mobile/v1/buku/video/getmapel',
      data: {"list_id_produk": listIdProduk},
      options: DioOptionHelper().dioOption,
    );

    if (kDebugMode) {
      logger.log('BUKU_SERVICE_API-FetchBuku: response >> $response');
    }

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }

    return response.data['data'] ?? [];
  }

  Future<List> fetchVideoJadwal(
      {required String noRegistrasi,
      required String idMataPelajaran,
      required int idBuku,
      required String levelTeori,
      required String kelengkapan}) async {
    final response = await _apiHelper.dio.post(
      "/buku/mobile/v1/buku/video/findbab",
      data: {
        "id_buku": idBuku,
        "level": levelTeori,
        "kelengkapan": kelengkapan
      },
      options: DioOptionHelper().dioOption,
    );

    if (kDebugMode) {
      logger.log(
          'VIDEO_SERVICE_API-FetchVideoJadwal: $idMataPelajaran response >> $response');
    }

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }

    return response.data['data'] ?? [];
  }
}
