part of 'tata_tertib_bloc.dart';

class TataTertibBlocState extends Equatable {
  const TataTertibBlocState();

  @override
  List<Object> get props => [];
}

class TataTertibBlocInitial extends TataTertibBlocState {}

class TataTertibBlocLoading extends TataTertibBlocState {}

class TataTertibBlocDetailLoading extends TataTertibBlocState {}

class TataTertibBlocDataLoaded extends TataTertibBlocState {
  final String aturanHtml;
  final bool isMenyetujui;
  final bool hasError;
  const TataTertibBlocDataLoaded({
    required this.aturanHtml,
    required this.isMenyetujui,
    this.hasError = false,
  });

  @override
  List<Object> get props => [
        aturanHtml,
        isMenyetujui,
        hasError,
      ];
}

class TataTertibBlocError extends TataTertibBlocState {
  final String errorMessage;

  const TataTertibBlocError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
