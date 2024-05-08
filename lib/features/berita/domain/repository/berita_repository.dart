abstract class BeritaRepository {
  Future<List<dynamic>> fetchBerita(Map<String, dynamic>? params);

  Future<List<dynamic>> fetchBeritaPopUp(Map<String, dynamic>? params);

  Future<void> setViewerBerita(Map<String, dynamic>? params);
}
