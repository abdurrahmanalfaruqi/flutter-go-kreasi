part of 'tobk_bloc.dart';

class TOBKEvent extends Equatable {
  const TOBKEvent();

  @override
  List<Object> get props => [];
}

class TOBKGetDaftarTOB extends TOBKEvent {
  final Map<String, dynamic> params;
  final bool isRefresh;
  final int idJenisProduk;
  final int idBundlingAktif;

  const TOBKGetDaftarTOB({
    required this.params,
    required this.isRefresh,
    required this.idJenisProduk,
    required this.idBundlingAktif,
  });

  @override
  List<Object> get props => [
        isRefresh,
        params,
        idJenisProduk,
        idBundlingAktif,
      ];
}

class TOBKCekBolehTO extends TOBKEvent {
  final String? noRegistrasi;
  final String kodeTOB;
  final String namaTOB;
  final bool isPopup;

  const TOBKCekBolehTO({
    this.noRegistrasi,
    required this.kodeTOB,
    required this.namaTOB,
    required this.isPopup,
  });

  @override
  List<Object> get props => [noRegistrasi ?? '', kodeTOB, namaTOB, isPopup];
}

class TOBKSetServerTime extends TOBKEvent {
  final DateTime serverTime;

  const TOBKSetServerTime(this.serverTime);

  @override
  List<Object> get props => [serverTime];
}

class TOBKToggleRaguRagu extends TOBKEvent {
  final String tahunAjaran;
  final String idSekolahKelas;
  final String? noRegistrasi;
  final String? tipeUser;
  final String kodePaket;

  const TOBKToggleRaguRagu({
    required this.tahunAjaran,
    required this.idSekolahKelas,
    this.noRegistrasi,
    this.tipeUser,
    required this.kodePaket,
  });

  @override
  List<Object> get props => [
        tahunAjaran,
        idSekolahKelas,
        noRegistrasi ?? '',
        tipeUser ?? '',
        kodePaket,
      ];
}

class TOBKGetDetailJawabanSiswa extends TOBKEvent {
  final String kodePaket;
  final String tahunAjaran;
  final String idSekolahKelas;
  final String? noRegistrasi;
  final String? tipeUser;

  const TOBKGetDetailJawabanSiswa({
    required this.kodePaket,
    required this.tahunAjaran,
    required this.idSekolahKelas,
    this.noRegistrasi,
    this.tipeUser,
  });

  @override
  List<Object> get props => [
        kodePaket,
        tahunAjaran,
        idSekolahKelas,
        noRegistrasi ?? '',
        tipeUser ?? '',
      ];
}

class TOBKGetDaftarSoalTO extends TOBKEvent {
  final String kodeTOB;
  final String kodePaket;
  final int idJenisProduk;
  final String namaJenisProduk;
  final String tahunAjaran;
  final String idSekolahKelas;
  final String? noRegistrasi;
  final String? tipeUser;
  final bool isAwalMulai;
  final int totalWaktu;
  final DateTime? tanggalSelesai;
  final DateTime? tanggalSiswaSubmit;
  final DateTime tanggalKedaluwarsaTOB;
  final bool isBlockingTime;
  final bool isTOBBerakhir;
  final bool isRandom;
  final bool isRemedialGOA;
  final bool isRefresh;
  final int nomorSoalAwal;
  final int urutan;
  final List<int> listIdBundleSoal;

  const TOBKGetDaftarSoalTO({
    required this.kodeTOB,
    required this.kodePaket,
    required this.idJenisProduk,
    required this.namaJenisProduk,
    required this.tahunAjaran,
    required this.idSekolahKelas,
    this.noRegistrasi,
    this.tipeUser,
    this.isAwalMulai = true,
    required this.totalWaktu,
    this.tanggalSelesai,
    this.tanggalSiswaSubmit,
    required this.tanggalKedaluwarsaTOB,
    required this.isBlockingTime,
    required this.isTOBBerakhir,
    required this.isRandom,
    required this.isRemedialGOA,
    this.isRefresh = false,
    this.nomorSoalAwal = 1,
    required this.urutan,
    required this.listIdBundleSoal,
  });

  @override
  List<Object> get props => [
        kodeTOB,
        kodePaket,
        idJenisProduk,
        namaJenisProduk,
        tahunAjaran,
        idSekolahKelas,
        noRegistrasi ?? '',
        tipeUser ?? '',
        isAwalMulai,
        totalWaktu,
        tanggalSelesai ?? DateTime.now(),
        tanggalSiswaSubmit ?? DateTime.now(),
        tanggalKedaluwarsaTOB,
        isBlockingTime,
        isTOBBerakhir,
        isRandom,
        isRemedialGOA,
        isRefresh,
        nomorSoalAwal,
        urutan,
        listIdBundleSoal,
      ];
}

class TOBKGetKisiKisiPaket extends TOBKEvent {
  final String kodePaket;
  final bool isRefresh;
  final int idJenisProduk;

  const TOBKGetKisiKisiPaket({
    required this.kodePaket,
    this.isRefresh = false,
    required this.idJenisProduk,
  });

  @override
  List<Object> get props => [kodePaket, isRefresh, idJenisProduk];
}

class TOBKGetLaporanGOA extends TOBKEvent {
  final String noRegistrasi;
  final String kodePaket;
  final bool isRefresh;

  const TOBKGetLaporanGOA({
    required this.noRegistrasi,
    required this.kodePaket,
    this.isRefresh = false,
  });

  @override
  List<Object> get props => [noRegistrasi, kodePaket, isRefresh];
}

