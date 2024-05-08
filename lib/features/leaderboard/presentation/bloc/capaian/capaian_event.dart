part of 'capaian_bloc.dart';

abstract class CapaianEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCapaian extends CapaianEvent {
  final bool isRefresh;
  final UserModel? userData;

  LoadCapaian({
    required this.isRefresh,
    required this.userData,
  });

  @override
  List<Object?> get props => [
        isRefresh,
        userData,
      ];
}
