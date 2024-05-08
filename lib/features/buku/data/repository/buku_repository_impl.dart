import 'package:dio/dio.dart';
import 'package:gokreasi_new/core/helper/api_helper.dart';
import 'package:gokreasi_new/core/helper/dio_option_helper.dart';
import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';
import 'package:gokreasi_new/features/buku/domain/repository/buku_repository.dart';

class BukuRepositoryImpl implements BukuRepository {
  final ApiHelper _apiHelper;

  const BukuRepositoryImpl(this._apiHelper);

  @override
  Future<List> fetchDaftarBuku(Map<String, dynamic>? params) async {
    try {
      String jenis = "teori";
      if (params?['id_jenis_produk'] == 46) {
        jenis = "teori-rumus";
      }
      final response = await _apiHelper.dio.post(
        '/buku/mobile/v1/buku/$jenis',
        data: params,
        options: DioOptionHelper().dioOption,
      );

      if (response.data['meta']['code'] != 200) {
        throw DioErrorHandler.errorFromResponse(response);
      }

      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }

  @override
  Future<List> fetchDaftarBab(Map<String, dynamic>? params) async {
    try {
      String jenis = "teori";
      if (params?['kelengkapan'] == "Rumus") {
        jenis = "teori-rumus";
      }
      final response = await _apiHelper.dio.post(
        '/buku/mobile/v1/buku/$jenis/findbab',
        data: params,
        options: DioOptionHelper().dioOption,
      );
      if (response.data['meta']['code'] != 200) {
        throw DioErrorHandler.errorFromResponse(response);
      }

      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }

  @override
  Future<Map<String, dynamic>> fetchContent(
      Map<String, dynamic>? params) async {
    try {
      String jenisbuku = "teori";
      if (params?['jenis'] == "Rumus") {
        jenisbuku = "teori-rumus";
      }

      final response = await _apiHelper.dio.post(
        '/buku/mobile/v1/buku/$jenisbuku/findteori',
        data: params,
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
