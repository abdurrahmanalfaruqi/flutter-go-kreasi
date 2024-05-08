part of 'pembayaran_bloc.dart';

abstract class PembayaranEvent extends Equatable {
  const PembayaranEvent();

  @override
  List<Object> get props => [];
}

class LoadPembayaran extends PembayaranEvent {
  final bool isRefresh;
  final String noRegistrasi;
  final int idbundling;
  const LoadPembayaran({
    required this.isRefresh,
    required this.noRegistrasi,
    required this.idbundling,
  });

  @override
  List<Object> get props => [isRefresh, noRegistrasi, idbundling];
}

class LoadPembayaranDetail extends PembayaranEvent {
  final bool isRefresh;
  final String noRegistrasi;
  final int idbundling;
  const LoadPembayaranDetail({
    required this.isRefresh,
    required this.noRegistrasi,
    required this.idbundling,
  });

  @override
  List<Object> get props => [isRefresh, noRegistrasi, idbundling];
}
