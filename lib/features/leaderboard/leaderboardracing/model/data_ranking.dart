import 'package:equatable/equatable.dart';

class DataRanking extends Equatable {
  final List<MyRank>? topFive;
  final List<MyRank>? myRank;

  const DataRanking({this.topFive, this.myRank});

  factory DataRanking.fromJson(Map<String, dynamic> json) => DataRanking(
        topFive: (json['topfive'] != null && json['topfive'].isNotEmpty)
            ? (json['topfive'] as List).map((x) => MyRank.fromJson(x)).toList()
            : [],
        myRank: (json['myrank'] != null && json['myrank'].isNotEmpty)
            ? (json['myrank'] as List).map((x) => MyRank.fromJson(x)).toList()
            : [],
      );

  Map<String, dynamic> toJson() => {
        'topfive': (topFive == null || topFive?.isEmpty == true)
            ? []
            : topFive!.map((x) => x.toJson()).toList(),
        'myrank': (myRank == null || myRank?.isEmpty == true)
            ? []
            : myRank!.map((x) => x.toJson()).toList(),
      };

  @override
  List<Object?> get props => [topFive, myRank];
}

class MyRank {
  /// [id] merupakan variabel yang berisi No Registrasi Siswa
  final String id;

  /// [fullName] merupakan variabel yang berisi Nama Lengkap Siswa
  final String fullName;

  /// [level] merupakan variabel yang berisi idSekolahKelas Siswa
  final int level;

  /// [sort] merupakan variabel yang berisi data list ranking
  /// dan tidak ada menampilkan ranking kembar walaupun nilainya sama ex: (1,2,3,4,5)
  final int sort;

  /// [rank] merupakan variabel yang berisi data list ranking
  /// dan akan menampilkan ranking kembar jika nilainya sama ex: (1,2,2,3,4)
  final int rank;

  /// [total] merupakan variabel yang berisi total skor nilai racing siswa
  final int total;

  const MyRank({
    required this.id,
    required this.fullName,
    required this.level,
    required this.sort,
    required this.rank,
    required this.total,
  });

  factory MyRank.fromJson(Map<String, dynamic> json) => MyRank(
        id: json['id'] ?? '-',
        fullName: json['fullname'] ?? '-',
        level: json['level'] ?? 0,
        sort: json['sort'] ?? 0,
        rank: json['rank'] ?? 0,
        total: json['total'] ?? 0,
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['fullName'] = fullName;
    data['level'] = level;
    data['sort'] = sort;
    data['rank'] = rank;
    data['total'] = total;
    return data;
  }
}
