part of 'profile_bloc.dart';

class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileGetOpsiError extends ProfileState {
  final String err;
  const ProfileGetOpsiError(this.err);

  @override
  List<Object> get props => [err];
}

class ProfileError extends ProfileState {
  final String err;
  const ProfileError(this.err);

  @override
  List<Object> get props => [err];
}

class ProfileFailedSaveMapel extends ProfileState {
  final String err;
  const ProfileFailedSaveMapel(this.err);

  @override
  List<Object> get props => [err];
}

class LoadedGetCurrentMapel extends ProfileState {
  final List<MapelPilihan> listMapelPilihan;

  const LoadedGetCurrentMapel(this.listMapelPilihan);

  @override
  List<Object> get props => [listMapelPilihan];
}

/// [ProfileNotValid] state ini digunakan ketika idSekolahKelas siswa tidak
/// valid kurikulum Merdeka
class ProfileNotValid extends ProfileState {}

class LoadedOpsiMapel extends ProfileState {
  final List<MapelPilihan> listOpsiMapel;
  final int minimalPilih;
  final int maximalPilih;
  const LoadedOpsiMapel({
    required this.listOpsiMapel,
    required this.minimalPilih,
    required this.maximalPilih,
  });

  @override
  List<Object> get props => [
        listOpsiMapel,
        minimalPilih,
        maximalPilih,
      ];
}

class SuccessSaveMapel extends ProfileState {
  final MapelPilihan selectedMapel;
  const SuccessSaveMapel(this.selectedMapel);

  @override
  List<Object> get props => [selectedMapel];
}
