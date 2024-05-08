import 'dart:developer' as logger show log;
import 'package:flutter/foundation.dart';
import 'package:gokreasi_new/core/helper/api_helper.dart';
import 'package:gokreasi_new/core/util/injector.dart';
import 'package:gokreasi_new/features/leaderboard/leaderboardracing/model/data_ranking.dart';

class RankingServiceAPI {
  final ApiHelper _apiHelper = locator<ApiHelper>();

  static final RankingServiceAPI _instance = RankingServiceAPI._internal();

  factory RankingServiceAPI() => _instance;

  RankingServiceAPI._internal();

  Future<DataRanking?> getranking({
    required String noreg,
    required String idSekolahKelas,
    required int number,
    required String level,
    required String penanda,
    required String idgedung,
    required String jeniswaktu,
    required int? idBundlingAktif,
  }) async {
    try {
      var data = {
        'noreg': noreg,
        'idkelas': idSekolahKelas,
        'idkota': penanda,
        'idgedung': idgedung,
        jeniswaktu: number,
        'id_bundling': idBundlingAktif,
      };
      final response = await _apiHelper.dio.post(
        "/leaderboard/mobile/v1/leaderboard/racing/$level",
        data: data,
      );

      if (kDebugMode) {
        logger.log(
            "number: $number, level: $level, jeniswaktu: $jeniswaktu, noreg: $noreg, penanda: $penanda, idgedung: $idgedung, idSekolahKelas: $idSekolahKelas");
        logger.log("Parameter ${response.data}");
      }

      if (response.data['meta']['code'] != 200) {
        throw 'Error Network';
      }

      return DataRanking.fromJson(response.data['data'].first);
    } catch (e) {
      if (kDebugMode) {
        logger.log("Error Racing: $e");
      }
      return null;
    }
  }
}
