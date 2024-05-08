import 'dart:collection';
import 'dart:developer' as logger show log;

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:gokreasi_new/core/config/extensions.dart';
import 'package:gokreasi_new/features/auth/data/model/bundling_model.dart';

import 'produk_dibeli_model.dart';

class Anak extends Equatable {
  final String noRegistrasi;
  final String namaLengkap;
  final String nomorHandphone;
  final String? email;
  final List<Bundling>? listBundling;
  final List<int>? listIdProduk;
  final List<Map<String, dynamic>>? daftarProduk;
  final List<Map<String, dynamic>>? daftarAnak;
  final List<Map<String, dynamic>>? daftarBundling;
  final String? noRegistrasiOrtu;
  final String? deviceId;

  const Anak({
    required this.noRegistrasi,
    required this.namaLengkap,
    required this.nomorHandphone,
    this.email,
    this.listBundling,
    this.listIdProduk,
    this.daftarProduk,
    this.daftarAnak,
    this.daftarBundling,
    this.noRegistrasiOrtu,
    this.deviceId,
  });

  factory Anak.fromJson({
    required Map<String, dynamic> json,
    List<Map<String, dynamic>>? daftarBundling,
    List<int>? listIdProduk,
    List<Map<String, dynamic>>? daftarProduk,
    List<Map<String, dynamic>>? daftarAnak,
  }) {
    return Anak(
      noRegistrasi: json['c_no_register'] ?? 'Undefined',
      namaLengkap: json['c_nama_lengkap'] ?? 'Sobat GO',
      nomorHandphone: json['c_nomor_hp'] ?? '-',
      email: json['c_email'],
      listBundling: (daftarBundling == null || daftarBundling.isEmpty)
          ? []
          : daftarBundling
              .map((bundling) => Bundling.fromJson(bundling))
              .toList(),
      listIdProduk:
          (listIdProduk == null || listIdProduk.isEmpty) ? [] : listIdProduk,
      daftarProduk:
          (daftarProduk == null || daftarProduk.isEmpty) ? [] : daftarProduk,
      daftarAnak: (daftarAnak == null || daftarAnak.isEmpty) ? [] : daftarAnak,
      daftarBundling: (daftarBundling == null || daftarBundling.isEmpty)
          ? []
          : daftarBundling,
      noRegistrasiOrtu: json['id_ortu'],
      deviceId: json['id_dev'],
    );
  }

  Map<String, dynamic> toJson() => {
        'c_no_register': noRegistrasi,
        'c_nama_lengkap': namaLengkap,
        'c_nomor_hp': nomorHandphone,
        'c_email': email,
        'id_ortu': noRegistrasiOrtu,
        'id_dev': deviceId,
        'list_bundling': listBundling?.map((x) => x.toJson()).toList(),
        'list_id_produk': listIdProduk,
        'daftar_produk': daftarProduk,
        'daftar_anak': daftarAnak,
      };

  @override
  List<Object?> get props => [noRegistrasi, namaLengkap, nomorHandphone];
}

// ignore: must_be_immutable
class UserModel extends Equatable {
  final String? noRegistrasi;
  final String? namaLengkap;
  final String? email;
  final String? emailOrtu;
  final String? nomorHp;
  final String? nomorHpOrtu;
  final String? idSekolahKelas;
  final String? namaSekolahKelas;
  final String? siapa;
  final List<String>? idKelasGO;
  final List<String>? namaKelasGO;
  final String? tipeKelasGO;
  final String? idGedung;
  final String? namaGedung;
  final int? idKomar;
  final String? namaKomar;
  final String? idKota;
  final String? namaKota;
  final String? idSekolah;
  final String? namaSekolah;
  final String? tahunAjaran;
  final String? statusBayar;
  final int? idJurusanPilihan1;
  final int? idJurusanPilihan2;
  final String? pekerjaanOrtu;
  final List<ProdukDibeli>? daftarProdukDibeli;
  final List<Bundling>? daftarBundling;
  final String? tingkat;
  final int? idJenisKelas;
  final String? tingkatKelas;
  List<Anak>? daftarAnak;
  final List<int>? listIdProduk;
  final int? idBundlingAktif;
  final String? namaBundlingAktif;
  final int? idKelas;
  final String? namaKelas;

  /// [isBolehPTN] digunakan untuk cek apakah siswa boleh memilih kampus impian
  final bool? isBolehPTN;

