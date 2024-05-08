import '../entity/ptn.dart';

// ignore: must_be_immutable
class PTNModel extends PTN {
  PTNModel({
    required super.idPTN,
    required super.namaPTN,
    required super.aliasPTN,
    required super.jenisPTN,
  });

  factory PTNModel.fromJson(Map<String, dynamic> json) => PTNModel(
        idPTN: json['id_universitas'] ?? '',
        namaPTN: json['nama_universitas'] ?? '',
        aliasPTN: json['akronim_universitas'] ?? '',
        jenisPTN: json['jenis'] ?? '',
      );
}
