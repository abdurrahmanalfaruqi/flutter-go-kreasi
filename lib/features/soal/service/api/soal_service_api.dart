import 'dart:developer' as logger show log;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gokreasi_new/core/config/constant.dart';
import 'package:gokreasi_new/core/helper/dio_option_helper.dart';
import 'package:gokreasi_new/core/helper/kreasi_shared_pref.dart';
import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';
import 'package:gokreasi_new/core/util/injector.dart';
import 'package:gokreasi_new/features/soal/module/bundel_soal/domain/entity/bundel_soal.dart';
import 'package:gokreasi_new/features/soal/module/paket_soal/data/model/jawaban_buku_sakti.dart';

import '../../../../core/helper/api_helper.dart';

class SoalServiceAPI {
  final ApiHelper _apiHelper = locator<ApiHelper>();

  static final SoalServiceAPI _instance = SoalServiceAPI._internal();

  factory SoalServiceAPI() => _instance;

  SoalServiceAPI._internal();

  Future<bool> simpanJawaban({
    required String tahunAjaran,
    required String noRegistrasi,
    required String idSekolahKelas,
    required String tipeUser,
    required String idKota,
    required String idGedung,
    required String kodeTOB,
    required String kodePaket,
    required String tingkatKelas,
    required int idJenisProduk,
    required int jumlahSoal,
    required String namaJenisProduk,
    required dynamic detailJawaban,
  }) async {
    String url = '';
    Map<String, dynamic> params = {
      'no_register': noRegistrasi,
      // 'role': tipeUser,
      'id_tingkat_kelas': tingkatKelas,
      'id_sekolah_kelas': idSekolahKelas,
      'id_kota': idKota,
      'id_gedung': idGedung,
      'tahun_ajaran': tahunAjaran,
      // 'kodetob': kodeTOB,
      'kode_paket': kodePaket,
      // 'jenisproduk': idJenisProduk,
      // 'jumsoal': jumlahSoal,
      'detil_jawaban': detailJawaban,
    };

    switch (namaJenisProduk) {
      case 'e-Latihan Extra':
        url = Constant.simpanLateks;
        break;
      case 'e-Empati Mandiri':
        url = Constant.simpanEMMA;
        break;
      case 'e-Empati Wajib':
        url = Constant.simpanEMWA;
        break;
      case 'e-Paket Intensif':
        url = Constant.simpanPakins;
        break;
      case 'e-Paket Soal Koding':
        url = Constant.simpanSokod;
        break;
      case 'e-Pendalaman Materi':
        url = Constant.simpanPenmat;
        break;
      case 'e-SoRef':
        url = Constant.simpanSoref;
        break;
      case 'e-VAK':
        url = Constant.simpanVAK;
        break;
      default:
        url = '/bukusoal/simpanjawabanV2';
    }
    final response = await _apiHelper.dio.post(
      url,
      data: params,
      options: DioOptionHelper().dioOption,
    );

    return response.data['meta']['code'] == 200;
  }

  Future<dynamic> fetchSolusi({required String idSoal}) async {
    if (kDebugMode) {
      logger.log('SOAL_SERVICE_API-FetchSolusi: START with params($idSoal)');
    }

    try {
      final response = await _apiHelper.dio.get(
        '/buku-sakti/mobile/v1/solusi-mobile/solusi/$idSoal',
        options: DioOptionHelper().dioOption,
      );

      return response.data['data'];
    } catch (e) {
      if (e is DioException) {
        throw DioErrorHandler.errorFromDio(e);
      }
      rethrow;
    }
  }

  Future<dynamic> fetchVideoSolusi({required String idVideo}) async {
    final response = await _apiHelper.dio.get(
      '/solusi/getvideo/$idVideo',
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }

    return response.data['data'];
  }

  Future<List<dynamic>> fetchSobatTips({
    required String idSoal,
    required String? idSekolahKelas,
    required List<int>? idProdukAktif,
  }) async {
    try {
      String? token = KreasiSharedPref().getTokenJWT();
      final response = await _apiHelper.dio.post(
        '/buku-sakti/mobile/v2/solusi-mobile/solusi/sobattips',
        data: {
          "id_soal": int.parse(idSoal),
          "id_sekolah_kelas": int.parse(idSekolahKelas ?? '0'),
          "id_produk": idProdukAktif,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "X-API-KEY": kDebugMode
                ? dotenv.env['X-API-KEY_DEV']
                : dotenv.env['X_API_KEY_PROD'],
          },
        ),
      );

      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }

