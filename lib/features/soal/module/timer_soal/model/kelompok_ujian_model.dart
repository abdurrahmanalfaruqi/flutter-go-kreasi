import 'package:equatable/equatable.dart';

class KelompokUjian extends Equatable {
  final String? namaKelompokUjian;
  final int? urutan;
  final bool? isSelesai;

  const KelompokUjian({
    this.namaKelompokUjian,
    this.urutan,
    this.isSelesai,
  });

  factory KelompokUjian.fromJson(Map<String, dynamic> json) => KelompokUjian(
    namaKelompokUjian: json['nama_kelompok_ujian'],
    urutan: json['urutan'],
    isSelesai: json['is_selesai'],
  );

  @override
  List<Object?> get props => [
        namaKelompokUjian,
        urutan,
        isSelesai,
      ];
}