  UserModel({
    this.noRegistrasi,
    this.namaLengkap,
    this.email,
    this.emailOrtu,
    this.nomorHp,
    this.nomorHpOrtu,
    this.idSekolahKelas,
    this.namaSekolahKelas,
    this.siapa,
    this.idKelasGO,
    this.namaKelasGO,
    this.tipeKelasGO,
    this.idGedung,
    this.namaGedung,
    this.idKomar,
    this.namaKomar,
    this.idKota,
    this.namaKota,
    this.idSekolah,
    this.namaSekolah,
    this.tahunAjaran,
    this.statusBayar,
    this.idJurusanPilihan1,
    this.idJurusanPilihan2,
    this.pekerjaanOrtu,
    this.daftarAnak,
    this.daftarProdukDibeli,
    this.daftarBundling,
    this.tingkat,
    this.tingkatKelas,
    this.listIdProduk,
    this.idBundlingAktif,
    this.namaBundlingAktif,
    this.idJenisKelas,
    this.idKelas,
    this.namaKelas,
    this.isBolehPTN,
  });

  // String get tingkatKelas =>
  //     Constant.kDataSekolahKelas.singleWhere(
  //       (sekolah) => sekolah['id'] == idSekolahKelas,
  //       orElse: () => {
  //         'id': '0',
  //         'kelas': 'Undefined',
  //         'tingkat': 'Other',
  //         'tingkatKelas': '0'
  //       },
  //     )['tingkatKelas'] ??
  //     '0';

  // String get tingkat =>
  //     Constant.kDataSekolahKelas.singleWhere(
  //       (sekolah) => sekolah['id'] == idSekolahKelas,
  //       orElse: () => {
  //         'id': '0',
  //         'kelas': 'Undefined',
  //         'tingkat': 'Other',
  //         'tingkatKelas': '0'
  //       },
  //     )['tingkat'] ??
  //     '0';

  List<int> get dataKampusImpian {
    List<int> data = [];

    if (idJurusanPilihan1 != null) {
      data.add(idJurusanPilihan1!);
      if (idJurusanPilihan2 != null) {
        data.add(idJurusanPilihan2!);
      }
    }

    return data;
  }

  Map<String, List<ProdukDibeli>> get daftarProdukGroupByJenisProduk {
    List<ProdukDibeli> produkDibeli = [...daftarProdukDibeli ?? []];
    produkDibeli.sort(
      (a, b) => a.namaJenisProduk.compareTo(b.namaJenisProduk),
    );

    return produkDibeli.fold<Map<String, List<ProdukDibeli>>>({},
        (prev, produk) {
      prev.putIfAbsent(produk.namaJenisProduk, () => []).add(produk);
      return prev;
    });
  }

  Map<String, Map<String, List<ProdukDibeli>>> get daftarProdukGroupByBundel {
    List<ProdukDibeli> produkDibeli = [...daftarProdukDibeli ?? []];
    produkDibeli.sort(
      (a, b) {
        int tingkatKelas = a.idSekolahKelas.compareTo(b.idSekolahKelas);
        if (tingkatKelas == 0) {
          // '-' for descending
          int namaBundling = a.namaBundling.compareTo(b.namaBundling);
          if (namaBundling == 0) {
            int jenisProduk = a.namaJenisProduk.compareTo(b.namaJenisProduk);
            if (jenisProduk == 0) {
              int panjangProduk =
                  a.namaProduk.length.compareTo(b.namaProduk.length);
              if (panjangProduk == 0) {
                return a.namaProduk.compareTo(b.namaProduk);
              }
              return panjangProduk;
            }
            return jenisProduk;
          }
          return namaBundling;
        }
        return tingkatKelas;
      },
    );
    var groupByBundle = produkDibeli
        .fold<Map<String, Map<String, List<ProdukDibeli>>>>({}, (prev, produk) {
      prev
          .putIfAbsent(produk.namaBundling,
              () => SplayTreeMap<String, List<ProdukDibeli>>())
          .putIfAbsent(produk.namaJenisProduk, () => [])
          .add(produk);
      if (kDebugMode) {
        logger.log('PRODUK-FOLD-BUNDLE: $prev');
      }
      return prev;
    });

    var groupByBundle2 = produkDibeli
        .fold<Map<String, Map<String, List<ProdukDibeli>>>>({}, (prev, produk) {
      prev.putIfAbsent(produk.namaBundling, () => {}).update(
            produk.namaJenisProduk,
            (value) => [...value, produk],
            ifAbsent: () => [produk],
          );
      if (kDebugMode) {
        logger.log('PRODUK-FOLD-BUNDLE-Method2: $prev');
      }
      return prev;
    });

    if (kDebugMode) {
      logger.log('PRODUK-FOLD-BUNDLE: Final Result 1 >> $groupByBundle');
      logger.log('PRODUK-FOLD-BUNDLE: Final Result 2 >> $groupByBundle2');
    }

    return groupByBundle;
  }

