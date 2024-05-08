part of 'log_bloc.dart';

class LogEvent extends Equatable {
  const LogEvent();

  @override
  List<Object?> get props => [];
}

class SendLogActivity extends LogEvent {
  final String? userType;

  const SendLogActivity(this.userType);

  @override
  List<Object?> get props => [userType];
}

class SaveLog extends LogEvent {
  final String? userId;
  final String? userType;
  final String? menu;
  final String? info;
  final String? accessType;

  const SaveLog({
    this.userId,
    this.userType,
    this.menu,
    this.info,
    this.accessType,
  });

  @override
  List<Object?> get props => [
        userId,
        userType,
        menu,
        info,
        accessType,
      ];
}
