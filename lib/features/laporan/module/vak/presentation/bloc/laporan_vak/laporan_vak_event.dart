part of 'laporan_vak_bloc.dart';

abstract class LaporanVakEvent extends Equatable {
  const LaporanVakEvent();

  @override
  List<Object> get props => [];
}

class LoadLaporanVak extends LaporanVakEvent {
  final String noRegistrasi;
  final String userType;
  final bool isRefresh;
  const LoadLaporanVak({required this.noRegistrasi, required this.userType, required this.isRefresh});

  @override
  List<Object> get props => [noRegistrasi,userType,isRefresh];
}
