part of 'tata_tertib_bloc.dart';

class TataTertibBlocEvent extends Equatable {
  const TataTertibBlocEvent();

  @override
  List<Object> get props => [];
}

class LoadTataTertib extends TataTertibBlocEvent {
  final String noregister;
  final String tahunAjaran;
  const LoadTataTertib({
    required this.noregister,
    required this.tahunAjaran,
  });

  @override
  List<Object> get props => [noregister, tahunAjaran];
}

class StujuiTataTertib extends TataTertibBlocEvent {
  final String noregister;
  const StujuiTataTertib({required this.noregister});
  @override
  List<Object> get props => [noregister];
}