  factory UserModel.fromJson(
    Map<String, dynamic> json, {
    List<ProdukDibeli>? daftarProduk,
    List<Bundling>? daftarBundling,
    List<Anak>? daftarAnak,
    List<int>? listIdProduk,
    int? idJurusanPilihan1,
    int? idJurusanPilihan2,
    String? pekerjaanOrtu,
    String? namaBundlingAktif,
    int? idBundlingAktif,
  }) {
    // final List<String> keyNotNullable = [
    //   'jenisKelas',
    //   'idSekolah',
    //   'namaSekolah',
    //   'tahunAjaran',
    //   'c_Statusbayar'
    // ];
    // json.forEach((key, value) {
    //   if (keyNotNullable.contains(key) && value == null) {
    //     throw DataException(message: 'Oops! Data $key kosong');
    //   }
    // });
    return UserModel(
      noRegistrasi: json['noRegistrasi'],
      namaLengkap: json['namaLengkap'],
      email: json['email'] ?? 'Email belum terdata',
      emailOrtu: json['emailOrtu'] ?? 'Email ortu belum terdata',
      nomorHp: json['nomor_hp'],
      nomorHpOrtu:
          json['nomor_hp_ortu'] ?? 'Nomor handphone ortu belum terdata',
      idSekolahKelas: json['idSekolahKelas'] is int
          ? json['idSekolahKelas'].toString()
          : json['idSekolahKelas'],
      namaSekolahKelas: json['namaSekolahKelas'],
      tingkat: json['namaSekolahKelas'] == null
          ? '-'
          : json['namaSekolahKelas'].substring(3, 6),
      tingkatKelas: json['c_tingkat_kelas'] == null
          ? '12'
          : json['c_tingkat_kelas'].toString(),
      siapa: json['siapa'],
      idKelasGO: (json['idKelas'] == null)
          ? const ['0']
          : (json['idKelas'].toString()).split(','),
      namaKelasGO: (json['namaKelas'] == null)
          ? const ['Undefined']
          : (json['namaKelas'] as String).split(','),
      tipeKelasGO: json['jenisKelas'] ?? 'Undefined',
      idGedung: (json['idGedung'] == null) ? '2' : json['idGedung'].toString(),
      namaGedung: json['namaGedung'] ?? "PW 36-B",
      idKomar: json['idKomar'],
      idKota: (json['idKota'] == null)
          ? '1'
          : json['idKota'] is int
              ? json['idKota'].toString()
              : json['idKota'],
      namaKota: (json['namaKota'] == null || json['namaKota'].isEmpty)
          ? 'BANDUNG'
          : json['namaKota'],
      idSekolah: json['idSekolah'] is int
          ? json['idSekolah'].toString()
          : json['idSekolah'] ?? '100878',
      namaSekolah: json['namaSekolah'] ?? 'Asal sekolah belum terdata',
      tahunAjaran: json['tahunAjaran'] ?? 'Undefined',
      statusBayar: json['c_Statusbayar'] ?? 'Undefined',
      idJurusanPilihan1: idJurusanPilihan1 ?? json['idJurusanPilihan1'],
      idJurusanPilihan2: idJurusanPilihan2 ?? json['idJurusanPilihan2'],
      pekerjaanOrtu: (pekerjaanOrtu?.isEmpty ?? true)
          ? null
          : pekerjaanOrtu ?? json['pekerjaanOrtu'],
      // json['daftarAnak'] merupakan json dari Kreasi Secure Storage.
      // Jika dari API maka akan menggunakan daftarAnak
      daftarAnak: daftarAnak ??
          json['daftar_anak']
              .map<Anak>((anak) => Anak.fromJson(json: anak))
              .toList(),
      // json['produkDibeli'] merupakan json dari Kreasi Secure Storage.
      // Jika dari API maka akan menggunakan daftarProduk
      daftarProdukDibeli: daftarProduk ??
          json['produkDibeli']
              .map<ProdukDibeli>(
                  (produkJson) => ProdukDibeli.fromJson(produkJson))
              .toList(),
      daftarBundling: daftarBundling ??
          json['daftar_bundling']
              .map<Bundling>((bundling) => Bundling.fromJson(bundling))
              .toList(),
      listIdProduk: listIdProduk ?? json['list_id_produk'].cast<int>(),
      idBundlingAktif: idBundlingAktif ?? json['id_bundling_aktif'],
      namaBundlingAktif: namaBundlingAktif ?? json['nama_bundling_aktif'],
      idJenisKelas: json['c_id_jenis_kelas'],
      idKelas: json['idKelas'],
      isBolehPTN: json['is_boleh_ptn'],
    );
  }

