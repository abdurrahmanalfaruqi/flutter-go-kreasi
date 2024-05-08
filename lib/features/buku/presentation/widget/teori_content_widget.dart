import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/buku/presentation/bloc/teori_content/teori_content_bloc.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../data/model/content_model.dart';
import '../../../video/data/model/video_teori.dart';
import '../../../video/presentation/provider/video_provider.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/shared/widget/empty/basic_empty.dart';
import '../../../../core/shared/widget/loading/shimmer_widget.dart';
import '../../../../core/shared/widget/html/widget_from_html.dart';
import '../../../../core/shared/widget/watermark/watermark_widget.dart';
import '../../../../core/shared/widget/refresher/custom_smart_refresher.dart';

class TeoriContentWidget extends StatefulWidget {
  final String namaBabSubBab;
  final String idTeoriBab;
  final String namaMataPelajaran;
  final String jenisBuku;
  final String kodeBab;
  final String levelTeori;
  final String kelengkapan;

  const TeoriContentWidget({
    Key? key,
    required this.namaBabSubBab,
    required this.idTeoriBab,
    required this.namaMataPelajaran,
    required this.jenisBuku,
    required this.kodeBab,
    required this.levelTeori,
    required this.kelengkapan,
  }) : super(key: key);

  @override
  State<TeoriContentWidget> createState() => _TeoriContentWidgetState();
}

