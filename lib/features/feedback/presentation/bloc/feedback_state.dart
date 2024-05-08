part of 'feedback_bloc.dart';

class FeedbackState extends Equatable {
  const FeedbackState();

  @override
  List<Object> get props => [];
}

class FeedbackInitial extends FeedbackState {}

class FeedbackLoading extends FeedbackState {}

class FeedbackLoaded extends FeedbackState {
  final List<FeedbackQuestion> listPertanyaan;
  const FeedbackLoaded({required this.listPertanyaan});

  @override
  List<Object> get props => [listPertanyaan];
}

class FeedbackError extends FeedbackState {
  final String err;
  const FeedbackError(this.err);

  @override
  List<Object> get props => [err];
}

class SaveFeedbackLoading extends FeedbackState {}

class SaveFeedbackError extends FeedbackState {
  final String message;
  const SaveFeedbackError(this.message);

  @override
  List<Object> get props => [message];
}

class SaveFeedbackSucces extends FeedbackState {}
