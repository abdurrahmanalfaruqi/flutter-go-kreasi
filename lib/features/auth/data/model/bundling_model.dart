import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/core/util/data_formatter.dart';

class Bundling extends Equatable {
  final int? idBundling;
  final int? idProdukMix;
  final int? idKota;
  final int? idJenisKelas;
  final int? idSekolahKelas;
  final bool? isOnline;
  final String? namaBundling;
  final DateTime? tanggalBerlaku;
  final DateTime? tanggalKadaluarsa;
  final String? deskripsi;
  final String? statusBundling;
  final int? idPembelian;
  final int? cIdSekolahKelas;
  final int? idKelas;
  final int? idGedung;
  final int? idKomar;
  final String? tahunAjaran;
  final String? tanggalDaftar;
  final int? idSekolah;
  final String? statusBayar;
  final String? lastUpdate;

  const Bundling({
    this.idBundling,
    this.idProdukMix,
    this.idKota,
    this.idJenisKelas,
    this.idSekolahKelas,
    this.isOnline,
    this.namaBundling,
    this.tanggalBerlaku,
    this.tanggalKadaluarsa,
    this.deskripsi,
    this.statusBundling,
    this.idPembelian,
    this.cIdSekolahKelas,
    this.idKelas,
    this.idGedung,
    this.idKomar,
    this.tahunAjaran,
    this.tanggalDaftar,
    this.idSekolah,
    this.statusBayar,
    this.lastUpdate,
  });

  factory Bundling.fromJson(Map<String, dynamic> json) {
    return Bundling(
      idBundling: json['id_bundling'],
      idProdukMix: json['id_produk_mix'],
      idKota: json['id_kota'],
      idJenisKelas: json['id_jenis_kelas'],
      idSekolahKelas: json['c_id_sekolah_kelas'],
      isOnline: json['is_online'] == 1,
      namaBundling: json['nama_bundling'],
      tanggalBerlaku: (json['tanggal_awal'] != null &&
              json['tanggal_awal'] != '' &&
              json['tanggal_awal'] != '-')
          ? DataFormatter.stringToDate(json['tanggal_awal'], 'yyyy-MM-dd')
          : null,
      tanggalKadaluarsa: (json['tanggal_akhir'] != null &&
              json['tanggal_akhir'] != '' &&
              json['tanggal_akhir'] != '-')
          ? DataFormatter.stringToDate(json['tanggal_akhir'], 'yyyy-MM-dd')
          : null,
      deskripsi: json['deskripsi'],
      statusBundling: json['status_bundling'],
      idPembelian: json['id_pembelian'],
      cIdSekolahKelas: json['id_sekolah_kelas'],
      idKelas: json['id_kelas'],
      idGedung: json['id_gedung'],
      idKomar: json['id_komar'],
      tahunAjaran: json['tahun_ajaran'],
      tanggalDaftar: json['tanggal_daftar'],
      idSekolah: json['id_sekolah'],
      statusBayar: json['status_bayar'],
      lastUpdate: json['last_update'],
    );
  }

  Map<String, dynamic> toJson() => {
        "id_bundling": idBundling,
        "id_produk_mix": idProdukMix,
        "id_kota": idKota,
        "id_jenis_kelas": idJenisKelas,
        "c_id_sekolah_kelas": idSekolahKelas,
        "is_online": isOnline,
        "nama_bundling": namaBundling,
        'tanggal_awal': (tanggalBerlaku != null)
            ? DataFormatter.dateTimeToString(tanggalBerlaku!, 'yyyy-MM-dd')
            : null,
        'tanggal_akhir': (tanggalKadaluarsa != null)
            ? DataFormatter.dateTimeToString(tanggalKadaluarsa!, 'yyyy-MM-dd')
            : null,
        "deskripsi": deskripsi,
        "status_bundling": statusBundling,
        "id_pembelian": idPembelian,
        "id_sekolah_kelas": cIdSekolahKelas,
        "id_kelas": idKelas,
        "id_gedung": idGedung,
        "id_komar": idKomar,
        "tahun_ajaran": tahunAjaran,
        "tanggal_daftar": tanggalDaftar,
        "id_sekolah": idSekolah,
        "status_bayar": statusBayar,
        "last_update": lastUpdate,
      };

  @override
  List<Object?> get props => [
        idBundling,
        idProdukMix,
        idKota,
        idJenisKelas,
        idSekolahKelas,
        isOnline,
        namaBundling,
        tanggalBerlaku,
        tanggalKadaluarsa,
        deskripsi,
        statusBundling,
      ];
}
