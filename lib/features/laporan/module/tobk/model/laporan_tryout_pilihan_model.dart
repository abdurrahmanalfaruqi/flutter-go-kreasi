import '../entity/laporan_tryout_pilihan.dart';

class LaporanTryoutPilihanModel extends LaporanTryoutPilihan {
  const LaporanTryoutPilihanModel(
      {required String kelompok,
      required String namaKelompok,
      required String ptn,
      required String jurusan,
      required String pg,
      required String nilai})
      : super(
            kelompok: kelompok,
            namakelompok: namaKelompok,
            ptn: ptn,
            jurusan: jurusan,
            pg: pg,
            nilai: nilai);

  factory LaporanTryoutPilihanModel.fromJson(Map<String, dynamic> json) =>
      LaporanTryoutPilihanModel(
          kelompok: json['kode_kelompok_jurusan'] ?? '-',
          namaKelompok:
              json['namaKelompok'] ?? json['nama_kelompok_jurusan'] ?? '-',
          ptn: json['nama_perguruan_tinggi'] ?? '-',
          jurusan: json['nama_jurusan'] ?? '-',
          pg: (json['pg'] == null) ? '-' : json['pg'].toString(),
          nilai: json['nilai'] != null
              ? json['nilai'].toString()
              : json['nilaiTOB'].toString());
}