class _TeoriContentWidgetState extends State<TeoriContentWidget> {
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  UserModel? userData;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is LoadedUser) {
      userData = authState.user;
    }
    _onRefresh(isRefresh: false);
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WatermarkWidget(
        floatingWidgets: _videoButtonBuilder(),
        child: BlocBuilder<TeoriContentBloc, TeoriContentState>(
            builder: (context, state) {
          Widget? htmlRender;

          if (state is TeoriContentLoaded) {
            ContentModel contentBab = state.content;
            htmlRender = WidgetFromHtml(
              htmlString: contentBab.uraian,
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 20.0,
                right: 20.0,
                bottom: 84.0,
              ),
            );
            // if (contentBab.uraian.contains('table')) {

            // } else {
            //   htmlRender = CustomHtml(
            //     htmlString: contentBab.uraian,
            //     padding: const EdgeInsets.only(
            //         top: 20.0, left: 20.0, right: 20.0, bottom: 84.0),
            //   );
            // }
          }

          if (state is TeoriContentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TeoriContentError || htmlRender == null) {
            return CustomSmartRefresher(
                isDark: true,
                controller: refreshController,
                onRefresh: () => _onRefresh(),
                child: _buildEmptyWidget());
          }

          return CustomSmartRefresher(
              isDark: true,
              controller: refreshController,
              onRefresh: () => _onRefresh(),
              child: (context.isMobile)
                  ? htmlRender
                  : MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: TextScaler.linear(context.textScale12),
                      ),
                      child: htmlRender));
        }));
  }

  Future<void> _onRefresh({bool isRefresh = true}) async {
    context.read<TeoriContentBloc>().add(LoadTeoriContent(
          idTeoriBab: widget.idTeoriBab,
          level: widget.levelTeori,
          kodeBab: widget.kodeBab,
          jenis: widget.jenisBuku,
          isRefresh: isRefresh,
        ));
    if (userData.isLogin) {
      context.read<VideoProvider>().getVideoTeori(
            isRefresh: true,
            noRegistrasi: userData?.noRegistrasi ?? '',
            kodeBab: widget.kodeBab,
            levelTeori: widget.levelTeori,
            kelengkapan: widget.kelengkapan,
            idTeoriBab: widget.idTeoriBab,
            jenisBuku: widget.jenisBuku,
            namaMataPelajaran: widget.namaMataPelajaran,
          );
    }
    refreshController.refreshCompleted();
  }

  void _onNavigateToVideoScreen(
          VideoTeori video, List<VideoTeori> daftarVideo) =>
      Navigator.pushNamed(
        context,
        Constant.kRouteVideoPlayer,
        arguments: {
          'video': video,
          'daftarVideo': daftarVideo,
          'kodeBab': widget.kodeBab,
          'namaBab': widget.namaBabSubBab,
          'namaMataPelajaran': widget.namaMataPelajaran,
          'userData': userData,
        },
      );

  // Future<void> _bottomSheetDaftarVideo({
  //   required String namaBabSubBab,
  //   required List<VideoTeori> daftarVideo,
  // }) {
  //   return showModalBottomSheet<void>(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(
  //         top: Radius.circular(25.0),
  //       ),
  //     ),
  //     builder: (context) => DaftarVideoTeori(
  //       isBeliVideoTeori: userData.isProdukDibeliSiswa(88),
  //       namaBabSubBab: namaBabSubBab,
  //       daftarVideo: daftarVideo,
  //       onClickVideo: _onNavigateToVideoScreen,
  //     ),
  //   );
  // }

  // List<Widget> _buildLoadingWidget(BuildContext context) => [
  //       ShimmerWidget.rounded(
  //         width: ((context.isMobile) ? context.dw : context.dh) * 0.6,
  //         height: min(30, context.dp(26)),
  //         borderRadius: gDefaultShimmerBorderRadius,
  //       ),
  //       SizedBox(height: min(16, context.dp(12))),
  //       ConstrainedBox(
  //         constraints: BoxConstraints(
  //           maxWidth: double.infinity,
  //           maxHeight: min(148, context.dp(128)),
  //         ),
  //         child: LayoutBuilder(
  //           builder: (context, constraint) => Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               ShimmerWidget.rounded(
  //                 width: constraint.maxWidth * 0.46,
  //                 height: constraint.maxHeight - min(16, context.dp(12)),
  //                 borderRadius: gDefaultShimmerBorderRadius,
  //               ),
  //               Expanded(
  //                 child: Column(
  //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                   children: [
  //                     for (int i = 0; i < 4; i++)
  //                       Padding(
  //                         padding: const EdgeInsets.only(left: 12),
  //                         child: ShimmerWidget.rounded(
  //                           width: constraint.maxWidth * 0.5,
  //                           height: min(24, context.dp(20)),
  //                           borderRadius: gDefaultShimmerBorderRadius,
  //                         ),
  //                       ),
  //                   ],
  //                 ),
  //               )
  //             ],
  //           ),
  //         ),
  //       ),
  //       for (int i = 0; i < 4; i++)
  //         Padding(
  //           padding: EdgeInsets.only(bottom: (i == 3) ? 26 : 12),
  //           child: ShimmerWidget.rounded(
  //             width: MediaQuery.of(context).size.width,
  //             height: min(24, context.dp(20)),
  //             borderRadius: gDefaultShimmerBorderRadius,
  //           ),
  //         ),
  //     ];

  bool _isProdukDibeli({bool ortuBolehAkses = false}) {
    // jenisBuku == teori, maka idJenis Produknya adalah 59, Jika rumus idJenisProduknya adalah 46.
    int idJenisProduk = (widget.jenisBuku == 'teori') ? 59 : 46;

    bool isProdukDibeli = userData.isProdukDibeliSiswa(idJenisProduk,
        ortuBolehAkses: ortuBolehAkses);
    if (idJenisProduk == 59) {
      bool isBeliTeori =
          userData.isProdukDibeliSiswa(59, ortuBolehAkses: ortuBolehAkses);
      bool isBeliTeoriSingkat =
          userData.isProdukDibeliSiswa(97, ortuBolehAkses: ortuBolehAkses);
      bool isBeliTeoriRingkas =
          userData.isProdukDibeliSiswa(98, ortuBolehAkses: ortuBolehAkses);

      isProdukDibeli = isBeliTeori | isBeliTeoriSingkat | isBeliTeoriRingkas;
    }
    return isProdukDibeli;
  }

  Widget _buildEmptyWidget() {
    String title =
        '${(widget.jenisBuku == 'teori') ? 'Teori' : 'Rumus'} Bab ${widget.namaBabSubBab}';

    Widget basicEmpty = BasicEmpty(
      shrink: (context.dh < 600) ? !context.isMobile : false,
      imageUrl: 'ilustrasi_data_not_found.png'.illustration,
      title: title,
      subTitle: gEmptyProductSubtitle(
          namaProduk: title,
          isProdukDibeli: _isProdukDibeli(ortuBolehAkses: true),
          isOrtu: userData.isOrtu,
          isNotSiswa: !userData.isSiswa),
      emptyMessage: gEmptyProductText(
        namaProduk: title,
        isOrtu: userData.isOrtu,
        isProdukDibeli: _isProdukDibeli(ortuBolehAkses: true),
      ),
    );

    return (context.isMobile || context.dh > 600)
        ? basicEmpty
        : SingleChildScrollView(
            child: basicEmpty,
          );
  }

  List<Widget> _videoButtonBuilder() => [
        (!userData.isLogin)
            ? _buildVideoButton(context, [], false)
            : Selector<VideoProvider, List<VideoTeori>>(
                selector: (_, video) =>
                    video.getVideoTeoriByKodeBab(widget.kodeBab),
                shouldRebuild: (prev, next) {
                  bool shouldRebuild = prev.length != next.length;

                  if (!shouldRebuild) {
                    shouldRebuild = prev.any(
                      (videoPrev) => next.any(
                        (videoNext) =>
                            videoNext.idVideo == videoPrev.idVideo &&
                            videoNext.namaMataPelajaran ==
                                videoPrev.namaMataPelajaran &&
                            videoNext.judulVideo != videoPrev.judulVideo &&
                            videoNext.deskripsi != videoPrev.deskripsi &&
                            videoNext.linkVideo != videoPrev.linkVideo,
                      ),
                    );
                  }

                  return shouldRebuild;
                },
                builder: (context, daftarVideoTeori, _) =>
                    FutureBuilder<List<VideoTeori>>(
                  future: context.read<VideoProvider>().getVideoTeori(
                        noRegistrasi: userData?.noRegistrasi ?? '',
                        kodeBab: widget.kodeBab,
                        levelTeori: widget.levelTeori,
                        kelengkapan: widget.kelengkapan,
                        idTeoriBab: widget.idTeoriBab,
                        jenisBuku: widget.jenisBuku,
                        namaMataPelajaran: widget.namaMataPelajaran,
                      ),
                  builder: (context, snapshot) {
                    bool isLoading =
                        snapshot.connectionState == ConnectionState.waiting ||
                            context.select<VideoProvider, bool>(
                                (video) => video.isLoadingVideoTeori);

                    if (!isLoading && daftarVideoTeori.isEmpty) {
                      const SizedBox.shrink();
                    }

                    return _buildVideoButton(
                        context, daftarVideoTeori, isLoading);
                  },
                ),
              ),
      ];

  Align _buildVideoButton(
      BuildContext context, List<VideoTeori> daftarVideoTeori, bool isLoading) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: EdgeInsets.only(
          left: min(26, context.dp(18)),
          bottom: min(24, context.dp(20)),
        ),
        child: (isLoading)
            ? ShimmerWidget.rounded(
                width: 64,
                height: 64,
                borderRadius: BorderRadius.circular(8),
              )
            : FloatingActionButton(
                onPressed: () {
                  if (daftarVideoTeori.isNotEmpty) {
                    _onNavigateToVideoScreen(
                        daftarVideoTeori.first, daftarVideoTeori);
                  } else {
                    gShowBottomDialogInfo(context,
                        message:
                            "Yaah, Video pembahasan terkait teori ini belum tersedia Sobat");
                  }
                },
                elevation: 12,
                heroTag: 'VIDEO_TEORI',
                tooltip: 'Lihat Video Pembahasan',
                foregroundColor: context.onSecondary,
                splashColor: context.secondaryContainer,
                backgroundColor: context.secondaryColor,
                child:
                    const FittedBox(child: Icon(Icons.video_library_outlined)),
              ),
      ),
    );
  }
}
