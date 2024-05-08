part of 'standby_bloc.dart';

class StandbyState extends Equatable {
  const StandbyState();

  @override
  List<Object> get props => [];
}

class StandbyInitial extends StandbyState {}

class StandbyLoading extends StandbyState {}

class RequestTSTLoading extends StandbyState {
  final String planId;
  const RequestTSTLoading(this.planId);

  @override
  List<Object> get props => [planId];
}

class StandbyDataLoaded extends StandbyState {
  final List<StandbyModel> listStandby;
  const StandbyDataLoaded({required this.listStandby});

  @override
  List<Object> get props => [listStandby];
}

class StandbyError extends StandbyState {
  final String errorMessage;

  const StandbyError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}