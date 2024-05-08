part of 'capaian_button_bloc.dart';

class CapaianButtonState extends Equatable {
  const CapaianButtonState();

  @override
  List<Object> get props => [];
}

class CapaianButtonInitial extends CapaianButtonState {}

class CapaianButtonDisable extends CapaianButtonState {}

class LoadedInitCapaianButton extends CapaianButtonState {
  final bool isScrollable;
  const LoadedInitCapaianButton(this.isScrollable);

  @override
  List<Object> get props => [isScrollable];
}

class LoadedExtentButton extends CapaianButtonState {
  final bool isMinExtent;
  final bool isMaxExtent;

  const LoadedExtentButton({
    required this.isMinExtent,
    required this.isMaxExtent,
  });

  @override
  List<Object> get props => [isMinExtent, isMaxExtent];
}
