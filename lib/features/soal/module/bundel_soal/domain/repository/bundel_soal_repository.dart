abstract class BundelSoalRepository {
  Future<Map<String, dynamic>> fetchDaftarBundel(Map<String, dynamic>? params);

  Future<List<dynamic>> fetchDaftarBabSubBab(Map<String, dynamic>? params);
}
