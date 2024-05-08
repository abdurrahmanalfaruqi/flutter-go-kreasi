part of 'news_bloc.dart';

class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object> get props => [];
}

class LoadNews extends NewsEvent {
  final String userType;
  final bool isRefresh;
  const LoadNews({required this.userType, required this.isRefresh});

  @override
  List<Object> get props => [userType, isRefresh];
}

class NewsAddViewer extends NewsEvent {
  final String idBerita;
  const NewsAddViewer(this.idBerita);

  @override
  List<Object> get props => [idBerita];
}

class LoadBeritaPopUp extends NewsEvent {
  final String userType;
  const LoadBeritaPopUp(this.userType);

  @override
  List<Object> get props => [userType];
}
