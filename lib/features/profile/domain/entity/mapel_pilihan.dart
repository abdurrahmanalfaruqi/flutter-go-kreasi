import 'package:equatable/equatable.dart';

class MapelPilihan extends Equatable {
  final String? idSekolahKelas;
  final int? idKelompokKelas;
  final String? namaKelompokUjian;
  final String? singkatan;

  const MapelPilihan({
    this.idSekolahKelas,
    this.idKelompokKelas,
    this.namaKelompokUjian,
    this.singkatan,
  });

  @override
  List<Object?> get props => [
        idKelompokKelas,
        idSekolahKelas,
        namaKelompokUjian,
        singkatan,
      ];
}