class TOBKGetDaftarPaketTO extends TOBKEvent {
  final String? noRegistrasi;
  final String? tahunAjaran;
  final String? idSekolahKelas;
  final String? kodeTOB;
  final int? idJenisProduk;
  final String? teaserRole;
  final bool isProdukDibeli;
  final String serviceType;
  final bool isRefresh;

  const TOBKGetDaftarPaketTO({
    required this.noRegistrasi,
    required this.tahunAjaran,
    required this.idSekolahKelas,
    this.kodeTOB,
    required this.idJenisProduk,
    required this.teaserRole,
    required this.serviceType,
    this.isProdukDibeli = false,
    this.isRefresh = false,
  });

  @override
  List<Object> get props => [
        noRegistrasi ?? '',
        tahunAjaran ?? '',
        idSekolahKelas ?? '',
        kodeTOB ?? '',
        idJenisProduk ?? 0,
        teaserRole ?? '',
        isProdukDibeli,
        isRefresh,
      ];
}

class TOBKKumpulkanJawabanGOA extends TOBKEvent {
  final String tahunAjaran;
  final String idSekolahKelas;
  final String tingkatKelas;
  final String? noRegistrasi;
  final String? tipeUser;
  final String idKota;
  final String idGedung;
  final int idJenisProduk;
  final String namaJenisProduk;
  final String kodeTOB;
  final String kodePaket;

  const TOBKKumpulkanJawabanGOA({
    required this.tahunAjaran,
    required this.idSekolahKelas,
    required this.tingkatKelas,
    this.noRegistrasi,
    this.tipeUser,
    required this.idKota,
    required this.idGedung,
    required this.idJenisProduk,
    required this.namaJenisProduk,
    required this.kodeTOB,
    required this.kodePaket,
  });

  @override
  List<Object> get props => [
        tahunAjaran,
        idSekolahKelas,
        tingkatKelas,
        noRegistrasi ?? '',
        tipeUser ?? '',
        idKota,
        idGedung,
        idJenisProduk,
        namaJenisProduk,
        kodeTOB,
        kodePaket,
      ];
}

class TOBKSetSisaWaktuFirebase extends TOBKEvent {
  final String noRegistrasi;
  final String tipeUser;
  final String kodePaket;
  final int totalWaktuSeharusnya;

  const TOBKSetSisaWaktuFirebase({
    required this.noRegistrasi,
    required this.tipeUser,
    required this.kodePaket,
    this.totalWaktuSeharusnya = -1,
  });

  @override
  List<Object> get props => [
        noRegistrasi,
        tipeUser,
        kodePaket,
        totalWaktuSeharusnya,
      ];
}

class TOBKSetMulaiTO extends TOBKEvent {
  final String noRegister;
  final String tahunAjaran;
  final String kodePaket;
  final int totalWaktuPaket;
  final PaketTO paketTO;
  final int idJenisProduk;
  final bool isRemedialGOA;
  final int tingkatKelas;

  const TOBKSetMulaiTO(
      {required this.noRegister,
      required this.tahunAjaran,
      required this.kodePaket,
      required this.totalWaktuPaket,
      required this.paketTO,
      required this.idJenisProduk,
      required this.isRemedialGOA,
      required this.tingkatKelas});

  @override
  List<Object> get props => [
        noRegister,
        tahunAjaran,
        kodePaket,
        totalWaktuPaket,
        paketTO,
        idJenisProduk,
        isRemedialGOA,
        tingkatKelas
      ];
}

class TOBKGetListTO extends TOBKEvent {
  final int idJenisProduk;
  final List<int> listIdProduk;
  final bool isRefresh;
  final String? kodeTOB;
  final int? page;
  final String? noRegistrasi;
  final int idBundlingAktif;

  const TOBKGetListTO({
    required this.idJenisProduk,
    required this.listIdProduk,
    required this.isRefresh,
    required this.noRegistrasi,
    required this.idBundlingAktif,
    this.page,
    this.kodeTOB,
  });

  @override
  List<Object> get props => [
        idJenisProduk,
        listIdProduk,
        isRefresh,
        kodeTOB ?? '',
        page ?? 0,
        idBundlingAktif,
      ];
}

class TOBKSetDetailWaktu extends TOBKEvent {
  final Map<String, List<DetailBundel>> detailWaktu;

  const TOBKSetDetailWaktu(this.detailWaktu);

  @override
  List<Object> get props => [detailWaktu];
}

class TOBKSetUrutanPaket extends TOBKEvent {
  final int urutan;

  const TOBKSetUrutanPaket(this.urutan);

  @override
  List<Object> get props => [urutan];
}

class TOBKSetBlockingTime extends TOBKEvent {
  final int waktuPengerjaan;

  const TOBKSetBlockingTime(this.waktuPengerjaan);

  @override
  List<Object> get props => [waktuPengerjaan];
}

class TOBKGetAllJawabanSiswa extends TOBKEvent {
  final String? noRegistrasi;
  final String kodePaket;
  final String? tahunAjaran;
  final int urutan;
  final int idJenisProduk;

  const TOBKGetAllJawabanSiswa({
    required this.noRegistrasi,
    required this.kodePaket,
    required this.tahunAjaran,
    required this.urutan,
    required this.idJenisProduk,
  });

  @override
  List<Object> get props => [
        noRegistrasi!,
        kodePaket,
        tahunAjaran!,
        urutan,
        idJenisProduk,
      ];
}

class TOBKIntervalTimer extends TOBKEvent {
  final int timer;
  const TOBKIntervalTimer(this.timer);

  @override
  List<Object> get props => [timer];
}
