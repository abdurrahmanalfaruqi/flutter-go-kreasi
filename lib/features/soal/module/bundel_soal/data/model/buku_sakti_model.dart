import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/model/package_to_model.dart';

class BukuSaktiModel extends Equatable {
  final BukuSaktiData? data;
  final Meta? meta;

  const BukuSaktiModel({
    this.data,
    this.meta,
  });

  factory BukuSaktiModel.fromJson(Map<String, dynamic> json) => BukuSaktiModel(
        data: json['data'] == null
            ? null
            : BukuSaktiData.fromJson(
                json['data'],
              ),
        meta: json['meta'] == null ? null : Meta.fromJson(json['meta']),
      );

  @override
  List<Object?> get props => [data, meta];
}

class BukuSaktiData extends Equatable {
  final List<Data>? listPaket;
  final List<ListKelompokUjian>? listKelompokUjian;

  const BukuSaktiData({
    this.listPaket,
    this.listKelompokUjian,
  });

  factory BukuSaktiData.fromJson(Map<String, dynamic> json) => BukuSaktiData(
        listPaket: json['list_paket'] == null
            ? []
            : (json['list_paket'] as List<dynamic>)
                .map((x) => Data.fromJson(x))
                .toList(),
        listKelompokUjian: json['list_kelompok_ujian'] == null
            ? []
            : (json['list_kelompok_ujian'] as List<dynamic>)
                .map((x) => ListKelompokUjian.fromJson(x))
                .toList(),
      );

  @override
  List<Object?> get props => [
        listPaket,
        listKelompokUjian,
      ];
}

class ListKelompokUjian extends Equatable {
  final int? cIdKelompokUjian;
  final String? cNamaKelompokUjian;
  final String? cSingkatan;
  final String? cIconMapelWeb;
  final String? cIconMapelMobile;
  final List<int>? listIdBundleSoal;

  const ListKelompokUjian({
    this.cIdKelompokUjian,
    this.cNamaKelompokUjian,
    this.cSingkatan,
    this.cIconMapelWeb,
    this.cIconMapelMobile,
    this.listIdBundleSoal,
  });

  factory ListKelompokUjian.fromJson(Map<String, dynamic> json) =>
      ListKelompokUjian(
        cIdKelompokUjian: json['c_id_kelompok_ujian'],
        cNamaKelompokUjian: json['c_nama_kelompok_ujian'],
        cSingkatan: json['c_singkatan'],
        cIconMapelWeb: json['c_icon_mapel_web'],
        cIconMapelMobile: json['c_icon_mapel_mobile'],
        listIdBundleSoal: json['list_id_bundel_soal'].cast<int>(),
      );

  @override
  List<Object?> get props => [
        cIdKelompokUjian,
        cNamaKelompokUjian,
        cSingkatan,
        cIconMapelWeb,
        cIconMapelMobile,
        listIdBundleSoal,
      ];
}
