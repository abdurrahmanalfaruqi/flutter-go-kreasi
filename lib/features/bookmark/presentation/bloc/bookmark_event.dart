part of 'bookmark_bloc.dart';

abstract class BookmarkEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadBookmark extends BookmarkEvent {
  final String noRegistrasi;
  final bool isSiswa;
  final bool isrefresh;

  LoadBookmark(
      {required this.noRegistrasi,
      required this.isSiswa,
      required this.isrefresh});

  @override
  List<Object?> get props => [noRegistrasi, isSiswa, isrefresh];
}

class RemoveBookmarkMapel extends BookmarkEvent {
  final bool role;
  final String idKelompokUjian;
  final String noRegistrasi;

  RemoveBookmarkMapel(
      {required this.role,
      required this.idKelompokUjian,
      required this.noRegistrasi});

  @override
  List<Object?> get props => [role, idKelompokUjian, noRegistrasi];
}

class RemoveBookmarkSoal extends BookmarkEvent {
  final bool role;
  final String noRegistrasi;
  final String idKelompokUjian;
  final BookmarkSoal bookmarkSoal;

  RemoveBookmarkSoal(
      {required this.role,
      required this.idKelompokUjian,
      required this.bookmarkSoal,
      required this.noRegistrasi});

  @override
  List<Object?> get props =>
      [role, idKelompokUjian, bookmarkSoal, noRegistrasi];
}


class AddBookmark extends BookmarkEvent {
  final bool role;
  final String noRegistrasi;
  final int idJenisProduk;
  final String namaJenisProduk;
  final String kodePaket;
  final String idBundel;
  final String kodeBab;
  final String namaBab;
  final String tanggalKedaluwarsa;
  final bool isPaket;
  final bool isSimpan;
  final String kodeTob;
  final Soal soal;

  AddBookmark(
      {required this.role,
      required this.noRegistrasi,
      required this.idJenisProduk,
      required this.kodeBab,
      required this.idBundel,
      required this.kodePaket,
      required this.kodeTob,
      required this.isPaket,
      required this.isSimpan,
      required this.namaBab,
      required this.tanggalKedaluwarsa,
      required this.namaJenisProduk,
      required this.soal});

  @override
  List<Object> get props => [
        role,
        noRegistrasi,
        idJenisProduk,
        isPaket,
        isSimpan,
        tanggalKedaluwarsa,
        namaJenisProduk,
        kodeBab,
        kodePaket,
        namaBab,
        idBundel,
        soal,
        kodeTob
      ];
}

class ReloadBookmarkFromHive extends BookmarkEvent {
  ReloadBookmarkFromHive();

  @override
  List<Object?> get props => [];
}

class DeleteBookmark extends BookmarkEvent {
  final BookmarkSoal bookmarkSoal;
  final String noRegister;
  final bool isBoleh;
  final String idKelompokUjian;
  DeleteBookmark(
      {required this.bookmarkSoal,
      required this.noRegister,
      required this.isBoleh,
      required this.idKelompokUjian});

  @override
  List<Object?> get props => [bookmarkSoal, noRegister, isBoleh,idKelompokUjian];
}
