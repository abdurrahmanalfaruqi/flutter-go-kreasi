abstract class BukuRepository {
  Future<List<dynamic>> fetchDaftarBuku(Map<String, dynamic>? params);

  Future<List<dynamic>> fetchDaftarBab(Map<String, dynamic>? params);

  Future<Map<String, dynamic>> fetchContent(Map<String, dynamic>? params);
}
