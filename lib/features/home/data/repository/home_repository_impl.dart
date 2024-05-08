import 'package:dio/dio.dart';
import 'package:gokreasi_new/core/helper/api_helper.dart';
import 'package:gokreasi_new/core/helper/dio_option_helper.dart';
import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';
import 'package:gokreasi_new/features/home/domain/repository/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final ApiHelper _apiHelper;

  const HomeRepositoryImpl(this._apiHelper);

  @override
  Future<List> fetchCarousel() async {
    try {
      final response = await _apiHelper.dio.get(
        '/data/api/v1/data/carousel',
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

  @override
  Future<Map<String, dynamic>> fetchCapaianScore(
      Map<String, dynamic>? params) async {
    try {
      final response = await _apiHelper.dio.post(
        '/leaderboard/mobile/v1/leaderboard/buku-soal/capaian',
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

  @override
  Future<List> fetchCapaianBar(Map<String, dynamic>? params) async {
    try {
      final response = await _apiHelper.dio.post(
        '/leaderboard/mobile/v1/leaderboard/buku-soal/capaian-bar',
        data: params,
        options: DioOptionHelper().dioOption,
      );

      return response.data['data'];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }

  @override
  Future<List> fetchFirstRankBukuSakti(Map<String, dynamic>? params) async {
    try {
      final response = await _apiHelper.dio.post(
        '/leaderboard/mobile/v1/leaderboard/buku-soal/first-rank',
        data: params,
        options: DioOptionHelper().dioOption,
      );

      if (response.data['meta']['code'] != 200) {
        throw DioErrorHandler.errorFromResponse(response);
      }
      return response.data['data'];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> fetchLeaderBoardBukuSakti(
      Map<String, dynamic>? params) async {
    try {
      String url = '';
      if (params?['type'] == 'myrank') {
        url =
            '/leaderboard/mobile/v1/leaderboard/buku-soal/myrank/${params?['rankType']}';
      } else {
        url =
            '/leaderboard/mobile/v1/leaderboard/buku-soal/${params?['rankType']}';
      }

      // delete type from request body
      params?.removeWhere((key, value) => key == 'type');

      final response = await _apiHelper.dio.post(
        url,
        data: params,
        options: DioOptionHelper().dioOption,
      );

      if (response.data['meta']['code'] != 200) {
        throw DioErrorHandler.errorFromResponse(response);
      }

      return response.data['data'][0];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }

  @override
  Future<Map<String, dynamic>> fetchPembayaran(
      Map<String, dynamic>? params) async {
    try {
      final response = await _apiHelper.dio.get(
        '/data/mobile/v1/data/pembayaran/get-pembayaran',
        data: params,
        options: DioOptionHelper().dioOption,
      );

      if (response.data['meta']['code'] != 200) {
        throw DioErrorHandler.errorFromResponse(response);
      }

      return response.data;
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }

  @override
  Future<List> fetchDetailPembayaran(Map<String, dynamic>? params) async {
    try {
      final response = await _apiHelper.dio.get(
        '/data/mobile/v1/data/pembayaran/get-detail-pembayaran',
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

  @override
  Future<List> fetchUniversitas(Map<String, dynamic>? params) async {
    try {
      final response = await _apiHelper.dio.get(
        '/ptn/mobile/v1/universitas',
        options: DioOptionHelper().dioOption,
      );
      return response.data['data'];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }

  @override
  Future<List> fetchJurusan(Map<String, dynamic>? params) async {
    try {
      final response = await _apiHelper.dio.get(
        '/ptn/mobile/v1/universitas/${params?['idPtn']}',
        options: DioOptionHelper().dioOption,
      );
      return response.data['data'];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<List> cekTOB(Map<String, dynamic>? params) async {
    try {
      final response = await _apiHelper.dio.get(
        '/ptn/mobile/v1/ptn-pilihan/cek-tob',
        data: params,
        options: DioOptionHelper().dioOption,
      );
      return response.data['data'];
    } on DioException catch (_) {
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getKampusImpian(
      Map<String, dynamic>? params) async {
    try {
      final res = await _apiHelper.dio.get(
        '/ptn/mobile/v1/ptn-pilihan/get/${params?['noRegistrasi']}',
        options: DioOptionHelper().dioOption,
      );
      return res.data['data'];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getKampusImpianByTOB(
      Map<String, dynamic>? params) async {
    try {
      final res = await _apiHelper.dio.get(
        '/ptn/mobile/v1/ptn-pilihan/get/${params?['noRegistrasi']}',
        options: DioOptionHelper().dioOption,
        queryParameters: params,
      );
      return res.data['data'];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getDetailJurusan(
      Map<String, dynamic>? params) async {
    try {
      final response = await _apiHelper.dio.get(
        '/ptn/mobile/v1/universitas/jurusan/${params?['idJurusan']}',
        options: DioOptionHelper().dioOption,
      );
      return response.data['data'];
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getPromotionEvent(
      Map<String, dynamic>? params) async {
    try {
      final response = await _apiHelper.dio.get(
        '/data/api/v1/banner-promo',
        options: DioOptionHelper().dioOption,
      );
      return response.data;
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    } catch (e) {
      rethrow;
    }
  }
}
