part of 'laporan_kuis_bloc.dart';

abstract class LaporanKuisEvent extends Equatable {
  const LaporanKuisEvent();

  @override
  List<Object> get props => [];
}

class LoadListLaporanKuis extends LaporanKuisEvent {
  final String noRegistrasi;
  final String idSekolahKelas;
  final String tahunAjaran;

  const LoadListLaporanKuis({
    required this.noRegistrasi,
    required this.idSekolahKelas,
    required this.tahunAjaran,
  });

  @override
  List<Object> get props => [noRegistrasi, idSekolahKelas, tahunAjaran];
}

class LoadListHasilKuis extends LaporanKuisEvent {
  final String noRegistrasi;
  final String idSekolahKelas;
  final String tahunAjaran;
  final String kodeQuiz;

  const LoadListHasilKuis(
      {required this.noRegistrasi,
      required this.idSekolahKelas,
      required this.tahunAjaran,
      required this.kodeQuiz});

  @override
  List<Object> get props =>
      [noRegistrasi, idSekolahKelas, tahunAjaran, kodeQuiz];
}

class ClearlistHasilKuis extends LaporanKuisEvent {
  const ClearlistHasilKuis();

  @override
  List<Object> get props => [];
}
