import '../entity/nilai.dart';

class NilaiModel extends Nilai {
  NilaiModel({
    required String kodeTob,
    required String tob,
    required bool isSelected,
    required bool isFix,
    Map<String, dynamic>? detailNilai,
  }) : super(
          kodeTob: kodeTob,
          tob: tob,
          isSelected: isSelected,
          isFix: isFix,
          detailNilai: detailNilai!,
        );

  factory NilaiModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> detailNilai = {};
    for (var nilai in json['nilai_kelompok_ujian']) {
      detailNilai.addAll({nilai['nama_kelompok_ujian']: nilai['nilai']});
    }

    if (json['info'] != null || (json['info'] as List).isNotEmpty) {
      detailNilai
          .addAll({'Nilai Akhir': (json['info'] as List).first['nilai']});
    }

    return NilaiModel(
      kodeTob: (json['kode_tob'] == null) ? '' : json['kode_tob'].toString(),
      tob: json['nama_tob'],
      isSelected: json['isSelected'] ?? true,
      isFix: json['isFix'] ?? false,
      detailNilai: detailNilai,
    );
  }
}

class DetailNilaiModel {
  String? mapel;
  int? nilai;
  String? kelompok;

  DetailNilaiModel({
    this.mapel,
    this.nilai,
    this.kelompok,
  });

  factory DetailNilaiModel.fromJson(Map<String, dynamic> json) =>
      DetailNilaiModel(
        mapel: json['mapel'],
        nilai: json['nilai'],
        kelompok: json['kelompok'],
      );

  Map<String, dynamic> toJson() => {
        'mapel': mapel,
        'nilai': nilai,
      };
}
