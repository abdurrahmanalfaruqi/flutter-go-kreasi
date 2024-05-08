import 'package:flutter/material.dart';
import 'package:gokreasi_new/features/video/presentation/widget/jadwal/video_ekstra_list.dart';

import 'video_mapel_list.dart';
import '../../../../../core/config/extensions.dart';

class VideoJadwalWidget extends StatelessWidget {
  final bool isRencanaPicker;

  const VideoJadwalWidget({Key? key, this.isRencanaPicker = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Column(
        children: [
          if (!context.isMobile) SizedBox(height: context.dp(6)),
          TabBar(
            indicatorWeight: 2,
            labelColor: context.onBackground,
            indicatorColor: context.onBackground,
            labelStyle: context.text.bodyMedium,
            unselectedLabelStyle: context.text.bodyMedium,
            indicatorSize: TabBarIndicatorSize.tab,
            unselectedLabelColor: context.onBackground.withOpacity(0.54),
            padding: EdgeInsets.symmetric(horizontal: context.dp(24)),
            indicatorPadding: EdgeInsets.zero,
            labelPadding: EdgeInsets.zero,
            // menutup video ekstra karena belum ada
            tabs: const [Tab(text: 'Video Teori'), Tab(text: 'Video Ekstra')],
            // tabs: const [Tab(text: 'Video Teori')],
          ),
          Expanded(
            child: TabBarView(
              physics: const ClampingScrollPhysics(),
              children: [
                VideoMapelList(isRencanaPicker: isRencanaPicker),
                VideoEkstraList(isRencanaPicker: isRencanaPicker),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
