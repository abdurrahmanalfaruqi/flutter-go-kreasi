part of 'capaian_bloc.dart';

class CapaianState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CapaianInitial extends CapaianState {}

class CapaianLoading extends CapaianState {}

class CapaianDataLoaded extends CapaianState {
  final CapaianScore capaianScore;
  final List<CapaianDetailScore> capaianNilaiDetail;

  CapaianDataLoaded({
    required this.capaianScore,
    required this.capaianNilaiDetail,
  });

  @override
  List<Object?> get props => [capaianScore, capaianNilaiDetail];
}

class CapaianError extends CapaianState {
  final String errorMessage;

  CapaianError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}