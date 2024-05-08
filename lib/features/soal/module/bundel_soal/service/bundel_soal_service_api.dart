import 'package:dio/dio.dart';
import 'package:gokreasi_new/core/helper/dio_option_helper.dart';
import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';
import 'package:gokreasi_new/core/util/injector.dart';

import '../../../../../core/helper/api_helper.dart';
import '../domain/entity/bundel_soal.dart';

class BundelSoalServiceApi {
  final ApiHelper _apiHelper = locator<ApiHelper>();

  // Future<Map<String, dynamic>> fetchDaftarBundel({
  //   required String idJenisProduk,
  //   required List<int> listIdProduk,
  //   required String noRegistrasi,
  // }) async {
  //   bool isAppStore = gAkunTester.contains(KreasiSharedPref().getNomorReg()) &&
  //       Platform.isIOS;
  //   try {
  //     String url = '';
  //     switch (idJenisProduk) {
  //       case '76':
  //         url = '/buku-sakti/mobile/v2/daftar-bundel/lateks';
  //         break;
  //       case '77':
  //         url = '/buku-sakti/mobile/v2/daftar-bundel/paket-intensif';
  //         break;
  //       case '78':
  //         url = '/buku-sakti/mobile/v2/daftar-bundel/soal-koding';
  //         break;
  //       case '79':
  //         url = '/buku-sakti/mobile/v2/daftar-bundel/pendalaman-materi';
  //         break;
  //       case '82':
  //         url = '/buku-sakti/mobile/v2/daftar-bundel/soal-referensi';
  //         break;
  //       default:
  //         url = '/buku-sakti/mobile/v2/daftar-bundel/lateks';
  //     }

  //     final response = await _apiHelper.dio.get(
  //       url,
  //       options: await dioOption(),
  //       data: {
  //         "list_id_produk": listIdProduk,
  //         "no_register": noRegistrasi,
  //       },
  //     );

  //     int statusCode = response.data['meta']['code'];
  //     if (statusCode != 200) {
  //       if (isAppStore) {
  //         switch (idJenisProduk) {
  //           case '77':
  //             return gDummyPakins['data'];
  //           case '79':
  //             return gDummyPenmat['data'];
  //           case '82':
  //             return gDummySoref['data'];
  //           default:
  //         }
  //       } else {
  //         throw DataException(message: 'Data tidak ditemukan');
  //       }
  //     }

  //     return response.data['data'];
  //   } on DioException catch (e) {
  //     if (isAppStore) {
  //       switch (idJenisProduk) {
  //         case '77':
  //           return gDummyPakins['data'];
  //         case '79':
  //           return gDummyPenmat['data'];
  //         case '82':
  //           return gDummySoref['data'];
  //         default:
  //         return gDummyPakins['data'];
  //       }
  //     } else {
  //       throw DataException(
  //         message: e.response?.data['meta']?['message'] ?? 'Terjadi Kesalahan',
  //       );
  //     }
  //   }
  // }

  // Future<List<dynamic>> fetchDaftarBabSubBab({
  //   required bool isJWT,
  //   required String idBundel,
  // }) async {
  //   final response = await _apiHelper.dio.get(
  //     '/buku-sakti/mobile/v2/daftar-bab/$idBundel',
  //     options: await dioOption(),
  //   );

  //   if (response.data['meta']['code'] != 200) {
  //     throw DataException(message: response.data['meta']['message']);
  //   }
  //   if (response.data['meta']['code'] != 200) {
  //     throw DataException(message: response.data['meta']['message']);
  //   }
  //   return response.data['data'];
  // }

  Future<List<dynamic>> fetchDaftarSoal({
    required bool isJWT,
    required String kodeBab,
    required String idBundel,
    required OpsiUrut opsiUrut,
  }) async {
    try {
      Response response;
      if (opsiUrut == OpsiUrut.bab) {
        response = await _apiHelper.dio.get(
          '/buku-sakti/mobile/v2/soal/bundel/$idBundel/$kodeBab',
          options: DioOptionHelper().dioOption,
        );
      } else {
        response = await _apiHelper.dio.get(
          '/buku-sakti/mobile/v2/soal/bundel/$idBundel',
          options: DioOptionHelper().dioOption,
        );
      }

      if (response.data['meta']['code'] != 200) {
        throw DioErrorHandler.errorFromResponse(response);
      }

      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> storeJawabanSiswa({
    required Map<String, dynamic> jawabanSiswa,
    required int idJenisProduk,
  }) async {
    try {
      String url = '';
      switch (idJenisProduk) {
        case 76:
          url = '/buku-sakti/mobile/v2/simpan-jawaban-bundel/lateks';
          break;
        case 77:
          url = '/buku-sakti/mobile/v2/simpan-jawaban-bundel/paket-intensif';
          break;
        case 78:
          url = '/buku-sakti/mobile/v2/simpan-jawaban-bundel/soal-koding';
          break;
        case 79:
          url = '/buku-sakti/mobile/v2/simpan-jawaban-bundel/pendalaman-materi';
          break;
        case 82:
          url = '/buku-sakti/mobile/v2/simpan-jawaban-bundel/soal-referensi';
          break;
        default:
          url = '/buku-sakti/mobile/v2/simpan-jawaban-bundel/lateks';
      }

      final res = await _apiHelper.dio.post(
        url,
        options: DioOptionHelper().dioOption,
        data: jawabanSiswa,
      );
      return res.data['meta']?['code'] == 200;
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }

  Future<List<dynamic>> getAllJawabanSiswa({
    required int idJenisProduk,
    required String noRegister,
    required String kodePaket,
    required String tahunAjaran,
  }) async {
    try {
      String url = '';
      switch (idJenisProduk) {
        case 76:
          url = '/buku-sakti/mobile/v2/get-jawaban-siswa-all/lateks';
          break;
        case 77:
          url = '/buku-sakti/mobile/v2/get-jawaban-siswa-all/paket-intensif';
          break;
        case 78:
          url = '/buku-sakti/mobile/v2/get-jawaban-siswa-all/soal-koding';
          break;
        case 79:
          url = '/buku-sakti/mobile/v2/get-jawaban-siswa-all/pendalaman-materi';
          break;
        case 82:
          url = '/buku-sakti/mobile/v2/get-jawaban-siswa-all/soal-referensi';
          break;
        default:
      }

      final res = await _apiHelper.dio.get(
        url,
        options: DioOptionHelper().dioOption,
        data: {
          "no_register": noRegister,
          "kode_paket": kodePaket,
          "tahun_ajaran": tahunAjaran,
        },
      );

      return res.data['data']['list_jawaban_siswa'] ?? [];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }
}
