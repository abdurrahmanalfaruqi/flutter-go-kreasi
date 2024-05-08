part of 'bundel_soal_bloc.dart';

class BundelSoalState extends Equatable {
  const BundelSoalState();

  @override
  List<Object> get props => [];
}

class BundelSoalInitial extends BundelSoalState {}

class BundelSoalLoading extends BundelSoalState {}

class BundelSoalPaginationLoading extends BundelSoalState {}

class BundelSoalLoaded extends BundelSoalState {
  final List<List<BundelSoal>> listBundelSoal;
  final List<String> listKelompokUjian;

  const BundelSoalLoaded({
    required this.listBundelSoal,
    required this.listKelompokUjian,
  });

  @override
  List<Object> get props => [listBundelSoal, listKelompokUjian];
}

class LoadedBundleBab extends BundelSoalState {
  final List<BabUtamaSoal> listBab;
  const LoadedBundleBab(this.listBab);

  @override
  List<Object> get props => [listBab];
}

class BundelSoalError extends BundelSoalState {
  final String err;
  const BundelSoalError({required this.err,});

  @override
  List<Object> get props => [err];
}