  Map<String, dynamic> toJson() => {
        'noRegistrasi': noRegistrasi,
        'namaLengkap': namaLengkap,
        'idSekolahKelas': idSekolahKelas,
        'namaSekolahKelas': namaSekolahKelas,
        'siapa': siapa,
        // 'idKelas': idKelasGO?.join(','),
        'namaKelas': namaKelasGO?.join(','),
        'jenisKelas': tipeKelasGO,
        'idGedung': idGedung,
        'namaGedung': namaGedung,
        'idKota': idKota,
        'namaKota': namaKota,
        'idSekolah': idSekolah,
        'namaSekolah': namaSekolah,
        'tahunAjaran': tahunAjaran,
        'c_Statusbayar': statusBayar,
        'email': email,
        'nomor_hp': nomorHp,
        'nomor_hp_ortu': nomorHpOrtu,
        'idJurusanPilihan1': idJurusanPilihan1,
        'idJurusanPilihan2': idJurusanPilihan2,
        'pekerjaanOrtu': pekerjaanOrtu,
        'daftarAnak': daftarAnak?.map((anak) => anak.toJson()).toList(),
        'produkDibeli':
            daftarProdukDibeli?.map((produk) => produk.toJson()).toList(),
        'daftarBundling':
            daftarBundling?.map((bundle) => bundle.toJson()).toList(),
        'emailOrtu': emailOrtu,
        'nama_bundling_aktif': namaBundlingAktif,
        'id_bundling_aktif': idBundlingAktif,
        'c_id_jenis_kelas': idJenisKelas,
        'idKelas': idKelas,
        'c_tingkat_kelas': tingkatKelas,
        'idKomar': idKomar,
        'daftar_anak': daftarAnak?.map((x) => x.toJson()).toList(),
        'daftar_bundling': daftarBundling?.map((x) => x.toJson()).toList(),
        'list_id_produk': listIdProduk,
        'is_boleh_ptn': isBolehPTN,
      };

  @override
  List<Object?> get props => [
        noRegistrasi,
        namaLengkap,
        idSekolahKelas,
        namaSekolahKelas,
        siapa,
        idKelasGO,
        namaKelasGO,
        tipeKelasGO,
        idGedung,
        namaGedung,
        idKota,
        namaKota,
        idSekolah,
        namaSekolah,
        tahunAjaran,
        statusBayar,
        email,
        nomorHp,
        nomorHpOrtu,
        idJurusanPilihan1,
        idJurusanPilihan2,
        pekerjaanOrtu,
        daftarProdukDibeli,
        isBolehPTN,
      ];

