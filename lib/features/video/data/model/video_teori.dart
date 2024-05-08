import '../../domain/entity/video.dart';

/// Object dari e-Video Teori (id: 88).<br>
/// Response:
///<br> {
///         c_NamaMataPelajaran,
///         c_IdVideo,
///         c_Deskripsi,
///         c_JudulVideo,
///         c_LinkVideo,
///<br> }
/// <br>
/// Source: /v4/video
class VideoTeori extends Video {
  final String namaMataPelajaran;

  const VideoTeori({
    required super.idVideo,
    required super.linkVideo,
    required super.judulVideo,
    required super.deskripsi,
    required super.keywords,
    required this.namaMataPelajaran,
  });

  factory VideoTeori.fromJson(Map<String, dynamic> json) {
    List<String> keywords = [];

    if (json['c_Keyword'] != null) {
      keywords = '${json['c_Keyword']}'.split(',');
    }

    return VideoTeori(
      idVideo: json['c_id_video'].toString(),
      linkVideo: json['c_link_video'],
      judulVideo: json['c_judul_video'],
      deskripsi: json['c_deskripsi'],
      keywords: keywords,
      namaMataPelajaran: json['c_mata_pelajaran'],
    );
  }
}
