import 'package:dio/dio.dart';
import 'package:gokreasi_new/core/config/global.dart';
import 'package:gokreasi_new/core/util/app_exceptions.dart';

class DioErrorHandler {
  static final DioErrorHandler _instance = DioErrorHandler._internal();

  factory DioErrorHandler() => _instance;

  DioErrorHandler._internal();

  /// [errorFromDio] digunakan untuk menghandle error dari Dio Exception
  static DataException errorFromDio(DioException e) {
    final err = e.response?.data;
    return DataException(
      message: (err is Map<String, dynamic>)
          ? (err['meta']?['message'] ?? err['message'] ?? gPesanError)
          : err ?? gPesanError,
    );
  }

  /// [errorFromResponse] digunakan untuk menghandle error dari Dio Response
  static DataException errorFromResponse(Response res) {
    return DataException(
      message: res.data['meta']?['message'] ??
          res.data['_meta']['message'] ??
          res.data['message'] ??
          gPesanError,
    );
  }
}
