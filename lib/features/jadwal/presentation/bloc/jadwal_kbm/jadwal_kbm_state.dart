part of 'jadwal_kbm_bloc.dart';

enum JadwalKBMStatus { initial, loadingTanggal, loadingJadwal, error, success }

class JadwalKBMState extends Equatable {
  final JadwalKBMStatus? status;
  final List<InfoJadwal>? listTanggalKBM;
  final List<JadwalSiswa>? listJadwalKBM;
  final DateTime? selectedDate;
  final bool isReverseTransition;

  const JadwalKBMState({
    this.status = JadwalKBMStatus.initial,
    this.selectedDate,
    this.listTanggalKBM,
    this.listJadwalKBM,
    this.isReverseTransition = false,
  });

  JadwalKBMState copyWith({
    required JadwalKBMStatus? status,
    DateTime? selectedDate,
    List<InfoJadwal>? listTanggalKBM,
    List<JadwalSiswa>? listJadwalKBM,
    bool? isReverseTransition,
  }) =>
      JadwalKBMState(
        status: status ?? this.status,
        selectedDate: selectedDate ?? this.selectedDate,
        listTanggalKBM: listTanggalKBM ?? this.listTanggalKBM,
        listJadwalKBM: listJadwalKBM ?? this.listJadwalKBM,
        isReverseTransition: isReverseTransition ?? this.isReverseTransition,
      );

  List<DateTime> get weekDays => List<DateTime>.generate(15, (index) {
        return DateTime.now().serverTimeFromOffset.add(Duration(days: index));
      });

  int get indexToday => weekDays.indexWhere((dateTime) {
        final now = DateTime.now();

        return now.day == dateTime.day &&
            now.month == dateTime.month &&
            now.year == dateTime.year;
      });

  @override
  List<Object?> get props => [
        status,
        listTanggalKBM,
        selectedDate,
        listJadwalKBM,
        isReverseTransition,
      ];
}
