part of 'buku_bloc.dart';

abstract class BukuEvent extends Equatable {
  const BukuEvent();

  @override
  List<Object> get props => [];
}

class LoadDaftarBuku extends BukuEvent {
  final String noRegistrasi;
  final int idJenisProduk;
  final String idSekolahKelas;
  final String roleTeaser;
  final bool isProdukDibeli;
  final List<int> listIdProduk;
  final bool isRefresh;
  final int idBundlingAktif;

  const LoadDaftarBuku({
    required this.noRegistrasi,
    required this.idJenisProduk,
    required this.roleTeaser,
    required this.isProdukDibeli,
    required this.listIdProduk,
    required this.isRefresh,
    required this.idSekolahKelas,
    required this.idBundlingAktif,
  });
  @override
  List<Object> get props => [
        noRegistrasi,
        idJenisProduk,
        idSekolahKelas,
        roleTeaser,
        isProdukDibeli,
        listIdProduk,
        isRefresh,
        idBundlingAktif,
      ];
}

class LoadDaftarBab extends BukuEvent {
  final String kodeBuku;
  final String kelengkapan;
  final String levelTeori;
  final int idJenisProduk;
  final bool isRefresh;
  final int idBundlingAktif;

  const LoadDaftarBab({
    required this.kodeBuku,
    required this.kelengkapan,
    required this.levelTeori,
    required this.idJenisProduk,
    required this.isRefresh,
    required this.idBundlingAktif,
  });

  @override
  List<Object> get props => [
        kodeBuku,
        kelengkapan,
        levelTeori,
        idJenisProduk,
        isRefresh,
        idBundlingAktif,
      ];
}
