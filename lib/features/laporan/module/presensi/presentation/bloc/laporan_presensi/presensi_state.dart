part of 'presensi_bloc.dart';

enum PresensiStatus { initial, loading, success, error }

class PresensiState extends Equatable {
  final PresensiStatus status;
  final List<LaporanPresensiInfo>? listJadwalPresence;
  final String? errorMessage;

  const PresensiState({
    this.status = PresensiStatus.initial,
    this.listJadwalPresence,
    this.errorMessage,
  });

  PresensiState copyWith({
    PresensiStatus? status,
    List<LaporanPresensiInfo>? listJadwalPresence,
    String? errorMessage,
  }) =>
      PresensiState(
        status: status ?? this.status,
        listJadwalPresence: listJadwalPresence ?? this.listJadwalPresence,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, listJadwalPresence, errorMessage];
}
