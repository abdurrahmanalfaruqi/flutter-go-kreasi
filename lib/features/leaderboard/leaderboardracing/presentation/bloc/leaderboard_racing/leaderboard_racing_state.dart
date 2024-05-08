part of 'leaderboard_racing_bloc.dart';

enum LeaderBoardRacingStatus { initial, loading, success, error }

class LeaderboardRacingState extends Equatable {
  final LeaderBoardRacingStatus status;
  final DataRanking? dataRanking;

  const LeaderboardRacingState({
    this.status = LeaderBoardRacingStatus.initial,
    this.dataRanking,
  });

  LeaderboardRacingState copyWith({
    LeaderBoardRacingStatus? status,
    DataRanking? dataRanking,
  }) =>
      LeaderboardRacingState(
        status: status ?? this.status,
        dataRanking: dataRanking ?? this.dataRanking,
      );

  @override
  List<Object?> get props => [status, dataRanking];
}