  UserModel copyWith({
    String? noRegistrasi,
    String? namaLengkap,
    String? email,
    String? emailOrtu,
    String? nomorHp,
    String? nomorHpOrtu,
    String? idSekolahKelas,
    String? namaSekolahKelas,
    String? siapa,
    List<String>? idKelasGO,
    List<String>? namaKelasGO,
    String? tipeKelasGO,
    String? idGedung,
    String? namaGedung,
    int? idKomar,
    String? namaKomar,
    String? idKota,
    String? namaKota,
    String? idSekolah,
    String? namaSekolah,
    String? tahunAjaran,
    String? statusBayar,
    int? idJurusanPilihan1,
    int? idJurusanPilihan2,
    String? pekerjaanOrtu,
    List<ProdukDibeli>? daftarProdukDibeli,
    List<Bundling>? daftarBundling,
    String? tingkat,
    String? tingkatKelas,
    List<Anak>? daftarAnak,
    List<int>? listIdProduk,
    String? namaBundlingAktif,
    int? idBundlingAktif,
    int? idJenisKelas,
    int? idKelas,
    String? namaKelas,
    bool? isBolehPTN,
  }) =>
      UserModel(
        noRegistrasi: noRegistrasi ?? this.noRegistrasi,
        namaLengkap: namaLengkap ?? this.namaLengkap,
        email: email ?? this.email,
        emailOrtu: emailOrtu ?? this.emailOrtu,
        nomorHp: nomorHp ?? this.nomorHp,
        nomorHpOrtu: nomorHpOrtu ?? this.nomorHpOrtu,
        idSekolahKelas: idSekolahKelas ?? this.idSekolahKelas,
        namaSekolahKelas: namaSekolahKelas ?? this.namaSekolahKelas,
        siapa: siapa ?? this.siapa,
        idKelasGO: idKelasGO ?? this.idKelasGO,
        namaKelasGO: namaKelasGO ?? this.namaKelasGO,
        tipeKelasGO: tipeKelasGO ?? this.tipeKelasGO,
        idGedung: idGedung ?? this.idGedung,
        namaGedung: namaGedung ?? this.namaGedung,
        idKomar: idKomar ?? this.idKomar,
        namaKomar: namaKomar ?? this.namaKomar,
        idKota: idKota ?? this.idKota,
        namaKota: namaKota ?? this.namaKota,
        idSekolah: idSekolah ?? this.idSekolah,
        namaSekolah: namaSekolah ?? this.namaSekolah,
        tahunAjaran: tahunAjaran ?? this.tahunAjaran,
        statusBayar: statusBayar ?? this.statusBayar,
        idJurusanPilihan1: idJurusanPilihan1 ?? this.idJurusanPilihan1,
        idJurusanPilihan2: idJurusanPilihan2 ?? this.idJurusanPilihan2,
        pekerjaanOrtu: pekerjaanOrtu ?? this.pekerjaanOrtu,
        daftarProdukDibeli: daftarProdukDibeli ?? this.daftarProdukDibeli,
        daftarBundling: daftarBundling ?? this.daftarBundling,
        tingkat: tingkat ?? this.tingkat,
        tingkatKelas: tingkatKelas ?? this.tingkatKelas,
        daftarAnak: daftarAnak ?? this.daftarAnak,
        listIdProduk: listIdProduk ?? this.listIdProduk,
        namaBundlingAktif: namaBundlingAktif ?? this.namaBundlingAktif,
        idBundlingAktif: idBundlingAktif ?? this.idBundlingAktif,
        idJenisKelas: idJenisKelas ?? this.idJenisKelas,
        idKelas: idKelas ?? this.idKelas,
        namaKelas: namaKelas ?? this.namaKelas,
        isBolehPTN: isBolehPTN ?? this.isBolehPTN,
      );
}

