part of 'jadwal_bloc.dart';

class JadwalState extends Equatable {
  const JadwalState();
  
  @override
  List<Object> get props => [];
}

class JadwalInitial extends JadwalState {}
class JadwalLoading extends JadwalState {}

class JadwalLoaded extends JadwalState {
  final List<InfoJadwal> listInfoJadwalKBM;
  const JadwalLoaded(
      {required this.listInfoJadwalKBM});

  @override
  List<Object> get props => [listInfoJadwalKBM];
}

class JadwalError extends JadwalState {
  final String err;
  const JadwalError(this.err);

  @override
  List<Object> get props => [err];
}