import 'package:hive/hive.dart';

import '../../../../../core/util/data_formatter.dart';

part 'kampus_impian.g.dart';

// @HiveType(typeId: 4)
// class KampusImpian extends HiveObject {
//   @HiveField(0)
//   final DetailJurusan pilihan1;
//   @HiveField(1)
//   final DetailJurusan pilihan2;
//   @HiveField(2)
//   List<DetailJurusan> riwayatPilihan;
//
//   KampusImpian({
//     required this.pilihan1,
//     this.pilihan2,
//     this.riwayatPilihan,
//   });
//
//   factory KampusImpian.fromJson(Map<String, dynamic> json) {
//     return KampusImpian(
//       idPTN: json['idPTN'],
//       namaPTN: json['namaPTN'],
//       aliasPTN: json['aliasPTN'],
//       idJurusan: json['idJurusan'],
//       namaJurusan: json['namaJurusan'],
//       kelompok: json['kelompok'],
//       rumpun: json['rumpun'],
//       peminat: json['info']?['peminat'] ?? [],
//       tampung: json['info']?['tampung'] ?? [],
//       passGrade: json['passgrade'],
//       lintas: (json['lintas'] == 'Y') ? true : false,
//       deskripsi: json['deskripsi'],
//       lapanganPekerjaan: json['lapker'],
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//         'pilihan1': pilihan1,
//         'pilihan2': pilihan2,
//         'riwayatPilihan': riwayatPilihan,
//       };
//
//   @override
//   String toString() => '\nKampusImpian('
//       'pilihan1: $pilihan1, '
//       'pilihan2: $pilihan2, '
//       'riwayatPilihan: $riwayatPilihan, '
//       ')\n\n';
// }

@HiveType(typeId: 4)
class KampusImpian extends HiveObject {
  @HiveField(0)
  final int pilihanKe;
  @HiveField(1)
  final DateTime tanggalPilih;
  @HiveField(2)
  final int idPTN;
  @HiveField(3)
  final String namaPTN;
  @HiveField(4)
  final String aliasPTN;
  @HiveField(5)
  final int idJurusan;
  @HiveField(6)
  final String namaJurusan;
  @HiveField(7)
  final String peminat;
  @HiveField(8)
  final String tampung;
  final String? kodeTOB;
  final String? namaTOB;

  KampusImpian({
    required this.pilihanKe,
    required this.tanggalPilih,
    required this.idPTN,
    required this.namaPTN,
    required this.aliasPTN,
    required this.idJurusan,
    required this.namaJurusan,
    required this.peminat,
    required this.tampung,
    this.kodeTOB,
    this.namaTOB,
  });

  factory KampusImpian.fromJson({
    required Map<String, dynamic> json,
    String? kodeTOB,
    String? namaTOB,
  }) {
    return KampusImpian(
      pilihanKe: json['pilihan'],
      tanggalPilih: json['tanggal'] == null
          ? DateTime.now()
          : DataFormatter.stringToDate(json['tanggal']),
      idPTN: json['id_universitas'],
      namaPTN: json['nama_universitas'],
      aliasPTN: json['akronim_universitas'],
      idJurusan: json['id_jurusan'],
      namaJurusan: json['nama_jurusan'],
      peminat: json['peminat'][0]['jml'].toString(),
      tampung: json['data_tampung'][0]['jml'].toString(),
      kodeTOB: kodeTOB,
      namaTOB: namaTOB,
    );
  }

  Map<String, dynamic> toJson() => {
        'pilihan': pilihanKe,
        'tanggal': DataFormatter.dateTimeToString(tanggalPilih),
        'idPTN': idPTN,
        'namaPTN': namaPTN,
        'aliasPTN': aliasPTN,
        'idJurusan': idJurusan,
        'namaJurusan': namaJurusan,
        'peminat': peminat,
        'tampung': tampung,
      };

  @override
  String toString() => '\nKampusImpian('
      'pilihanKe: $pilihanKe,'
      'tanggalPilih: $tanggalPilih,'
      'idPTN: $idPTN, '
      'namaPTN: $namaPTN, '
      'aliasPTN: $aliasPTN, '
      'idJurusan: $idJurusan, '
      'namaJurusan: $namaJurusan, '
      'peminat: $peminat, '
      'tampung: $tampung'
      ')';
}
