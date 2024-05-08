part of 'laporan_tobk_bloc.dart';

abstract class LaporanTobkEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadFristLaporan extends LaporanTobkEvent {
  final String noRegister;
  LoadFristLaporan({required this.noRegister});
  @override
  List<Object> get props => [noRegister];
}

class LoadLaporanTobk extends LaporanTobkEvent {
  final UserModel? userData;
  final JenisTO jenisTO;

  LoadLaporanTobk({
    required this.userData,
    required this.jenisTO,
  });

  @override
  List<Object?> get props => [
        userData,
        jenisTO,
      ];
}

class UploadLaporanToFeed extends LaporanTobkEvent {
  final String? userId;
  final String? content;
  final String? file64;
  UploadLaporanToFeed({this.userId, this.content, this.file64});
  @override
  List<Object?> get props => [userId, content, file64];
}
