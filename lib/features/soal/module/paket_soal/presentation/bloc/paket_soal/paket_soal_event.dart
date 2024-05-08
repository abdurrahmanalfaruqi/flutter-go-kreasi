part of 'paket_soal_bloc.dart';

class PaketSoalEvent extends Equatable {
  const PaketSoalEvent();

  @override
  List<Object> get props => [];
}

class GetPaketSoalList extends PaketSoalEvent {
  final String noRegistrasi;
  final String idSekolahKelas;
  final int idJenisProduk;
  final bool isRefresh;
  final List<int> listIdProduk;
  final int page;
  final int idBundlingAktif;
  final int tingkatKelas;

  const GetPaketSoalList({
    required this.idJenisProduk,
    required this.isRefresh,
    required this.noRegistrasi,
    required this.idSekolahKelas,
    required this.listIdProduk,
    required this.page,
    required this.idBundlingAktif,
    required this.tingkatKelas,
  });
  @override
  List<Object> get props => [
        noRegistrasi,
        idSekolahKelas,
        idJenisProduk,
        isRefresh,
        listIdProduk,
        page,
        idBundlingAktif,
        tingkatKelas,
      ];
}

class PaketMulaiTO extends PaketSoalEvent {
  final int idJenisProduk;
  final String noRegister;
  final String tahunAjaran;
  final String kodePaket;
  final String kodeTOB;
  final bool isSelesai;
  final String? tanggalKadaluarsa;
  final int totalWaktuPaket;
  final List<int> listIdBundel;
  final int jumlahSoalPaket;
  final bool isKedaluarsa;

  const PaketMulaiTO({
    required this.idJenisProduk,
    required this.noRegister,
    required this.tahunAjaran,
    required this.kodePaket,
    required this.kodeTOB,
    required this.isSelesai,
    required this.tanggalKadaluarsa,
    required this.totalWaktuPaket,
    required this.listIdBundel,
    required this.jumlahSoalPaket,
    required this.isKedaluarsa,
  });

  @override
  List<Object> get props => [
        idJenisProduk,
        noRegister,
        tahunAjaran,
        kodePaket,
        kodeTOB,
        isSelesai,
        tanggalKadaluarsa ?? '',
        totalWaktuPaket,
        listIdBundel,
        jumlahSoalPaket,
        isKedaluarsa,
      ];
}

class PaketSelesaiTO extends PaketSoalEvent {
  final int idJenisProduk;
  final String noRegister;
  final String tahunAjaran;
  final String kodePaket;
  final int tingkatKelas;
  final UserModel? userData;

  const PaketSelesaiTO({
    required this.idJenisProduk,
    required this.noRegister,
    required this.tahunAjaran,
    required this.kodePaket,
    required this.tingkatKelas,
    required this.userData,
  });

  @override
  List<Object> get props => [
        idJenisProduk,
        noRegister,
        tahunAjaran,
        kodePaket,
        tingkatKelas,
        userData ?? UserModel(),
      ];
}
