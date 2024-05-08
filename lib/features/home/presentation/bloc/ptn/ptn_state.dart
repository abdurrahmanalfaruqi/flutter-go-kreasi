part of 'ptn_bloc.dart';

class PtnState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PtnInitial extends PtnState {}

class PtnLoading extends PtnState {
  final EventPTNType? event;
  PtnLoading({this.event});
  @override
  List<Object?> get props => [event];
}

class PtnUpdateSuccess extends PtnState {}

class PtnUpdateError extends PtnState {
  final String errorMessage;
  PtnUpdateError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class PtnDataLoaded extends PtnState {
  final List<PTN>? listPTN;
  final List<Jurusan>? listJurusan;
  final DetailJurusan? detailJurusan;
  final PTN? selectedPTN;
  final Jurusan? selectedJurusan;
  final int? pilihan2;
  final StatePTNType? stateType;
  final EventPTNType? eventType;
  final bool isBoleh;
  final String? kodeTOB;
  final List<KampusImpian> listKampusPilihan;
  final List<KampusImpian> riwayatKampusPilihan;
  final int? index;

  PtnDataLoaded({
    this.listPTN,
    this.listJurusan,
    this.detailJurusan,
    this.selectedPTN,
    this.selectedJurusan,
    this.pilihan2,
    this.stateType,
    this.eventType,
    this.index,
    required this.isBoleh,
    required this.kodeTOB,
    required this.listKampusPilihan,
    required this.riwayatKampusPilihan,
  });

  @override
  List<Object?> get props => [
        listPTN,
        listJurusan,
        detailJurusan,
        selectedPTN,
        selectedJurusan,
        pilihan2,
        stateType,
        eventType,
        isBoleh,
        kodeTOB,
        listKampusPilihan,
        riwayatKampusPilihan,
        index,
      ];
}

class KampusImpianUpdated extends PtnState {}

class PtnError extends PtnState {
  final String errorMessage;
  PtnError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class PTNErrorPopUp extends PtnState {
  final String err;
  PTNErrorPopUp(this.err);

  @override
  List<Object?> get props => [err];
}
