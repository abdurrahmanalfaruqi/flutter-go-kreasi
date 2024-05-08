import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/leaderboard/presentation/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import 'big_three_widget.dart';
import '../../model/leaderboard_rank_model.dart';
import '../../../laporan/module/tobk/presentation/provider/laporan_tryout_provider.dart';
import '../../../../core/config/enum.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/shared/widget/empty/basic_empty.dart';
import '../../../../core/shared/widget/dialog/custom_dialog.dart';
import '../../../../core/shared/widget/loading/loading_widget.dart';
import '../../../../core/shared/widget/image/profile_picture_widget.dart';
import '../../../../core/shared/widget/refresher/custom_smart_refresher.dart';

class ListJuaraBukuSakti extends StatefulWidget {
  final String juaraType;

  const ListJuaraBukuSakti({Key? key, required this.juaraType})
      : super(key: key);
  @override
  State<ListJuaraBukuSakti> createState() => _ListJuaraBukuSaktiState();
}

class _ListJuaraBukuSaktiState extends State<ListJuaraBukuSakti> {
  late final NavigatorState _navigator = Navigator.of(context);
  final _screenshotController = ScreenshotController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  late String juaraType;
  late String juaraMyRank;

  String ranking = '-';
  UserModel? userdata;

  @override
  void initState() {
    super.initState();
    if (widget.juaraType == 'Nasional') {
      juaraType = 'national';
      juaraMyRank = widget.juaraType.toLowerCase();
    } else if (widget.juaraType == 'Kota') {
      juaraType = 'city';
      juaraMyRank = widget.juaraType.toLowerCase();
    } else if (widget.juaraType == 'Gedung') {
      juaraType = 'gedung';
      juaraMyRank = widget.juaraType.toLowerCase();
    }
    final authState = context.read<AuthBloc>().state;
    if (authState is LoadedUser) {
      userdata = authState.user;
    }

    _onRefresh(isRefresh: false);
  }