UserModel responseLoginToUserModel(Map<String, dynamic> response) {
  try {
    // Menambahkan daftar anak untuk akun ORTU
    List<Map<String, dynamic>>? daftarAnakResponse =
        (response['data']['daftar_anak'] != null ||
                response['data']['DataSiswa']['siapa'] == 'ORTU')
            ? response['data']['daftar_anak'].cast<Map<String, dynamic>>()
            : null;

    //mendaftarkan produk yg dibeli siswa
    // TODO: ganti nullable / non nullable jika flow tamu sudah jelas
    List<Map<String, dynamic>>? daftarProduk =
        (response['data']['daftar_produk'] == null)
            ? null
            : response['data']['daftar_produk'].cast<Map<String, dynamic>>();

    // Decode Object ptn pilihan
    // Map<String, dynamic>? ptnPilihan =
    //     (response['data']['pilihanPTN'] != null &&
    //             (response['data']['pilihanPTN']?.isNotEmpty ?? false))
    //         ? json.decode(response['data']['pilihanPTN'])
    //         : null;

    // Convert daftarAnak to List<Anak>
    List<Anak> daftarAnak = daftarAnakResponse
            ?.map<Anak>((anak) => Anak.fromJson(
                  json: anak,
                  daftarAnak: daftarAnakResponse,
                  daftarBundling: (response['data']['daftar_bundling'] == null)
                      ? null
                      : response['data']['daftar_bundling']
                          .cast<Map<String, dynamic>>(),
                  daftarProduk: daftarProduk,
                  listIdProduk: (response['data']['list_id_produk'] == null)
                      ? null
                      : response['data']['list_id_produk'].cast<int>(),
                ))
            .toList() ??
        [];
    // Convert daftarProduk to List<ProdukDibeli>
    List<ProdukDibeli> daftarProdukDibeli = daftarProduk
            ?.map<ProdukDibeli>(
                (produkJson) => ProdukDibeli.fromJson(produkJson))
            .toList() ??
        [];
    daftarProdukDibeli
        .sort((a, b) => a.idJenisProduk.compareTo(b.idJenisProduk));
    daftarProdukDibeli.removeWhere((element) {
      final now = DateTime.now().serverTimeFromOffset;
      return now.isAfter(element.tanggalKedaluwarsa ?? now);
    });

    List<int> listIdProduk = daftarProdukDibeli
        .map((produk) => int.parse(produk.idKomponenProduk))
        .toList();

    int idBundlingAktif = response['data']['id_bundling_aktif'];

    List<Bundling> daftarBundling =
        (response['data']['daftar_bundling'] as List<dynamic>)
            .map((bundling) => Bundling.fromJson(bundling))
            .toList();

    daftarBundling.sort(
      (a, b) => (a.idBundling ?? 0).compareTo(b.idBundling ?? 0),
    );

    int indexBundleAktif = daftarBundling
        .indexWhere((element) => element.idBundling == idBundlingAktif);

    String? namaBundlingAktif = (indexBundleAktif != -1)
        ? daftarBundling[indexBundleAktif].namaBundling
        : 'N/a';

    /// [_userJson] merupakan json User Data yang di dapat dari hasil decode dari Token JWT
    var userJson = response['data']['DataSiswa'];

    if (kDebugMode) {
      logger.log(
          'AUTH_OTP_PROVIDER-ResponseLoginToUserModel: UserModel >> $userJson');
    }
    return UserModel.fromJson(
      userJson,
      daftarAnak: daftarAnak,
      daftarProduk: daftarProdukDibeli,
      daftarBundling: daftarBundling,
      // idJurusanPilihan1: (ptnPilihan?['pilihan1'] is int)
      //     ? (ptnPilihan?['pilihan1'])
      //     : int.tryParse('${ptnPilihan?['pilihan1']}'),
      // idJurusanPilihan2: (ptnPilihan?['pilihan2'] is int)
      //     ? (ptnPilihan?['pilihan2'])
      //     : int.tryParse('${ptnPilihan?['pilihan2']}'),
      pekerjaanOrtu: response['data']['jobOrtu'],
      listIdProduk: listIdProduk,
      namaBundlingAktif: namaBundlingAktif,
      idBundlingAktif: idBundlingAktif,
    );
  } catch (e) {
    return UserModel();
  }
}

class DataSekolahSiswa extends Equatable {
  final String? namaSekolah;
  final String? namaSekolahKelas;
  final String? tingkatKelas;
  final bool? isBolehPTN;

  const DataSekolahSiswa({
    required this.namaSekolah,
    required this.namaSekolahKelas,
    required this.tingkatKelas,
    required this.isBolehPTN,
  });

  factory DataSekolahSiswa.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return DataSekolahSiswa(
      namaSekolah: data['sekolah'],
      namaSekolahKelas: data['nama_sekolah_kelas'],
      tingkatKelas: data['tingkat_kelas'],
      isBolehPTN: data['is_boleh_ptn'],
    );
  }

  @override
  List<Object?> get props => [
        namaSekolah,
        namaSekolahKelas,
        tingkatKelas,
        isBolehPTN,
      ];
}

class DataGedungKomarSiswa extends Equatable {
  final String? namaGedung;
  final String? namaKomar;
  final String? namaKota;

  const DataGedungKomarSiswa({
    required this.namaGedung,
    required this.namaKomar,
    required this.namaKota,
  });

  factory DataGedungKomarSiswa.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return DataGedungKomarSiswa(
      namaGedung: data['nama_gedung']['c_nama_gedung'],
      namaKomar: data['nama_komar']['c_nama_komar'],
      namaKota: data['nama_kota']['c_kota'],
    );
  }

  @override
  List<Object?> get props => [namaGedung, namaKomar, namaKota];
}

class NamaKelasSiswa extends Equatable {
  final int? idKelas;
  final String? namaKelas;
  final int? tingkatKelas;
  final int? idGedung;

  const NamaKelasSiswa({
    required this.idKelas,
    required this.namaKelas,
    required this.tingkatKelas,
    required this.idGedung,
  });

  factory NamaKelasSiswa.fromJson(Map<String, dynamic> json) => NamaKelasSiswa(
        idKelas: json['id'],
        namaKelas: json['nama_kelas'],
        tingkatKelas: json['tingkat_kelas'],
        idGedung: json['id_gedung'],
      );

  @override
  List<Object?> get props => [idKelas, namaKelas, tingkatKelas, idGedung];
}
