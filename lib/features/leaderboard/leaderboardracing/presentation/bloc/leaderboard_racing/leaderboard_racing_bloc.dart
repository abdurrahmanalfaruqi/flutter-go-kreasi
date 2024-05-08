import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/features/leaderboard/leaderboardracing/model/data_ranking.dart';
import 'package:gokreasi_new/features/leaderboard/leaderboardracing/service/api/ranking_service_api.dart';

part 'leaderboard_racing_event.dart';
part 'leaderboard_racing_state.dart';

class LeaderboardRacingBloc
    extends Bloc<LeaderboardRacingEvent, LeaderboardRacingState> {
  final Map<String, DataRanking> _dataRanking = {};

  final _apiService = RankingServiceAPI();

  LeaderboardRacingBloc() : super(const LeaderboardRacingState()) {
    on<LoadLeaderBoardRacing>(_onLoadLeaderBoardRacing);
  }

  void _onLoadLeaderBoardRacing(
      LoadLeaderBoardRacing event, Emitter<LeaderboardRacingState> emit) async {
    String leaderboardKey = '${event.noreg}-${event.idBundlingAktif}-'
        '${event.level}-${event.jenisWaktu}';
    try {
      if (!event.isRefresh && _dataRanking.containsKey(leaderboardKey)) {
        emit(state.copyWith(
          status: LeaderBoardRacingStatus.success,
          dataRanking: _dataRanking[leaderboardKey],
        ));
        return;
      }

      emit(state.copyWith(status: LeaderBoardRacingStatus.loading));

      final resDataRanking = await _apiService.getranking(
        noreg: event.noreg,
        idSekolahKelas: event.idSekolahKelas,
        number: event.number,
        level: event.level,
        penanda: event.penanda,
        idgedung: event.idGedung,
        jeniswaktu: event.jenisWaktu,
        idBundlingAktif: event.idBundlingAktif,
      );

      if (resDataRanking == null) {
        throw 'Data Kosong';
      }

      if (!_dataRanking.containsKey(leaderboardKey)) {
        _dataRanking[leaderboardKey] = const DataRanking();
      }

      resDataRanking.topFive?.sort((a, b) => a.rank.compareTo(b.rank));
      resDataRanking.myRank?.sort((a, b) => a.rank.compareTo(b.rank));

      _dataRanking[leaderboardKey] = resDataRanking;

      emit(state.copyWith(
        status: LeaderBoardRacingStatus.success,
        dataRanking: _dataRanking[leaderboardKey],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LeaderBoardRacingStatus.error,
        dataRanking: const DataRanking(),
      ));
    }
  }
}
