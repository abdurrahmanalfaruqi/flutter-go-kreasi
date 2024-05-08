import 'package:equatable/equatable.dart';
import '../../../../core/util/data_formatter.dart';

class ProdukDibeli extends Equatable {
  final String idKomponenProduk;
  final String idBundling;
  final String namaBundling;
  final String namaProduk;
  final int idJenisProduk;
  final int idSekolahKelas;
  final String namaJenisProduk;
  final DateTime? tanggalBerlaku;
  final DateTime? tanggalKedaluwarsa;

  const ProdukDibeli(
      {required this.idKomponenProduk,
      required this.idBundling,
      required this.namaBundling,
      required this.namaProduk,
      required this.idJenisProduk,
      required this.idSekolahKelas,
      required this.namaJenisProduk,
      required this.tanggalBerlaku,
      required this.tanggalKedaluwarsa});

  bool get isExpired => (tanggalKedaluwarsa == null)
      ? true
      : DateTime.now()
          .add(const Duration(hours: 7))
          .isAfter(tanggalKedaluwarsa!);

  factory ProdukDibeli.fromJson(Map<String, dynamic> json) => ProdukDibeli(
      idKomponenProduk: json['id_produk'].toString(),
      idBundling: json['id_bundling'] is int
          ? json['id_bundling'].toString()
          : json['id_bundling'] ?? '0',
      namaBundling: json['nama_bundling'] ?? 'Undefined',
      namaProduk: json['nama_produk'],
      idSekolahKelas: (json['id_sekolah_kelas'] != null &&
              json['id_sekolah_kelas'] is String)
          ? int.parse(json['id_sekolah_kelas'])
          : (json['id_sekolah_kelas'] != null &&
                  json['id_sekolah_kelas'] is int)
              ? json['id_sekolah_kelas']
              : 0,
      idJenisProduk: (json['id_jenis_produk'] != null &&
              json['id_jenis_produk'] is String)
          ? int.parse(json['id_jenis_produk'])
          : (json['id_jenis_produk'] != null && json['id_jenis_produk'] is int)
              ? json['id_jenis_produk']
              : 0,
      namaJenisProduk: '${json['nama_jenis_produk']}'.replaceAll('- ', '-'),
      tanggalBerlaku: (json['tanggal_awal'] != null &&
              json['tanggal_awal'] != '' &&
              json['tanggal_awal'] != '-')
          ? DataFormatter.stringToDate(json['tanggal_awal'], 'yyyy-MM-dd')
          : null,
      tanggalKedaluwarsa: (json['tanggal_akhir'] != null &&
              json['tanggal_akhir'] != '' &&
              json['tanggal_akhir'] != '-')
          ? DateTime.parse(json['tanggal_akhir'])
          : null);

  Map<String, dynamic> toJson() => {
        'id_produk': idKomponenProduk,
        'id_bundling': idBundling,
        'nama_bundling': namaBundling,
        'nama_produk': namaProduk,
        'id_jenis_produk': '$idJenisProduk',
        'id_sekolah_kelas': '$idSekolahKelas',
        'nama_jenis_produk': namaJenisProduk,
        'tanggal_awal': (tanggalBerlaku != null)
            ? DataFormatter.dateTimeToString(tanggalBerlaku!, 'yyyy-MM-dd')
            : null,
        'tanggal_akhir': (tanggalKedaluwarsa != null)
            ? DataFormatter.dateTimeToString(tanggalKedaluwarsa!, 'yyyy-MM-dd')
            : null,
      };

  @override
  List<Object?> get props => [
        idKomponenProduk,
        idBundling,
        namaProduk,
        idJenisProduk,
        namaJenisProduk,
        tanggalBerlaku,
        tanggalKedaluwarsa
      ];
}
