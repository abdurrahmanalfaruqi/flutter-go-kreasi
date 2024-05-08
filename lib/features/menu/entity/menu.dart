import 'package:equatable/equatable.dart';

class Menu extends Equatable {
  final int idJenis;
  final String label;
  final String namaJenisProduk;
  final String? iconPath;
  final List<String>? permission;

  const Menu({
    required this.idJenis,
    required this.label,
    required this.namaJenisProduk,
    this.iconPath,
    this.permission,
  });

  factory Menu.fromJson(Map<String, dynamic> json) => Menu(
        idJenis: json['id_jenis'] ?? -1,
        label: json['label'] ?? '-',
        namaJenisProduk: json['nama_jenis_produk'] ?? '-',
      );

  @override
  List<Object> get props => [idJenis, label, namaJenisProduk];
}
