part of 'leaderboard_racing_bloc.dart';

class LeaderboardRacingEvent extends Equatable {
  const LeaderboardRacingEvent();

  @override
  List<Object?> get props => [];
}

class LoadLeaderBoardRacing extends LeaderboardRacingEvent {
  final String noreg;
  final String idSekolahKelas;
  final int number;
  final String level;
  final String penanda;
  final String idGedung;
  final String jenisWaktu;
  final int? idBundlingAktif;
  final bool isRefresh;

  const LoadLeaderBoardRacing({
    required this.noreg,
    required this.idSekolahKelas,
    required this.number,
    required this.level,
    required this.penanda,
    required this.idGedung,
    required this.jenisWaktu,
    required this.idBundlingAktif,
    required this.isRefresh,
  });

  @override
  List<Object?> get props => [
        noreg,
        idSekolahKelas,
        number,
        level,
        penanda,
        idGedung,
        jenisWaktu,
        idBundlingAktif,
        isRefresh,
      ];
}
