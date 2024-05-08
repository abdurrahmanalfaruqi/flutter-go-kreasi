import 'package:gokreasi_new/features/profile/domain/entity/mapel_pilihan.dart';

class MapelPilihanModel extends MapelPilihan {
  const MapelPilihanModel({
    super.idSekolahKelas,
    super.idKelompokKelas,
    super.namaKelompokUjian,
    super.singkatan,
  });

  factory MapelPilihanModel.fromJson(Map<String, dynamic> json) =>
      MapelPilihanModel(
        idSekolahKelas: json['id_sekolah_kelas'],
        idKelompokKelas: json['id_kelompok_ujian'],
        namaKelompokUjian: json['nama_kelompok_ujian'],
        singkatan: json['singkatan'],
      );
}
