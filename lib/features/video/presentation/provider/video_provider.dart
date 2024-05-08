// ignore_for_file: use_build_context_synchronously

import 'dart:collection';
import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import 'package:gokreasi_new/core/config/extensions.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/video/data/model/video_teaser_model.dart';
import 'package:gokreasi_new/features/video/domain/entity/video_teaser.dart';
import 'package:video_player/video_player.dart';

// import '../../../../core/config/constant.dart';
import '../../../../core/config/global.dart';
import '../../../../core/util/app_exceptions.dart';
import '../../domain/entity/video_mapel.dart';
import '../../data/model/video_jadwal.dart';
import '../../data/model/video_soal.dart';
import '../../data/model/video_teori.dart';
import '../../service/api/video_service_api.dart';

class VideoProvider extends ChangeNotifier {
  final _apiService = VideoServiceApi();
  // final _sembastHelper = VideoHistoryHelper();

  final bool _isLoadingStreamToken = true;
  bool _isLoadingVideoSoal = true;
  bool _isLoadingVideoTeori = true;
  bool _isLoadingVideoTeaser = true;
  bool _isLoadingVideoJadwal = true;
  bool _isVideoPlayed = false;
  final bool _isLoadingVideoJadwalMapel = true;

  String? _streamToken;

  /// [_listVideoTeori] merupakan cache data video teori dengan key kodeBab.
  final Map<String, List<VideoTeori>> _listVideoTeori = {};

  /// [_listVideoJadwalMapel] merupakan cache list data video mapel dengan key noRegistrasi-userType.
  final Map<String, List<VideoMapel>> _listVideoJadwalMapel = {};

  /// [_listVideoJadwal] merupakan cache list data video teori dan ekstra dengan key idMapel.
  final Map<String, List<BabUtamaVideoJadwal>> _listVideoJadwal = {};

  /// [_videoSoal] merupakan cache data video soal dengan key idVideo.
  final Map<int, VideoSoal> _videoSoal = {};

  /// [_linkVideoTeaser] merupakan cache data link video teaser dengan key idSekolahKelas-userType.
  final Map<String, String> _linkVideoTeaser = {};
  final Map<String, bool> _linkVideoTeaserExist = {};

  String get streamToken => _streamToken ?? '';
  bool get isLoadingVideoSoal => _isLoadingVideoSoal;
  bool get isLoadingVideoTeori => _isLoadingVideoTeori;
  bool get isLoadingVideoTeaser => _isLoadingVideoTeaser;
  bool get isLoadingVideoJadwal => _isLoadingVideoJadwal;
  bool get isLoadingVideoJadwalMapel => _isLoadingVideoJadwalMapel;
  bool get isVideoPlayed => _isVideoPlayed;
  bool get isLoadingStreamToken => _isLoadingStreamToken;

  /// Function untuk mengambil List Video Teori dari cache berdasarkan kodeBab
  UnmodifiableListView<VideoTeori> getVideoTeoriByKodeBab(String kodeBab) =>
      UnmodifiableListView(_listVideoTeori[kodeBab] ?? []);

  /// Function untuk mengambil List Video Mapel dari cache berdasarkan key idSekolahKelas-userType
  UnmodifiableListView<VideoMapel> getVideoJadwalMapelFromCache(
          String noRegistrasi, String userType) =>
      UnmodifiableListView(
          _listVideoJadwalMapel['$noRegistrasi-$userType'] ?? []);

  /// Function untuk mengambil List Video Jadwal (Teori + Ekstra) dari cache berdasarkan idMapel
  UnmodifiableListView<BabUtamaVideoJadwal> getVideoJadwalByIdMapel(
          String idMataPelajaran) =>
      UnmodifiableListView(_listVideoJadwal[idMataPelajaran] ?? []);

  /// Function untuk mengambil Video Soal dari cache berdasarkan idVideo
  VideoSoal? getVideoSoalByIdVideo(int idVideo) => _videoSoal[idVideo];

  /// Function untuk mengambil Link Video Teaser dari
  /// [key] merupakan 'idSekolahKelas-UserType'. ex: '14-SISWA', '10-No User'
  String getVideoTeaserFromCache(String idSekolahKelas, String userType) =>
      _linkVideoTeaser['$idSekolahKelas-$userType'] ?? '';

