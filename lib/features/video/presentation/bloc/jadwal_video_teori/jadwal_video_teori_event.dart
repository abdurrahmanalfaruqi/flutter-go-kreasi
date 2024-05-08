part of 'jadwal_video_teori_bloc.dart';

abstract class JadwalVideoTeoriEvent extends Equatable {
  const JadwalVideoTeoriEvent();

  @override
  List<Object> get props => [];
}

class LoadDaftarVideo extends JadwalVideoTeoriEvent {
  final List<int> listIdProduk;
  final bool isRefresh;
  const LoadDaftarVideo({
    required this.listIdProduk,
    required this.isRefresh,
  });
  @override
  List<Object> get props => [
        listIdProduk,
        isRefresh,
      ];
}

class LoadDaftarBabVideo extends JadwalVideoTeoriEvent {
  final String noRegistrasi;
  final String idMataPelajaran;
  final String tingkatSekolah;
  final String levelTeori;
  final int idBuku;
  final String kelengkapan;
  const LoadDaftarBabVideo({
    required this.noRegistrasi,
    required this.idMataPelajaran,
    required this.tingkatSekolah,
    required this.levelTeori,
    required this.idBuku,
    required this.kelengkapan,
  });
  @override
  List<Object> get props => [
        noRegistrasi,
        idMataPelajaran,
        tingkatSekolah,
        levelTeori,
        idBuku,
        kelengkapan
      ];
}

class LoadDaftarVideoEkstra extends JadwalVideoTeoriEvent {
  final UserModel? userData;

  const LoadDaftarVideoEkstra(this.userData);

  @override
  List<Object> get props => [userData ?? UserModel()];
}
