part of 'capaian_button_bloc.dart';

class CapaianButtonEvent extends Equatable {
  const CapaianButtonEvent();

  @override
  List<Object> get props => [];
}

class InitialCapaianButton extends CapaianButtonEvent {
  final bool isScrollable;
  const InitialCapaianButton(this.isScrollable);

  @override
  List<Object> get props => [isScrollable];
}

class SetExtentButton extends CapaianButtonEvent {
  final bool isMinExtent;
  final bool isMaxExtent;

  const SetExtentButton({ required this.isMinExtent,required this.isMaxExtent});

  @override
  List<Object> get props => [isMinExtent, isMaxExtent];
}
