part of 'standby_bloc.dart';

class StandbyEvent extends Equatable {
  const StandbyEvent();

  @override
  List<Object?> get props => [];
}

class LoadStandby extends StandbyEvent {
  final UserModel? userData;
  const LoadStandby({required this.userData});

  @override
  List<Object> get props => [userData ?? UserModel()];
}

class RequestTST extends StandbyEvent {
  final Map<String, dynamic> params;
  final UserModel? userData;
  final String planId;

  const RequestTST({
    required this.params,
    required this.userData,
    required this.planId,
  });

  @override
  List<Object?> get props => [params, userData, planId];
}
