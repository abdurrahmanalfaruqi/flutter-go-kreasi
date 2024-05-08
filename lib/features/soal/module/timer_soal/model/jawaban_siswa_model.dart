import 'package:gokreasi_new/features/soal/module/timer_soal/entity/jawaban_siswa.dart';

class JawabanSiswaModel extends JawabanSiswa {
  const JawabanSiswaModel({
    required super.idSoal,
    required super.jawabanSiswa,
    required super.isRagu,
    required super.tipeSoal
  });

  factory JawabanSiswaModel.fromJson(Map<String, dynamic> json) =>
      JawabanSiswaModel(
        idSoal: json['id_soal'].toString(),
        jawabanSiswa: json['jawaban_siswa'],
        isRagu: json['is_ragu'] ?? false,
        tipeSoal: json['tipe_soal'] ?? ''
      );

  @override
  List<Object?> get props => [idSoal, jawabanSiswa, isRagu];
}
