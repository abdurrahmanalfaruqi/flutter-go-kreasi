import 'package:gokreasi_new/features/video/domain/entity/video_teaser.dart';

class VideoTeaserModel extends VideoTeaser {
  const VideoTeaserModel({
    required super.id,
    required super.idTingkatKelas,
    required super.linkVideo,
    required super.role,
  });

  factory VideoTeaserModel.fromJson(Map<String, dynamic> json) =>
      VideoTeaserModel(
        id: json['id'] ?? 0,
        idTingkatKelas: json['id_tingkat_kelas'] ?? 0,
        linkVideo: json['link_video'] ?? '',
        role: json['role'] ?? '-',
      );
}
