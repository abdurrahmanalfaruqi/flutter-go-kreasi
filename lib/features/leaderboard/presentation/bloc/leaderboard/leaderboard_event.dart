part of 'leaderboard_bloc.dart';

abstract class LeaderboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadFristRankLeaderboard extends LeaderboardEvent {
  final String noRegistrasi;
  final String idSekolah;
  final String idKota;
  final String idGedung;
  final int idBundlingAktif;
  final bool onRefresh;

  LoadFristRankLeaderboard({
    required this.noRegistrasi,
    required this.idSekolah,
    required this.idKota,
    required this.idGedung,
    required this.idBundlingAktif,
    required this.onRefresh,
  });

  @override
  List<Object?> get props => [
        noRegistrasi,
        idSekolah,
        idKota,
        idGedung,
        onRefresh,
        idBundlingAktif,
      ];
}

class LoadLeaderboard extends LeaderboardEvent {
  final UserModel? userData;
  final String rankKay;
  final bool isRefresh;

  LoadLeaderboard(
      {required this.userData, required this.rankKay, required this.isRefresh});

  @override
  List<Object?> get props => [
        userData,
        rankKay,
        isRefresh,
      ];
}
