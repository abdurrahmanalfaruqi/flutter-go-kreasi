part of 'auth_bloc.dart';

class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthError extends AuthState {
  final String err;
  const AuthError(this.err);

  @override
  List<Object> get props => [err];
}

class AuthErrorLogin extends AuthState {
  final String err;
  final String deviceId;
  const AuthErrorLogin({
    required this.err,
    required this.deviceId,
  });

  @override
  List<Object> get props => [err, deviceId];
}

class AuthCurrentUserError extends AuthState {}

class AuthLogoutError extends AuthState {
  final String err;
  const AuthLogoutError(this.err);

  @override
  List<Object> get props => [err];
}

class LoadedOTP extends AuthState {
  final String otp;
  const LoadedOTP(this.otp);

  @override
  List<Object> get props => [otp];
}

class LoadedUser extends AuthState {
  final UserModel? user;
  final Map<String, dynamic>? rawUser;
  final bool? isSuccessUpdate;
  final bool? isFailedLogout;
  final String? updatedBundle;

  const LoadedUser({
    required this.user,
    this.rawUser,
    this.isSuccessUpdate,
    this.isFailedLogout,
    this.updatedBundle,
  });

  @override
  List<Object> get props => [
        user ?? UserModel(),
        rawUser ?? {},
        isSuccessUpdate ?? false,
        isFailedLogout ?? false,
        updatedBundle ?? '',
      ];
}

class LoadedIdSekolahKelas extends AuthState {
  final String idSekolahKelas;
  const LoadedIdSekolahKelas(this.idSekolahKelas);

  @override
  List<Object> get props => [idSekolahKelas];
}
