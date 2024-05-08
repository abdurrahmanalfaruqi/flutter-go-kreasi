part of 'laporan_vak_bloc.dart';

abstract class LaporanVakState extends Equatable {
  const LaporanVakState();

  @override
  List<Object> get props => [];
}

class LaporanVakInitial extends LaporanVakState {}

class LaporanVakLoading extends LaporanVakState {}

class LaporanVakDataLoaded extends LaporanVakState {
  final LaporanVAK laporanVAK;

  const LaporanVakDataLoaded({required this.laporanVAK});

  @override
  List<Object> get props => [laporanVAK];
}

class LaporanVakError extends LaporanVakState {
  final String errorMessage;

  const LaporanVakError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
