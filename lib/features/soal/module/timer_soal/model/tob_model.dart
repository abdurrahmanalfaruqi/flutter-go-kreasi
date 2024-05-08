import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../entity/tob.dart';

class TobModel extends Tob {
  const TobModel({
    required super.kodeTOB,
    required super.namaTOB,
    required super.jenisTOB,
    required super.tanggalMulai,
    required super.tanggalBerakhir,
    required super.jarakAntarPaket,
    super.isPernahMengerjakan = false,
    super.isFormatTOMerdeka = false,
    required super.isBersyarat,
    super.isTeaser = false,
    required super.isSudahDiKumpulkan,
    required super.isSelesai,
    required super.isTOBMulai,
    required super.isTOBBerakhir,
  });

  factory TobModel.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      logger.log('TOB_MODEL-FromJson: json >> $json');
    }
    return TobModel(
      kodeTOB: json['kode_tob'].toString(),
      namaTOB: json['nama_tob'],
      jenisTOB: json['jenis_tob'] ?? 'TryOut',
      tanggalMulai: json['tanggal_mulai'],
      tanggalBerakhir: json['tanggal_berakhir'],
      jarakAntarPaket: json['menit_antar_soal'] ?? 0,
      isFormatTOMerdeka: json['is_to_merdeka'],
      isBersyarat: json['is_bersyarat'] == '1',
      isTeaser: json['jenis'] == 'teaser',
      isPernahMengerjakan: json['isPernahMengerjakan'] ?? false,
      isSudahDiKumpulkan: json['isSudahDikumpulkan'] ?? false,
      isSelesai: json['is_selesai'] ?? false,
      isTOBMulai: json['is_tob_mulai'],
      isTOBBerakhir: json['is_tob_berakhir'],
    );
  }
}
