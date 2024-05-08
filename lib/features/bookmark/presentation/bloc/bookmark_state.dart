part of 'bookmark_bloc.dart';

class BookmarkState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BookmarkInitial extends BookmarkState {}

class BookmarkLoading extends BookmarkState {}
class BookmarkAddLoading extends BookmarkState {}
class BookmarkAddSucces extends BookmarkState {}
class BookmarkAddError extends BookmarkState {}
class BookmarkDeleteLoading extends BookmarkState {}
class BookmarkDeleteSucces extends BookmarkState {}
class BookmarkDeleteError extends BookmarkState {}

class BookmarkDataLoaded extends BookmarkState {
  final List<BookmarkMapel> listBookmark;

  BookmarkDataLoaded({required this.listBookmark});

  @override
  List<Object?> get props => [listBookmark];
}

class BookmarkError extends BookmarkState {
  final String errorMessage;

  BookmarkError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}