import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gokreasi_new/api/dummy_data.dart';
import 'package:gokreasi_new/core/config/global.dart';
import 'package:gokreasi_new/core/helper/api_helper.dart';
import 'package:gokreasi_new/core/helper/dio_option_helper.dart';
import 'package:gokreasi_new/core/helper/kreasi_shared_pref.dart';
import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';
import 'package:gokreasi_new/core/util/app_exceptions.dart';
import 'package:gokreasi_new/features/soal/module/bundel_soal/domain/repository/bundel_soal_repository.dart';

class BundelSoalRepositoryImpl implements BundelSoalRepository {
  final ApiHelper _apiHelper;

  const BundelSoalRepositoryImpl(this._apiHelper);

  @override
  Future<Map<String, dynamic>> fetchDaftarBundel(
      Map<String, dynamic>? params) async {
    bool isAppStore = gAkunTesterSiswa.contains(KreasiSharedPref().getNomorReg()) &&
        Platform.isIOS;
    String idJenisProduk = params?['idJenisProduk'];
    try {
      String url = '';
      Map<String, dynamic> reqBody = {}
        ..['list_id_produk'] = params?['list_id_produk']
        ..['no_register'] = params?['no_register'];

      switch (idJenisProduk) {
        case '76':
          url = '/buku-sakti/mobile/v2/daftar-bundel/lateks';
          break;
        case '77':
          url = '/buku-sakti/mobile/v2/daftar-bundel/paket-intensif';
          break;
        case '78':
          url = '/buku-sakti/mobile/v2/daftar-bundel/soal-koding';
          break;
        case '79':
          url = '/buku-sakti/mobile/v2/daftar-bundel/pendalaman-materi';
          break;
        case '82':
          url = '/buku-sakti/mobile/v2/daftar-bundel/soal-referensi';
          break;
        default:
          url = '/buku-sakti/mobile/v2/daftar-bundel/lateks';
      }

      final response = await _apiHelper.dio.get(
        url,
        options: DioOptionHelper().dioOption,
        data: reqBody,
      );

      int statusCode = response.data['meta']['code'];
      if (statusCode != 200) {
        if (isAppStore) {
          switch (idJenisProduk) {
            case '77':
              return gDummyPakins['data'];
            case '79':
              return gDummyPenmat['data'];
            case '82':
              return gDummySoref['data'];
            default:
          }
        } else {
          throw DataException(message: 'Data tidak ditemukan');
        }
      }

      return response.data['data'];
    } on DioException catch (e) {
      if (isAppStore) {
        switch (idJenisProduk) {
          case '77':
            return gDummyPakins['data'];
          case '79':
            return gDummyPenmat['data'];
          case '82':
            return gDummySoref['data'];
          default:
            return gDummyPakins['data'];
        }
      } else {
        throw DioErrorHandler.errorFromDio(e);
      }
    }
  }

  @override
  Future<List> fetchDaftarBabSubBab(Map<String, dynamic>? params) async {
    try {
      String idBundel = params?['id_bundel'];
      final response = await _apiHelper.dio.get(
        '/buku-sakti/mobile/v2/daftar-bab/$idBundel',
        options: DioOptionHelper().dioOption,
      );

      if (response.data['meta']['code'] != 200) {
        throw DioErrorHandler.errorFromResponse(response);
      }
      return response.data['data'];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }
}
