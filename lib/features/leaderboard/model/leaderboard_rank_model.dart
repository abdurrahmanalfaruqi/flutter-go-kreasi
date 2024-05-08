import 'package:equatable/equatable.dart';

class LeaderboardRankModel extends Equatable {
  final String noRegistrasi;
  final String namaLengkap;
  final String level;
  final String sort;
  final int rank;
  final String score;
  final String? profilePicture;

  const LeaderboardRankModel({
    required this.noRegistrasi,
    required this.namaLengkap,
    required this.level,
    required this.sort,
    required this.rank,
    required this.score,
    required this.profilePicture,
  });

  bool get isJuaraSatu => rank == 1;
  bool get isJuaraDua => rank == 2;
  bool get isJuaraTiga => rank == 3;
  bool get isBigThree => rank > 0 && rank <= 3;
  bool get isBigFive => rank > 0 && rank <= 5;

  factory LeaderboardRankModel.fromJson(Map<String, dynamic> json) =>
      LeaderboardRankModel(
        noRegistrasi: json['id'].toString(),
        namaLengkap: json['fullname'],
        level: json['level'] is int ? json['level'].toString() : json['level'],
        sort: json['sort'].toString(),
        rank: json['rank'],
        score: json['total'].toString(),
        profilePicture: json['profile_picture'],
      );

  @override
  List<Object> get props =>
      [noRegistrasi, namaLengkap, level, sort, rank, score];
}
