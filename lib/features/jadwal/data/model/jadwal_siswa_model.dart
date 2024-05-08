import '../../../../core/util/data_formatter.dart';

import '../../domain/entity/jadwal_siswa.dart';

class InfoJadwalModel extends InfoJadwal {
  const InfoJadwalModel({
    required super.tanggal,
    required super.daftarJadwalSiswa,
  });

  factory InfoJadwalModel.fromJson(Map<String, dynamic> json) {
    List<JadwalSiswa> daftarJadwal = [];

    if (json['listJadwal'] != null && json['listJadwal'].isNotEmpty) {
      for (var jadwal in json['listJadwal']) {
        daftarJadwal.add(JadwalSiswaModel.fromJson(jadwal));
      }
    }

    return InfoJadwalModel(
      tanggal: DataFormatter.stringToDate(json['tanggal'], 'yyyy-MM-dd'),
      daftarJadwalSiswa: daftarJadwal,
    );
  }
}

class JadwalSiswaModel extends JadwalSiswa {
  const JadwalSiswaModel({
    required super.tanggal,
    required super.jamMulai,
    required super.jamSelesai,
    required super.namaKelas,
    required super.idKelasGO,
    required super.mataPelajaran,
    required super.nikPengajar,
    required super.namaPengajar,
    required super.infoKegiatan,
    required super.kegiatan,
    required super.idRencana,
    required super.namaGedung,
    required super.feedbackPermission,
    required super.sesi,
  });

  factory JadwalSiswaModel.fromJson(Map<String, dynamic> json) =>
      JadwalSiswaModel(
        tanggal: json['tanggal'],
        jamMulai: json['jam_awal'],
        jamSelesai: json['jam_akhir'],
        idKelasGO: json['id_kelas'],
        mataPelajaran: json['nama_kelompok_ujian'] ?? "-",
        nikPengajar: json['nik_pengajar'],
        namaPengajar: json['nama_pengajar'],
        infoKegiatan: '${json['info'] ?? '-'} ${json['paket'] ?? '-'}',
        kegiatan: json['nama_kegiatan'] ?? "",
        idRencana: json['id_rencana'].toString(),
        namaGedung: json['nama_gedung'],
        feedbackPermission: json['ijin_feedback'],
        sesi: json['sesi'],
        namaKelas: json['nama_kelas'] ?? '-',
      );
}
