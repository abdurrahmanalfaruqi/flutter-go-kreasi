import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/core/util/data_formatter.dart';
import 'package:gokreasi_new/features/soal/module/bundel_soal/domain/entity/bundel_soal.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/model/paket_to_model.dart';

class PackageTOModel extends Equatable {
  final List<Data>? data;
  final Meta? meta;

  const PackageTOModel({this.data, this.meta});

  factory PackageTOModel.fromJson(Map<String, dynamic> json) {
    return PackageTOModel(
      data: json['data'] == null
          ? []
          : (json['data'] as List<dynamic>)
              .map((v) => Data.fromJson(v))
              .toList(),
      meta: json['meta'] == null ? null : Meta.fromJson(json['meta']),
    );
  }

  PackageTOModel copyWith({List<Data>? listData}) => PackageTOModel(
        data: listData ?? data,
        meta: meta,
      );

  @override
  List<Object?> get props => [data, meta];
}

class Data extends Equatable {
  final String? kodePaket;
  final String? deskripsiPaket;
  final int? nomorUrut;
  final int? kodeTob;
  final int? idJenisProduk;
  final int? idSekolahKelas;
  final bool? isBlockingTime;
  final bool? isSelesai;
  final bool? isPernahMengerjakan;
  final bool? isRandom;
  final String? jenis;
  final String? tanggalBerlaku;
  final String? tanggalKedaluarsa;
  final List<int>? listIdBundleSoal;
  final List<DaftarBundleSoal>? daftarBundleSoal;
  final DateTime? tanggalMengumpulkan;
  final int? cWaktuPengerjaanSoal;
  final int? cJumlahSoalTotal;
  final List<int>? listIdBundelSoal;

  /// [isTOBMulai] digunakan untuk cek apakah tob sudah dimulai, dengan maksud
  /// tanggal sekarang sudah melewati tanggal mulai tob
  final bool? isTOBMulai;

  /// [isTOBBerakhir] digunakan untuk cek apakah tob sudah berakhir, dengan maksud
  /// tanggal sekarang sudah melewati tanggal kadaluarsa tob
  final bool? isTOBBerakhir;

  /// [urutanAktif] digunakan untuk cek udah masuk di urutan subtest ke berapa
  final int? urutanAktif;

  const Data({
    this.kodePaket,
    this.deskripsiPaket,
    this.nomorUrut,
    this.kodeTob,
    this.idJenisProduk,
    this.idSekolahKelas,
    this.isBlockingTime,
    this.isSelesai,
    this.isPernahMengerjakan,
    this.isRandom,
    this.jenis,
    this.tanggalBerlaku,
    this.tanggalKedaluarsa,
    this.listIdBundleSoal,
    this.daftarBundleSoal,
    this.cWaktuPengerjaanSoal,
    this.cJumlahSoalTotal,
    this.listIdBundelSoal,
    this.tanggalMengumpulkan,
    required this.isTOBMulai,
    required this.isTOBBerakhir,
    required this.urutanAktif,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      kodePaket: json['kode_paket'],
      deskripsiPaket: json['deskripsi_paket'],
      nomorUrut: json['nomor_urut'],
      kodeTob: json['kode_tob'],
      idJenisProduk: json['id_jenis_produk'],
      idSekolahKelas: json['id_sekolah_kelas'],
      isBlockingTime: json['is_blocking_time'],
      jenis: json['jenis'],
      tanggalBerlaku: json['tanggal_berlaku'],
      tanggalKedaluarsa: json['tanggal_kedaluwarsa'],
      // tanggalKedaluarsa: json['tanggal_kedaluwarsa'],
      listIdBundleSoal: json['list_id_bundel_soal'].cast<int>(),
      daftarBundleSoal: json['daftar_bundel_soal'] == null
          ? []
          : (json['daftar_bundel_soal'] as List<dynamic>)
              .map((v) => DaftarBundleSoal.fromJson(v))
              .toList(),
      cWaktuPengerjaanSoal: json['total_waktu_paket'],
      cJumlahSoalTotal: json['jumlah_soal_paket'],
      listIdBundelSoal: json['list_id_bundel_soal'] == null
          ? []
          : json['list_id_bundel_soal'].cast<int>(),
      isSelesai: json['is_selesai'],
      isPernahMengerjakan: json['is_pernah_mengerjakan'],
      isRandom: json['is_random'],
      tanggalMengumpulkan: json['tanggal_mengumpulkan'] == null ||
              json['tanggal_mengumpulkan'] == '-'
          ? null
          : DataFormatter.stringToDate(
              json['tanggal_mengumpulkan'],
            ),
      isTOBMulai: json['is_tob_mulai'],
      isTOBBerakhir: json['is_tob_berakhir'],
      urutanAktif: json['urutan_aktif'],
    );
  }