  /// [setVideoPlay] digunakan untuk merubah variable [_isVideoPlayed] 
  void setVideoPlay(VideoPlayerController? videoPlayerController) {
    _isVideoPlayed = videoPlayerController?.value.position !=
        const Duration(seconds: 0, minutes: 0, hours: 0);
    notifyListeners();
  }

  Future<void> setLastPosition(int lastPosition) async {
    // _lastPosition = lastPosition;
  }

  Future<void> saveVideoHistory() async {
    // final videoModel = VideoSembastModel.fromMap({
    //   'videoId': _videoId,
    //   'lesson': _lesson,
    //   'package': _package,
    //   'number': _number,
    //   'lastPosition': _lastPosition,
    // });

    // await _sembastHelper.setVideoHistory(videoModel: videoModel);
  }

  // Fetch token stream provider

  Future<String> getVideoTeaser({
    required String idSekolahKelas,
    required String userType,
    required UserModel? userData,
    bool isRefresh = false,
  }) async {
    final String cacheKey = '$idSekolahKelas-$userType';
    // Jika pada terdapat data dengan key idSekolahKelas-userType maka return dari cache.
    if (_linkVideoTeaserExist.containsKey(cacheKey)) {
      if (!(_linkVideoTeaserExist[cacheKey] ?? false)) {
        return '';
      }
      if (_linkVideoTeaser.containsKey(cacheKey) &&
          (_linkVideoTeaser[cacheKey]?.isNotEmpty ?? false)) {
        return getVideoTeaserFromCache(idSekolahKelas, userType);
      }
    }

    if (isRefresh) {
      _isLoadingVideoTeaser = true;
      notifyListeners();
    }

    try {
      if (kDebugMode) {
        logger.log('VIDEO_PROVIDER-GetVideoTeaser: START with '
            'params($idSekolahKelas, $userType)');
      }

      final response = await _apiService.fetchVideoTeaser(
          idSekolahKelas: idSekolahKelas, userType: userType);

      VideoTeaser selectedVideoTeaser = response
          .map((video) => VideoTeaserModel.fromJson(video))
          .toList()
          .firstWhere((videoTeaser) {
        if (userData?.isOrtu == true) {
          return videoTeaser.isOrtu;
        } else {
          return videoTeaser.isTamu;
        }
      });

      if (kDebugMode) {
        logger.log(
            'VIDEO_PROVIDER-GetVideoTeaser: responseData >> $selectedVideoTeaser');
      }

      if (isRefresh &&
          _linkVideoTeaser.containsKey(cacheKey) &&
          _linkVideoTeaserExist.containsKey(cacheKey)) {
        _linkVideoTeaser.remove(cacheKey);
        _linkVideoTeaserExist.remove(cacheKey);
      }

      if (response.isEmpty) {
        _linkVideoTeaserExist.update(
          cacheKey,
          (value) => response.isEmpty,
          ifAbsent: () => response.isEmpty,
        );
      }

      if (selectedVideoTeaser.id != 0) {
        _linkVideoTeaser.update(
          cacheKey,
          (_) => selectedVideoTeaser.linkVideo,
          ifAbsent: () => selectedVideoTeaser.linkVideo,
        );
      }

      if (kDebugMode) {
        logger.log(
            'VIDEO_PROVIDER-GetVideoTeaser: Video Teaser $cacheKey >> ${_linkVideoTeaser[cacheKey]}');
      }

      _isLoadingVideoTeaser = false;
      notifyListeners();
      return getVideoTeaserFromCache(idSekolahKelas, userType);
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-GetVideoTeaser: $e');
      }

      // gShowTopFlash(gNavigatorKey.currentState!.context, gPesanErrorKoneksi);
      _isLoadingVideoTeaser = false;
      notifyListeners();
      return getVideoTeaserFromCache(idSekolahKelas, userType);
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('DataException-GetVideoTeaser: $e');
      }

      if ('$e'.contains('tidak ditemukan')) {
        _linkVideoTeaser.putIfAbsent(cacheKey, () => '');
        _linkVideoTeaserExist.putIfAbsent(cacheKey, () => false);
      }

