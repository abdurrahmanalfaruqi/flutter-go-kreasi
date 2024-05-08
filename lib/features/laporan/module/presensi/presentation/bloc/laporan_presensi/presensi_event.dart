part of 'presensi_bloc.dart';

class PresensiEvent extends Equatable {
  const PresensiEvent();

  @override
  List<Object> get props => [];
}

class LoadPresensiByTanggal extends PresensiEvent {
  final String noRegistrasi;
  final int idBundlingAktif;
  final String tanggal;
  final bool isRefresh;

  const LoadPresensiByTanggal({
    required this.noRegistrasi,
    required this.idBundlingAktif,
    required this.tanggal,
    required this.isRefresh,
  });

  @override
  List<Object> get props => [noRegistrasi, tanggal, idBundlingAktif, isRefresh];
}
