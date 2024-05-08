part of 'pembayaran_bloc.dart';

class PembayaranState extends Equatable {
  const PembayaranState();

  @override
  List<Object> get props => [];
}

class PembayaranInitial extends PembayaranState {}

class PembayaranLoading extends PembayaranState {}

class PembayaranDetailLoading extends PembayaranState {}

class PembayaranDataLoaded extends PembayaranState {
  final PembayaranModel pembayaranModel;
  final String pesan;
  final List<Pembayaran> listDetailPembayaran;
  
  const PembayaranDataLoaded({
    required this.pembayaranModel,
    required this.pesan,
    required this.listDetailPembayaran,
  });

  @override
  List<Object> get props => [pembayaranModel, pesan, listDetailPembayaran];
}

class PembayaranError extends PembayaranState {
  final String errorMessage;

  const PembayaranError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class PembayaranDetailError extends PembayaranState {
  final String errorMessage;

  const PembayaranDetailError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
