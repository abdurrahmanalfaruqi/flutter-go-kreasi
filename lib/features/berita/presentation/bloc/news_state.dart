part of 'news_bloc.dart';

class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object> get props => [];
}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsDataLoaded extends NewsState {
  final List<Berita>? headlineNews;
  final List<Berita>? allNews;
  final Berita? beritaPopUp;

  const NewsDataLoaded({
    this.headlineNews,
    this.allNews,
    this.beritaPopUp,
  });

  @override
  List<Object> get props => [
        headlineNews ?? [],
        allNews ?? [],
        beritaPopUp ?? [],
      ];
}

class NewsError extends NewsState {
  final String errorMessage;

  const NewsError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
