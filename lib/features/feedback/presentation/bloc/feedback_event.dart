part of 'feedback_bloc.dart';

class FeedbackEvent extends Equatable {
  const FeedbackEvent();

  @override
  List<Object> get props => [];
}

class LoadFeedback extends FeedbackEvent {
  final String noRegistrasi;
  final String idRencana;
  const LoadFeedback({
    required this.noRegistrasi,
    required this.idRencana,
  });
  @override
  List<Object> get props => [noRegistrasi, idRencana];
}

class SaveFeedback extends FeedbackEvent {
  final String userId;
  final String rencanaId;
  const SaveFeedback({required this.userId, required this.rencanaId});
  @override
  List<Object> get props => [userId, rencanaId];
}

class AnswerFeedback extends FeedbackEvent {
  final int no;
  final String answer;
  const AnswerFeedback({required this.no, required this.answer});
  @override
  List<Object> get props => [no, answer];
}