  void _onRefresh({bool isRefresh = true}) {
    context.read<LeaderboardBloc>().add(LoadLeaderboard(
          userData: userdata,
          rankKay: widget.juaraType,
          isRefresh: isRefresh,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
        builder: (context, state) {
      if (state is LeaderboardLoading) {
        return const LoadingWidget();
      }
      if (state is LeaderboardDataLoaded &&
          state.listTopFiveBukuSakti?[juaraType]?.isNotEmpty == true) {
        List<LeaderboardRankModel> listTopFive = [];
        List<LeaderboardRankModel> listRankingTerdekat = [];
        if (state.listTopFiveBukuSakti != null) {
          listTopFive = state.listTopFiveBukuSakti?[juaraType] ?? [];
          listRankingTerdekat =
              state.listRankingTerdekatBukuSakti?[juaraMyRank] ?? [];
        }
        List<LeaderboardRankModel> listTopThree = (listTopFive.length <= 3)
            ? listTopFive
            : listTopFive.getRange(0, 3).toList();
        List<LeaderboardRankModel> bigTen = (listTopFive.length > 5)
            ? listTopFive.getRange(5, listTopFive.length).toList()
            : [];
        return CustomSmartRefresher(
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              vertical: (context.isMobile) ? context.dp(20) : 32,
              horizontal: (context.isMobile || context.dw > 1100)
                  ? min(32, context.dp(24))
                  : 24,
            ),
            children: [
              BigThreeWidget(topThreeJuaraBukuSakti: listTopThree),
              SizedBox(height: context.dp(12)),
              if (listTopFive.length > 3) ..._buildItemJuara(listTopFive[3]),
              if (listTopFive.length > 4) ..._buildItemJuara(listTopFive[4]),
              Padding(
                padding:
                    EdgeInsets.symmetric(vertical: min(24, context.dp(18))),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '\u00B7\u00B7\u00B7 ${state.pesan}* \u00B7\u00B7\u00B7',
                    style: context.text.labelSmall,
                    maxLines: 1,
                  ),
                ),
              ),
              if (listRankingTerdekat.isNotEmpty)
                ..._buildRankingTerdekat(
                  dataRankingTerdekat: listRankingTerdekat,
                  bigTen: bigTen,
                ),
              SizedBox(height: context.dp(12)),
              if (listRankingTerdekat.isNotEmpty) _buildShareButton(),
            ],
          ),
        );
      } else {
        String location = (widget.juaraType != 'Nasional')
            ? 'pada ${widget.juaraType.toLowerCase()} ini'
            : 'ditingkat nasional';
        final basicEmpty = BasicEmpty(
            shrink: (context.dh < 600) ? !context.isMobile : false,
            imageUrl: 'ilustrasi_juara_buku_sakti.png'.illustration,
            title: 'Oops!',
            subTitle: 'Belum ada data peringkat',
            emptyMessage: 'Data peringkat siswa belum ada $location');

        return (context.isMobile || context.dh > 600)
            ? basicEmpty
            : SingleChildScrollView(
                child: basicEmpty,
              );
      }
    });
  }

  List<Widget> _buildItemJuara(LeaderboardRankModel dataRanking) {
    if (dataRanking.noRegistrasi == userdata?.noRegistrasi) {
      ranking = dataRanking.rank.toString();
    }
    return [
      dataRanking.noRegistrasi == userdata?.noRegistrasi
          ? Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: context.hintColor,
              ),
              child: Row(
                children: [
                  Text('${dataRanking.rank}',
                      style: context.text.titleSmall
                          ?.copyWith(color: context.onPrimary)),
                  Padding(
                    padding: EdgeInsets.only(
                      left: context.dp(12),
                      right: context.dp(8),
                    ),
                    child: ProfilePictureWidget.leaderboard(
                      key: ValueKey(
                          'PHOTO_PROFILE_LEADERBOARD-${dataRanking.noRegistrasi}-${dataRanking.namaLengkap}'),
                      width: min(82, context.dp(48)),
                      height: min(82, context.dp(48)),
                      noRegistrasi: dataRanking.noRegistrasi,
                      name: dataRanking.namaLengkap,
                      photoUrl: dataRanking.profilePicture,
                    ),
                  ),
                  Expanded(
                    child: Text(dataRanking.namaLengkap,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodyLarge
                            ?.copyWith(color: context.onPrimary)),
                  ),
                  Text(dataRanking.score,
                      style: context.text.bodyLarge
                          ?.copyWith(color: context.onPrimary)),
                ],
              ),
            )
          : Row(
              children: [
                const SizedBox(width: 8),
                Text('${dataRanking.rank}',
                    style: context.text.titleSmall?.copyWith(
                        color: dataRanking.isBigFive
                            ? context.onPrimary
                            : context.onBackground)),
                Padding(
                  padding: EdgeInsets.only(
                    left: context.dp(12),
                    right: context.dp(8),
                  ),
                  child: ProfilePictureWidget.leaderboard(
                    key: ValueKey(
                        'PHOTO_PROFILE_LEADERBOARD-${dataRanking.noRegistrasi}-${dataRanking.namaLengkap}'),
                    width: min(82, context.dp(48)),
                    height: min(82, context.dp(48)),
                    noRegistrasi: dataRanking.noRegistrasi,
                    // userType: 'SISWA',
                    name: dataRanking.namaLengkap,
                    photoUrl: dataRanking.profilePicture,
                  ),
                ),
                Expanded(
                  child: Text(dataRanking.namaLengkap,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyLarge?.copyWith(
                          color: dataRanking.isBigFive
                              ? context.onPrimary
                              : context.onBackground)),
                ),
                Text(dataRanking.score,
                    style: context.text.bodyLarge?.copyWith(
                        color: dataRanking.isBigFive
                            ? context.onPrimary
                            : context.onBackground)),
                const SizedBox(width: 8),
              ],
            ),
      Divider(
          color: dataRanking.isBigFive ? context.onPrimary : context.hintColor),
    ];
  }

  List<Widget> _buildRankingTerdekat({
    List<LeaderboardRankModel> dataRankingTerdekat = const [],
    List<LeaderboardRankModel> bigTen = const [],
  }) {
    List<Widget> widgetsRankingTerdekat = [];

    if (dataRankingTerdekat.isNotEmpty) {
      for (var dataRanking in dataRankingTerdekat) {
        widgetsRankingTerdekat.addAll(_buildItemJuara(dataRanking));
      }
    } else {
      if (bigTen.isNotEmpty) {
        for (var dataRanking in bigTen) {
          widgetsRankingTerdekat.addAll(_buildItemJuara(dataRanking));
        }
      }

      widgetsRankingTerdekat.add(Padding(
        padding: EdgeInsets.only(
          left: 16,
          top: (bigTen.isNotEmpty) ? 16 : 0,
        ),
        child: Text('Peringkat Terdekat', style: context.text.titleSmall),
      ));
      widgetsRankingTerdekat.add(
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: context.hintColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Hai Sobat! Kamu belum tercatat dalam daftar ranking. '
            'Bisa jadi karena kamu belum mengerjakan latihan soal, '
            'atau tunggu dulu 1 jam untuk melihat hasil perubahannya yaa!',
            style: context.text.bodySmall?.copyWith(color: context.onPrimary),
          ),
        ),
      );
    }
    return widgetsRankingTerdekat;
  }

  Widget _buildShareButton() {
    return TextButton.icon(
      icon: const Icon(Icons.share),
      label: const Text("Bagikan"),
      onPressed: () async {
        final rank = ranking;
        final tingkat = widget.juaraType;

        await showCupertinoModalPopup(
          context: context,
          builder: (_) => CupertinoActionSheet(
            actions: [
              CupertinoActionSheetAction(
                child: const Text("Feed Go Expert"),
                onPressed: () async {
                  CustomDialog.loadingDialog(context);
                  final image =
                      await _screenshotController.captureFromWidget(_buildFeed(
                    rank: rank,
                    tingkat: tingkat,
                  ));
                  final directory = await getApplicationDocumentsDirectory();
                  final imagePath =
                      await File('${directory.path}/image.png').create();
                  await imagePath.writeAsBytes(image);
                  final caption =
                      "[FLEXING RANKING]\nHai guys, wah saya ranking $rank $tingkat lohhh.\nJangan mau kalah yaaa";
                  final file64 = base64Encode(imagePath.readAsBytesSync());
                  if (!mounted) return;
                  // TODO : uploadFeed provider masih berada di laporan tryout, untuk kedepannya akan dipisahkan untuk mempermudah dalam development
                  await context.read<LaporanTryoutProvider>().uploadFeed(
                        userId: gNoRegistrasi,
                        content: caption,
                        file64: file64,
                      );
                  if (!mounted) return;
                  gShowTopFlash(
                      context, "Berhasil membuat Feed rangking buku sakti",
                      dialogType: DialogType.success);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
              CupertinoActionSheetAction(
                child: const Text("Aplikasi Lain"),
                onPressed: () async {
                  try {
                    CustomDialog.loadingDialog(context);
                    final image = await _screenshotController.captureFromWidget(
                        _buildFeed(rank: rank, tingkat: tingkat));
                    final directory = await getApplicationDocumentsDirectory();
                    final imagePath =
                        await File('${directory.path}/image.png').create();
                    await imagePath.writeAsBytes(image);
                    const caption = "Flexing Rank Ganss\n\n#Let'sGO";
                    // TODO : shareFiles deprecated harus disesuaikan kembali
                    Share.shareXFiles([XFile(imagePath.path)], text: caption);
                    _navigator.pop();
                  } catch (_) {
                    _navigator.pop();
                    CustomDialog.fatalExceptionDialog(context);
                  }
                },
              )
            ],
            cancelButton: CupertinoActionSheetAction(
              isDefaultAction: true,
              onPressed: () => _navigator.pop(),
              child: const Text('Cancel'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeed({String? rank, String? tingkat}) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        width: 720,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/img/bg-tobk.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            clipBehavior: Clip.antiAlias,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  color: Colors.blue.shade50,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      "assets/img/logo.webp",
                      width: 100,
                    ),
                  ),
                ),
                Icon(
                  CupertinoIcons.rosette,
                  color: Theme.of(context).primaryColor,
                  size: 150,
                ),
                Text(
                  "Ranking $rank $tingkat",
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
