import 'package:dio/dio.dart';
import 'package:gokreasi_new/core/config/constant.dart';
import 'package:gokreasi_new/core/helper/dio_option_helper.dart';
import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';
import 'package:gokreasi_new/core/util/injector.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';

import '../../../../../core/helper/api_helper.dart';

class PaketSoalServiceApi {
  final ApiHelper _apiHelper = locator<ApiHelper>();

  Future<List<dynamic>> fetchDaftarTOBBersyarat({
    required String kodePaket,
  }) async {
    final response = await _apiHelper.dio.get(
      '/bukusoal/prasyarat/$kodePaket',
      options: DioOptionHelper().dioOption,
    );
    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }

    return response.data['data'] ?? [];
  }

  // Future<dynamic> fetchDaftarPaketSoal({
  //   required List<int> listIdProduk,
  //   required String idJenisProduk,
  //   required String noRegistrasi,
  //   int page = 1,
  //   int offset = 10,
  // }) async {
  //   bool isAppStore = gAkunTester.contains(KreasiSharedPref().getNomorReg()) &&
  //       Platform.isIOS;
  //   try {
  //     Response response;
  //     String url = '';
  //     switch (idJenisProduk) {
  //       case '72':
  //         url = '/buku-sakti/mobile/v2/daftar-paket/emwa';
  //         break;
  //       case '71':
  //         url = '/buku-sakti/mobile/v2/daftar-paket/emma';
  //         break;
  //       case '65':
  //         url = '/goa-vak/mobile/v1/vak-mobile/list';
  //         break;
  //       default:
  //     }

  //     if (idJenisProduk != '65') {
  //       response = await _apiHelper.dio.get(
  //         url,
  //         data: {
  //           "list_id_produk": listIdProduk,
  //           "halaman": page,
  //           "konten_per_halaman": offset,
  //           "no_register": noRegistrasi,
  //         },
  //         options: await dioOption(),
  //       );
  //     } else {
  //       response = await _apiHelper.dio.post(
  //         url,
  //         data: {
  //           "list_id_produk": listIdProduk,
  //           "halaman": page,
  //           "konten_per_halaman": offset,
  //           "no_register": noRegistrasi,
  //         },
  //         options: await dioOption(),
  //       );
  //     }

  //     if (kDebugMode) {
  //       logger.log(
  //           'PAKET_SOAL_SERVICE_API-FetchDaftarPaket: response >> $response');
  //     }

  //     if (response.data['meta']['code'] != 200) {
  //       if (isAppStore && idJenisProduk == '72') {
  //         return {
  //           "list_paket": gDummyEmwa['data']['list_paket'],
  //           "jumlah_halaman": gDummyEmwa['data']['jumlah_halaman'],
  //         };
  //       } else {
  //         throw DataException(message: response.data['meta']['message']);
  //       }
  //     }

  //     switch (idJenisProduk) {
  //       case '71':
  //       case '72':
  //         return {
  //           "list_paket": response.data['data']['list_paket'],
  //           "jumlah_halaman": response.data['data']['jumlah_halaman'],
  //         };
  //       case '65':
  //         return response.data['data'];

  //       default:
  //     }
  //   } on DioException catch (e) {
  //     if (isAppStore && idJenisProduk == '72') {
  //       return {
  //         "list_paket": gDummyEmwa['data']['list_paket'],
  //         "jumlah_halaman": gDummyEmwa['data']['jumlah_halaman'],
  //       };
  //     } else {
  //       throw DataException(message: e.response?.data['meta']?['message']);
  //     }
  //   }
  // }

  Future<List<dynamic>> fetchDaftarSoal({
    bool isJWT = true,
    required String kodePaket,
    required int idJenisProduk,
    required List<int> listId,
    required int? urutan,
  }) async {
    Response response;
    if (idJenisProduk != 65) {
      response = await _apiHelper.dio.get(
        '/buku-sakti/mobile/v2/soal/paket/$kodePaket/$urutan',
        options: DioOptionHelper().dioOption,
      );
    } else {
      response = await _apiHelper.dio.post(
        '/buku-sakti/mobile/v1/buku-sakti-mobile/soal/listbundel',
        options: DioOptionHelper().dioOption,
        data: {
          "list_id_bundel_soal": listId,
        },
      );
    }

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }

    return response.data['data'] ?? [];
  }

  Future<bool> setMulaiTO({
    required int idJenisProduk,
    required String noRegister,
    required String tahunAjaran,
    required String kodePaket,
    required int totalWaktuPaket,
    required String merk,
    required String versi,
    required String versiOS,
  }) async {
    try {
      String url = '';
      switch (idJenisProduk) {
        case 65:
          url = Constant.startVAK;
          break;
        case 71:
          url = Constant.startEMMA;
          break;
        case 72:
          url = Constant.startEMWA;
          break;
        default:
      }
      final res = await _apiHelper.dio.post(
        url,
        data: {
          "no_register": noRegister,
          "tahun_ajaran": tahunAjaran,
          "kode_paket": kodePaket,
          "total_waktu_paket": totalWaktuPaket,
          "merk": merk,
          "versi": versi,
          "versi_os": versiOS,
        },
        options: DioOptionHelper().dioOption,
      );

      if (res.data['meta']['code'] != 200) {
        throw DioErrorHandler.errorFromResponse(res);
      }

      return res.data['meta']['code'] == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> setSelesaiTO({
    required int idJenisProduk,
    required String kodePaket,
    required int tingkatKelas,
    required UserModel? userData,
  }) async {
    try {
      String url = '';
      Map<String, dynamic> params = {
        "no_register": userData?.noRegistrasi,
        "tahun_ajaran": userData?.tahunAjaran,
        "kode_paket": kodePaket,
        "tingkat_kelas": tingkatKelas,
      };
      switch (idJenisProduk) {
        case 65:
          url = Constant.endVAK;
          break;
        case 71:
          url = Constant.endEMMA;
          params.addAll({
            "nama_lengkap": userData?.namaLengkap,
            "id_kota": int.parse(userData?.idKota ?? '0'),
            "id_gedung": int.parse(userData?.idGedung ?? '0'),
            "id_sekolah_kelas": int.parse(userData?.idSekolahKelas ?? '0'),
            "id_bundling": userData?.idBundlingAktif,
          });
          break;
        case 72:
          url = Constant.endEMWA;
          params.addAll({
            "nama_lengkap": userData?.namaLengkap,
            "id_kota": int.parse(userData?.idKota ?? '0'),
            "id_gedung": int.parse(userData?.idGedung ?? '0'),
            "id_sekolah_kelas": int.parse(userData?.idSekolahKelas ?? '0'),
            "id_bundling": userData?.idBundlingAktif,
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

      return res.data['meta']['code'] == 200;
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
        case 71:
          url = '/buku-sakti/mobile/v2/simpan-jawaban-bundel/emma';
          break;
        case 72:
          url = '/buku-sakti/mobile/v2/simpan-jawaban-bundel/emwa';
          break;
        case 65:
          url = '/goa-vak/mobile/v1/vak-mobile/simpan-jawaban';
          break;
        default:
      }

      final res = await _apiHelper.dio.post(
        url,
        data: jawabanSiswa,
        options: DioOptionHelper().dioOption,
      );

      return res.data['meta']?['code'] == 200;
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }

  Future<List<dynamic>> fetchDetailWaktu({
    required int idJenisProduk,
    required String kodePaket,
  }) async {
    try {
      String url = Constant.waktuPaket;

      final res = await _apiHelper.dio.get(
        url + kodePaket,
        options: DioOptionHelper().dioOption,
      );

      return res.data['data'] ?? [];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }
}
