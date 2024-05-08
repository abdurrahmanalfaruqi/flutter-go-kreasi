part of 'carousel_bloc.dart';

class CarouselEvent extends Equatable {
  const CarouselEvent();

  @override
  List<Object> get props => [];
}

class CarouselGet extends CarouselEvent {
  final String noRegistrasi;

  const CarouselGet(this.noRegistrasi);

  @override
  List<Object> get props => [noRegistrasi];
}
