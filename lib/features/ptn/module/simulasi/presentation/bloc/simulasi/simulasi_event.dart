part of 'simulasi_bloc.dart';

class SimulasiEvent extends Equatable {
  const SimulasiEvent();

  @override
  List<Object> get props => [];
}

class LoadSimulasiNilai extends SimulasiEvent {
  final UserModel? userData;
  const LoadSimulasiNilai({required this.userData});

  @override
  List<Object> get props => [userData ?? UserModel()];
}

class SaveNilaiEvent extends SimulasiEvent {
  final String noRegistrasi;
  final int kodeTOB;
  final int nilaiAkhir;
  final String detailNilai;

  const SaveNilaiEvent({
    required this.detailNilai,
    required this.kodeTOB,
    required this.nilaiAkhir,
    required this.noRegistrasi,
  });

  @override
  List<Object> get props => [
        noRegistrasi,
        kodeTOB,
        nilaiAkhir,
        detailNilai,
      ];
}
