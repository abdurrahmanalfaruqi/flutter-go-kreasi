import '../entity/sobat_tips_bab.dart';

class SobatTipsBabModel extends SobatTipsBab {
  const SobatTipsBabModel({
    required super.kodeBab,
    required super.namaBab,
    required super.idTeoriBab,
    required super.levelTeori,
    required super.kelengkapan,
    required super.idMataPelajaran,
    required super.mataPelajaran,
  });

  factory SobatTipsBabModel.fromJson(Map<String, dynamic> json) {
    // List<String> listIdTeori = [];
    //
    // if (json['c_idteoribab'] != null) {
    //   listIdTeori = '${json['c_idteoribab']}'.split(',');
    //   listIdTeori.sort((a, b) => a.compareTo(b));
    // }

    return SobatTipsBabModel(
      kodeBab: json['kode_bab'],
      namaBab: '${json['nama_bab']} (Teori ${json['kelengkapan']})',
      idTeoriBab: json['id_teori'].toString(),
      levelTeori: json['levelTeori'],
      kelengkapan: json['kelengkapan'],
      idMataPelajaran: json['id_mapel'].toString(),
      mataPelajaran: json['nama_mapel'],
      // listIdTeoriBab: listIdTeori,
    );
  }
}
