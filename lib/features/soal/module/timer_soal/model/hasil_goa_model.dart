import '../entity/hasil_goa.dart';

class HasilGOAModel extends HasilGOA {
  HasilGOAModel(
      {required super.isRemedial,
      required super.jumlahPercobaanRemedial,
      required super.detailHasilGOA,
      required super.jumlahMaksimalPercobaanRemidial});

  factory HasilGOAModel.fromJson(Map<String, dynamic> json) {
    List<DetailHasilGOA> detailHasilGOA = (json['hasil'] as List)
        .map<DetailHasilGOA>((hasil) => DetailHasilGOAModel.fromJson(hasil))
        .toList();

    bool isRemedial = detailHasilGOA.any((goa) => !goa.isLulus);

    return HasilGOAModel(
        isRemedial: isRemedial,
        jumlahPercobaanRemedial: json['jumRemedial'],
        detailHasilGOA: detailHasilGOA,
        jumlahMaksimalPercobaanRemidial: json['maksRemedial'] ?? 2);
  }
}

class DetailHasilGOAModel extends DetailHasilGOA {
  DetailHasilGOAModel({
    required super.isLulus,
    required super.benar,
    required super.salah,
    required super.kosong,
    required super.targetLulus,
    required super.idKelompokUjian,
    required super.namaKelompokUjian,
  });

  factory DetailHasilGOAModel.fromJson(Map<String, dynamic> json) =>
      DetailHasilGOAModel(
        isLulus: json['isLulus'] == 1,
        benar: json['benar'],
        salah: json['salah'],
        kosong: json['kosong'],
        targetLulus: json['targetLulus'] ?? 0,
        idKelompokUjian: json['idKelompokUjian'] ?? 0,
        namaKelompokUjian: json['namaKelompokUjian'],
      );
}
