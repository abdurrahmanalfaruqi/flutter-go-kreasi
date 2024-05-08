import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gokreasi_new/core/shared/widget/refresher/custom_smart_refresher.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/leaderboard/leaderboardracing/model/data_ranking.dart';
import 'package:gokreasi_new/features/leaderboard/leaderboardracing/presentation/bloc/leaderboard_racing/leaderboard_racing_bloc.dart';
import 'package:isoweek/isoweek.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/widget/empty/no_data_found.dart';
import '../../../../../../core/shared/widget/loading/loading_widget.dart';
import '../../../../../../core/util/data_formatter.dart';
import '../list_ranking.dart';

class MingguRacing extends StatefulWidget {
  final String level;

  const MingguRacing({super.key, required this.level});
  @override
  State<MingguRacing> createState() => _MingguRacingState();
}

class _MingguRacingState extends State<MingguRacing> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void didUpdateWidget(covariant MingguRacing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!context.isMobile && oldWidget.level != widget.level) {
      currentWeek = Week.current().addWeeks(selisihweek);
      selectedweek = currentWeek;
      tanggaltampil =
          "${DataFormatter.formatDate(currentWeek!.days[0].toString(), 'dd MMM yyyy')} s/d ${DataFormatter.formatDate(currentWeek!.days[6].toString(), 'dd MMM yyyy')}";
      delay();
    }
  }

  int selisihweek = 0;
  Week? currentWeek;
  bool _loading = true;
  bool _hasiltopfive = false;
  bool _hasilmyrank = false;
  Week? selectedweek;
  String? tanggaltampil;
  Timer? _timer;
  DataRanking dataRanking = const DataRanking();
  UserModel? userData;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is LoadedUser) {
      userData = authState.user;
    }
    currentWeek = Week.current().addWeeks(selisihweek);
    selectedweek = currentWeek;
    tanggaltampil =
        "${DataFormatter.formatDate(currentWeek!.days[0].toString(), 'dd MMM yyyy')} s/d ${DataFormatter.formatDate(currentWeek!.days[6].toString(), 'dd MMM yyyy')}";
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
          idSekolahKelas: userData?.idSekolahKelas ?? '',
          idGedung: userData?.idGedung ?? '',
          jenisWaktu: 'minggu',
          level: widget.level,
          noreg: userData?.noRegistrasi ?? '',
          number: selectedweek!.weekNumber,
          penanda: userData?.idKota ?? '',
          idBundlingAktif: userData?.idBundlingAktif,
          isRefresh: isRefresh,
        ));
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    _refreshController.dispose();
  }

  /// [proses] adalah fungsi yang digunakan untuk mengubah kisaran minggu.
  ///
  /// args:
  /// add (bool): boolean, benar jika Anda ingin menambahkan minggu, false jika Anda ingin mengurangi minggu
  void proses(bool add) {
    _timer?.cancel();
    add ? selisihweek++ : selisihweek--;
    setState(() {
      _loading = true;
      _hasiltopfive = false;
      _hasilmyrank = false;
      selectedweek = currentWeek!.addWeeks(selisihweek);
      tanggaltampil =
          "${DataFormatter.formatDate(selectedweek!.days[0].toString(), 'dd MMM yyyy')} s/d ${DataFormatter.formatDate(selectedweek!.days[6].toString(), 'dd MMM yyyy')}";
    });

    getdata();
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
                        child: (dataRanking.myRank?.isEmpty == true &&
                                dataRanking.topFive?.isEmpty == true)
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
