part of 'rencana_belajar_bloc.dart';

class RencanaBelajarEvent extends Equatable {
  const RencanaBelajarEvent();

  @override
  List<Object> get props => [];
}

class LoadRencanaBelajar extends RencanaBelajarEvent {
  final String noregister;
  final bool isRefresh;
  const LoadRencanaBelajar({required this.noregister, required this.isRefresh});

  @override
  List<Object> get props => [noregister, isRefresh];
}
