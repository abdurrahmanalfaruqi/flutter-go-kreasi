import '../../domain/entity/carousel.dart';

class CarouselModel extends Carousel {
  const CarouselModel({
    required String namaFile,
    required String keterangan,
    required dynamic link,
    required String status,
    required String tanggal,
  }) : super(
          namaFile: namaFile,
          keterangan: keterangan,
          link: link,
          status: status,
          tanggal: tanggal,
        );

  factory CarouselModel.fromJson(Map<String, dynamic> json) => CarouselModel(
        namaFile: json['c_nama_file'],
        keterangan: json['c_keterangan'],
        link: json['c_link'],
        status: json['c_status'],
        tanggal: json['c_created_at'],
      );

  Map<String, dynamic> toJson() => {
        'c_nama_file': namaFile,
        'c_keterangan': keterangan,
        'c_link': link,
        'c_status': status,
        'c_created_at': tanggal,
      };
}
