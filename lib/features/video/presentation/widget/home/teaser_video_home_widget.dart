import 'dart:developer' as logger show log;

import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../provider/video_provider.dart';
import '../../../../../core/config/global.dart';
import '../../../../../core/config/extensions.dart';
import '../../../../../core/shared/widget/loading/shimmer_widget.dart';

class TeaserVideoHomeWidget extends StatefulWidget {
  final bool isLogin;
  final bool isBeliVideoTeori;
  final String userType;
  final String idSekolahKelas;
  final UserModel? userData;

  const TeaserVideoHomeWidget({
    Key? key,
    required this.isLogin,
    required this.isBeliVideoTeori,
    required this.userType,
    required this.idSekolahKelas,
    required this.userData,
  }) : super(key: key);

  @override
  State<TeaserVideoHomeWidget> createState() => _TeaserVideoHomeWidgetState();
}

class _TeaserVideoHomeWidgetState extends State<TeaserVideoHomeWidget> {
  ChewieController? _chewieController;
  VideoPlayerController? _videoPlayerController;
  String? _tempLink;
  bool _playerVisible = false;

  @override
  void dispose() {
    logger.log('VIDEO_TEASER_WIDGET-OnDispose: Called');
    if (gNavigatorKey.currentContext!.isMobile) {
      // gSetDeviceOrientations();
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }

    if (_videoPlayerController != null) {
      _videoPlayerController!.pause();
      _videoPlayerController!.dispose();
    }
    if (_chewieController != null) {
      _chewieController!.pause();
      _chewieController!.removeListener(_exitFullscreen);
      _chewieController!.dispose();
    }
    super.dispose();
  }

  void _initializePlayer(String linkVideoTeaser) async {
    if (kDebugMode) {
      logger.log('VIDEO_TEASER_WIDGET-InitializePlayer: START');
    }
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse('${dotenv.env['BASE_URL_VIDEO_TEASER']}$linkVideoTeaser'),
      formatHint: VideoFormat.other,
    );

    _chewieController = ChewieController(
      materialProgressColors: ChewieProgressColors(
          backgroundColor: const Color.fromARGB(100, 255, 255, 255),
          bufferedColor: Colors.grey),
      videoPlayerController: _videoPlayerController!,
      allowPlaybackSpeedChanging: false,
      showControls: true,
      autoInitialize: true,
      autoPlay: false,
      aspectRatio: 286 / 147,
      placeholder: ShimmerWidget.rounded(
          width: double.infinity,
          height: double.infinity,
          borderRadius: gDefaultShimmerBorderRadius),
      overlay: Selector<VideoProvider, bool>(
          selector: (_, videoProvider) => videoProvider.isVideoPlayed,
          builder: (context, isPlayed, _) {
            if (isPlayed) return const SizedBox.shrink();
            
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                image: DecorationImage(
                  image: AssetImage('assets/img/logo.webp'),
                ),
              ),
            );
          }),
      errorBuilder: (_, errorMessage) {
        if (kDebugMode) {
          logger.log('VIDEO_TEASER_WIDGET-ErrorChewie: $errorMessage');
        }
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Yah, video teaser sedang bermasalah sobat',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
      deviceOrientationsOnEnterFullScreen: [
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ],
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
      ],
    );

    _chewieController!.addListener(_exitFullscreen);
    if (kDebugMode) {
      logger.log('VIDEO_TEASER_WIDGET-InitializePlayer: FINISHED');
    }
  }

  void _exitFullscreen() {
    if (_chewieController == null) return;
    if (!_playerVisible && !_chewieController!.isFullScreen) {
      Navigator.popUntil(
          gNavigatorKey.currentState!.context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      logger.log(
          'VIDEO_TEASER_BUILD: ${widget.idSekolahKelas}-${widget.userType}');
    }
    return FutureBuilder<String>(
      future: context.read<VideoProvider>().getVideoTeaser(
            idSekolahKelas: widget.idSekolahKelas,
            userType: widget.userType,
            userData: widget.userData,
          ),
      builder: (context, snapshot) {
        bool showTextPromosi = !widget.isLogin || !widget.isBeliVideoTeori;

        bool isLoading = snapshot.connectionState == ConnectionState.waiting ||
            context.select<VideoProvider, bool>(
                (video) => video.isLoadingVideoTeaser);

        String linkVideoTeaser = snapshot.data ??
            context.select<VideoProvider, String>((video) =>
                video.getVideoTeaserFromCache(
                    widget.idSekolahKelas, widget.userType));

        // String streamToken =
        //     context.select<VideoProvider, String>((video) => video.streamToken);

        if (kDebugMode) {
          logger.log(
              'VIDEO_TEASER_WIDGET-CheckFullScreen: ${_chewieController?.isFullScreen}');
          logger.log(
              'VIDEO_TEASER_WIDGET-CheckLink: ${linkVideoTeaser != _tempLink}'
              '\n$linkVideoTeaser\n$_tempLink');
        }

        bool isFistInit =
            _videoPlayerController == null && _chewieController == null;

        bool isReInit = linkVideoTeaser != _tempLink &&
            _videoPlayerController != null &&
            _chewieController != null;

        if (isReInit) {
          _videoPlayerController!.dispose();
          _chewieController!.dispose();
          _videoPlayerController = null;
          _chewieController = null;
        }
        if (!isLoading &&
            linkVideoTeaser.isNotEmpty &&
            (isFistInit || isReInit)) {
          _tempLink = linkVideoTeaser;
          _initializePlayer(linkVideoTeaser);
          _videoPlayerController?.addListener(_checkVideoIsPlayed);
        }

        if (isLoading) {
          return _buildLoadingVideoTeaser();
        }

        if (linkVideoTeaser.isEmpty) {
          return const SizedBox.shrink();
        }

        return VisibilityDetector(
          key: const Key("Video Teaser"),
          onVisibilityChanged: (VisibilityInfo info) {
            _playerVisible = info.visibleFraction != 0;
            if (info.visibleFraction == 0 &&
                _videoPlayerController != null &&
                _chewieController != null) {
              _videoPlayerController!.pause();
              _chewieController!.pause();
            }
          },
          child: (showTextPromosi)
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RotatedBox(
                      quarterTurns: 4,
                      child: Image.asset(
                        'assets/img/teaser_video_text.png',
                        height: (context.isMobile)
                            ? context.dp(150)
                            : context.dp(100),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular((context.isMobile)
                            ? context.dp(10)
                            : context.dp(6)),
                        child: AspectRatio(
                          aspectRatio: 286 / 147,
                          child: Chewie(controller: _chewieController!),
                        ),
                      ),
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(
                    (context.isMobile) ? context.dp(10) : context.dp(6),
                  ),
                  child: AspectRatio(
                    aspectRatio: 286 / 147,
                    child: Chewie(controller: _chewieController!),
                  ),
                ),
        );
      },
    );
  }

  Row _buildLoadingVideoTeaser() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: ShimmerWidget.rounded(
              width: double.infinity,
              height: (context.isMobile) ? context.dp(177) : context.dp(120),
              borderRadius: BorderRadius.circular(context.dp(24)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: ShimmerWidget.rounded(
              width: double.infinity,
              height: (context.isMobile) ? context.dp(147) : context.dp(100),
              borderRadius: BorderRadius.circular(context.dp(12)),
            ),
          ),
        ],
      );

  /// [_checkVideoIsPlayed] digunakan untuk mengetahui apakah video teaser
  /// sudah di play atau belum
  void _checkVideoIsPlayed() {
    context.read<VideoProvider>().setVideoPlay(_videoPlayerController);
  }
}
