abstract class AuthRepository {
  Future<Map<String, dynamic>> loginSiswa(Map<String, dynamic>? params);

  Future<Map<String, dynamic>> getDetailSiswa(Map<String, dynamic>? params);

  Future<Map<String, dynamic>> getDataSekolahSiswa(
      Map<String, dynamic>? params);

  Future<Map<String, dynamic>> getGedungKomarSiswa(
      Map<String, dynamic>? params);

  Future<List<dynamic>> getNamaKelasSiswa(Map<String, dynamic>? params);

  Future<bool> logoutSiswa(Map<String, dynamic>? params);

  Future<Map<String, dynamic>> loginOrtu(Map<String, dynamic>? params);

  Future<bool> logoutOrtu(Map<String, dynamic>? params);

  Future<Map<String, dynamic>> changeBundling(Map<String, dynamic>? params);

  Future<void> setTargetCapaian(Map<String, dynamic>? params);
}
