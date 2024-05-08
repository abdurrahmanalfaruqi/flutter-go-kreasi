part of 'profile_bloc.dart';

class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class ProfileGetSekolahKelas extends ProfileEvent {
  final UserModel? userData;
  const ProfileGetSekolahKelas(this.userData);

  @override
  List<Object> get props => [userData ?? UserModel()];
}

class ProfileGetOpsiMapel extends ProfileEvent {
  final String idSekolahKelas;
  const ProfileGetOpsiMapel(this.idSekolahKelas);

  @override
  List<Object> get props => [idSekolahKelas];
}

class ProfileSaveMapel extends ProfileEvent {
  final String noRegistrasi;
  final List<MapelPilihan> listSelectedMapel;
  const ProfileSaveMapel({
    required this.noRegistrasi,
    required this.listSelectedMapel,
  });

  @override
  List<Object> get props => [noRegistrasi, listSelectedMapel];
}
