import 'dart:convert';
import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../entity/soal.dart';

// ignore: must_be_immutable
class SoalModel extends Soal {
  SoalModel({
    required super.idSoal,
    required super.initial,
    required super.nomorSoal,
    required super.nomorSoalSiswa,
    required super.textSoal,
    required super.tingkatKesulitan,
    required super.tipeSoal,
    required super.opsi,
    required super.kunciJawaban,
    required super.translatorEPB,
    required super.kunciJawabanEPB,
    super.idVideo,
    super.idWacana,
    super.wacana,
    required super.idKelompokUjian,
    required super.namaKelompokUjian,
    super.kodePaket,
    super.idBundle,
    super.kodeBab,
    super.nilai = 0,
    super.kesempatanMenjawab,
    required super.isBookmarked,
    super.isRagu = false,
    required super.sudahDikumpulkan,
    super.isReportSubmitted = false,
    super.jawabanSiswa,
    super.jawabanSiswaEPB,
    super.lastUpdate,
  });

  factory SoalModel.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      logger.log('FROM JSON >> SoalModel: ${jsonEncode(json['opsi'])}');
    }
    String? idVideo = json['id_video'] != null || json['id_video'] != ''
        ? json['id_video'].toString()
        : null;
    String? idWacana = json['id_wacana'].toString();
    return SoalModel(
      idSoal: json['c_IdSoal'] ?? json['id_soal'].toString(),
      nomorSoal: json['nomor_soal'] ?? 1,
      initial: json['singkatan'] ?? 'N/a',
      textSoal: json['c_Soal'] ?? json['soal'],
      tingkatKesulitan: json['tingkat_kesulitan'] ?? 1,
      tipeSoal: json['c_TipeSoal'] ?? json['tipe_soal'],
      opsi: json['c_Opsi'] ?? jsonEncode(json['opsi']),
      idVideo: ((idVideo?.isEmpty == true) || idVideo == '0') ? null : idVideo,
      idWacana: ((idWacana.isEmpty) || idWacana == '0') ? null : idWacana,
      wacana: json['wacana'],
      idKelompokUjian:
          json['c_IdKelompokUjian'] ?? json['id_kelompok_ujian'].toString(),
      namaKelompokUjian:
          json['c_NamaKelompokUjian'] ?? json['nama_kelompok_ujian'] ?? '-',
      kodePaket: json['c_KodePaket'] ?? json['kode_paket'],
      idBundle: json['c_IdBundel'] ?? json['id_bundel'].toString(),
      kodeBab: json['c_KodeBab'],
      nomorSoalSiswa: json['nomorSoalSiswa'] ?? 0,
      nilai: json['nilai'] ?? 0.0,
      jawabanSiswa: json['jawabanSiswa'],
      kunciJawaban: json['kunciJawaban'],
      translatorEPB: json['translatorEPB'],
      jawabanSiswaEPB: json['jawabanSiswaEPB'],
      kunciJawabanEPB: json['kunciJawabanEPB'],
      kesempatanMenjawab: json['kesempatanMenjawab'],
      isBookmarked: json['isBookmarked'] ?? false,
      isRagu: json['isRagu'] ?? false,
      sudahDikumpulkan: json['sudahDikumpulkan'] ?? false,
      lastUpdate: json['lastUpdate'],
    );
  }
}
