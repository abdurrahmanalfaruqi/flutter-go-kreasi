part of 'laporan_goa_bloc.dart';

abstract class LaporanGoaEvent extends Equatable {
  const LaporanGoaEvent();

  @override
  List<Object> get props => [];
}

class LoadLaporanGoa extends LaporanGoaEvent {
  final String noRegistrasi;
  final PaketTO paketTO;
  final String ta;
  final String kodePaket;

  const LoadLaporanGoa({
    required this.noRegistrasi,
    required this.paketTO,
    required this.ta,
    required this.kodePaket,
  });

  @override
  List<Object> get props => [noRegistrasi, paketTO, ta, kodePaket];
}
