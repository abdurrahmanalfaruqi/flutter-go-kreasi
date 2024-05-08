part of 'rencana_belajar_bloc.dart';

class RencanaBelajarState extends Equatable {
  const RencanaBelajarState();

  @override
  List<Object> get props => [];
}

class RencanaBelajarInitial extends RencanaBelajarState {}

class RencanaBelajarLoading extends RencanaBelajarState {}

class RencanaBelajarDataLoaded extends RencanaBelajarState {
  final List<RencanaBelajar> listRencanaBelajar;
  final List<RencanaMenu> listMenuRencana;
  const RencanaBelajarDataLoaded({required this.listRencanaBelajar, required this.listMenuRencana});

  @override
  List<Object> get props => [listRencanaBelajar, listMenuRencana];
}

class RencanaBelajarError extends RencanaBelajarState {
  final String errorMessage;

  const RencanaBelajarError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
