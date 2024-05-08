import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gokreasi_new/api/dummy_data.dart';
import 'package:gokreasi_new/core/config/global.dart';
import 'package:gokreasi_new/core/helper/api_helper.dart';
import 'package:gokreasi_new/core/helper/dio_option_helper.dart';
import 'package:gokreasi_new/core/helper/kreasi_shared_pref.dart';
import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';
import 'package:gokreasi_new/features/soal/module/paket_soal/domain/repository/paket_soal_repository.dart';

class PaketSoalRepositoryImpl implements PaketSoalRepository {
  final ApiHelper _apiHelper;

  const PaketSoalRepositoryImpl(this._apiHelper);

  @override
  Future<Map<String, dynamic>> fetchDaftarPaketSoal(
      Map<String, dynamic>? params) async {
    bool isAppStore = gAkunTesterSiswa.contains(KreasiSharedPref().getNomorReg()) &&
        Platform.isIOS;
    String idJenisProduk = params?['idJenisProduk'];
    Map<String, dynamic> reqBody = {}
      ..['list_id_produk'] = params?['list_id_produk']
      ..['halaman'] = params?['halaman']
      ..['konten_per_halaman'] = params?['konten_per_halaman']
      ..['no_register'] = params?['no_register']
      ..['tingkat_kelas'] = params?['tingkat_kelas'];

    try {
      Response response;
      String url = '';
      switch (idJenisProduk) {
        case '72':
          url = '/buku-sakti/mobile/v2/daftar-paket/emwa';
          break;
        case '71':
          url = '/buku-sakti/mobile/v2/daftar-paket/emma';
          break;
        case '65':
          url = '/goa-vak/mobile/v1/vak-mobile/list';
          break;
        default:
      }

      if (idJenisProduk != '65') {
        response = await _apiHelper.dio.get(
          url,
          data: reqBody,
          options: DioOptionHelper().dioOption,
        );
      } else {
        response = await _apiHelper.dio.post(
          url,
          data: reqBody,
          options: DioOptionHelper().dioOption,
        );
      }

      if (response.data['meta']['code'] != 200) {
        if (isAppStore && idJenisProduk == '72') {
          return {
            "list_paket": gDummyEmwa['data']['list_paket'],
            "jumlah_halaman": gDummyEmwa['data']['jumlah_halaman'],
          };
        } else if (isAppStore && idJenisProduk == '71') {
          return {
            "list_paket": gDummyEmma['data']['list_paket'],
            "jumlah_halaman": gDummyEmma['data']['jumlah_halaman']
          };
        } else {
          throw DioErrorHandler.errorFromResponse(response);
        }
      }

      switch (idJenisProduk) {
        case '71':
        case '72':
          return {
            "list_paket": response.data['data']['list_paket'],
            "jumlah_halaman": response.data['data']['jumlah_halaman'],
          };

        default:
          return response.data['data'];
      }
    } on DioException catch (e) {
      if (isAppStore && idJenisProduk == '72') {
        return {
          "list_paket": gDummyEmwa['data']['list_paket'],
          "jumlah_halaman": gDummyEmwa['data']['jumlah_halaman'],
        };
      } else if (isAppStore && idJenisProduk == '71') {
        return {
          "list_paket": gDummyEmma['data']['list_paket'],
          "jumlah_halaman": gDummyEmma['data']['jumlah_halaman']
        };
      } else {
        throw DioErrorHandler.errorFromDio(e);
      }
    }
  }
}
