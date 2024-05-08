import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/core/config/extensions.dart';
import 'package:gokreasi_new/core/util/injector.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/home/domain/usecase/home_usecase.dart';
import 'package:gokreasi_new/features/leaderboard/model/leaderboard_rank_model.dart';
import 'package:gokreasi_new/features/leaderboard/model/ranking_satu_model.dart';

part 'leaderboard_event.dart';
part 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  // List<String> tipeLeaderboard = ['gedung', 'city', 'national'];
  final Map<String, List<RankingSatuModel>> _listRankingSatuBukuSakti = {};
  String pesan = '';

  final HashMap<String, List<LeaderboardRankModel>> _listTopFiveBukuSakti =
      HashMap();
  final HashMap<String, List<LeaderboardRankModel>>
      _listRankingTerdekatBukuSakti = HashMap();

  LeaderboardBloc() : super(LeaderboardState()) {
    on<LoadFristRankLeaderboard>((event, emit) async {
      try {
        emit(LeaderboardLoading());
        String leaderBoardKey =
            '${event.noRegistrasi}-${event.idBundlingAktif}';
        if (!event.onRefresh &&
            _listRankingSatuBukuSakti.containsKey(leaderBoardKey)) {
          emit(
            LeaderboardDataLoaded(
                listRankingSatuBukuSakti:
                    _listRankingSatuBukuSakti[leaderBoardKey]!),
          );
          return;
        }

        if (!_listRankingSatuBukuSakti.containsKey(leaderBoardKey)) {
          _listRankingSatuBukuSakti[leaderBoardKey] = [];
        }

        final params = {
          "idkelas": int.parse(event.idSekolah),
          "idkota": int.parse(event.idKota),
          "idgedung": int.parse(event.idGedung)
        };

        final responseData = await locator<GetFirstRankBukuSakti>().call(
          params: params,
        );

        _listRankingSatuBukuSakti[leaderBoardKey] = responseData
            .map((dynamic item) => RankingSatuModel.fromJson(item))
            .toList();
        if (!_listRankingSatuBukuSakti[leaderBoardKey]!
            .any((juara) => juara.tipe == "Nasional")) {
          _listRankingSatuBukuSakti[leaderBoardKey]!
              .insert(0, UndefinedRankingSatu(tipe: 'Nasional'));
        }
        if (!_listRankingSatuBukuSakti[leaderBoardKey]!
            .any((juara) => juara.tipe == "Kota")) {
          _listRankingSatuBukuSakti[leaderBoardKey]!
              .insert(1, UndefinedRankingSatu(tipe: 'Kota'));
        }
        if (!_listRankingSatuBukuSakti[leaderBoardKey]!
            .any((juara) => juara.tipe == "Gedung")) {
          _listRankingSatuBukuSakti[leaderBoardKey]!
              .insert(2, UndefinedRankingSatu(tipe: 'Gedung'));
        }

        emit(LeaderboardDataLoaded(
          listRankingSatuBukuSakti: _listRankingSatuBukuSakti[leaderBoardKey]!,
        ));
      } catch (e) {
        emit(LeaderboardError(e.toString()));
      }
    });

    on<LoadLeaderboard>((event, emit) async {
      try {
        String leaderBoardKey =
            '${event.userData?.noRegistrasi}-${event.userData?.idBundlingAktif}';

        String typeLeaderBoard = (event.rankKay.equalsIgnoreCase('kota'))
            ? 'city'
            : (event.rankKay.equalsIgnoreCase('nasional'))
                ? 'national'
                : 'gedung';

        String typeMyRank = (event.rankKay.equalsIgnoreCase('kota'))
            ? 'kota'
            : (event.rankKay.equalsIgnoreCase('nasional'))
                ? 'nasional'
                : 'gedung';

        if (_listRankingTerdekatBukuSakti[typeMyRank] != null &&
            _listRankingTerdekatBukuSakti[typeMyRank]!.isNotEmpty &&
            _listTopFiveBukuSakti[typeLeaderBoard] != null &&
            _listTopFiveBukuSakti[typeLeaderBoard]!.isNotEmpty &&
            event.isRefresh) {
        } else {
          emit(LeaderboardLoading());

          UserModel? userData = event.userData;
          final params = {
            "noreg": userData?.noRegistrasi,
            "idkelas": int.parse(userData?.idSekolahKelas ?? '0'),
            "idkota": int.parse(userData?.idKota ?? '0'),
            "idgedung": int.parse(userData?.idGedung ?? '0'),
            "idbundling": userData?.idBundlingAktif,
            "rankType": event.rankKay,
            "type": 'topFive',
            "tahun_ajaran": userData?.tahunAjaran,
          };

          final response = await locator<GetLeaderBoardBukuSakti>().call(
            params: params,
          );

          params['type'] = 'myrank';

          final responseMyrank = await locator<GetLeaderBoardBukuSakti>().call(
            params: params,
          );

          // clear list for initial state
          _listTopFiveBukuSakti[typeLeaderBoard]?.clear();

          // Data Ranking topFive dan terdekat dari API.
          final Map<String, dynamic>? dataRanking =
              response.containsKey(typeLeaderBoard)
                  ? response[typeLeaderBoard]
                  : null;

          if (dataRanking != null) {
            _setLeaderboardRank(dataRanking, typeLeaderBoard);
          }

          // Data Ranking topFive dan terdekat dari API.
          final Map<String, dynamic>? dataMyRanking =
              responseMyrank.containsKey(typeMyRank)
                  ? responseMyrank[typeMyRank]
                  : null;

          if (dataMyRanking != null) {
            _setLeaderboardRank(dataMyRanking, typeMyRank);
          }

          pesan = response['pesan'];
        }

        emit(LeaderboardDataLoaded(
          listRankingSatuBukuSakti: _listRankingSatuBukuSakti[leaderBoardKey]!,
          listRankingTerdekatBukuSakti: _listRankingTerdekatBukuSakti,
          listTopFiveBukuSakti: _listTopFiveBukuSakti,
          pesan: pesan,
        ));
      } catch (e) {
        emit(LeaderboardError(e.toString()));
      }
    });
  }

  void _setLeaderboardRank(
    Map<String, dynamic> leaderboardRankData,
    String keyTipe,
  ) {
    List<dynamic> topFive = leaderboardRankData.containsKey('topfive') &&
            leaderboardRankData['topfive'] != null
        ? leaderboardRankData['topfive']
        : [];

    List<dynamic> myRank = (leaderboardRankData.containsKey('myrank') &&
            leaderboardRankData['myrank'] != null)
        ? leaderboardRankData['myrank']
        : (leaderboardRankData.containsKey('topfive') &&
                leaderboardRankData['topfive'] != null)
            ? leaderboardRankData['topfive']
            : [];

    if (!_listTopFiveBukuSakti.containsKey(keyTipe)) {
      _listTopFiveBukuSakti[keyTipe] = [];
    }

    _listRankingTerdekatBukuSakti[keyTipe] = [];

    for (var data in topFive) {
      _listTopFiveBukuSakti[keyTipe]!.add(LeaderboardRankModel.fromJson(data));
    }

    for (var data in myRank) {
      _listRankingTerdekatBukuSakti[keyTipe]!
          .add(LeaderboardRankModel.fromJson(data));
    }
  }
}
