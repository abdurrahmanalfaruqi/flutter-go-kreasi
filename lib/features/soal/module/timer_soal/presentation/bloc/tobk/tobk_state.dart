part of 'tobk_bloc.dart';

class TOBKState extends Equatable {
  const TOBKState();

  @override
  List<Object?> get props => [];
}

class TOBKInitial extends TOBKState {}

class TOBKLoading extends TOBKState {}

class TOBKPaginateLoading extends TOBKState {}

class TOBIsLoading extends TOBKState {}

class TOBKSyaratLoading extends TOBKState {}

class TOBKSuccessMulaiTO extends TOBKState {
  final PaketTO paketTO;
  final bool isRemedialGOA;

  const TOBKSuccessMulaiTO({
    required this.paketTO,
    required this.isRemedialGOA,
  });

  @override
  List<Object> get props => [paketTO, isRemedialGOA];
}

class TOBKError extends TOBKState {
  final String err;
  final int? page;
  final bool? shouldBeEmpty;

  const TOBKError({required this.err, this.page, this.shouldBeEmpty});

  @override
  List<Object?> get props => [err, page];
}

class TOBKErrorResponse extends TOBKState {
  final String err;
  const TOBKErrorResponse(this.err);

  @override
  List<Object> get props => [err];
}

class TOBKErrorMapel extends TOBKState {}

class TOBKErrorSyarat extends TOBKState {
  final String err;

  const TOBKErrorSyarat(this.err);

  @override
  List<Object> get props => [err];
}

class LoadedListTOB extends TOBKState {
  // final List<dynamic> resListTOB;
  final List<Tob> listTOB;

  const LoadedListTOB(this.listTOB);

  @override
  List<Object> get props => [listTOB];
}

class LoadedItemSyaratTOBK extends TOBKState {
  final Map<String, SyaratTOBK> listSyaratTOB;
  final List<String> listKodeTOBMemenuhiSyarat;

  const LoadedItemSyaratTOBK(
      this.listSyaratTOB, this.listKodeTOBMemenuhiSyarat);

  @override
  List<Object> get props => [listSyaratTOB];
}

class LoadedPopUpSyaratTOBK extends TOBKState {
  final Map<String, SyaratTOBK> listSyaratTOB;
  final List<String> listKodeTOBMemenuhiSyarat;

  const LoadedPopUpSyaratTOBK(
      this.listSyaratTOB, this.listKodeTOBMemenuhiSyarat);

  @override
  List<Object> get props => [listSyaratTOB];
}

class LoadedServerTimeTOBK extends TOBKState {
  final DateTime serverTime;

  const LoadedServerTimeTOBK(this.serverTime);

  @override
  List<Object> get props => [serverTime];
}

class LoadedDetailJawabanSiswa extends TOBKState {
  final List<DetailJawaban> listDetailJawabanSiswa;

  const LoadedDetailJawabanSiswa(this.listDetailJawabanSiswa);

  @override
  List<Object> get props => [listDetailJawabanSiswa];
}

class LoadedDaftarSoalTO extends TOBKState {
  final List<DetailBundel> listDetailBundel;

  const LoadedDaftarSoalTO(this.listDetailBundel);

  @override
  List<Object> get props => [listDetailBundel];
}

class LoadedListKisiKisi extends TOBKState {
  final Map<String, List<KisiKisi>> listKisiKisi;

  const LoadedListKisiKisi(this.listKisiKisi);

  @override
  List<Object> get props => [listKisiKisi];
}

class LoadedHasilGOA extends TOBKState {
  final Map<String, HasilGOA> hasilGOA;

  const LoadedHasilGOA(this.hasilGOA);

  @override
  List<Object> get props => [hasilGOA];
}

class LoadedPaketTO extends TOBKState {
  final Map<String, List<PaketTO>> listPaketTO;

  const LoadedPaketTO(this.listPaketTO);

  @override
  List<Object> get props => [listPaketTO];
}

class SuccessKumpulkanJawabanGOA extends TOBKState {
  final bool success;

  const SuccessKumpulkanJawabanGOA(this.success);

  @override
  List<Object> get props => [success];
}

class LoadedListTO extends TOBKState {
  final List<PaketTO> paketTO;
  final int? page;
  final int? jumlahHalaman;
  final bool isRefresh;

  const LoadedListTO({
    required this.paketTO,
    required this.isRefresh,
    this.page,
    this.jumlahHalaman,
  });

  @override
  List<Object> get props => [
        paketTO,
        page ?? 0,
        jumlahHalaman ?? 0,
        isRefresh,
      ];
}

class LoadedListSoalPaketTO extends TOBKState {
  final Map<String, List<Soal>>? listSoal;
  final UnmodifiableListView<DetailBundel>? listDetailWaktuByKodePaket;

  const LoadedListSoalPaketTO({this.listSoal, this.listDetailWaktuByKodePaket});

  @override
  List<Object> get props => [listSoal ?? {}, listDetailWaktuByKodePaket ?? []];
}

class LoadedDetailWaktu extends TOBKState {
  final Map<String, List<DetailBundel>> listDetailWaktu;

  const LoadedDetailWaktu(this.listDetailWaktu);

  @override
  List<Object> get props => [listDetailWaktu];
}

class LoadedUrutanPaket extends TOBKState {
  final int urutan;

  const LoadedUrutanPaket(this.urutan);

  @override
  List<Object> get props => [urutan];
}

class LoadedSisaWaktu extends TOBKState {
  final Duration sisaWaktu;

  const LoadedSisaWaktu(this.sisaWaktu);

  @override
  List<Object> get props => [sisaWaktu];
}

class LoadedSoal extends TOBKState {
  final List<DetailBundel>? listDetailWaktu;
  final List<Soal> listSoal;
  final Duration? waktuPengerjaan;
  final int? indexPaket;
  final int? totalSoalRagu;

  const LoadedSoal({
    this.listDetailWaktu,
    required this.listSoal,
    this.waktuPengerjaan,
    this.indexPaket,
    this.totalSoalRagu = 0,
  });

  @override
  List<Object> get props => [
        listDetailWaktu ?? [],
        listSoal,
        waktuPengerjaan ?? const Duration(),
        indexPaket ?? 0,
        totalSoalRagu ?? 0,
      ];
}

class LoadedIntervalTimer extends TOBKState {
  final int timer;
  const LoadedIntervalTimer(this.timer);

  @override
  List<Object> get props => [timer];
}
