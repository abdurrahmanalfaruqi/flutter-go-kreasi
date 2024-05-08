part of 'jadwal_video_teori_bloc.dart';

class JadwalVideoTeoriState extends Equatable {
  const JadwalVideoTeoriState();

  @override
  List<Object> get props => [];
}

class JadwalVideoTeoriInitial extends JadwalVideoTeoriState {}

class JadwalVideoLoading extends JadwalVideoTeoriState {}

class JadwalVideoLoaded extends JadwalVideoTeoriState {
  final List<Buku> listBukuVideo;
  final List<BabUtamaVideoJadwal> listBabVideo;

  const JadwalVideoLoaded(
      {required this.listBukuVideo, required this.listBabVideo});

  @override
  List<Object> get props => [listBukuVideo, listBabVideo];
}

class JadwalVideoError extends JadwalVideoTeoriState {
  final String err;
  const JadwalVideoError(this.err);

  @override
  List<Object> get props => [err];
}

class JadwalVideoBabError extends JadwalVideoTeoriState {
  final String err;
  const JadwalVideoBabError(this.err);

  @override
  List<Object> get props => [err];
}

class LoadedVideoEkstra extends JadwalVideoTeoriState {
  final Map<String, List<VideoExtra>> listVideoEkstra;
  const LoadedVideoEkstra(this.listVideoEkstra);

  @override
  List<Object> get props => [listVideoEkstra];
}
