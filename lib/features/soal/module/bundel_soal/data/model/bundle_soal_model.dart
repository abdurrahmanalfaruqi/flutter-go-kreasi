import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../domain/entity/bundel_soal.dart';
import '../../../../../../core/config/extensions.dart';

class BundleSoalModel extends BundelSoal {
  const BundleSoalModel({
    required super.idBundel,
    required super.kodeTOB,
    required super.kodePaket,
    required super.idSekolahKelas,
    required super.idKelompokUjian,
    required super.namaKelompokUjian,
    required super.initialKelompokUjian,
    required super.deskripsi,
    required super.iconMapel,
    super.waktuPengerjaan,
    required super.jumlahSoal,
    super.isTeaser = false,
    required super.opsiUrut,
  });

  factory BundleSoalModel.fromJson(Map<String, dynamic> json) {
    final baseUrlImage = dotenv.env["BASE_URL_IMAGE"] ?? '';
    if (kDebugMode) {
      logger.log('FROM JSON >> BundleSoalModel: $json');
    }
    return BundleSoalModel(
      kodePaket: json['kode_paket'] ?? '-',
      deskripsi: json['deskripsi_bundel'] ?? '-',
      kodeTOB: json['kode_tob'].toString(),
      idBundel: json['id_bundel'].toString(),
      idSekolahKelas: json['id_sekolah_kelas'] is int
          ? json['id_sekolah_kelas'].toString()
          : json['id_sekolah_kelas'] ?? '0',
      namaKelompokUjian: json['nama_kelompok_ujian'] ?? '-',
      iconMapel: json['icon_mapel_mobile'] ??
          json['icon_mapel_web'] ??
          '$baseUrlImage/arsip-mobile/img/logo.webp',
      idKelompokUjian: json['id_kelompok_ujian'] ?? 0,
      initialKelompokUjian: json['singkatan'] ?? '-',
      jumlahSoal: json['jumlah_soal'] ?? 0,
      opsiUrut: ('${json['opsi_urut']}'.equalsIgnoreCase('Nomor'))
          ? OpsiUrut.nomor
          : OpsiUrut.bab,
      waktuPengerjaan: json['waktu_pengerjaan'],
      isTeaser: json['jenis'] == 'teaser',

      // idBundel: json['daftar_bundel_soal'][0]['c_id_bundel'].toString(),
      // kodeTOB: json['kode_tob'].toString(),
      // kodePaket: json['kode_paket'],
      // idSekolahKelas: json['id_sekolah_kelas'] is int
      //     ? json['id_sekolah_kelas'].toString()
      //     : json['id_sekolah_kelas'] ?? '0',
      // idKelompokUjian: json['daftar_bundel_soal'][0]['c_id_kelompok_ujian'],
      // namaKelompokUjian: json['nama_kelompok_ujian'],
      // initialKelompokUjian: json['singkatan'],
      // deskripsi: json['deskripsi_paket'],
      // waktuPengerjaan: (json['c_waktu_pengerjaan'] != null)
      //     ? json['c_waktu_pengerjaan']
      //     : null,
      // jumlahSoal:
      //     (json['jumlah_soal_total'] != null) ? json['jumlah_soal_total'] : 0,
      // isTeaser: json['jenis'] == 'teaser',
      // opsiUrut: ('${json['nomor_urut']}'.equalsIgnoreCase('Nomor'))
      //     ? OpsiUrut.nomor
      //     : OpsiUrut.bab,
      // iconMapel: json['iconMapel'] ?? '',
    );
  }
}
