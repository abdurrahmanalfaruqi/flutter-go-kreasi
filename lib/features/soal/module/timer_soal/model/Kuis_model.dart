import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../entity/paket_to.dart';
import '../../../../../core/util/data_formatter.dart';

// ignore: must_be_immutable
class QuizModel extends PaketTO {
  QuizModel({
    required super.kodeTOB,
    required super.kodePaket,
    required super.deskripsi,
    super.idKelompokUjian = 0,
    required super.nomorUrut,
    required super.idJenisProduk,
    required super.idSekolahKelas,
    required super.merekHp,
    required super.totalWaktu,
    required super.jumlahSoal,
    super.tanggalBerlaku,
    super.tanggalKedaluwarsa,
    super.kapanMulaiMengerjakan,
    super.deadlinePengerjaan,
    super.tanggalSiswaSubmit,
    required super.isBlockingTime,
    required super.isRandom,
    required super.isSelesai,
    required super.isWaktuHabis,
    required super.isPernahMengerjakan,
    super.isTeaser = false,
    super.isWajib = true,
    required super.iconMapel,
    required super.initial,
    required super.namaKelompokUjian,
    required super.listIdBundleSoal,
    required super.isTOBMulai,
    required super.isTOBBerakhir,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      logger.log('PAKET_TO_MODEL-FromJson: json >> $json');
    }

    return QuizModel(
      kodeTOB: json['kode_tob'].toString(),
      kodePaket: json['kode_paket'].toString(),
      deskripsi: json['deskripsi_paket'] ?? json['kode_paket'],
      idKelompokUjian: (json['daftar_bundel_soal'][0]['c_id_kelompok_ujian'] ==
              null)
          ? 0
          : (json['daftar_bundel_soal'][0]['c_id_kelompok_ujian'] is int)
              ? json['daftar_bundel_soal'][0]['c_id_kelompok_ujian']
              : int.tryParse(
                      json['daftar_bundel_soal'][0]['c_id_kelompok_ujian']) ??
                  0,
      merekHp: json['merk'] ?? '',
      nomorUrut: json['nomor_urut'],
      idJenisProduk: json['id_jenis_produk'] is int
          ? json['id_jenis_produk'].toString()
          : json['id_jenis_produk'] ?? '25',
      idSekolahKelas: json['id_sekolah_kelas'].toString(),
      totalWaktu: json['total_waktu_paket'],
      jumlahSoal: json['jumlah_soal_paket'],
      tanggalBerlaku: json['tanggal_berlaku'],
      tanggalKedaluwarsa: json['tanggal_kedaluwarsa'],
      kapanMulaiMengerjakan:
          (json['tanggal_mulai_to'] == null || json['tanggal_mulai_to'] == '-')
              ? null
              : DataFormatter.stringToDate(json['tanggal_mulai_to']),
      deadlinePengerjaan:
          (json['tanggal_deadline_to'] == null || json['tanggal_deadline_to'] == '-')
              ? null
              : DataFormatter.stringToDate(json['tanggal_deadline_to']),
      tanggalSiswaSubmit: (json['tanggal_mengumpulkan'] == null ||
              json['tanggal_mengumpulkan'] == '-')
          ? null
          : DataFormatter.stringToDate(json['tanggal_mengumpulkan']),
      isBlockingTime: json['is_blocking_time'] ?? false,
      isRandom: json['is_random'] ?? false,
      isSelesai: json['is_selesai'] ?? false,
      isWaktuHabis: DataFormatter.stringToDate(json['tanggal_kedaluwarsa'])
          .isAfter(DateTime.now()),
      isPernahMengerjakan: json['is_pernah_mengerjakan'] ?? false,
      isWajib: json['is_wajib'] ?? false,
      isTeaser: (json['jenis'] == null)
          ? false
          : (json['jenis'] == 'teaser')
              ? true
              : false,
      iconMapel: json['iconMapel'] ?? '',
      initial: json['singkatan'] ?? 'N/a',
      namaKelompokUjian: json['nama_kelompok_ujian'] ?? 'N/a',
      listIdBundleSoal: json['list_id_bundel_soal'].cast<int>(),
      isTOBMulai: json['is_tob_mulai'],
      isTOBBerakhir: json['is_tob_berakhir'],
    );
  }
}
