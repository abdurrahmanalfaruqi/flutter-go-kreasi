part of 'soal_bloc.dart';

class SoalEvent extends Equatable {
  const SoalEvent();

  @override
  List<Object?> get props => [];
}

class LoadListBukuSoal extends SoalEvent {
  final UserModel? userData;
  final bool isRefresh;

  const LoadListBukuSoal({required this.isRefresh, required this.userData});

  @override
  List<Object?> get props => [userData, isRefresh];
}

class SetSelectedMenu extends SoalEvent {
  final Menu? selectedMenu;

  const SetSelectedMenu({required this.selectedMenu});

  @override
  List<Object?> get props => [selectedMenu];
}
