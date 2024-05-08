import 'package:gokreasi_new/core/shared/usecase/base_usecase.dart';
import 'package:gokreasi_new/features/feedback/domain/repository/feedback_repository.dart';

class GetFeedbackQuestionUseCase
    implements BaseUseCase<List<dynamic>, Map<String, dynamic>> {
  final FeedbackRepository _feedbackRepository;
  const GetFeedbackQuestionUseCase(this._feedbackRepository);

  @override
  Future<List> call({Map<String, dynamic>? params}) {
    return _feedbackRepository.fetchFeedbackQuestion(params);
  }
}

class SetFeedback implements BaseUseCase<void, Map<String, dynamic>> {
  final FeedbackRepository _feedbackRepository;
  const SetFeedback(this._feedbackRepository);

  @override
  Future<void> call({Map<String, dynamic>? params}) {
    return _feedbackRepository.saveFeedback(params);
  }
}
