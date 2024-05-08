import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import '../../service/api/laporan_tryout_service_api.dart';
import '../../../../../../core/util/app_exceptions.dart';

class LaporanTryoutProvider extends ChangeNotifier {
  final _apiService = LaporanTryoutServiceAPI();

  /// [fetchEpbToken] Ini untuk mengambil token bagi pengguna untuk mengakses EPB.
  // Future<String> fetchEpbToken() async {
  //   try {
  //     final responseData = await _apiService.fetchEpbToken();
  //     Codec<String, String> stringToBase64 = utf8.fuse(base64);
  //     String encoded = stringToBase64.encode(responseData.toString());
  //     encoded = stringToBase64.encode(encoded);
  //     encoded = stringToBase64.encode(encoded);

  //     return encoded;
  //   } on NoConnectionException {
  //     rethrow;
  //   } on DataException catch (e) {
  //     if (kDebugMode) {
  //       logger.log('Exception-FetchTokenLaporanTryoutEpb: $e');
  //     }
  //     rethrow;
  //   } catch (e) {
  //     if (kDebugMode) {
  //       logger.log('FatalException-FetchTokenLaporanTryoutEpb: $e');
  //     }
  //     throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
  //   }
  // }

  /// [uploadFeed] untuk mengupload feed Nilai TO dan feed ranking.
  ///
  /// Args:
  ///   userId (String): nomor registrasi.
  ///   content (String): Isi dari feed (berupa text).
  ///   file64 (String): url gambar dari feed tersebut.
  Future<void> uploadFeed(
      {String? userId, String? content, String? file64}) async {
    try {
      await _apiService.uploadFeed(
          userId: userId, content: content, file64: file64);
    } on NoConnectionException {
      rethrow;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-Data-UploadFeed: $e');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-Data-UploadFeed: $e');
      }
      return;
    }
  }
}
