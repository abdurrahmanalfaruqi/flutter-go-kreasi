import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioOptionHelper {
  static final DioOptionHelper _instance = DioOptionHelper._internal();

  factory DioOptionHelper() => _instance;

  DioOptionHelper._internal();

  final Options _dioOption = Options(
    headers: {
      "X-API-KEY": kDebugMode
          ? dotenv.env['X-API-KEY_DEV']
          : dotenv.env['X_API_KEY_PROD'],
    },
  );

  set setDioOption(String token) {
    _dioOption.headers?.putIfAbsent("Authorization", () => "Bearer $token");
  }

  Options get dioOption => _dioOption;
}
