part of 'laporan_aktivitas_bloc.dart';

abstract class LaporanAktivitasEvent extends Equatable {
  const LaporanAktivitasEvent();

  @override
  List<Object> get props => [];
}

class LoadLaporanAktivitas extends LaporanAktivitasEvent {
  final String noRegistrasi;
  final String type;
  final bool isRefresh;

  const LoadLaporanAktivitas({
    required this.noRegistrasi,
    required this.type,
    required this.isRefresh,
  });

  @override
  List<Object> get props => [noRegistrasi, type, isRefresh];
}
