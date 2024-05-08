import 'dart:developer' as logger show log;
import 'package:flutter/foundation.dart';
import 'package:gokreasi_new/core/helper/api_helper.dart';
import 'package:gokreasi_new/core/helper/dio_option_helper.dart';
import 'package:gokreasi_new/core/util/injector.dart';
import 'package:gokreasi_new/features/bookmark/domain/entity/bookmark.dart';
import '../../../../core/util/app_exceptions.dart';

class BookmarkServiceAPI {
  final ApiHelper _apiHelper = locator<ApiHelper>();

  Future<dynamic> updateBookmark({
    required List<BookmarkMapel> daftarBookmark,
    required String noRegister,
  }) async {
    try {
      final response = await _apiHelper.dio.post(
        '/data/mobile/v1/data/bookmark/update',
        data: {
          'no_register': noRegister,
          'daftarBookmark': daftarBookmark,
        },
        options: DioOptionHelper().dioOption,
      );

      if (kDebugMode) {
        logger
            .log("BOOKMARK_SERVICE_API-UpdateBookmark: response >> $response");
      }

      return response.data['status'];
    } catch (e) {
      throw DataException(message: e.toString());
    }
  }

  // ignore: non_constant_identifier_names
  Future<bool> AddBookmark({
    required int idKelompokUjian,
    required String noRegister,
    required int idsoal,
    required int nomorsoaldatabase,
    required String kodebab,
    required String namabab,
    required int kodetob,
    required int idbundel,
    required String kodepaket,
    required int idjenisproduk,
    required String namajenisproduk,
    required int nomorsoalsiswa,
    required String lastupdate,
    required String tanggalkedaluwarsa,
  }) async {
    try {
      final response = await _apiHelper.dio.post(
        '/data/mobile/v1/data/bookmark/add',
        data: {
          "no_register": noRegister,
          "id_kelompok_ujian": idKelompokUjian,
          "id_soal": idsoal,
          "nomor_soal": nomorsoaldatabase,
          "kode_bab": kodebab == '' ? null : kodebab,
          "nama_bab": namabab,
          "kode_tob": kodetob,
          "id_bundel": idbundel,
          "kode_paket": kodepaket,
          "id_jenis_produk": idjenisproduk,
          "nama_jenis_produk": namajenisproduk,
          "nomor_soal_siswa": nomorsoalsiswa,
          "last_update": lastupdate,
          "tanggal_kedaluwarsa":
              tanggalkedaluwarsa == '' ? null : tanggalkedaluwarsa
        },
        options: DioOptionHelper().dioOption,
      );

      if (kDebugMode) {
        logger
            .log("BOOKMARK_SERVICE_API-UpdateBookmark: response >> $response");
      }

      return response.data['meta']['code'] == 200;
    } catch (e) {
      throw DataException(message: e.toString());
    }
  }
}