      _isLoadingVideoTeaser = false;
      notifyListeners();
      return getVideoTeaserFromCache(idSekolahKelas, userType);
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-GetVideoTeaser: $e');
      }

      // gShowTopFlash(gNavigatorKey.currentState!.context, gPesanError);
      _isLoadingVideoTeaser = false;
      notifyListeners();
      return getVideoTeaserFromCache(idSekolahKelas, userType);
    }
  }

  Future<VideoSoal?> getVideoSoal({
    required int idVideo,
    bool isRefresh = false,
  }) async {
    // Jika pada terdapat data dengan key idSekolahKelas-userType maka return dari cache.
    if (!isRefresh && _videoSoal.containsKey(idVideo)) {
      return getVideoSoalByIdVideo(idVideo);
    }
    if (isRefresh) {
      _isLoadingVideoSoal = true;
      notifyListeners();
    }
    try {
      if (kDebugMode) {
        logger.log('VIDEO_PROVIDER-GetVideoSoal: START with params($idVideo)');
      }

      final responseData = await _apiService.fetchVideoSoal(idVideo: idVideo);

      if (kDebugMode) {
        logger
            .log('VIDEO_PROVIDER-GetVideoSoal: responseData >> $responseData');
      }

      if (isRefresh) _videoSoal.remove(idVideo);

      if (responseData != null) {
        _videoSoal.putIfAbsent(idVideo, () => VideoSoal.fromJson(responseData));
      }

      if (kDebugMode) {
        logger.log(
            'VIDEO_PROVIDER-GetVideoSoal: Video Soal $idVideo >> ${_videoSoal[idVideo]}');
      }

      _isLoadingVideoSoal = false;
      notifyListeners();
      return getVideoSoalByIdVideo(idVideo);
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-GetVideoSoal: $e');
      }

      gShowTopFlash(gNavigatorKey.currentState!.context, e.toString());
      _isLoadingVideoSoal = false;
      notifyListeners();
      return getVideoSoalByIdVideo(idVideo);
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('DataException-GetVideoSoal: $e');
      }

      if (!'$e'.contains('tidak ditemukan')) {
        gShowTopFlash(gNavigatorKey.currentState!.context, e.toString());
      }

      _isLoadingVideoSoal = false;
      notifyListeners();
      return getVideoSoalByIdVideo(idVideo);
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-GetVideoSoal: $e');
      }

      gShowTopFlash(gNavigatorKey.currentState!.context, e.toString());
      _isLoadingVideoSoal = false;
      notifyListeners();
      return getVideoSoalByIdVideo(idVideo);
    }
  }

  Future<List<VideoTeori>> getVideoTeori({
    required String noRegistrasi,
    required String kodeBab,
    required String levelTeori,
    required String kelengkapan,
    required String idTeoriBab,
    required String namaMataPelajaran,
    String jenisBuku = 'teori',
    bool isRefresh = false,
  }) async {
    if (!isRefresh && _listVideoTeori.containsKey(kodeBab)) {
      return getVideoTeoriByKodeBab(kodeBab);
    }
    if (isRefresh) {
      _isLoadingVideoTeori = true;
      // notifyListeners();
    }
    try {
      if (kDebugMode) {
        logger.log(
          'VIDEO_PROVIDER-GetVideoTeori: START with '
          'params($noRegistrasi, $kodeBab, $levelTeori, '
          '$kelengkapan, $jenisBuku, $idTeoriBab)',
        );
      }

      final responseData = await _apiService.fetchVideoTeori(
          noRegistrasi: noRegistrasi,
          kodeBab: kodeBab,
          levelTeori: levelTeori,
          kelengkapan: kelengkapan,
          idTeoriBab: idTeoriBab,
          jenisBuku: jenisBuku,
          namaMatapelajaran: namaMataPelajaran);

      if (kDebugMode) {
        logger
            .log('VIDEO_PROVIDER-GetVideoTeori: responseData >> $responseData');
      }

      if (isRefresh) _listVideoTeori.remove(kodeBab);

      _listVideoTeori.putIfAbsent(kodeBab, () => []);

      if (responseData.isNotEmpty && _listVideoTeori[kodeBab]!.isEmpty) {
        for (var data in responseData) {
          _listVideoTeori[kodeBab]!.add(VideoTeori.fromJson(data));
        }

        _listVideoTeori[kodeBab]!.sort(
          (a, b) => (a.judulVideo ?? '').compareTo(b.judulVideo ?? ''),
        );
      }

      if (kDebugMode) {
        logger.log(
            'VIDEO_PROVIDER-GetVideoTeori: Video Teori $kodeBab >> ${_listVideoTeori[kodeBab]}');
      }

      _isLoadingVideoTeori = false;
      notifyListeners();
      return getVideoTeoriByKodeBab(kodeBab);
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-GetVideoTeori: $e');
      }

      gShowTopFlash(gNavigatorKey.currentState!.context, e.toString());
      _isLoadingVideoTeori = false;
      notifyListeners();
      return getVideoTeoriByKodeBab(kodeBab);
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('DataException-GetVideoTeori: $e');
      }

      if ('$e'.contains('tidak ditemukan')) {
        _listVideoTeori.putIfAbsent(kodeBab, () => []);
      } else {
        gShowTopFlash(gNavigatorKey.currentState!.context, e.toString());
      }
      _isLoadingVideoTeori = false;
      notifyListeners();
      return getVideoTeoriByKodeBab(kodeBab);
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-GetVideoTeori: $e');
      }

      gShowTopFlash(gNavigatorKey.currentState!.context, e.toString());
      _isLoadingVideoTeori = false;
      notifyListeners();
      return getVideoTeoriByKodeBab(kodeBab);
    }
  }

  /// [getVideoJadwal] Function untuk mendapatkan list Bab pada
  /// menu Video & Jadwal -> Video -> Mapel.
  Future<List<BabUtamaVideoJadwal>> getVideoJadwal({
    required String noRegistrasi,
    required String idMataPelajaran,
    required String tingkatSekolah,
    required String levelTeori,
    required int idBuku,
    required String kelengkapan,
    bool isRefresh = false,
  }) async {
    final String cacheKey = '$idMataPelajaran-$tingkatSekolah';
    if (!isRefresh && _listVideoJadwal.containsKey(cacheKey)) {
      return getVideoJadwalByIdMapel(cacheKey);
    }
    if (isRefresh) {
      _isLoadingVideoJadwal = true;
      // notifyListeners();
    }
    try {
      if (kDebugMode) {
        logger.log('VIDEO_PROVIDER-GetVideoJadwal: START with '
            'params($noRegistrasi, $cacheKey)');
      }

      final responseData = await _apiService.fetchVideoJadwal(
          noRegistrasi: noRegistrasi,
          idMataPelajaran: idMataPelajaran,
          levelTeori: levelTeori,
          idBuku: idBuku,
          kelengkapan: kelengkapan);

      if (kDebugMode) {
        logger.log(
            'VIDEO_PROVIDER-GetVideoJadwal: responseData >> $responseData');
      }

      if (isRefresh) _listVideoJadwal.remove(cacheKey);

      _listVideoJadwal.putIfAbsent(cacheKey, () => []);

      if (responseData.isNotEmpty && _listVideoJadwal[cacheKey]!.isEmpty) {
        for (var data in responseData) {
          logger.log(
              'VIDEO_PROVIDER-GetVideoJadwal: Start adding >> ${data['info']}');
          if (data['info'].length != 0) {
            if (data['info'][0]['video'] != null) {
              _listVideoJadwal[cacheKey]!
                  .add(BabUtamaVideoJadwal.fromJson(data));
            }
          }

          logger.log('VIDEO_PROVIDER-GetVideoJadwal: Start adding >> $data');
        }
      }

      if (kDebugMode) {
        logger.log('VIDEO_PROVIDER-GetVideoJadwal: Video Jadwal '
            '$cacheKey >> ${_listVideoJadwal[cacheKey]}');
      }

      _isLoadingVideoJadwal = false;
      notifyListeners();
      return getVideoJadwalByIdMapel(cacheKey);
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-GetVideoJadwal: $e');
      }

      gShowTopFlash(gNavigatorKey.currentState!.context, e.toString());
      _isLoadingVideoJadwal = false;
      notifyListeners();
      return getVideoJadwalByIdMapel(cacheKey);
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('DataException-GetVideoJadwal: $e');
      }

      if ('$e'.contains('tidak ditemukan')) {
        _listVideoJadwalMapel.putIfAbsent(idMataPelajaran, () => []);
      } else {
        gShowTopFlash(gNavigatorKey.currentState!.context, "tidak ditemukan");
      }
      _isLoadingVideoJadwal = false;
      notifyListeners();
      return getVideoJadwalByIdMapel(cacheKey);
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-GetVideoJadwal: $e');
      }

      gShowTopFlash(
          gNavigatorKey.currentState!.context, "Tidak ada Data Di temukan");
      _isLoadingVideoJadwal = false;
      notifyListeners();
      return getVideoJadwalByIdMapel(cacheKey);
    }
  }
}
