import 'package:gokreasi_new/features/ptn/module/simulasi/model/universitas_model.dart';

class HasilModel {
  final int? prioritas;
  final int? idJurusan;
  final String total;
  final String? hasil;
  final UniversitasModel universitasModel;

  HasilModel({
    required this.prioritas,
    required this.idJurusan,
    required this.hasil,
    required this.total,
    required this.universitasModel,
  });

  factory HasilModel.fromJson(Map<String, dynamic> json) {

    return HasilModel(
      prioritas: json['prioritas'],
      idJurusan: json['id_jurusan'],
      hasil: json['hasil'],
      total: (json['total'] == null) ? "" : json['total'].toString(),
      universitasModel: UniversitasModel.fromJson({
        'ptn': json['nama_ptn'] ?? "",
        'jurusanId':
            (json['id_jurusan'] == null) ? "" : json['id_jurusan'].toString(),
        'jurusan': json['nama_jurusan'] ?? "",
        'rumpun': json['rumpun'] ?? "",
        'pg': (json['passing_grade'] == null)
            ? ""
            : json['passing_grade'].toString(),
        'peminat': json['data_peminat'] ??
            {
              'jml': 0,
              'tahun': 0,
            },
        'tampung': json['data_daya_tampung'] ??
            {
              'jml': 0,
              'tahun': 0,
            },
      }),
    );
  }
}
