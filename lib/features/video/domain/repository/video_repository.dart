abstract class VideoRepository {
  Future<List<dynamic>> fetchVideoJadwalMapel(Map<String, dynamic>? params);

  Future<List<dynamic>> fetchVideoExtra(Map<String, dynamic>? params);
}
