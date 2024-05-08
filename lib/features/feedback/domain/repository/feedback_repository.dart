abstract class FeedbackRepository {
  Future<List<dynamic>> fetchFeedbackQuestion(Map<String, dynamic>? params);

  Future<void> saveFeedback(Map<String, dynamic>? params);
}
