part of 'soal_bloc.dart';

enum SoalStatus { initial, loading, error, success }

class SoalState extends Equatable {
  final SoalStatus? soalStatus;
  final BukuSoal? bukuSoal;
  final Menu? selectedMenu;
  
  const SoalState({
    this.soalStatus = SoalStatus.initial,
    this.bukuSoal,
    this.selectedMenu,
  });

  SoalState copyWith({
    SoalStatus? soalStatus,
    BukuSoal? bukuSoal,
    Menu? selectedMenu,
  }) =>
      SoalState(
        soalStatus: soalStatus ?? this.soalStatus,
        bukuSoal: bukuSoal ?? this.bukuSoal,
        selectedMenu: selectedMenu ?? this.selectedMenu,
      );

  @override
  List<Object?> get props => [soalStatus, bukuSoal, selectedMenu];
}
