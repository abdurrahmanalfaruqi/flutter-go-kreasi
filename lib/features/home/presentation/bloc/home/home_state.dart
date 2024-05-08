part of 'home_bloc.dart';

class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeError extends HomeState {
  final String err;
  const HomeError({required this.err});

  @override
  List<Object?> get props => [err];
}

class LoadedPromotion extends HomeState {
  final Promotion promotionData;
  const LoadedPromotion(this.promotionData);
  
  @override
  List<Object?> get props => [promotionData];
}
