import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/features/laporan/module/tobk/model/laporan_tryout_nilai_model.dart';

import '../model/laporan_tryout_pilihan_model.dart';

class LaporanTryoutTob extends Equatable {
  /// [kode] Variabel untuk menyimpan data kode TO.
  final String kode;

  /// [nama] Variabel untuk menyimpan data nama TO.
  final String nama;

  /// [penilaian] Variabel untuk menyimpan data jenis penilaian.
  final String penilaian;

  /// [link] Variabel untuk menyimpan data link EPB.
  final String link;

  /// [pilihan] Variabel untuk menyimpan data pilihan PTN.
  final List<LaporanTryoutPilihanModel> pilihan;

  /// [listNilai] Variabel untuk detail nilai
  final List<LaporanTryoutNilaiModel> listNilai;

  /// [isExists] Variabel untuk menyimpan data isExist EPB.
  final bool isExists;

  /// [tanggalAkhir] Variabel untuk menyimpan data tanggal akhir TO.
  final String tanggalAkhir;
  const LaporanTryoutTob({
    required this.kode,
    required this.nama,
    required this.penilaian,
    required this.link,
    required this.pilihan,
    required this.isExists,
    required this.tanggalAkhir,
    required this.listNilai,
  });

  @override
  List<Object> get props => [
        kode,
        nama,
        penilaian,
        link,
        pilihan,
        isExists,
        tanggalAkhir,
        listNilai,
      ];
}
