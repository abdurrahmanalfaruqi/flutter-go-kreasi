part of 'laporan_goa_bloc.dart';

class LaporanGoaState extends Equatable {
  const LaporanGoaState();

  @override
  List<Object> get props => [];
}

class LaporanGoaInitial extends LaporanGoaState {}

class LaporanGoaLoading extends LaporanGoaState {}

class LaporanGoaLoaded extends LaporanGoaState {
  final HasilGOA hasilGOA;

  const LaporanGoaLoaded({required this.hasilGOA});

  @override
  List<Object> get props => [hasilGOA];
}

class LaporanGoaError extends LaporanGoaState {
  final String err;
  const LaporanGoaError(this.err);

  @override
  List<Object> get props => [err];
}
