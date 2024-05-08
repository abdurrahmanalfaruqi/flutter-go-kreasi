import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gokreasi_new/core/config/constant.dart';
import 'package:gokreasi_new/core/config/extensions.dart';
import 'package:gokreasi_new/core/shared/widget/empty/no_data_found.dart';
import 'package:gokreasi_new/core/shared/widget/expanded/custom_expansion_tile.dart';
import 'package:gokreasi_new/core/shared/widget/loading/shimmer_list_tiles.dart';
import 'package:gokreasi_new/core/shared/widget/refresher/custom_smart_refresher.dart';
import 'package:gokreasi_new/core/shared/widget/separator/dash_divider.dart';
import 'package:gokreasi_new/core/shared/widget/watermark/watermark_widget.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/video/domain/entity/video_ekstra.dart';
import 'package:gokreasi_new/features/video/presentation/bloc/jadwal_video_teori/jadwal_video_teori_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class VideoEkstraList extends StatefulWidget {
  final bool isRencanaPicker;
  const VideoEkstraList({super.key, required this.isRencanaPicker});

  @override
  State<VideoEkstraList> createState() => _VideoEkstraListState();
}

class _VideoEkstraListState extends State<VideoEkstraList> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  UserModel? userData;
  Map<String, List<VideoExtra>> listVideoEkstra = {};

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is LoadedUser) {
      userData = authState.user;
    }

    _onRefresh(false);
  }

  @override
  void dispose() {
    super.dispose();
    _refreshController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<JadwalVideoTeoriBloc, JadwalVideoTeoriState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is JadwalVideoLoading) {
          return const ShimmerListTiles(isWatermarked: true);
        }

        if (state is LoadedVideoEkstra) {
          listVideoEkstra = state.listVideoEkstra;
        }

        var refreshWidget = CustomSmartRefresher(
          controller: _refreshController,
          onRefresh: _onRefresh,
          isDark: true,
          child: (listVideoEkstra.isEmpty)
              ? _buildEmptyVideoEkstra()
              : _buildListVideoJadwal(listVideoEkstra),
        );

        return (listVideoEkstra.isEmpty)
            ? refreshWidget
            : WatermarkWidget(
                child: refreshWidget,
              );
      },
    );
  }

  void _onRefresh([bool refresh = true]) {
    context.read<JadwalVideoTeoriBloc>().add(LoadDaftarVideoEkstra(userData));
  }

  Widget _buildListVideoJadwal(Map<String, List<VideoExtra>> listVideo) =>
      ListView.separated(
        itemCount: listVideo.length,
        padding: EdgeInsets.only(top: context.dp(8), bottom: context.dp(30)),
        separatorBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(top: 6),
          child: DashedDivider(
            dashColor: context.outline,
            strokeWidth: 0.6,
            dash: 4,
            direction: Axis.horizontal,
          ),
        ),
        itemBuilder: (_, index) {
          String jenis = listVideo.keys.toList()[index];
          List<VideoExtra> subListVideo = listVideo.values.toList()[index];
          return CustomExpansionTile(
            title: Text(
              jenis,
              style: context.text.titleSmall?.copyWith(
                fontFamily: 'Montserrat',
              ),
            ),
            subtitle: Text(
              'Jumlah Video: ${subListVideo.length}',
              style: context.text.bodySmall?.copyWith(color: Colors.black54),
            ),
            children: List.generate(
              subListVideo.length,
              (subIndex) => _buildItemBab(
                videoAktif: subListVideo[subIndex],
                daftarVideo: subListVideo,
              ),
            ),
          );
        },
      );

  Widget _buildEmptyVideoEkstra() {
    return NoDataFoundWidget(
      imageUrl:
          '${dotenv.env["BASE_URL_IMAGE"]}/arsip-mobile/img/ilustrasi_data_not_found.png',
      subTitle: 'Tidak ada video ekstra di kelas ${userData?.tingkatKelas}',
      emptyMessage: 'Belum ada video ekstra '
          'yang sesuai dengan BAH.',
    );
  }

  Widget _buildItemBab({
    required VideoExtra videoAktif,
    required List<VideoExtra> daftarVideo,
  }) {
    return Container(
      constraints: BoxConstraints(
        minWidth: double.infinity,
        maxWidth: double.infinity,
        minHeight: min(54, context.dp(38)),
        // maxHeight: context.dp(60),
      ),
      margin: EdgeInsets.only(left: context.dp(24)),
      padding: EdgeInsets.only(
        top: min(12, context.dp(8)),
        right: min(32, context.dp(24)),
        bottom: min(12, context.dp(8)),
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.disableColor)),
      ),
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        onTap: () => _navigateToVideoPlayerScreen(
          videoAktif: videoAktif,
          daftarVideo: daftarVideo,
        ),
        minLeadingWidth: min(46, context.dp(32)),
        leading: Icon(
          Icons.movie_outlined,
          color: context.tertiaryColor,
          size: min(46, context.dp(32)),
        ),
        title: Text(
          videoAktif.judulVideo ?? '-',
          textAlign: TextAlign.left,
          semanticsLabel: 'Bab dan Sub Bab Kisi-Kisi',
        ),
      ),
    );
  }

  void _navigateToVideoPlayerScreen({
    required VideoExtra videoAktif,
    required List<VideoExtra> daftarVideo,
  }) {
    Map<String, dynamic> argument = {
      'video': videoAktif,
      'daftarVideo': daftarVideo,
      'kodeBab': videoAktif.jenis,
      'namaBab': '',
      'namaMataPelajaran': '',
      'userData': userData,
      'isVideoExtra': true,
    };

    if (widget.isRencanaPicker) {
      argument.putIfAbsent('idJenisProduk', () => 88);
      argument.putIfAbsent(
        'keterangan',
        () => 'Menonton Video ${videoAktif.judulVideo} '
            'Dengan jenis ${videoAktif.jenis}.',
      );

      // Kirim data ke Rencana Belajar Editor
      Navigator.pop(context, argument);
    } else {
      Navigator.pushNamed(
        context,
        Constant.kRouteVideoPlayer,
        arguments: argument,
      );
    }
  }
}
