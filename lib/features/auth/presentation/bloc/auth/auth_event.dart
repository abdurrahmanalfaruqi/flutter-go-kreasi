part of 'auth_bloc.dart';

class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthGenerateOTP extends AuthEvent {}

class AuthLogin extends AuthEvent {
  final String nomorReg;
  final String? noRegistrasiRefresh;
  final String userTypeRefresh;

  const AuthLogin({
    required this.nomorReg,
    this.noRegistrasiRefresh,
    required this.userTypeRefresh,
  });

  @override
  List<Object> get props => [
        nomorReg,
        noRegistrasiRefresh ?? '',
        userTypeRefresh,
      ];
}

class AuthLoginOrtu extends AuthEvent {
  final String? noRegistrasiRefresh;
  final String nomorHpOrtu;
  final String noregOrtu;
  final String noregAnak;
  final int idBundlingAktif;
  final String deviceId;
  final List<Map<String, dynamic>> daftarBundling;
  final List<Map<String, dynamic>> daftarAnak;
  final List<int> listIdProduk;
  final List<Map<String, dynamic>> daftarProduk;

  const AuthLoginOrtu({
    this.noRegistrasiRefresh,
    required this.nomorHpOrtu,
    required this.noregOrtu,
    required this.noregAnak,
    required this.idBundlingAktif,
    required this.deviceId,
    required this.daftarBundling,
    required this.daftarAnak,
    required this.listIdProduk,
    required this.daftarProduk,
  });

  @override
  List<Object> get props => [
        noRegistrasiRefresh ?? '',
        noregOrtu,
        noregAnak,
        idBundlingAktif,
        deviceId,
        daftarBundling,
        daftarAnak,
        listIdProduk,
        daftarProduk,
        nomorHpOrtu,
      ];
}

class AuthGetCurrentUser extends AuthEvent {
  final bool? isSplashScreen;
  final bool? isRefresh;
  const AuthGetCurrentUser({this.isSplashScreen, this.isRefresh});
  @override
  List<Object> get props => [isSplashScreen ?? false, isRefresh ?? false];
}

class AuthLogout extends AuthEvent {}

class AuthSetIdSekolahKelas extends AuthEvent {
  final String idSekolahKelas;
  const AuthSetIdSekolahKelas(this.idSekolahKelas);

  @override
  List<Object> get props => [idSekolahKelas];
}

class AuthSwitchBundle extends AuthEvent {
  final String noRegistrasi;
  final String selectedBundle;
  final int idBundling;
  final List<Bundling> daftarBundle;

  const AuthSwitchBundle({
    required this.noRegistrasi,
    required this.selectedBundle,
    required this.idBundling,
    required this.daftarBundle,
  });

  @override
  List<Object> get props => [noRegistrasi, idBundling, daftarBundle];
}

class AuthResetSuccessState extends AuthEvent {}

class AuthGetGedungKomarSiswa extends AuthEvent {
  final UserModel? userData;
  final bool isRefresh;
  const AuthGetGedungKomarSiswa({
    required this.isRefresh,
    required this.userData,
  });

  @override
  List<Object> get props => [userData ?? UserModel(), isRefresh];
}

class AuthRefreshProfileSiswa extends AuthEvent {}