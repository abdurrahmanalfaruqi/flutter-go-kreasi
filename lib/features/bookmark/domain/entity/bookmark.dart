// ignore: depend_on_referenced_packages
import 'package:hive/hive.dart';

part 'bookmark.g.dart';

@HiveType(typeId: 1)
class BookmarkMapel extends HiveObject {
  @HiveField(0)
  final String idKelompokUjian;
  @HiveField(1)
  final String namaKelompokUjian;
  @HiveField(2, defaultValue: null)
  String? iconMapel;
  @HiveField(3)
  String initial;
  @HiveField(4, defaultValue: [])
  List<BookmarkSoal> listBookmark;

  BookmarkMapel({
    required this.idKelompokUjian,
    required this.namaKelompokUjian,
    this.iconMapel,
    required this.initial,
    this.listBookmark = const [],
  });

  // String get initial {
  //   int id = int.parse(idKelompokUjian);

  //   return Constant.kInitialKelompokUjian.entries
  //           .singleWhere(
  //             (kelompokUjian) => kelompokUjian.key == id,
  //             orElse: () =>
  //                 const MapEntry(0, {'nama': 'Undefined', 'singkatan': 'N/a'}),
  //           )
  //           .value['singkatan'] ??
  //       'N/a';
  // }

  factory BookmarkMapel.fromJson(Map<String, dynamic> json) => BookmarkMapel(
        idKelompokUjian: json['c_id_kelompok_ujian'].toString(),
        namaKelompokUjian: json['nama_kelompok_ujian'],
        iconMapel: json['iconMapel'],
        initial: json['singkatan'],
        listBookmark: List<BookmarkSoal>.generate(
          (json['listBookmark'] as List).length,
          (index) => BookmarkSoal.fromJson(json['listBookmark'][index]),
        ),
      );

  Map<String, dynamic> toJson() => {
        'c_id_kelompok_ujian': idKelompokUjian,
        'nama_kelompok_ujian': namaKelompokUjian,
        'iconMapel': iconMapel,
        'singkatan': initial,
        'listBookmark':
            listBookmark.map<Map<String, dynamic>>((e) => e.toJson()).toList()
      };

  @override
  String toString() => 'BookmarkMapel('
      '\nidKelompokUjian: $idKelompokUjian, namaKelompokUjian: $namaKelompokUjian, iconMapel: $iconMapel,'
      '\nlistBookmark: $listBookmark\n), ';
}

@HiveType(typeId: 2)
class BookmarkSoal extends HiveObject {
  @HiveField(0)
  final String idSoal;
  @HiveField(1)
  final int nomorSoal;
  @HiveField(2)
  final int nomorSoalSiswa;
  @HiveField(3)
  final String kodeTOB;
  @HiveField(4)
  final String kodePaket;
  @HiveField(5)
  final String idBundel;
  @HiveField(6)
  final String? kodeBab;
  @HiveField(7)
  final String? namaBab;
  @HiveField(8)
  final int idJenisProduk;
  @HiveField(9)
  final String namaJenisProduk;
  @HiveField(10)
  final String? tanggalKedaluwarsa;
  @HiveField(11)
  final bool isPaket;
  @HiveField(12)
  final bool isSimpan;
  @HiveField(13)
  String lastUpdate;

  BookmarkSoal(
      {required this.idSoal,
      required this.nomorSoal,
      required this.nomorSoalSiswa,
      required this.idBundel,
      required this.kodeTOB,
      required this.kodePaket,
      this.kodeBab,
      this.namaBab,
      required this.idJenisProduk,
      required this.namaJenisProduk,
      this.tanggalKedaluwarsa,
      required this.isPaket,
      required this.isSimpan,
      required this.lastUpdate});

  factory BookmarkSoal.fromJson(Map<String, dynamic> json) => BookmarkSoal(
        idSoal: json['c_id_soal'].toString(),
        nomorSoal: (json['c_nomor_soal'] is int)
            ? json['c_nomor_soal']
            : int.parse(json['c_nomor_soal'].toString()),
        nomorSoalSiswa: (json['c_nomor_soal_siswa'] is int)
            ? json['c_nomor_soal_siswa']
            : int.parse(json['c_nomor_soal_siswa'].toString()),
        idBundel: json['c_id_bundel'].toString(),
        kodeTOB: json['kodeTOB'].toString(),
        kodePaket: json['c_kode_paket'],
        kodeBab: json['c_kode_bab'],
        namaBab: json['c_nama_bab'],
        isPaket: (json['c_kode_paket'] as String).contains('EMMA') ||
            (json['c_kode_paket'] as String).contains('EMWA'),
        isSimpan: true,
        idJenisProduk: json['c_id_jenis_produk'],
        namaJenisProduk: json['c_nama_jenis_produk'],
        tanggalKedaluwarsa: json['c_tanggal_kedaluwarsa'],
        lastUpdate: json['c_last_update'],
      );

  Map<String, dynamic> toJson() => {
        'c_id_soal': idSoal,
        'c_nomor_soal': nomorSoal,
        'c_nomor_soal_siswa': nomorSoalSiswa,
        'c_id_bundel': idBundel,
        'kodeTOB': kodeTOB,
        'c_kode_paket': kodePaket,
        'c_kode_bab': kodeBab,
        'c_nama_bab': namaBab,
        'c_id_jenis_produk': idJenisProduk,
        'c_nama_jenis_produk': namaJenisProduk,
        'c_tanggal_kedaluwarsa': tanggalKedaluwarsa,
        'isPaket': isPaket,
        'isSimpan': isSimpan,
        'c_last_update': lastUpdate,
      };

  int compareTo(BookmarkSoal b) {
    if (kodePaket == b.kodePaket) {
      return nomorSoalSiswa.compareTo(b.nomorSoalSiswa);
    } else {
      return kodePaket.compareTo(b.kodePaket);
    }
  }

  @override
  String toString() => ' BookmarkMapel('
      'idSoal: $idSoal, '
      'nomorSoal: $nomorSoal, '
      'nomorSoalSiswa $nomorSoalSiswa, '
      'c_id_bundel: $idBundel, '
      'kodeTOB: $kodeTOB, '
      'c_kode_paket: $kodePaket, '
      'c_kode_bab: $kodeBab, '
      'namaBab: $namaBab, '
      'idJenisProduk: $idJenisProduk, '
      'namaJenisProduk: $namaJenisProduk, '
      'c_tanggal_kedaluwarsa: $tanggalKedaluwarsa, '
      'isPaket: $isPaket, '
      'isSimpan: $isSimpan, '
      'lastUpdate: $lastUpdate), ';
}
