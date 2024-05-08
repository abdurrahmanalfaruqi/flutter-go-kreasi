part of 'jadwal_bloc.dart';

class JadwalEvent extends Equatable {
  const JadwalEvent();

  @override
  List<Object> get props => [];
}

class LoadJadwal extends JadwalEvent {
  final UserModel? userData;
  final bool isRefresh;
  const LoadJadwal({required this.userData, required this.isRefresh});

  @override
  List<Object> get props => [userData ?? UserModel(), isRefresh];
}
