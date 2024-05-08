part of 'capaianbar_bloc.dart';

class CapaianBarState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CapaianBarInitial extends CapaianBarState {}

class CapaianBarLoading extends CapaianBarState {}

class CapaianBarDataLoaded extends CapaianBarState {
  final Filternilai filterNilai;
  final List<PengerjaanSoal> listPengerjaanSoal;

  CapaianBarDataLoaded({
    required this.listPengerjaanSoal,
    required this.filterNilai,
  });

  @override
  List<Object?> get props => [listPengerjaanSoal, filterNilai];
}

class CapaianBarError extends CapaianBarState {
  final String errorMessage;

  CapaianBarError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}