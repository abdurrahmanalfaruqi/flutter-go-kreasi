import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/core/util/app_exceptions.dart';
import 'package:gokreasi_new/core/util/injector.dart';
import 'package:gokreasi_new/features/home/data/model/carousel_model.dart';
import 'package:gokreasi_new/features/home/domain/usecase/home_usecase.dart';

part 'carousel_event.dart';
part 'carousel_state.dart';

class CarouselBloc extends Bloc<CarouselEvent, CarouselState> {
  final Map<String, List<CarouselModel>> _listCarousel = {};

  CarouselBloc() : super(CarouselInitial()) {
    on<CarouselEvent>((event, emit) async {
      if (event is CarouselGet) {
        emit(CarouselLoading());
        try {
          if (_listCarousel.containsKey(event.noRegistrasi)) {
            emit(LoadedCarousel(_listCarousel[event.noRegistrasi]!));
            return;
          }

          final res = await locator<GetCarouselUseCase>().call();

          if (!_listCarousel.containsKey(event.noRegistrasi)) {
            _listCarousel[event.noRegistrasi] = [];
          }

          _listCarousel[event.noRegistrasi] =
              res.map((x) => CarouselModel.fromJson(x)).toList();

          emit(LoadedCarousel(_listCarousel[event.noRegistrasi]!));
        } on NoConnectionException catch (e) {
          emit(CarouselError(e.toString()));
        } on DataException catch (e) {
          emit(CarouselError(e.toString()));
        } catch (e) {
          emit(CarouselError(e.toString()));
        }
      }
    });
  }
}
