import 'package:gokreasi_new/core/shared/usecase/base_usecase.dart';
import 'package:gokreasi_new/features/video/domain/repository/video_repository.dart';

class GetVideoJadwalMapel
    implements BaseUseCase<List<dynamic>, Map<String, dynamic>> {
  final VideoRepository _videoRepository;
  const GetVideoJadwalMapel(this._videoRepository);

  @override
  Future<List> call({Map<String, dynamic>? params}) {
    return _videoRepository.fetchVideoJadwalMapel(params);
  }
}

class GetVideoExtra
    implements BaseUseCase<List<dynamic>, Map<String, dynamic>> {
  final VideoRepository _videoRepository;
  const GetVideoExtra(this._videoRepository);

  @override
  Future<List> call({Map<String, dynamic>? params}) {
    return _videoRepository.fetchVideoExtra(params);
  }
}
