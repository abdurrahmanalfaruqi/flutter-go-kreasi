import 'package:gokreasi_new/features/video/domain/entity/video.dart';

class VideoExtra extends Video {
  final String? jenis;
  const VideoExtra({
    required this.jenis,
    required super.idVideo,
    required super.linkVideo,
    required super.judulVideo,
    required super.deskripsi,
    required super.keywords,
  });

  factory VideoExtra.fromJson(Map<String, dynamic> json, int index) {
    final keywords = (json['nama_video'] as String).split(' ');
    return VideoExtra(
      idVideo: index.toString(),
      linkVideo: json['link'],
      judulVideo: json['nama_video'],
      deskripsi: json['nama_video'],
      keywords: keywords,
      jenis: json['jenis']
    );
  }
}
