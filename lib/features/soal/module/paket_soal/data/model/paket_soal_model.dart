import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../../domain/entity/paket_soal.dart';

class PaketSoalModel extends PaketSoal {
  const PaketSoalModel({
    required super.kodeTOB,
    required super.kodePaket,
    required super.deskripsi,
    required super.idJenisProduk,
    required super.idSekolahKelas,
    super.tanggalBerlaku,
    super.tanggalKedaluwarsa,
    required super.jumlahSoal,
    required super.totalWaktu,
    required super.isBlockingTime,
    super.isTeaser = false,
    required super.listIdBundelSoal,
    required super.isSelesai,
    required super.isPernahMengerjakan,
  });

  factory PaketSoalModel.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      logger.log('PAKET_SOAL_MODEL-FromJson: json >> $json');
    }
    return PaketSoalModel(
      kodeTOB: json['kode_tob'].toString(),
      kodePaket: json['kode_paket'],
      deskripsi: json['deskripsi_paket'],
      idJenisProduk: json['id_jenis_produk'].toString(),
      idSekolahKelas: json['id_sekolah_kelas'] is int
          ? json['id_sekolah_kelas'].toString()
          : json['id_sekolah_kelas'] ?? '0',
      isBlockingTime: json['is_blocking_time'],
      tanggalBerlaku: (json['tanggal_berlaku'] != null ||
              json['tanggal_berlaku'] != '-' ||
              json['tanggal_berlaku'] != '')
          ? json['tanggal_berlaku']
          : null,
      // tanggalKedaluwarsa: '2023-11-30 00:00:00',
      tanggalKedaluwarsa: (json['tanggal_kedaluwarsa'] != null ||
              json['tanggal_kedaluwarsa'] != '-' ||
              json['tanggal_kedaluwarsa'] != '')
          ? json['tanggal_kedaluwarsa']
          : null,
      totalWaktu: json['c_waktu_pengerjaan_total'] ??
          json['waktu_pengerjaan_total'] ??
          0,
      jumlahSoal: json['c_jumlah_soal_total'] ??
          json['jumlah_soal_total'] ??
          json['jumlah_soal'],
      isTeaser: json['jenis'] == 'teaser',
      listIdBundelSoal: (json['list_id_bundel_soal'] == null)
          ? []
          : json['list_id_bundel_soal']
              .map<int>((value) => int.parse(value.toString()))
              .toList(),
      isSelesai: json['is_selesai'] ?? false,
      isPernahMengerjakan: json['is_pernah_mengerjakan'] ?? false,
    );
  }
}
