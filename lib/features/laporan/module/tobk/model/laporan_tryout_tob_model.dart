import 'dart:convert';

import 'package:gokreasi_new/features/laporan/module/tobk/model/laporan_tryout_nilai_model.dart';

import '../entity/laporan_tryout_tob.dart';
import 'laporan_tryout_pilihan_model.dart';

// ignore: must_be_immutable
class LaporanTryoutTobModel extends LaporanTryoutTob {
  bool? isSelected;
  LaporanTryoutTobModel({
    required String kode,
    required String nama,
    required String penilaian,
    required String link,
    required List<LaporanTryoutPilihanModel> pilihan,
    required List<LaporanTryoutNilaiModel> listNilai,
    required bool isExists,
    required String tanggalAkhir,
    this.isSelected,
  }) : super(
            kode: kode,
            nama: nama,
            penilaian: penilaian,
            link: link,
            pilihan: pilihan,
            listNilai: listNilai,
            isExists: isExists,
            tanggalAkhir: tanggalAkhir);

  factory LaporanTryoutTobModel.fromJson(Map<String, dynamic> json) =>
      LaporanTryoutTobModel(
        kode: json['kode_tob'].toString(),
        nama: json['nama_tob'],
        penilaian: json['penilaian'],
        link: (json['link'] == null || (json['link'] as String).isEmpty)
            ? ''
            : decodeLink(json['link']),
        pilihan: (json['info'] != null
                ? json['info'] as List
                : json['hasil'] as List)
            .map((val) => LaporanTryoutPilihanModel.fromJson(val))
            .toList(),
        isExists: json['link'] != null || (json['link'] as String).isNotEmpty,
        // isExists: json['isexists'] ?? false,
        tanggalAkhir: json['tanggal_akhir'],
        listNilai: (json['nilai_kelompok_ujian'] == null ||
                (json['nilai_kelompok_ujian'] as List<dynamic>).isEmpty)
            ? []
            : (json['nilai_kelompok_ujian'] as List<dynamic>)
                .map((nilai) => LaporanTryoutNilaiModel.fromJson(nilai))
                .toList(),
      );
}

String decodeLink(String encodedString) {
  String decodedString = encodedString;

  for (int i = 0; i < 3; i++) {
    final decodedBytes = base64Decode(decodedString);
    decodedString = utf8.decode(decodedBytes);
  }

  return decodedString;
}
