part of 'laporan_jawaban_bloc.dart';

abstract class LaporanJawabanEvent extends Equatable {
  const LaporanJawabanEvent();

  @override
  List<Object> get props => [];
}

class LoadLaporanJawaban extends LaporanJawabanEvent {
  final String noRegistrasi;
  final String kodeTob;
  final String jenisTOB;
  final String tingkatKelas;

  const LoadLaporanJawaban({
    required this.noRegistrasi,
    required this.kodeTob,
    required this.jenisTOB,
    required this.tingkatKelas,
  });

  @override
  List<Object> get props => [noRegistrasi, kodeTob, jenisTOB, tingkatKelas];
}
