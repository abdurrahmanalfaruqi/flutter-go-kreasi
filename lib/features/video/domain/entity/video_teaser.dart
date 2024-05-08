import 'package:equatable/equatable.dart';

class VideoTeaser extends Equatable {
  final int id;
  final int idTingkatKelas;
  final String linkVideo;
  final String role;

  const VideoTeaser({
    required this.id,
    required this.idTingkatKelas,
    required this.linkVideo,
    required this.role,
  });

  bool get isOrtu => role == 'Orang Tua';

  bool get isTamu => role == 'Tamu';

  @override
  List<Object?> get props => [id, idTingkatKelas, linkVideo, role];
}
