import 'package:equatable/equatable.dart';

class JawabanBukuSakti extends Equatable {
  final String? idSoal;
  final String? kodePaket;
  final String? tipeSoal;
  final dynamic jawabanSiswa;
  final dynamic kunciJawaban;
  final bool? isRagu;

  const JawabanBukuSakti({
    this.idSoal,
    this.kodePaket,
    this.tipeSoal,
    this.jawabanSiswa,
    this.kunciJawaban,
    this.isRagu,
  });

  factory JawabanBukuSakti.fromJson(Map<String, dynamic> json) =>
      JawabanBukuSakti(
          idSoal: json['id_soal'].toString(),
          kodePaket: json['kode_paket'],
          tipeSoal: json['tipe_soal'],
          jawabanSiswa: json['jawaban_siswa'],
          kunciJawaban: json['kunci_jawaban'],
          isRagu: json['is_ragu']);

  @override
  List<Object?> get props => [
        idSoal,
        kodePaket,
        tipeSoal,
        jawabanSiswa,
        kunciJawaban,
        isRagu,
      ];
}
