import 'package:gokreasi_new/core/shared/usecase/base_usecase.dart';
import 'package:gokreasi_new/features/auth/domain/repository/auth_repository.dart';

class LoginSiswaUseCase
    implements BaseUseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final AuthRepository _authRepository;
  LoginSiswaUseCase(this._authRepository);

  @override
  Future<Map<String, dynamic>> call({Map<String, dynamic>? params}) {
    return _authRepository.loginSiswa(params);
  }
}

class LogoutSiswaUseCase implements BaseUseCase<bool, Map<String, dynamic>> {
  final AuthRepository _authRepository;
  const LogoutSiswaUseCase(this._authRepository);

  @override
  Future<bool> call({Map<String, dynamic>? params}) {
    return _authRepository.logoutSiswa(params);
  }
}

class LoginOrtuUseCase
    implements BaseUseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final AuthRepository _authRepository;
  const LoginOrtuUseCase(this._authRepository);

  @override
  Future<Map<String, dynamic>> call({Map<String, dynamic>? params}) {
    return _authRepository.loginOrtu(params);
  }
}

class LogoutOrtuUseCase implements BaseUseCase<bool, Map<String, dynamic>> {
  final AuthRepository _authRepository;
  const LogoutOrtuUseCase(this._authRepository);

  @override
  Future<bool> call({Map<String, dynamic>? params}) {
    return _authRepository.logoutOrtu(params);
  }
}

class ChangeBundlingUseCase
    implements BaseUseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final AuthRepository _authRepository;
  const ChangeBundlingUseCase(this._authRepository);

  @override
  Future<Map<String, dynamic>> call({Map<String, dynamic>? params}) {
    return _authRepository.changeBundling(params);
  }
}

class GetDetailSiswa
    implements BaseUseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final AuthRepository _authRepository;
  const GetDetailSiswa(this._authRepository);

  @override
  Future<Map<String, dynamic>> call({Map<String, dynamic>? params}) {
    return _authRepository.getDetailSiswa(params);
  }
}

class GetDataSekolahSiswa
    implements BaseUseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final AuthRepository _authRepository;
  const GetDataSekolahSiswa(this._authRepository);

  @override
  Future<Map<String, dynamic>> call({Map<String, dynamic>? params}) {
    return _authRepository.getDataSekolahSiswa(params);
  }
}

class GetGedungKomarSiswa
    implements BaseUseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final AuthRepository _authRepository;
  const GetGedungKomarSiswa(this._authRepository);

  @override
  Future<Map<String, dynamic>> call({Map<String, dynamic>? params}) {
    return _authRepository.getGedungKomarSiswa(params);
  }
}

class SetTargetCapaian implements BaseUseCase<void, Map<String, dynamic>> {
  final AuthRepository _authRepository;
  const SetTargetCapaian(this._authRepository);

  @override
  Future<void> call({Map<String, dynamic>? params}) {
    return _authRepository.setTargetCapaian(params);
  }
}

class GetNamaKelasSiswa
    implements BaseUseCase<List<dynamic>, Map<String, dynamic>> {
  final AuthRepository _authRepository;
  const GetNamaKelasSiswa(this._authRepository);

  @override
  Future<List> call({Map<String, dynamic>? params}) {
    return _authRepository.getNamaKelasSiswa(params);
  }
}
