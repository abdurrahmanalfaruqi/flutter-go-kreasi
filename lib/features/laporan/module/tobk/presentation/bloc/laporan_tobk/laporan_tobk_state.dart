part of 'laporan_tobk_bloc.dart';

class LaporanTobkState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LaporanTobkInitial extends LaporanTobkState {}

class LaporanTobkLoading extends LaporanTobkState {}

class LaporanTobkDataLoaded extends LaporanTobkState {
  final List<LaporanTryoutPilihanModel> listPilihan;
  final List<LaporanTryoutNilaiModel> listNilai;
  final List<LaporanListTryoutModel> listTryOut;
  final List<LaporanTryoutTobModel> listLaporanTryout;
  final List<Map<String, String>> opsiTOBK;
  final double totalNilai;

  LaporanTobkDataLoaded(
      {required this.listLaporanTryout,
      required this.listNilai,
      required this.listTryOut,
      required this.listPilihan,
      required this.opsiTOBK,
      required this.totalNilai});

  @override
  List<Object?> get props => [
        listPilihan,
        listNilai,
        listTryOut,
        listLaporanTryout,
        opsiTOBK,
        totalNilai
      ];
}

class LaporanTobkError extends LaporanTobkState {
  final String errorMessage;

  LaporanTobkError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class UploadErrorEvent extends LaporanTobkState {}

class UploadSuccessEvent extends LaporanTobkState {}

class FetchEpbTokenEvent extends LaporanTobkState {
  final String token;
  FetchEpbTokenEvent(this.token);
  @override
  List<Object?> get props => [token];
}

class FetchEpbTokenError extends LaporanTobkState {
  final String errorMessage;

  FetchEpbTokenError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
