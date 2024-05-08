import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gokreasi_new/features/soal/entity/solusi.dart';
import 'package:gokreasi_new/features/video/domain/entity/video.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/shared/widget/loading/shimmer_widget.dart';
import '../../../video/presentation/widget/video_player_card.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/shared/widget/animation/custom_rect_tween.dart';

class VideoSolusiExpand extends StatelessWidget {
  final Solusi solusi;
  final String? baseUrlVideo;

  const VideoSolusiExpand({
    Key? key,
    required this.solusi,
    this.baseUrlVideo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.all(min(28, context.dp(24))),
        child: Hero(
          tag: 'video_solusi',
          transitionOnUserGestures: true,
          createRectTween: (begin, end) =>
              CustomRectTween(begin: begin, end: end),
          child: Material(
            elevation: 4,
            color: Colors.transparent,
            borderRadius: gDefaultShimmerBorderRadius,
            child: SingleChildScrollView(
              child: Builder(
                builder: (context) {
                  Video video = Video(
                    linkVideo: solusi.linkVideo,
                    judulVideo: solusi.judulVideo,
                  );

                  String? baseUrl = (baseUrlVideo == null)
                      ? dotenv.env['BASE_URL_VIDEO']
                      : baseUrlVideo;

                  return VideoPlayerCard(
                    video: video,
                    accessFrom: AccessVideoCardFrom.videoSolusi,
                    allowFullScreen: true,
                    padding: const EdgeInsets.all(6),
                    videoPlayerController: VideoPlayerController.networkUrl(
                      Uri.parse('$baseUrl${solusi.linkVideo}'),
                      formatHint: VideoFormat.other,
                      // httpHeaders: {
                      //   'secretkey': streamToken,
                      //   'credentialauth': Constant.kVideoCredential,
                      // },
                    ),
                    loadingWidget: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: ShimmerWidget.rounded(
                          width: double.infinity,
                          height: double.infinity,
                          borderRadius: gDefaultShimmerBorderRadius),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