  Future<List<dynamic>> fetchDetailHasilJawaban(
      {required String noRegistrasi,
      required String idSekolahKelas,
      required String jenisHasil,
      required String kodePaket,
      required int jumlahSoal,
      required int tingkatkelas,
      required}) async {
    String urllast =
        kodePaket.substring(0, kodePaket.indexOf("-")).toLowerCase();
    bool isPaket = true;
    String url = '';

    if (urllast == 'emma' ||
        urllast == 'emwa' ||
        urllast == 'vak' ||
        urllast == 'kuis' ||
        urllast == 'rac') {
      isPaket = true;
    } else {
      isPaket = false;
    }
    if (urllast != 'vak' && urllast != 'rac') {
      if (urllast == 'kuis') {
        url = Constant.hasilKuis;
      } else {
        url = Constant.hasilJawaban + urllast;
      }
    } else if (urllast == 'rac') {
      url = Constant.hasilRacing;
    } else {
      url = Constant.hasilVAK;
    }
    try {
      final response = await _apiHelper.dio.post(
        url,
        data: {
          "no_register": noRegistrasi,
          "id_tingkat_kelas": tingkatkelas,
          "tahun_ajaran": "2023/2024",
          "kode_paket": kodePaket,
          "is_paket": isPaket
        },
        options: DioOptionHelper().dioOption,
      );

      if (response.data['meta']['code'] != 200) {
        throw DioErrorHandler.errorFromResponse(response);
      }

      return response.data['data'] ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<List<JawabanBukuSakti>> getJawabanSiswaBukuSakti({
    required int idJenisProduk,
    required String noRegistrasi,
    required String idTingkatKelas,
    required String tahunAjaran,
    required String kodePaket,
    required OpsiUrut opsiUrut,
    String? idBundleSoal,
    String? kodeBab,
  }) async {
    try {
      Map<String, dynamic> params = {
        "no_register": noRegistrasi,
        "id_tingkat_kelas": idTingkatKelas,
        "tahun_ajaran": tahunAjaran,
        "kode_paket": kodePaket,
        "kode_bab": kodeBab
      };

      String url = '';
      switch (idJenisProduk) {
        case 65:
          url = Constant.getJawabanVAK;
          break;
        case 71:
          url = Constant.getJawabanEMMA;
          break;
        case 72:
          url = Constant.getJawabanEMWA;
          break;
        case 76:
          url = (opsiUrut == OpsiUrut.nomor)
              ? '/buku-sakti/mobile/v1/buku-sakti-mobile/get-jawaban-bundel/lateks'
              : Constant.getJawabanLateks;
          params.addAll({
            'id_bundel_soal': idBundleSoal,
          });
          break;
        case 77:
          url = (opsiUrut == OpsiUrut.nomor)
              ? '/buku-sakti/mobile/v1/buku-sakti-mobile/get-jawaban-bundel/paket-intensif'
              : Constant.getJawabanPakins;
          params.addAll({
            'id_bundel_soal': idBundleSoal,
          });
          break;
        case 78:
          url = (opsiUrut == OpsiUrut.nomor)
              ? '/buku-sakti/mobile/v1/buku-sakti-mobile/get-jawaban-bundel/soal-koding'
              : Constant.getJawabanSoKod;
          params.addAll({
            'id_bundel_soal': idBundleSoal,
          });
          break;
        case 79:
          url = (opsiUrut == OpsiUrut.nomor)
              ? '/buku-sakti/mobile/v1/buku-sakti-mobile/get-jawaban-bundel/pendalaman-materi'
              : Constant.getJawabanPenMat;
          params.addAll({
            'id_bundel_soal': idBundleSoal,
          });
          break;
        case 82:
          url = (opsiUrut == OpsiUrut.nomor)
              ? '/buku-sakti/mobile/v1/buku-sakti-mobile/get-jawaban-bundel/soal-referensi'
              : Constant.getJawabanSoRef;
          params.addAll({
            'id_bundel_soal': idBundleSoal,
          });
          break;
        default:
      }
      final res = await _apiHelper.dio.post(
        url,
        data: params,
        options: DioOptionHelper().dioOption,
      );
      if (res.data['meta']['code'] != 200) {
        throw DioErrorHandler.errorFromResponse(res);
      }

      return (res.data['data'] as List<dynamic>)
          .map((soal) => JawabanBukuSakti.fromJson(soal))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> postReportProblem(Map<String, dynamic> params) async {
    try {
      final res = await _apiHelper.dio.post(
        '/data/api/v1/go-expert-report',
        data: params,
        options: DioOptionHelper().dioOption,
      );

      return res.data['meta']?['code'] == 200;
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }

  Future<Map<String, dynamic>> fetchListBukuSoal(List<int> listIdProduk) async {
    try {
      final res = await _apiHelper.dio.post(
        '/buku-sakti/api/v1/buku-sakti/menu-buku-soal',
        data: {
          'list_id_produk': listIdProduk,
        },
        options: DioOptionHelper().dioOption,
      );

      return res.data['data'];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    } catch (e) {
      rethrow;
    }
  }
}
