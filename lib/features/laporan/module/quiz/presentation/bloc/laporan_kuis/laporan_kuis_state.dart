part of 'laporan_kuis_bloc.dart';

class LaporanKuisState extends Equatable {
  const LaporanKuisState();

  @override
  List<Object> get props => [];
}

class LaporanKuisInitial extends LaporanKuisState {}

class LaporanKuisLoading extends LaporanKuisState {}

class LaporanHasilKuisLoading extends LaporanKuisState {}

class LaporanKuisDataLoaded extends LaporanKuisState {
  final List<LaporanKuisModel> listLaporanKuis;
  final List<DetailJawaban> listHasilKuis;

  const LaporanKuisDataLoaded(
      {required this.listLaporanKuis, required this.listHasilKuis});

  @override
  List<Object> get props => [listLaporanKuis, listHasilKuis];
}

class LaporanKuisError extends LaporanKuisState {
  final String errorMessage;

  const LaporanKuisError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
