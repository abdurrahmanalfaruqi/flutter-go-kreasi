import 'package:gokreasi_new/features/ptn/module/ptnclopedia/entity/jurusan.dart';
import 'package:gokreasi_new/features/ptn/module/ptnclopedia/entity/ptn.dart';
import 'package:gokreasi_new/features/ptn/module/ptnclopedia/model/jurusan_model.dart';
import 'package:gokreasi_new/features/ptn/module/ptnclopedia/model/ptn_model.dart';

class PilihanModel {
  final String? noRegistrasi;
  final int? prioritas;
  final int? status;
  bool isAktif;
  final int? id;
  double? pg;
  PTN? namaPTN;
  Jurusan? namaJurusan;

  PilihanModel({
    required this.noRegistrasi,
    required this.id,
    required this.isAktif,
    required this.namaJurusan,
    required this.namaPTN,
    required this.prioritas,
    required this.status,
    required this.pg,
  });

  factory PilihanModel.fromJson(Map<String, dynamic> json) => PilihanModel(
        noRegistrasi: json['no_register'],
        prioritas: json['prioritas'],
        status: json['status'],
        isAktif: json['is_aktif'] ?? false,
        id: json['id'],
        pg: (json['passing_grade'] == null || json['passing_grade'] == 0)
            ? 0
            : (json['passing_grade'] is double)
                ? json['passing_grade']
                : (json['passing_grade'] as int).toDouble(),
        namaJurusan: JurusanModel.fromJson({
          'id_jurusan': json['id_jurusan'],
          'nama_jurusan': json['nama_jurusan'],
        }),
        namaPTN: PTNModel.fromJson({
          'nama_universitas': json['nama_ptn'],
          'id_universitas': json['id_ptn'] ?? 0,
        }),
      );

  Map<String, dynamic> toJson({required String noRegistrasi}) => {
        "no_register": noRegistrasi,
        "id_jurusan": namaJurusan?.idJurusan,
        "id_ptn": namaPTN?.idPTN,
        "prioritas": prioritas,
        "status": status ?? 1,
        "passing_grade": pg,
        "is_aktif": isAktif,
      };

  PilihanModel copyWith({int? prioritas}) {
    return PilihanModel(
      noRegistrasi: noRegistrasi,
      id: id,
      isAktif: isAktif,
      namaJurusan: namaJurusan,
      namaPTN: namaPTN,
      prioritas: prioritas ?? this.prioritas,
      status: status,
      pg: pg,
    );
  }

  int get sisaSimulasi {
    return 4 - (status ?? 0);
  }

  bool get bolehPilihPTN {
    return sisaSimulasi > 0;
  }
}
