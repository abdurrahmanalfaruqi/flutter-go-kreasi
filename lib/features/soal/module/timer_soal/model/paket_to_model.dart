import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../entity/paket_to.dart';
import '../../../../../core/util/data_formatter.dart';

// ignore: must_be_immutable
class PaketTOModel extends PaketTO {
  PaketTOModel({
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
    super.listKelompokUjian,
    super.urutanAktif,
  });

  factory PaketTOModel.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      logger.log('PAKET_TO_MODEL-FromJson: json >> $json');
    }

    return PaketTOModel(
      kodeTOB: json['kode_tob'].toString(),
      idKelompokUjian: json['id_kelompok_ujian'] ?? 0,
      kodePaket: json['kode_paket'],
      deskripsi: json['deskripsi_paket'],
      nomorUrut: json['urutan'] ?? 1,
      idJenisProduk: json['id_jenis_produk'].toString(),
      idSekolahKelas: json['id_sekolah_kelas'].toString(),
      merekHp: json['merk'],
      totalWaktu: json['total_waktu_paket'],
      jumlahSoal: json['jumlah_soal_paket'],
      isBlockingTime: json['is_blocking_time'],
      isRandom: json['is_random'],
      isSelesai: json['is_selesai'],
      isWaktuHabis: json['waktu_habis'] is bool
          ? json['waktu_habis']
          : json['waktu_habis'] != '-',
      isPernahMengerjakan: json['is_pernah_mengerjakan'],
      iconMapel: json['icon_mapel'] ?? '',
      initial: '-',
      namaKelompokUjian: '-',
      kapanMulaiMengerjakan:
          json['tanggal_mulai_to'] == null || json['tanggal_mulai_to'] == '-'
              ? null
              : DataFormatter.stringToDate(json['tanggal_mulai_to']),
      deadlinePengerjaan: json['tanggal_deadline_to'] == null ||
              json['tanggal_deadline_to'] == '-'
          ? null
          : DataFormatter.stringToDate(json['tanggal_deadline_to']),
      tanggalSiswaSubmit: json['tanggal_mengumpulkan'] == null ||
              json['tanggal_mengumpulkan'].trim() == '-'
          ? null
          : DataFormatter.stringToDate(json['tanggal_mengumpulkan']),
      listIdBundleSoal: json['list_id_bundel_soal'] == null
          ? []
          : json['list_id_bundel_soal'].cast<int>(),
      listKelompokUjian: json['list_kelompok_ujian'] == null
          ? []
          : (json['list_kelompok_ujian'] as List<dynamic>)
              .map((x) => NamaKelompokUjian.fromJson(x))
              .toList(),
      urutanAktif: json['urutan_aktif'],
      isTOBMulai: json['is_tob_mulai'],
      isTOBBerakhir: json['is_tob_berakhir'],
    );

    // return PaketTOModel(
    //     kodeTOB: json['kodeTOB'],
    //     kodePaket: json['kodePaket'],
    //     deskripsi: json['c_Deskripsi'] ?? json['kodePaket'],
    //     idKelompokUjian: (json['idKelompokUjian'] == null)
    //         ? 0
    //         : (json['idKelompokUjian'] is int)
    //             ? json['idKelompokUjian']
    //             : int.tryParse(json['idKelompokUjian']) ?? 0,
    //     merekHp: json['merk'],
    //     nomorUrut: int.parse(json['nomorUrut']),
    //     idJenisProduk: json['idJenisProduk'] ?? '25',
    //     idSekolahKelas: '${json['idSekolahKelas'] ?? '0'}',
    //     totalWaktu: int.parse(json['totalWaktu']),
    //     jumlahSoal: int.parse(json['jumlahSoal']),
    //     tanggalBerlaku: json['tanggalBerlaku'],
    //     tanggalKedaluwarsa: json['tanggalKedaluwarsa'],
    //     kapanMulaiMengerjakan:
    //         (json['tanggalMulai'] == null || json['tanggalMulai'] == '-')
    //             ? null
    //             : DataFormatter.stringToDate(json['tanggalMulai']),
    //     deadlinePengerjaan:
    //         (json['tanggalDeadline'] == null || json['tanggalDeadline'] == '-')
    //             ? null
    //             : DataFormatter.stringToDate(json['tanggalDeadline']),
    //     tanggalSiswaSubmit: (json['tanggalMengumpulkan'] == null ||
    //             json['tanggalMengumpulkan'] == '-')
    //         ? null
    //         : DataFormatter.stringToDate(json['tanggalMengumpulkan']),
    //     isBlockingTime: (json['isBlockingTime'] == '1') ? true : false,
    //     isRandom: (json['isRandom'] == '1') ? true : false,
    //     isSelesai: (json['isSelesai'] == 'n') ? false : true,
    //     isWaktuHabis: (json['waktuHabis'] == 'n') ? false : true,
    //     isPernahMengerjakan:
    //         (json['isPernahMengerjakan'] == 'n') ? false : true,
    //     isWajib: (json['isWajib'] == '0') ? false : true,
    //     isTeaser: (json['jenis'] == null)
    //         ? false
    //         : (json['jenis'] == 'teaser')
    //             ? true
    //             : false,
    //     iconMapel: json['iconMapel'],
    //     initial: json['initial'] ?? 'N/a',
    //     namaKelompokUjian: json['namaKelompokUjian'] ?? 'N/a');
  }
}
