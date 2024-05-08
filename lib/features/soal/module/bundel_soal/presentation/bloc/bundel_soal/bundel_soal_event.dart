part of 'bundel_soal_bloc.dart';

class BundelSoalEvent extends Equatable {
  const BundelSoalEvent();

  @override
  List<Object> get props => [];
}

class GetBundelSoalList extends BundelSoalEvent {
  final int idBundlingAktif;
  final String idSekolahKelas;
  final int idJenisProduk;
  final String teaserRole;
  final bool isRefresh;
  final List<int> listIdProduk;
  final String noRegistrasi;

  const GetBundelSoalList({
    required this.idBundlingAktif,
    required this.idJenisProduk,
    required this.isRefresh,
    required this.idSekolahKelas,
    required this.teaserRole,
    required this.listIdProduk,
    required this.noRegistrasi,
  });
  @override
  List<Object> get props => [
        idBundlingAktif,
        idSekolahKelas,
        idJenisProduk,
        teaserRole,
        isRefresh,
        listIdProduk,
      ];
}

class GetBundleBabList extends BundelSoalEvent {
  final int idBundlingAktif;
  final String idBundle;
  final bool isRefresh;

  const GetBundleBabList({
    required this.idBundlingAktif,
    required this.idBundle,
    required this.isRefresh,
  });

  @override
  List<Object> get props => [
        idBundlingAktif,
        idBundle,
        isRefresh,
      ];
}
