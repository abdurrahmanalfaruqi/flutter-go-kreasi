abstract class JadwalRepository {
  Future<dynamic> fetchJadwal(Map<String, dynamic>? params);

  Future<List<dynamic>> fetchStandby(Map<String, dynamic>? params);

  Future<List<dynamic>> fetchVideoJadwal(Map<String, dynamic>? params);

  Future<bool> postRequestTST(Map<String, dynamic>? params);
}
