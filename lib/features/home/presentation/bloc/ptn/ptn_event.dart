part of 'ptn_bloc.dart';

abstract class PtnEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadListPtn extends PtnEvent {
  final StatePTNType? statePTNType;
  final EventPTNType? from;
  final int? index;
  LoadListPtn({this.statePTNType, this.from, this.index});

  @override
  List<Object?> get props => [statePTNType, from, index];
}

class LoadJurusanList extends PtnEvent {
  final int idPtn;

  LoadJurusanList({required this.idPtn});

  @override
  List<Object?> get props => [idPtn];
}

class GetDetailJurusan extends PtnEvent {
  final KampusImpian kampusImpian;

  GetDetailJurusan({required this.kampusImpian});

  @override
  List<Object?> get props => [kampusImpian];
}

class GetKampusImpian extends PtnEvent {
  final UserModel? userData;
  final String role;

  GetKampusImpian({
    required this.userData,
    required this.role,
  });

  @override
  List<Object?> get props => [userData ?? UserModel(), role];
}

class SetSelectedPTN extends PtnEvent {
  final PTN? selectedPtn;
  final EventPTNType? from;
  final StatePTNType? statePTNType;
  final int? index;

  SetSelectedPTN({
    required this.selectedPtn,
    this.statePTNType,
    this.from,
    this.index,
  });

  @override
  List<Object?> get props => [selectedPtn, statePTNType, from, index];
}

class SetSelectedJurusan extends PtnEvent {
  final Jurusan? selectedJurusan;
  final PTN? selectedPTN;

  SetSelectedJurusan({
    required this.selectedJurusan,
    required this.selectedPTN,
  });

  @override
  List<Object?> get props => [selectedJurusan, selectedPTN];
}

class UpdateKampusImpian extends PtnEvent {
  final int pilihanKe;
  final String noRegistrasi;
  final int idJurusan;
  final int kodeTOB;

  UpdateKampusImpian({
    required this.pilihanKe,
    required this.noRegistrasi,
    required this.idJurusan,
    required this.kodeTOB,
  });

  @override
  List<Object?> get props => [
        pilihanKe,
        noRegistrasi,
        idJurusan,
        kodeTOB,
      ];
}

class SaveKampusPilihan extends PtnEvent {
  final int pilihanKe;
  final KampusImpian kampusImpian;

  SaveKampusPilihan({
    required this.pilihanKe,
    required this.kampusImpian,
  });

  @override
  List<Object?> get props => [pilihanKe, kampusImpian];
}

class PTNResetSelectedPTN extends PtnEvent {}
