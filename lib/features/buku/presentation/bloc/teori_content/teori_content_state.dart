part of 'teori_content_bloc.dart';

class TeoriContentState extends Equatable {
  const TeoriContentState();

  @override
  List<Object> get props => [];
}

class TeoriContentInitial extends TeoriContentState {}

class TeoriContentLoading extends TeoriContentState {}

class TeoriContentError extends TeoriContentState {
  final String err;
  const TeoriContentError(this.err);

  @override
  List<Object> get props => [err];
}

class TeoriContentLoaded extends TeoriContentState {
  final ContentModel content;

  const TeoriContentLoaded(this.content);

  @override
  List<Object> get props => [content];
}
