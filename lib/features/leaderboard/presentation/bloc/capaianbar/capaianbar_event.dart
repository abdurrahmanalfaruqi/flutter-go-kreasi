part of 'capaianbar_bloc.dart';

abstract class CapaianBarEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCapaianBar extends CapaianBarEvent {
  final UserModel? userData;
  final bool isRefresh;

  LoadCapaianBar({
    required this.userData,
    required this.isRefresh,
  });

  @override
  List<Object?> get props => [userData, isRefresh];
}

class SetFilternilai extends CapaianBarEvent {
  final Filternilai filternilai;

  SetFilternilai({required this.filternilai});

  @override
  List<Object?> get props => [filternilai];
}
