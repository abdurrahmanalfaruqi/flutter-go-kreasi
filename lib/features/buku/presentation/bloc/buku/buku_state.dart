part of 'buku_bloc.dart';

class BukuState extends Equatable {
  const BukuState();

  @override
  List<Object> get props => [];
}

class BukuInitial extends BukuState {}

class BukuLoading extends BukuState {}

class BukuLoaded extends BukuState {
  final List<Buku> listBuku;
  final List<BabUtamaBuku> listBab;

  const BukuLoaded({
    required this.listBuku,
    required this.listBab,
  });

  @override
  List<Object> get props => [listBuku, listBab];
}

class BukuError extends BukuState {
  final String err;
  const BukuError(this.err);

  @override
  List<Object> get props => [err];
}
