abstract class BookMarkRepository {
  Future<List<dynamic>> fetchBookmark(Map<String, dynamic>? params);

  Future<bool> deleteBookmarkMapel(Map<String, dynamic>? params);

  Future<bool> deleteBookmark(Map<String, dynamic>? params);

  Future<bool> addBookmark(Map<String, dynamic>? params);
}
