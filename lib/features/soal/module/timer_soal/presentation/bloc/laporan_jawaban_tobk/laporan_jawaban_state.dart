part of 'laporan_jawaban_bloc.dart';

class LaporanJawabanState extends Equatable {
  const LaporanJawabanState();

  @override
  List<Object> get props => [];
}

class LaporanJawabanInitial extends LaporanJawabanState {}

class LaporanJawabanLoading extends LaporanJawabanState {}

class LaporanJawabanLoaded extends LaporanJawabanState {
  final List<LaporanTryoutJawabanModel> listLaporanJawaban;

  const LaporanJawabanLoaded({required this.listLaporanJawaban});

  @override
  List<Object> get props => [listLaporanJawaban];
}

class LaporanJawabanError extends LaporanJawabanState {
  final String err;
  const LaporanJawabanError(this.err);

  @override
  List<Object> get props => [err];
}
