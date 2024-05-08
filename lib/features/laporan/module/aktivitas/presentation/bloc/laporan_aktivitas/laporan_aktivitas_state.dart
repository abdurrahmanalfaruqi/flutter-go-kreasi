part of 'laporan_aktivitas_bloc.dart';

abstract class LaporanAktivitasState extends Equatable {
  const LaporanAktivitasState();

  @override
  List<Object> get props => [];
}

class LaporanAktivitasInitial extends LaporanAktivitasState {}

class LaporanAktivitasLoading extends LaporanAktivitasState {}

class LaporanAktivitasLoaded extends LaporanAktivitasState {
  final List<LaporanAktivitasModel> listLaporanAktivitas;

  const LaporanAktivitasLoaded({required this.listLaporanAktivitas});

  @override
  List<Object> get props => [listLaporanAktivitas];
}

class LaporanAktivitasError extends LaporanAktivitasState {
  final String err;
  const LaporanAktivitasError(this.err);

  @override
  List<Object> get props => [err];
}
