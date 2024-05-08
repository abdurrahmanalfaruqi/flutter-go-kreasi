import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gokreasi_new/core/shared/widget/refresher/custom_smart_refresher.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/leaderboard/leaderboardracing/model/data_ranking.dart';
import 'package:gokreasi_new/features/leaderboard/leaderboardracing/presentation/bloc/leaderboard_racing/leaderboard_racing_bloc.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../list_ranking.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/widget/empty/no_data_found.dart';
import '../../../../../../core/shared/widget/loading/loading_widget.dart';

class BulanRacing extends StatefulWidget {
  final String? level;

  const BulanRacing({super.key, @required this.level});
  @override
  State<BulanRacing> createState() => _BulanRacing();
}

class _BulanRacing extends State<BulanRacing> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void didUpdateWidget(covariant BulanRacing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!context.isMobile && oldWidget.level != widget.level) {
      now = DateTime.now();
      var formatter = DateFormat('MMM yyyy');
      currentmonth = now!.month;
      selectedmonth = currentmonth;
      tanggaltampil = formatter.format(now!);
      delay();
    }
  }

  int selisihmonth = 0;
  int? currentmonth;
  bool _loading = true;
  bool _hasiltopfive = false;
  bool _hasilmyrank = false;
  int? selectedmonth;
  String? tanggaltampil;
  Timer? _timer;
  DateTime? now;
  DataRanking dataRanking = const DataRanking();

  UserModel? userData;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is LoadedUser) {
      userData = authState.user;
    }
    now = DateTime.now();
    var formatter = DateFormat('MMM yyyy');
    currentmonth = now!.month;
    selectedmonth = currentmonth;
    tanggaltampil = formatter.format(now!);
    getdata();
  }

  delay() {
    _timer = Timer(const Duration(milliseconds: 300), () {
      getdata();
    });
  }

  /// [getdata] adalah fungsi untuk mendapatkan data dari API.
  void getdata({bool isRefresh = false}) async {
    context.read<LeaderboardRacingBloc>().add(LoadLeaderBoardRacing(
          noreg: userData?.noRegistrasi ?? '',
          idSekolahKelas: userData?.idSekolahKelas ?? '',
          number: selectedmonth!,
          level: widget.level!,
          penanda: userData?.idKota ?? '',
          idGedung: userData?.idGedung ?? '',
          jenisWaktu: 'bulan',
          idBundlingAktif: userData?.idBundlingAktif,
          isRefresh: isRefresh,
        ));
  }

  /// [proses] adalah fungsi yang digunakan untuk mengubah kisaran bulan.
  ///
  /// args:
  /// add (bool): boolean, jika benar, bulan akan ditambahkan, jika false, bulan akan dikurangi
  void proses(bool add) {
    _timer?.cancel();
    add ? selisihmonth++ : selisihmonth--;
    setState(() {
      var jiffy = Jiffy.now().add(months: selisihmonth);
      _loading = true;
      _hasiltopfive = false;
      _hasilmyrank = false;
      selectedmonth = Jiffy.now().add(months: selisihmonth).month;
      tanggaltampil = jiffy.format(pattern: 'MMM yyyy');
    });

    getdata();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    _refreshController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeaderboardRacingBloc, LeaderboardRacingState>(
      builder: (context, state) {
        _loading = state.status == LeaderBoardRacingStatus.loading;
        dataRanking = state.dataRanking ?? const DataRanking();
        _hasiltopfive = dataRanking.topFive != null &&
            dataRanking.topFive?.isNotEmpty == true;
        _hasilmyrank = dataRanking.myRank != null &&
            dataRanking.myRank?.isNotEmpty == true;

        bool isDataRankingEmpty = (dataRanking.myRank == null ||
                dataRanking.myRank?.isEmpty == true) &&
            (dataRanking.topFive == null ||
                dataRanking.topFive?.isEmpty == true);

        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              padding: EdgeInsets.only(
                  left: context.dp(20),
                  right: context.dp(20),
                  bottom: context.dp(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                      onTap: () => proses(false),
                      child: Icon(
                        Icons.arrow_circle_left_outlined,
                        size: 24,
                        color: (context.isMobile)
                            ? context.background
                            : Colors.black,
                      )),
                  Text(
                    tanggaltampil!,
                    style: context.text.bodyMedium?.copyWith(
                      color: (context.isMobile)
                          ? context.background
                          : Colors.black,
                    ),
                  ),
                  InkWell(
                    onTap: () => proses(true),
                    child: Icon(
                      Icons.arrow_circle_right_outlined,
                      size: 24,
                      color: (context.isMobile)
                          ? context.background
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: context.dw,
                padding: const EdgeInsets.only(right: 12, left: 12),
                decoration: BoxDecoration(
                  color: context.background,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                  ),
                ),
                child: _loading
                    ? const LoadingWidget()
                    : CustomSmartRefresher(
                        controller: _refreshController,
                        isDark: true,
                        onRefresh: () {
                          getdata(isRefresh: true);
                          _refreshController.refreshCompleted();
                        },
                        child: (isDataRankingEmpty)
                            ? SingleChildScrollView(
                                child: SizedBox(
                                  height: context.dh / 1.6,
                                  child: NoDataFoundWidget(
                                      imageUrl:
                                          '${dotenv.env["BASE_URL_IMAGE"]}/arsip-mobile/img/ilustrasi_data_not_found.png',
                                      subTitle: "Leaderboard Racing",
                                      isLandscape: !context.isMobile,
                                      emptyMessage:
                                          "Data masih kosong, ayo kerjakan soal racing Sobat"),
                                ),
                              )
                            : SingleChildScrollView(
                                child: Container(
                                  width: context.dw,
                                  padding: EdgeInsets.only(top: context.pd),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: context.pd,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width:
                                                  (context.isMobile) ? 40 : 50,
                                              child: Text(
                                                "Rank",
                                                style: context.text.bodySmall
                                                    ?.copyWith(
                                                        color:
                                                            context.hintColor),
                                              ),
                                            ),
                                            Expanded(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Nama Siswa",
                                                    style: context
                                                        .text.bodySmall
                                                        ?.copyWith(
                                                            color: context
                                                                .hintColor),
                                                  ),
                                                  Text(
                                                    "Skor",
                                                    style: context
                                                        .text.bodySmall
                                                        ?.copyWith(
                                                            color: context
                                                                .hintColor),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      _hasiltopfive
                                          ? LeaderboardRacingListRank(
                                              context: context,
                                              dataRanking:
                                                  dataRanking.topFive ?? [])
                                          : Text(
                                              "Data kosong",
                                              style: context.text.bodyMedium
                                                  ?.copyWith(
                                                      color: context.hintColor),
                                            ),
                                      SizedBox(
                                        height: 50,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            const Expanded(child: Divider()),
                                            Container(
                                              constraints: BoxConstraints(
                                                  maxWidth: context.dw - 32),
                                              padding: const EdgeInsets.only(
                                                  right: 12, left: 12),
                                              child: Text(
                                                "Ranking Terdekat",
                                                style: context.text.titleMedium
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const Expanded(child: Divider()),
                                          ],
                                        ),
                                      ),
                                      _hasilmyrank
                                          ? LeaderboardRacingListRank(
                                              context: context,
                                              dataRanking:
                                                  dataRanking.myRank ?? [])
                                          : Text(
                                              "Data kosong",
                                              style: context.text.bodyMedium
                                                  ?.copyWith(
                                                      color: context.hintColor),
                                            )
                                    ],
                                  ),
                                ),
                              ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
