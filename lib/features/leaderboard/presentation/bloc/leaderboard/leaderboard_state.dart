part of 'leaderboard_bloc.dart';

class LeaderboardState {}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardDataLoaded extends LeaderboardState {
  List<RankingSatuModel> listRankingSatuBukuSakti;
  HashMap<String, List<LeaderboardRankModel>>? listTopFiveBukuSakti;
  HashMap<String, List<LeaderboardRankModel>>? listRankingTerdekatBukuSakti;
  String? pesan;

  LeaderboardDataLoaded(
      {required this.listRankingSatuBukuSakti,
      this.listRankingTerdekatBukuSakti,
      this.listTopFiveBukuSakti,
      this.pesan});

  List<Object> get props => [
        listRankingSatuBukuSakti,
        listRankingTerdekatBukuSakti!,
        listTopFiveBukuSakti!,
        pesan!
      ];
}

class LeaderboardError extends LeaderboardState {
  final String errorMessage;
  LeaderboardError(this.errorMessage);
}
