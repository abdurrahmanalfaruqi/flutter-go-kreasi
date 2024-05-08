part of 'jadwal_kbm_bloc.dart';

class JadwalKBMEvent extends Equatable {
  const JadwalKBMEvent();

  @override
  List<Object?> get props => [];
}

class SetSelectedDate extends JadwalKBMEvent {
  final DateTime selectedDateTime;

  const SetSelectedDate(this.selectedDateTime);

  @override
  List<Object?> get props => [selectedDateTime];
}

class GetTanggalKBM extends JadwalKBMEvent {
  final UserModel? userData;
  final bool isRefresh;

  const GetTanggalKBM({required this.userData, required this.isRefresh});

  @override
  List<Object?> get props => [userData, isRefresh];
}

class GetJadwalByTanggal extends JadwalKBMEvent {
  final UserModel? userData;
  final bool isRefresh;

  const GetJadwalByTanggal({
    required this.userData,
    required this.isRefresh,
  });

  @override
  List<Object?> get props => [userData, isRefresh];
}
