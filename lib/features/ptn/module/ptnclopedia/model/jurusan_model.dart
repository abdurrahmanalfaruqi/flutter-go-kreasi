import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';

import '../entity/jurusan.dart';

// ignore: must_be_immutable
class JurusanModel extends Jurusan {
  JurusanModel({
    required super.idPTN,
    required super.idJurusan,
    required super.namaJurusan,
    required super.kelompok,
    required super.rumpun,
    required super.lintas,
    super.passGrade,
    required super.peminat,
    required super.tampung,
    super.deskripsi,
    super.lapanganPekerjaan,
  });

  factory JurusanModel.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      logger.log(
          'JURUSAN_MODEL-FromJson: ${json['id_universitas'] is String} || ${json['id_jurusan'] is String}');
    }

    return JurusanModel(
      idPTN: json['id_universitas'],
      idJurusan: json['id_jurusan'],
      namaJurusan: json['nama_jurusan'],
      kelompok: json['kelompok_jurusan'],
      rumpun: json['rumpun_jurusan'],
      peminat: json['info']?['peminat'] ?? json['peminat'] ?? [],
      tampung: json['info']?['tampung'] ?? json['tampung'] ?? [],
      passGrade: json['passing_grade'].toString(),
      lintas: json['lintas_jurusan'],
      deskripsi: json['deskripsi'],
      lapanganPekerjaan: json['lapangan_kerja'],
    );
  }
}

// ignore: must_be_immutable
class DetailJurusan extends Jurusan {
  final String namaPTN;
  final String alias;

  DetailJurusan({
    required super.idPTN,
    required this.namaPTN,
    required this.alias,
    required super.idJurusan,
    required super.namaJurusan,
    required super.kelompok,
    required super.rumpun,
    required super.lintas,
    super.passGrade,
    required super.peminat,
    required super.tampung,
    super.deskripsi,
    super.lapanganPekerjaan,
  });

  factory DetailJurusan.fromJson(Map<String, dynamic> json) {
    return DetailJurusan(
      idPTN: json['id_universitas'],
      namaPTN: json['nama_universitas'],
      alias: json['akronim_universitas'],
      idJurusan: json['id_jurusan'],
      namaJurusan: json['nama_jurusan'],
      kelompok: json['kelompok_jurusan'],
      rumpun: json['rumpun_jurusan'],
      peminat: json['info']?['peminat'] ?? [],
      tampung: json['info']?['tampung'] ?? [],
      passGrade: json['passing_grade'].toString(),
      lintas: json['lintas_jurusan'],
      deskripsi: json['deskripsi'],
      lapanganPekerjaan: json['lapangan_kerja'],
    );
  }
}
