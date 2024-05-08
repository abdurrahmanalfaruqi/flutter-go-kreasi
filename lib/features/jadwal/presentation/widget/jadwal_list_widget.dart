import 'dart:math';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gokreasi_new/core/config/global.dart';
import 'package:gokreasi_new/core/shared/widget/card/custom_card.dart';
import 'package:gokreasi_new/core/shared/widget/empty/no_data_found.dart';
import 'package:gokreasi_new/core/shared/widget/loading/shimmer_widget.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/jadwal/presentation/bloc/jadwal_kbm/jadwal_kbm_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'jadwal_item_widget.dart';
import '../../domain/entity/jadwal_siswa.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/shared/widget/refresher/custom_smart_refresher.dart';

class JadwalListWidget extends StatefulWidget {
  const JadwalListWidget({Key? key}) : super(key: key);

  @override
  State<JadwalListWidget> createState() => _JadwalListWidgetState();
}

class _JadwalListWidgetState extends State<JadwalListWidget> {
  // final RefreshController _refreshController =
  //     RefreshController(initialRefresh: false);
  final ItemScrollController _dateScrollController = ItemScrollController();
  final List<RefreshController> _refreshControllers =
      List<RefreshController>.generate(
          16, (index) => RefreshController(initialRefresh: false));

  UserModel? userData;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is LoadedUser) {
      userData = authState.user;
    }

    _onRefreshJadwalPengajar(isEmpty: true, isRefresh: false);
  }

  @override
  void dispose() {
    // ignore: avoid_function_literals_in_foreach_calls
    _refreshControllers.forEach((controller) {
      controller.dispose();
    });

    super.dispose();
  }

  Future<void> _onRefreshJadwalPengajar({
    bool isRefresh = true,
    bool isEmpty = false,
  }) async {
    if (isEmpty) {
      context.read<JadwalKBMBloc>().add(GetTanggalKBM(
            isRefresh: isRefresh,
            userData: userData,
          ));
    } else {
      context.read<JadwalKBMBloc>().add(GetJadwalByTanggal(
            userData: userData,
            isRefresh: isRefresh,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JadwalKBMBloc, JadwalKBMState>(
      builder: (context, state) {
        if (state.status == JadwalKBMStatus.loadingTanggal) {
          return _buildLoadingWidget(context);
        }

        return _buildJadwalByTanggal(state.listTanggalKBM ?? []);
      },
    );
  }

  Widget _buildJadwalByTanggal(List<InfoJadwal> listJadwalSiswa) =>
      NestedScrollView(
        physics: const BouncingScrollPhysics(),
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildDatePicker(
            context,
            listJadwalSiswa: listJadwalSiswa,
          ),
        ],
        body: BlocSelector<JadwalKBMBloc, JadwalKBMState, JadwalKBMState>(
          selector: (state) => state,
          builder: (context, state) {
            if (state.status == JadwalKBMStatus.loadingJadwal) {
              return _buildLoadingWidget(context, true);
            }

            int indexSelectedInfo = listJadwalSiswa.indexWhere((infoJadwal) =>
                infoJadwal.tanggal.day == state.selectedDate?.day &&
                infoJadwal.tanggal.month == state.selectedDate?.month &&
                infoJadwal.tanggal.year == state.selectedDate?.year);

            InfoJadwal? selectedInfoJadwal = (indexSelectedInfo < 0)
                ? null
                : listJadwalSiswa[indexSelectedInfo];

            return PageTransitionSwitcher(
              duration: const Duration(milliseconds: 600),
              reverse: state.isReverseTransition,
              transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                return SharedAxisTransition(
                  fillColor: Colors.transparent,
                  animation: primaryAnimation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.horizontal,
                  child: child,
                );
              },
              child: (indexSelectedInfo < 0 ||
                      selectedInfoJadwal == null ||
                      (state.status == JadwalKBMStatus.error &&
                          selectedInfoJadwal.daftarJadwalSiswa.isEmpty))
                  ? CustomSmartRefresher(
                      key: ValueKey(
                          'jadwal_empty_${state.selectedDate?.displayDDMMMMYYYY}'),
                      controller: _refreshControllers.last,
                      onRefresh: () => _onRefreshJadwalPengajar(isEmpty: true),
                      isDark: true,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: NoDataFoundWidget(
                            imageUrl:
                                '${dotenv.env["BASE_URL_IMAGE"]}/arsip-mobile/img/ilustrasi_data_not_found.png',
                            shrink: true,
                            subTitle: 'Tidak Ada Jadwal',
                            emptyMessage:
                                '${state.selectedDate?.displayEDDMMMMYYYY} tidak ditemukan jadwal KBM untuk kamu, sobat'),
                      ),
                    )
                  : CustomSmartRefresher(
                      key: ValueKey(
                          'jadwal_${state.selectedDate?.displayDDMMMMYYYY}'),
                      controller: _refreshControllers[indexSelectedInfo],
                      isDark: true,
                      onRefresh: _onRefreshJadwalPengajar,
                      child: ListView.builder(
                        cacheExtent: 4,
                        itemCount: selectedInfoJadwal.daftarJadwalSiswa.length,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 80),
                        itemBuilder: (context, index) {
                          final jadwal =
                              selectedInfoJadwal.daftarJadwalSiswa[index];
                          return JadwalItemWidget(
                            jadwal: jadwal,
                          );
                        },
                      ),
                    ),
            );
          },
        ),
      );

  SliverAppBar _buildDatePicker(
    BuildContext context, {
    required List<InfoJadwal> listJadwalSiswa,
  }) {
    return SliverAppBar(
      snap: true,
      floating: true,
      centerTitle: false,
      automaticallyImplyLeading: false,
      toolbarHeight: (context.isMobile) ? context.dp(100) : 64,
      surfaceTintColor: context.background,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: BlocBuilder<JadwalKBMBloc, JadwalKBMState>(
          builder: (context, state) {
            final int indexToday = state.indexToday;

            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(min(context.ts, 1.2))),
              child: ScrollablePositionedList.builder(
                initialAlignment: 0.5,
                physics: const BouncingScrollPhysics(),
                itemScrollController: _dateScrollController,
                initialScrollIndex: (indexToday < 0) ? 0 : indexToday,
                padding: EdgeInsets.only(
                  top: min(14, context.dp(10)),
                  left: min(22, context.dp(18)),
                  right: min(22, context.dp(18)),
                  bottom: min(52, context.dp(48)),
                ),
                scrollDirection: Axis.horizontal,
                itemCount: state.weekDays.length,
                itemBuilder: (context, index) {
                  final DateTime dateTime = state.weekDays[index];
                  final bool isToday = index == indexToday;

                  final bool isSelected =
                      dateTime.day == state.selectedDate?.day &&
                          dateTime.month == state.selectedDate?.month &&
                          dateTime.year == state.selectedDate?.year;

                  final int indexInfo = listJadwalSiswa.indexWhere(
                      (infoJadwal) =>
                          infoJadwal.tanggal.day == dateTime.day &&
                          infoJadwal.tanggal.month == dateTime.month &&
                          infoJadwal.tanggal.year == dateTime.year);

                  final InfoJadwal? infoJadwal =
                      (indexInfo < 0) ? null : listJadwalSiswa[indexInfo];

                  bool isNotActive = indexInfo < 0 || infoJadwal == null;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        (isSelected)
                            ? 300
                            : (context.isMobile)
                                ? 18
                                : 26,
                      ),
                      onTap: () {
                        if (isNotActive) {
                          gShowBottomDialogInfo(
                            context,
                            title: 'Tidak ada jadwal pada'
                                ' ${dateTime.displayEDDMMMMYYYY}',
                            message:
                                'Saat ini tidak ditemukan jadwal KBM untuk kamu, sobat. ',
                          );
                        } else {
                          if (state.selectedDate?.isAtSameMomentAs(dateTime) ==
                              false) {
                            context
                                .read<JadwalKBMBloc>()
                                .add(SetSelectedDate(dateTime));
                            context
                                .read<JadwalKBMBloc>()
                                .add(GetJadwalByTanggal(
                                  userData: userData,
                                  isRefresh: false,
                                ));
                          }
                        }
                      },
                      child: AnimatedContainer(
                        width: min(68, context.dp(50)),
                        curve: Curves.easeIn,
                        duration: const Duration(milliseconds: 400),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: (isNotActive)
                              ? context.disableColor
                              : (isSelected)
                                  ? context.primaryColor
                                  : (isToday)
                                      ? context.primaryContainer
                                      : null,
                          border: Border.all(color: context.outline),
                          borderRadius: BorderRadius.all(
                            (isSelected)
                                ? Radius.circular(max(context.dp(24), 24))
                                : Radius.circular((context.isMobile)
                                    ? max(context.dp(18), 18)
                                    : 26),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat.E('ID').format(dateTime),
                              style: context.text.labelSmall?.copyWith(
                                  color: (isNotActive)
                                      ? context.disableColor
                                      : (isSelected)
                                          ? context.onPrimary
                                          : (isToday)
                                              ? context.onPrimaryContainer
                                              : context.onBackground),
                            ),
                            FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Text(
                                DateFormat.d('ID').format(dateTime),
                                style: context.text.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Montserrat',
                                    color: (isNotActive)
                                        ? context.disableColor
                                        : (isSelected)
                                            ? context.onPrimary
                                            : (isToday)
                                                ? context.onPrimaryContainer
                                                : context.onBackground),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size(
          double.infinity,
          (context.isMobile) ? max(32, context.dp(32)) : 96,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(indent: 24, endIndent: 24, thickness: 1),
            Padding(
              padding: EdgeInsets.only(
                left: min(48, context.dp(24)),
                right: min(32, context.dp(24)),
                bottom: min(14, context.dp(12)),
              ),
              child:
                  BlocSelector<JadwalKBMBloc, JadwalKBMState, JadwalKBMState>(
                selector: (state) => state,
                builder: (context, state) {
                  if (state.status == JadwalKBMStatus.loadingTanggal) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(right: 158),
                          child: ShimmerWidget.rounded(
                            width: 211,
                            height: 16,
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ],
                    );
                  }

                  int indexSelectedInfo = listJadwalSiswa.indexWhere(
                      (infoJadwal) =>
                          infoJadwal.tanggal.day == state.selectedDate?.day &&
                          infoJadwal.tanggal.month ==
                              state.selectedDate?.month &&
                          infoJadwal.tanggal.year == infoJadwal.tanggal.year);

                  InfoJadwal? selectedInfoJadwal = (indexSelectedInfo < 0)
                      ? null
                      : listJadwalSiswa[indexSelectedInfo];

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    layoutBuilder: (currentChild, previousChildren) => Stack(
                      alignment: Alignment.centerLeft,
                      children: [...previousChildren, currentChild!],
                    ),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0.0, -1.0),
                          end: const Offset(0.0, 0.0),
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: Text(
                      '${selectedInfoJadwal?.daftarJadwalSiswa.length ?? 0} jadwal pada ${state.selectedDate?.displayDDMMMMYYYY}',
                      key: ValueKey('${state.selectedDate?.displayDDMMMMYYYY}-'
                          '${selectedInfoJadwal?.daftarJadwalSiswa.length ?? 0}'),
                      style: context.text.bodySmall
                          ?.copyWith(color: context.hintColor),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListView _buildLoadingWidget(
    BuildContext context, [
    bool isLoadingJadwalByTanggal = false,
  ]) {
    return ListView(
      cacheExtent: 4,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        top: 4,
        bottom: context.dp(32),
      ),
      children: [
        if (!isLoadingJadwalByTanggal) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List<Widget>.generate(
                  (context.isMobile)
                      ? 6
                      : (context.dw < 1200)
                          ? 8
                          : 12,
                  (index) => ShimmerWidget.rounded(
                        width: (context.isMobile)
                            ? (context.dw / 6) - 16
                            : (context.dw / ((context.dw < 1200) ? 12 : 16)) -
                                20,
                        height: (context.isMobile) ? 67 : 82,
                        borderRadius: BorderRadius.circular(14),
                      )),
            ),
          ),
          const Divider(indent: 24, endIndent: 24),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 158),
            child: ShimmerWidget.rounded(
              width: 211,
              height: 16,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ],
        const SizedBox(height: 12),
        ...List<Widget>.generate(
          6,
          (index) => CustomCard(
            padding: EdgeInsets.all((context.isMobile) ? 12 : 20),
            margin: EdgeInsets.only(
                left: (context.isMobile) ? context.dp(24) : context.dw * 0.1,
                right: (context.isMobile) ? context.dp(24) : context.dw * 0.1,
                bottom: 16),
            borderRadius: (context.isMobile)
                ? BorderRadius.circular(36)
                : BorderRadius.circular(54),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const ShimmerWidget.circle(width: 40, height: 40),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerWidget.rounded(
                          width: 235,
                          height: 20,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        const SizedBox(height: 2),
                        ShimmerWidget.rounded(
                          width: 86,
                          height: 16,
                          borderRadius: BorderRadius.circular(14),
                        )
                      ],
                    ),
                  ],
                ),
                const Divider(height: 20),
                ShimmerWidget.rounded(
                  width: 112,
                  height: 16,
                  borderRadius: BorderRadius.circular(14),
                ),
                const SizedBox(height: 4),
                ShimmerWidget.rounded(
                  width: 147,
                  height: 16,
                  borderRadius: BorderRadius.circular(14),
                ),
                const SizedBox(height: 8),
                ShimmerWidget.rounded(
                  width: 112,
                  height: 16,
                  borderRadius: BorderRadius.circular(14),
                ),
                const SizedBox(height: 2),
                ShimmerWidget.rounded(
                  width: 152,
                  height: 20,
                  borderRadius: BorderRadius.circular(14),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ShimmerWidget.rounded(
                        width: double.infinity,
                        height: 36,
                        borderRadius: BorderRadius.circular(300),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ShimmerWidget.rounded(
                        width: double.infinity,
                        height: 36,
                        borderRadius: BorderRadius.circular(300),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
