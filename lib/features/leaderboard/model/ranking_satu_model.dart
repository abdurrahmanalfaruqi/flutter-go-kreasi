class RankingSatuModel {
  final String noRegistrasi;
  final String namaLengkap;
  final String score;
  final String tipe;
  final String? photoUrl;

  RankingSatuModel({
    required this.noRegistrasi,
    required this.namaLengkap,
    required this.score,
    required this.tipe,
    this.photoUrl,
  });

  factory RankingSatuModel.fromJson(Map<String, dynamic> json) =>
      RankingSatuModel(
          noRegistrasi: json['noregistrasi'],
          namaLengkap: json['namalengkap'],
          score: json['total'].toString(),
          tipe: json['tipe']
              .replaceFirst(json['tipe'][0], json['tipe'][0].toUpperCase()),
          photoUrl: json['url']);

  Map<String, dynamic> toJson() => {
        'noregistrasi': noRegistrasi,
        'namalengkap': namaLengkap,
        'total': score,
        'tipe': tipe,
        'url': photoUrl
      };
}

class UndefinedRankingSatu extends RankingSatuModel {
  UndefinedRankingSatu({required String tipe})
      : super(
            noRegistrasi: '-', namaLengkap: '......', score: '...', tipe: tipe);
}
