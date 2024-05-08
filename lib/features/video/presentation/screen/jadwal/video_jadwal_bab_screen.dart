import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/buku/domain/entity/buku.dart';
import 'package:gokreasi_new/features/video/presentation/bloc/jadwal_video_teori/jadwal_video_teori_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../data/model/video_jadwal.dart';
import '../../../../../core/config/constant.dart';
import '../../../../../core/config/extensions.dart';
import '../../../../../core/shared/screen/basic_screen.dart';
import '../../../../../core/shared/widget/empty/no_data_found.dart';
import '../../../../../core/shared/widget/expanded/custom_expansion_tile.dart';
import '../../../../../core/shared/widget/loading/shimmer_list_tiles.dart';
import '../../../../../core/shared/widget/watermark/watermark_widget.dart';
import '../../../../../core/shared/widget/refresher/custom_smart_refresher.dart';

class BabVideoJadwalScreen extends StatefulWidget {
  final String idMataPelajaran;
  final String namaMataPelajaran;
  final String? tingkatSekolah;
  final bool isRencanaPicker;
  final Buku buku;

  const BabVideoJadwalScreen({
    Key? key,
    required this.idMataPelajaran,
    required this.namaMataPelajaran,
    this.tingkatSekolah,
    required this.isRencanaPicker,
    required this.buku,
  }) : super(key: key);

  @override
  State<BabVideoJadwalScreen> createState() => _BabVideoJadwalScreenState();
}

class _BabVideoJadwalScreenState extends State<BabVideoJadwalScreen> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  UserModel? userData;
  late bool isBeliVideoEkstra =
      userData.isProdukDibeliSiswa(57, ortuBolehAkses: false);
  List<BabUtamaVideoJadwal> listVideoJadwal = [];

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is LoadedUser) {
      userData = authState.user;
    }
    _onRefreshVideoJadwal();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BasicScreen(
      title: widget.namaMataPelajaran,
      jumlahBarisTitle: 1,
      body: BlocBuilder<JadwalVideoTeoriBloc, JadwalVideoTeoriState>(
        builder: (context, state) {
          var emptyWidget = NoDataFoundWidget(
              imageUrl:
                  '${dotenv.env["BASE_URL_IMAGE"]}/arsip-mobile/img/ilustrasi_data_not_found.png',
              subTitle:
                  'Tidak ada Bab pada ${widget.namaMataPelajaran} (${widget.tingkatSekolah})',
              emptyMessage:
                  'Belum ada Bab pada mata pelajaran ${widget.namaMataPelajaran} '
                  '(${widget.tingkatSekolah}) yang tertaut. Silahkan hubungi Customer Service.');

          if (state is JadwalVideoLoading) {
            return const ShimmerListTiles(
              isWatermarked: true,
            );
          }

          if (state is JadwalVideoBabError) {
            listVideoJadwal.clear();
            return emptyWidget;
          }

          if (state is JadwalVideoLoaded) {
            listVideoJadwal = state.listBabVideo;
          }

          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(context.textScale12),
            ),
            child: CustomSmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefreshVideoJadwal,
              isDark: true,
              child: (listVideoJadwal.isEmpty)
                  ? emptyWidget
                  : WatermarkWidget(
                      child: _buildListVideoJadwal(listVideoJadwal),
                    ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _onRefreshVideoJadwal([bool refresh = true]) async {
    // Function load and refresh data

    context.read<JadwalVideoTeoriBloc>().add(LoadDaftarBabVideo(
          noRegistrasi: userData?.noRegistrasi ?? '',
          idMataPelajaran: widget.idMataPelajaran,
          tingkatSekolah: widget.tingkatSekolah ?? '',
          levelTeori: widget.buku.levelTeori,
          idBuku: int.parse(widget.buku.kodeBuku),
          kelengkapan: widget.buku.kelengkapan,
        ));

    if (refresh) {
      _refreshController.refreshCompleted();
    }
  }

  void _navigateToVideoPlayerScreen({
    required String namaBabUtama,
    required VideoJadwal videoAktif,
    required List<VideoJadwal> daftarVideo,
  }) {
    Map<String, dynamic> argument = {
      'video': videoAktif,
      'daftarVideo': daftarVideo,
      'kodeBab': videoAktif.kodeBab,
      'namaBab': videoAktif.namaBab,
      'namaMataPelajaran': widget.namaMataPelajaran,
      'userData': userData,
    };

    if (widget.isRencanaPicker) {
      argument.putIfAbsent('idJenisProduk', () => 88);
      argument.putIfAbsent(
        'keterangan',
        () => 'Menonton Video ${widget.namaMataPelajaran} '
            'Bagian Bab ${videoAktif.kodeBab} - ${videoAktif.judulVideo}.',
      );

      // Kirim data ke Rencana Belajar Editor
      Navigator.pop(context, argument);
      if (widget.idMataPelajaran != 'extra') {
        Navigator.pop(context, argument);
      }
    } else {
      Navigator.pushNamed(
        context,
        Constant.kRouteVideoPlayer,
        arguments: argument,
      );
    }
  }

  Widget _buildListVideoJadwal(List<BabUtamaVideoJadwal> listBab) =>
      ListView.separated(
        itemCount: listBab.length,
        padding: EdgeInsets.only(top: context.dp(8), bottom: context.dp(30)),
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, index) => CustomExpansionTile(
          title: Text(
            listBab[index].namaBabUtama,
            style: context.text.titleSmall?.copyWith(
              fontFamily: 'Montserrat',
            ),
          ),
          subtitle: Text(
            'Jumlah Video: ${listBab[index].daftarVideo.length}',
            style: context.text.bodySmall?.copyWith(color: Colors.black54),
          ),
          children: listBab[index]
              .daftarVideo
              .map<Widget>(
                (video) => _buildItemBab(
                  videoAktif: video,
                  daftarVideo: listBab[index].daftarVideo,
                  namaBabUtama: listBab[index].namaBabUtama,
                ),
              )
              .toList(),
        ),
      );

  Widget _buildItemBab({
    required String namaBabUtama,
    required VideoJadwal videoAktif,
    required List<VideoJadwal> daftarVideo,
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
          namaBabUtama: namaBabUtama,
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
        subtitle: RichText(
          textAlign: TextAlign.left,
          textScaler: TextScaler.linear(context.textScale12),
          text: TextSpan(
            text: '(${videoAktif.kodeBab}) ~ ',
            style: context.text.labelSmall?.copyWith(color: Colors.black54),
            semanticsLabel: 'Bab ${videoAktif.kodeBab}',
            children: [
              TextSpan(
                text: videoAktif.namaBab,
                style: context.text.bodySmall?.copyWith(color: Colors.black54),
                semanticsLabel: 'Bab ${videoAktif.namaBab}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
