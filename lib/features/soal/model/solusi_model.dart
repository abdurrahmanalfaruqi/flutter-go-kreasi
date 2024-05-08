import '../entity/solusi.dart';

class SolusiModel extends Solusi {
  const SolusiModel({
    required super.solusi,
    required super.idSoal,
    required super.linkVideo,
    required super.tipeSoal,
    required super.judulVideo,
    super.theKing,
    super.idVideo,
  });

  factory SolusiModel.fromJson(Map<String, dynamic> json) {
    return SolusiModel(
      solusi: json['solusi'],
      theKing: json['the_king'],
      idVideo: json['id_video'],
      idSoal: json['id_soal'],
      judulVideo: json['judul_video'],
      linkVideo: json['link_video'],
      tipeSoal: json['tipe_soal']
    );
  }
}

class VideoSolusiModel extends VideoSolusi {
  const VideoSolusiModel({
    required super.idVideo,
    required super.judulVideo,
    required super.keyword,
    required super.deskripsi,
    required super.videoUrl,
  });

  factory VideoSolusiModel.fromJson(Map<String, dynamic> json) =>
      VideoSolusiModel(
        idVideo: json['c_idVideo'],
        judulVideo: json['c_judulVideo'],
        keyword: json['c_Keyword'],
        deskripsi: json['c_Deskripsi'],
        videoUrl: json['c_LinkVideo'],
      );
}
