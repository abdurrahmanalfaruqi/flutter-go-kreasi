import 'package:gokreasi_new/features/menu/entity/menu.dart';
import 'package:gokreasi_new/features/soal/entity/buku_soal.dart';

class BukuSoalModel extends BukuSoal {
  const BukuSoalModel({
    super.listBukuPaket,
    super.listBukuSakti,
  });

  factory BukuSoalModel.fromJson(Map<String, dynamic> json) => BukuSoalModel(
        listBukuPaket: (json['other_products'] == null)
            ? []
            : (json['other_products'] as List)
                .map((buku) => Menu.fromJson(buku))
                .toList(),
        listBukuSakti: (json['buku_sakti'] == null)
            ? []
            : (json['buku_sakti'] as List)
                .map((buku) => Menu.fromJson(buku))
                .toList(),
      );
}
