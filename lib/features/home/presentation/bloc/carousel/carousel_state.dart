part of 'carousel_bloc.dart';

class CarouselState extends Equatable {
  const CarouselState();

  @override
  List<Object> get props => [];
}

class CarouselInitial extends CarouselState {}

class CarouselLoading extends CarouselState {}

class CarouselError extends CarouselState {
  final String err;
  const CarouselError(this.err);
  
  @override
  List<Object> get props => [err];
}

class LoadedCarousel extends CarouselState {
  final List<CarouselModel> items;

  const LoadedCarousel(this.items);

  @override
  List<Object> get props => [items];
}
