part of 'paket_soal_bloc.dart';

class PaketSoalState extends Equatable {
  const PaketSoalState();

  @override
  List<Object?> get props => [];
}

class PaketSoalInitial extends PaketSoalState {}

class PaketSoalLoading extends PaketSoalState {}

class PaketSoalPaginateLoading extends PaketSoalState {}

class PaketSoalLoaded extends PaketSoalState {
  final List<PaketSoal> listPaketSoal;
  final int page;
  final int jumlahHalaman;

  const PaketSoalLoaded({
    required this.listPaketSoal,
    required this.page,
    required this.jumlahHalaman,
  });

  @override
  List<Object> get props => [listPaketSoal, page, jumlahHalaman];
}

class PaketSoalError extends PaketSoalState {
  final String err;
  final int? page;
  final bool? shouldBeEmpty;
  const PaketSoalError({required this.err, this.page, this.shouldBeEmpty});

  @override
  List<Object?> get props => [err, page ?? 0, shouldBeEmpty];
}

class PaketSuccessMulaiTO extends PaketSoalState {
  final bool isSuccess;
  final String kodePaket;
  final String kodeTOB;
  final bool isSelesai;
  final String? tanggalKadaluarsa;
  final List<int> listIdBundel;
  final int jumlahSoalPaket;
  final bool isKedaluarsa;
  const PaketSuccessMulaiTO({
    required this.isSuccess,
    required this.kodePaket,
    required this.kodeTOB,
    required this.isSelesai,
    required this.listIdBundel,
    required this.jumlahSoalPaket,
    this.tanggalKadaluarsa,
    required this.isKedaluarsa,
  });

  @override
  List<Object> get props => [
        isSuccess,
        kodePaket,
        kodeTOB,
        isSelesai,
        tanggalKadaluarsa ?? '',
        listIdBundel,
        jumlahSoalPaket,
        isKedaluarsa,
      ];
}

class PaketSuccessSelesaiTO extends PaketSoalState {
  final bool isSuccess;
  const PaketSuccessSelesaiTO(this.isSuccess);

  @override
  List<Object> get props => [isSuccess];
}
