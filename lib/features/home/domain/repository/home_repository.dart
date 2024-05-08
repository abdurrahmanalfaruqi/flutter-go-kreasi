abstract class HomeRepository {
  Future<List<dynamic>> fetchCarousel();

  Future<Map<String, dynamic>> fetchCapaianScore(Map<String, dynamic>? params);

  Future<List<dynamic>> fetchCapaianBar(Map<String, dynamic>? params);

  Future<List<dynamic>> fetchFirstRankBukuSakti(Map<String, dynamic>? params);

  Future<Map<String, dynamic>> fetchLeaderBoardBukuSakti(
      Map<String, dynamic>? params);

  Future<Map<String, dynamic>> fetchPembayaran(Map<String, dynamic>? params);

  Future<List<dynamic>> fetchDetailPembayaran(Map<String, dynamic>? params);

  Future<List<dynamic>> fetchUniversitas(Map<String, dynamic>? params);

  Future<List<dynamic>> fetchJurusan(Map<String, dynamic>? params);

  Future<List<dynamic>> cekTOB(Map<String, dynamic>? params);

  Future<Map<String, dynamic>> getKampusImpian(Map<String, dynamic>? params);

  Future<Map<String, dynamic>> getKampusImpianByTOB(
      Map<String, dynamic>? params);

  Future<Map<String, dynamic>> getDetailJurusan(Map<String, dynamic>? params);

  Future<Map<String, dynamic>> getPromotionEvent(Map<String, dynamic>? params);
}
