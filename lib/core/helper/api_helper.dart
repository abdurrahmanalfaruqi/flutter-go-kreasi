import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gokreasi_new/core/helper/dio_logging_interceptor.dart';
import 'package:requests_inspector/requests_inspector.dart';

class ApiHelper {
  final Dio dio;

  ApiHelper({
    required String baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) : dio = Dio(BaseOptions(
          connectTimeout: connectTimeout ?? const Duration(seconds: 24),
          receiveTimeout: receiveTimeout ?? const Duration(seconds: 24),
          baseUrl: baseUrl,
          headers: {
            "X-API-KEY": kDebugMode
                ? dotenv.env['X-API-KEY_DEV']
                : dotenv.env['X_API_KEY_PROD'],
          },
        ))
          ..interceptors.addAll([
            RequestsInspectorInterceptor(),
            DioLoggingInterceptor(),
          ]);
}
