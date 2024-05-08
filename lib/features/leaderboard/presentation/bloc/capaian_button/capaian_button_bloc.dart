import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'capaian_button_event.dart';
part 'capaian_button_state.dart';

class CapaianButtonBloc extends Bloc<CapaianButtonEvent, CapaianButtonState> {
  CapaianButtonBloc() : super(CapaianButtonInitial()) {
    on<CapaianButtonEvent>((event, emit) {
      if (event is InitialCapaianButton) {
        // jika item tidak overflow maka disable
        if (event.isScrollable) {
          emit(LoadedInitCapaianButton(event.isScrollable));
        } else {
          emit(CapaianButtonDisable());
        }
      }

      if (event is SetExtentButton) {
        emit(LoadedExtentButton(
          isMinExtent: event.isMinExtent,
          isMaxExtent: event.isMaxExtent,
        ));
      }
    });
  }
}
