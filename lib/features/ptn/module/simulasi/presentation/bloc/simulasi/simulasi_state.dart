part of 'simulasi_bloc.dart';

class SimulasiState extends Equatable {
  const SimulasiState();

  @override
  List<Object> get props => [];
}

class SimulasiInitial extends SimulasiState {}

class SimulasiLoading extends SimulasiState {}

class SimulasiDataLoaded extends SimulasiState {
  final List<NilaiModel> listNilai;
  const SimulasiDataLoaded(
      {required this.listNilai});

  @override
  List<Object> get props => [listNilai];
}

class SimulasiError extends SimulasiState {
  final String errorMessage;

  const SimulasiError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
