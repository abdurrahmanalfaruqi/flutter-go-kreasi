class LaporanTryoutJawabanModel {
  final String mapel;
  final int benar;
  final int salah;
  final int kosong;
  final int jumlahSoal;
  final String kodeSoal;
  final String initial;
  final int? nilai;

  LaporanTryoutJawabanModel({
    required this.mapel,
    required this.benar,
    required this.salah,
    required this.kosong,
    required this.jumlahSoal,
    required this.kodeSoal,
    required this.initial,
    required this.nilai,
  });

  factory LaporanTryoutJawabanModel.fromJson(Map<String, dynamic> json) =>
      LaporanTryoutJawabanModel(
        mapel: json['nama_kelompok_ujian'] ?? '-',
        benar: json['benar'] ?? 0,
        salah: json['salah'] ?? 0,
        kosong: json['kosong'] ?? 0,
        jumlahSoal: json['jumlah_soal'] ?? 0,
        kodeSoal: json['kode_paket'] ?? "",
        initial: json['singkatan'] ?? "N/a",
        nilai: json['nilai'],
      );
}
