import '../entity/detail_bundel.dart';

class DetailBundelModel extends DetailBundel {
  const DetailBundelModel({
    required super.idBundel,
    required super.namaKelompokUjian,
    required super.jumlahSoal,
    required super.indexSoalPertama,
    required super.indexSoalTerakhir,
    required super.waktuPengerjaan,
    required super.isLulus,
    super.urutan,
  });

  factory DetailBundelModel.fromJson({
    required Map<String, dynamic> json,
    required int indexSoalPertama,
    required int indexSoalTerakhir,
    int? urutan,
  }) =>
      DetailBundelModel(
        idBundel: json['c_idbundel'] ?? json['id_bundel'].toString(),
        namaKelompokUjian:
            json['c_namakelompokujian'] ?? json['nama_kelompok_ujian'],
        jumlahSoal: (json['jumlah_soal'] == null)
            ? 0
            : (json['jumlah_soal'] is int)
                ? json['jumlah_soal']
                : int.parse(json['jumlah_soal'].toString()),
        indexSoalPertama: indexSoalPertama,
        indexSoalTerakhir: indexSoalTerakhir,
        waktuPengerjaan: (json['waktu_pengerjaan'] == null)
            ? 0
            : (json['waktu_pengerjaan'] is int)
                ? json['waktu_pengerjaan']
                : int.parse(json['waktu_pengerjaan'].toString()),
        urutan: urutan ?? json['urutan'],
        isLulus: json['is_lulus'] == 1,
      );
}
