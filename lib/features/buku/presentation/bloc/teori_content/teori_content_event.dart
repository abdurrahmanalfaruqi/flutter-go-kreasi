part of 'teori_content_bloc.dart';

class TeoriContentEvent extends Equatable {
  const TeoriContentEvent();

  @override
  List<Object> get props => [];
}

class LoadTeoriContent extends TeoriContentEvent {
  final String idTeoriBab;
  final String level;
  final String kodeBab;
  final String jenis;
  final bool isRefresh;

  const LoadTeoriContent({
    required this.idTeoriBab,
    required this.level,
    required this.kodeBab,
    required this.jenis,
    required this.isRefresh,
  });

  @override
  List<Object> get props => [
        idTeoriBab,
        level,
        kodeBab,
        jenis,
        isRefresh,
      ];
}