  PaketTOModel convertToPaketTO() {
    return PaketTOModel(
      kodeTOB: kodeTob.toString(),
      kodePaket: kodePaket ?? '-',
      deskripsi: deskripsiPaket ?? '-',
      nomorUrut: nomorUrut ?? 1,
      idJenisProduk: idJenisProduk.toString(),
      idSekolahKelas: idSekolahKelas.toString(),
      merekHp: '-',
      totalWaktu: cWaktuPengerjaanSoal ?? 0,
      jumlahSoal: cJumlahSoalTotal ?? 0,
      isBlockingTime: isBlockingTime ?? false,
      isRandom: isRandom ?? false,
      isSelesai: isSelesai ?? false,
      isWaktuHabis: false,
      isPernahMengerjakan: isPernahMengerjakan ?? false,
      iconMapel: '-',
      initial: '-',
      namaKelompokUjian: '-',
      tanggalBerlaku: tanggalBerlaku,
      tanggalKedaluwarsa: tanggalKedaluarsa,
      isTeaser: jenis == 'teaser',
      listIdBundleSoal: listIdBundelSoal ?? [],
      tanggalSiswaSubmit: tanggalMengumpulkan,
      isTOBMulai: isTOBMulai,
      isTOBBerakhir: isTOBBerakhir,
      urutanAktif: urutanAktif ?? 1,
    );
  }

  BundelSoal convertToBundleSoal() {
    return BundelSoal(
      kodeTOB: kodeTob.toString(),
      kodePaket: kodePaket ?? '',
      idBundel: '-',
      idSekolahKelas: idSekolahKelas.toString(),
      idKelompokUjian: 0,
      namaKelompokUjian: '-',
      initialKelompokUjian: '-',
      deskripsi: deskripsiPaket ?? '',
      iconMapel: '-',
      jumlahSoal: cJumlahSoalTotal ?? 0,
      waktuPengerjaan: cWaktuPengerjaanSoal,
      // temporary hardcode
      opsiUrut: OpsiUrut.nomor,
      isTeaser: jenis == 'teaser',
    );
  }

  @override
  List<Object?> get props => [
        kodePaket,
        deskripsiPaket,
        nomorUrut,
        kodeTob,
        idJenisProduk,
        idSekolahKelas,
        isBlockingTime,
        jenis,
        tanggalBerlaku,
        tanggalKedaluarsa,
        listIdBundleSoal,
        daftarBundleSoal,
        cWaktuPengerjaanSoal,
        cJumlahSoalTotal,
      ];
}

class DaftarBundleSoal extends Equatable {
  final int? cIdBundle;
  final int? cUrutan;
  final int? cIdKelompokUjian;
  final int? cWaktuPengerjaan;
  final int? cJumlahSoal;
  final String? cNamaKelompokUjian;
  final String? cSingkatan;
  final dynamic cIconMapelWeb;
  final dynamic cIconMapelMobile;

  const DaftarBundleSoal({
    this.cIdBundle,
    this.cUrutan,
    this.cIdKelompokUjian,
    this.cWaktuPengerjaan,
    this.cJumlahSoal,
    this.cNamaKelompokUjian,
    this.cSingkatan,
    this.cIconMapelWeb,
    this.cIconMapelMobile,
  });

  factory DaftarBundleSoal.fromJson(Map<String, dynamic> json) =>
      DaftarBundleSoal(
        cIdBundle: json['c_id_bundel'],
        cUrutan: json['c_urutan'],
        cIdKelompokUjian: json['c_id_kelompok_ujian'],
        cWaktuPengerjaan: json['c_waktu_pengerjaan'],
        cJumlahSoal: json['c_jumlah_soal'],
        cNamaKelompokUjian: json['c_nama_kelompok_ujian'],
        cSingkatan: json['c_singkatan'],
        cIconMapelWeb: json['c_icon_mapel_web'],
        cIconMapelMobile: json['c_icon_mapel_mobile'],
      );

  @override
  List<Object?> get props => [
        cIdBundle,
        cUrutan,
        cIdKelompokUjian,
        cWaktuPengerjaan,
        cJumlahSoal,
        cNamaKelompokUjian,
        cSingkatan,
        cIconMapelWeb,
        cIconMapelMobile,
      ];
}

class Meta {
  final int? code;
  final String? message;

  const Meta({this.code, this.message});

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        code: json['code'],
        message: json['message'],
      );
}
