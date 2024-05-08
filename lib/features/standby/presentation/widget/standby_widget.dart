import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/jadwal/presentation/bloc/standby/standby_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../model/standby_model.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/shared/widget/card/custom_card.dart';
import '../../../../core/shared/widget/empty/basic_empty.dart';
import '../../../../core/shared/widget/separator/dash_divider.dart';
import '../../../../core/shared/widget/loading/shimmer_list_tiles.dart';
import '../../../../core/shared/widget/expanded/custom_expansion_tile.dart';
import '../../../../core/shared/widget/refresher/custom_smart_refresher.dart';

class StandbyWidget extends StatefulWidget {
  const StandbyWidget({Key? key}) : super(key: key);

  @override
  State<StandbyWidget> createState() => _StandbyWidgetState();
}

class _StandbyWidgetState extends State<StandbyWidget> {
  final RefreshController _refreshControllerToday =
      RefreshController(initialRefresh: false);
  final RefreshController _refreshControllerTomorrow =
      RefreshController(initialRefresh: false);
  UserModel? userData;
  List<StandbyModel> snapStandby = [];

  _refreshShceduleTST() {
    context.read<StandbyBloc>().add(
          LoadStandby(userData: userData),
        );
  }

  Future<void> _requestTST({
    required String planId,
    required int idMataPelajaran,
  }) async {
    context.read<StandbyBloc>().add(RequestTST(
          params: {
            "id_rencana": int.parse(planId),
            "no_register": userData?.noRegistrasi,
            "id_mata_pelajaran": idMataPelajaran,
            "tingkat_kelas": int.tryParse(userData?.tingkatKelas ?? '0'),
            "tahun_ajaran": userData?.tahunAjaran,
          },
          userData: userData,
          planId: planId,
        ));
  }

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is LoadedUser) {
      userData = authState.user;
    }
    _refreshShceduleTST();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StandbyBloc, StandbyState>(
      builder: (context, state) {
        Widget basicEmpty = BasicEmpty(
          shrink: (context.dh < 600) ? !context.isMobile : false,
          imageUrl: 'ilustrasi_tst.png'.illustration,
          title: 'Jadwal TST',
          subTitle: 'TST Super Belum tersedia',
          emptyMessage: 'Saat ini sedang tidak ada jadwal TST untuk kamu sobat',
        );

        if (state is StandbyLoading) {
          return const ShimmerListTiles();
        }

        if (state is StandbyError) {
          return basicEmpty;
        }

        if (state is StandbyDataLoaded) {
          snapStandby = state.listStandby;
        }

        return (snapStandby.isEmpty)
            ? basicEmpty
            : DefaultTabController(
                initialIndex: 0,
                length: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        top: context.dp(16),
                        right: context.dp(16),
                        left: context.dp(16),
                      ),
                      decoration: BoxDecoration(
                          color: context.background,
                          borderRadius: BorderRadius.circular(300),
                          boxShadow: const [
                            BoxShadow(
                                offset: Offset(0, 2),
                                blurRadius: 4,
                                color: Colors.black26)
                          ]),
                      child: TabBar(
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: context.background,
                        indicatorColor: context.primaryColor,
                        labelStyle: context.text.bodyMedium,
                        unselectedLabelStyle: context.text.bodyMedium,
                        unselectedLabelColor: context.onBackground,
                        splashBorderRadius: BorderRadius.circular(300),
                        indicator: BoxDecoration(
                            color: context.primaryColor,
                            borderRadius: BorderRadius.circular(300)),
                        indicatorPadding: EdgeInsets.zero,
                        labelPadding: EdgeInsets.zero,
                        tabs: const [Tab(text: 'Hari ini'), Tab(text: 'Besok')],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildSchedule(
                            context,
                            snapStandby,
                            0,
                            _refreshControllerToday,
                          ),
                          _buildSchedule(
                            context,
                            snapStandby,
                            1,
                            _refreshControllerTomorrow,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
      },
    );
  }

  Widget _buildSchedule(
    BuildContext context,
    List<StandbyModel> snapStandby,
    int selectedTabIndex,
    RefreshController refreshController,
  ) {
    Widget basicEmpty = BasicEmpty(
      shrink: (context.dh < 600) ? !context.isMobile : false,
      imageUrl: 'ilustrasi_tst.png'.illustration,
      title: 'Jadwal TST',
      subTitle: 'Tidak Ada Jadwal TST',
      emptyMessage: 'Saat ini sedang tidak ada pengajar yang standby sobat',
    );

    return CustomSmartRefresher(
      controller: refreshController,
      onRefresh: _refreshShceduleTST,
      isDark: true,
      child: snapStandby[selectedTabIndex].teachers!.isEmpty
          ? ((context.isMobile || context.dh > 600)
              ? basicEmpty
              : SingleChildScrollView(
                  child: basicEmpty,
                ))
          : ListView.builder(
              itemCount: snapStandby[selectedTabIndex].teachers!.length,
              itemBuilder: (context, index) {
                final listTeacher = snapStandby[selectedTabIndex].teachers;
                final teacher = listTeacher![index];

                return Column(
                  children: [
                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: CustomExpansionTile(
                        title: Text(teacher.name!.toTitleCase()),
                        subtitle: (teacher.schedule != null &&
                                teacher.schedule?.isNotEmpty == true)
                            ? Text("${teacher.schedule?.first.teacherId}")
                            : null,
                        children:
                            List.generate(teacher.schedule!.length, (index) {
                          final schedule = teacher.schedule![index];
                          return BlocBuilder<StandbyBloc, StandbyState>(
                            builder: (context, state) {
                              bool isLoadingRequestTST =
                                  state is RequestTSTLoading &&
                                      state.planId == schedule.planId;
                              return _buildCard(
                                context,
                                schedule,
                                teacher.lesson!,
                                teacher.name!,
                                teacher.idMataPelajaran ?? 0,
                                isLoadingRequestTST,
                              );
                            },
                          );
                        }),
                      ),
                    ),
                    const Divider()
                  ],
                );
              },
            ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    StandbyScheduleModel schedule,
    String lesson,
    String teacher,
    int idMataPelajaran,
    bool isLoadingRequestTST,
  ) {
    return CustomCard(
      elevation: 3,
      margin: EdgeInsets.symmetric(
        horizontal: context.dp(18),
        vertical: context.dp(8),
      ),
      borderRadius: BorderRadius.circular(24),
      padding: EdgeInsets.only(
          top: context.dp(10),
          left: context.dp(10),
          right: context.dp(10),
          bottom: context.dp(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, schedule, idMataPelajaran, isLoadingRequestTST),
          const Divider(
            height: 24,
            thickness: 1,
            color: Colors.black12,
          ),
          IntrinsicHeight(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: (context.isMobile) ? 46 : 112),
              child: Row(
                children: [
                  _buildWaktuKegiatan(context, schedule),
                  _buildInformasiKegiatan(context, schedule, lesson, teacher),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Expanded _buildInformasiKegiatan(BuildContext context,
      StandbyScheduleModel schedule, String lesson, String teacher) {
    return Expanded(
      flex: 5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            maxLines: 1,
            overflow: TextOverflow.fade,
            textScaler: TextScaler.linear(context.textScale12),
            text: TextSpan(
              text: 'Lokasi: ',
              style: context.text.labelMedium,
              children: [
                TextSpan(
                    text: schedule.buildingName,
                    style: context.text.labelMedium
                        ?.copyWith(color: context.hintColor))
              ],
            ),
          ),
          // const SizedBox(height: 4),
          // RichText(
          //   maxLines: 1,
          //   overflow: TextOverflow.fade,
          //   textScaler: TextScaler.linear(context.textScale12),
          //   text: TextSpan(
          //     text: 'Mata Pelajaran: ',
          //     style: context.text.labelMedium,
          //     children: [
          //       TextSpan(
          //           text: lesson,
          //           style: context.text.labelMedium
          //               ?.copyWith(color: context.hintColor))
          //     ],
          //   ),
          // ),
          const SizedBox(height: 4),
          Text(
            'Pengajar:',
            style: context.text.labelMedium,
            maxLines: 1,
            overflow: TextOverflow.fade,
          ),
          const SizedBox(height: 4),
          Text(
            teacher,
            style: context.text.labelMedium?.copyWith(color: context.hintColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            schedule.teacherId ?? '-',
            style: context.text.bodySmall?.copyWith(color: context.hintColor),
            maxLines: 1,
            overflow: TextOverflow.fade,
          ),
        ],
      ),
    );
  }

  Expanded _buildWaktuKegiatan(
      BuildContext context, StandbyScheduleModel schedule) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: EdgeInsets.only(right: context.dp(6)),
        child: Column(
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: context.secondaryColor,
                borderRadius: BorderRadius.circular(300),
                boxShadow: [
                  BoxShadow(
                      offset: const Offset(-1, -1),
                      blurRadius: 4,
                      spreadRadius: 2,
                      color: context.secondaryContainer.withOpacity(0.87)),
                  BoxShadow(
                      offset: const Offset(1, 1),
                      blurRadius: 4,
                      spreadRadius: 2,
                      color: context.secondaryContainer.withOpacity(0.87)),
                ],
              ),
              child: Text(
                schedule.start!,
                style: context.text.labelMedium,
              ),
            ),
            Expanded(
              flex: 2,
              child: DashedDivider(
                dashColor: context.disableColor,
                strokeWidth: 1,
                dash: 6,
                direction: Axis.vertical,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: context.secondaryColor,
                borderRadius: BorderRadius.circular(300),
                boxShadow: [
                  BoxShadow(
                      offset: const Offset(-1, -1),
                      blurRadius: 4,
                      spreadRadius: 1,
                      color: context.secondaryContainer.withOpacity(0.87)),
                  BoxShadow(
                      offset: const Offset(1, 1),
                      blurRadius: 4,
                      spreadRadius: 1,
                      color: context.secondaryContainer.withOpacity(0.87)),
                ],
              ),
              child: Text(schedule.finish!, style: context.text.labelMedium),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Row _buildHeader(
    BuildContext context,
    StandbyScheduleModel schedule,
    int idMataPelajaran,
    bool isLoadingRequestTST,
  ) {
    return Row(
      children: [
        _buildIconJadwal(context),
        Expanded(
          child: Row(
            children: [
              Text(
                schedule.activity!,
                style: context.text.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              (schedule.registered == 'BELUM')
                  ? InkWell(
                      onTap: () async {
                        // if (!schedule.isTST!) {
                        //   gShowBottomDialog(
                        //     context,
                        //     message:
                        //         "Sobat orang pertama yang mengajukan tst\nBersedia menjadi ketua?",
                        //     actions: (controller) => [
                        //       TextButton(
                        //         onPressed: () async {
                        //           controller.dismiss(true);
                        //           await _requestTST(
                        //             planId: schedule.planId!,
                        //             idMataPelajaran: idMataPelajaran,
                        //           );

                        //           await Future.delayed(gDelayedNavigation);

                        //           // ignore: use_build_context_synchronously
                        //           gShowTopFlash(
                        //             context,
                        //             'Yeey, kamu berhasil mengajukan TST Sobat',
                        //             dialogType: DialogType.success,
                        //           );
                        //         },
                        //         child: const Text('Ya'),
                        //       ),
                        //       TextButton(
                        //         onPressed: () async {
                        //           controller.dismiss(true);
                        //           gShowTopFlash(
                        //             context,
                        //             'Oke, Sobat harus menunggu sampai ada yang bersedia menjadi Ketua TST',
                        //             dialogType: DialogType.info,
                        //           );
                        //         },
                        //         child: const Text('Tidak'),
                        //       )
                        //     ],
                        //   );
                        // } else {
                        //   await _requestTST(
                        //     planId: schedule.planId!,
                        //     idMataPelajaran: idMataPelajaran,
                        //   );

                        //   await Future.delayed(gDelayedNavigation);

                        //   // ignore: use_build_context_synchronously
                        //   gShowTopFlash(
                        //     context,
                        //     'Yeey, kamu berhasil mengajukan TST Sobat',
                        //     dialogType: DialogType.success,
                        //   );
                        // }

                        if (isLoadingRequestTST) return;

                        await _requestTST(
                          planId: schedule.planId!,
                          idMataPelajaran: idMataPelajaran,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: (isLoadingRequestTST) ? 40 : 10,
                            vertical: (isLoadingRequestTST) ? 9 : 6),
                        decoration: BoxDecoration(
                            color: context.primaryColor,
                            borderRadius: BorderRadius.circular(300),
                            boxShadow: [
                              BoxShadow(
                                  offset: const Offset(-1, -1),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                  color: context.primaryColor.withOpacity(0.1)),
                              BoxShadow(
                                  offset: const Offset(1, 1),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                  color: context.primaryColor.withOpacity(0.1))
                            ]),
                        child: (isLoadingRequestTST)
                            ? const SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                !schedule.isTST! ? 'Ajukan TST' : 'Gabung TST',
                                style: context.text.labelMedium
                                    ?.copyWith(color: context.background),
                              ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: context.disableColor,
                        borderRadius: BorderRadius.circular(300),
                        boxShadow: [
                          BoxShadow(
                              offset: const Offset(-1, -1),
                              blurRadius: 4,
                              spreadRadius: 1,
                              color: context.disableColor.withOpacity(0.1)),
                          BoxShadow(
                            offset: const Offset(1, 1),
                            blurRadius: 4,
                            spreadRadius: 1,
                            color: context.disableColor.withOpacity(0.1),
                          ),
                        ],
                      ),
                      child: Text(
                        "${schedule.registered!} TST",
                        style: context.text.labelMedium
                            ?.copyWith(color: context.background),
                      ),
                    )
            ],
          ),
        ),
      ],
    );
  }

  Container _buildIconJadwal(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      margin: EdgeInsets.only(right: context.dp(12)),
      decoration: BoxDecoration(
          color: context.tertiaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                offset: const Offset(-1, -1),
                blurRadius: 4,
                spreadRadius: 1,
                color: context.tertiaryColor.withOpacity(0.42)),
            BoxShadow(
                offset: const Offset(1, 1),
                blurRadius: 4,
                spreadRadius: 1,
                color: context.tertiaryColor.withOpacity(0.42))
          ]),
      child: Icon(
        Icons.schedule,
        size: context.dp(32),
        color: context.onTertiary,
        semanticLabel: 'ic_jadwal_siswa',
      ),
    );
  }
}
