import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/core/shared/widget/refresher/custom_smart_refresher.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/laporan/module/presensi/presentation/bloc/laporan_presensi/presensi_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../model/laporan_presensi.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/constant.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/util/data_formatter.dart';
import '../../../../../../core/shared/widget/card/custom_card.dart';
import '../../../../../../core/shared/widget/empty/basic_empty.dart';
import '../../../../../../core/shared/widget/loading/loading_widget.dart';
import '../../../../../../core/shared/widget/separator/dash_divider.dart';

class LaporanPresensiWidget extends StatefulWidget {
  final UserModel? userData;
  const LaporanPresensiWidget({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  State<LaporanPresensiWidget> createState() => _LaporanPresensiWidgetState();
}

class _LaporanPresensiWidgetState extends State<LaporanPresensiWidget> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final RefreshController _emptyRefreshController =
      RefreshController(initialRefresh: false);

  final ValueNotifier<DateTime> _currentDate = ValueNotifier(DateTime.now());
  DateTime tempDate = DateTime.now();

  /// [_refreshPresensi] fungsi yang digunakan untuk menyegarkan data yang ditampilkan di layar.
  _refreshPresensi({bool isRefresh = true}) {
    context.read<PresensiBloc>().add(LoadPresensiByTanggal(
          noRegistrasi: widget.userData?.noRegistrasi ?? '',
          idBundlingAktif: widget.userData?.idBundlingAktif ?? 0,
          tanggal:
              DataFormatter.dateTimeToString(_currentDate.value, 'yyyy-MM-dd'),
          isRefresh: isRefresh,
        ));
  }

  @override
  void initState() {
    super.initState();
    _refreshPresensi(isRefresh: false);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _emptyRefreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPresensiDatePicker(),
        Expanded(
          child: BlocBuilder<PresensiBloc, PresensiState>(
            builder: (context, state) {
              if (state.status == PresensiStatus.loading) {
                return const LoadingWidget();
              }

              if (state.status == PresensiStatus.success &&
                  state.listJadwalPresence?.isNotEmpty == true) {
                return Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Expanded(
                        child: Container(
                          color: Colors.transparent,
                          child: CustomSmartRefresher(
                            controller: _refreshController,
                            onRefresh: _refreshPresensi,
                            isDark: true,
                            child:
                                _buildListPresence(state.listJadwalPresence!),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }

              return CustomSmartRefresher(
                controller: _emptyRefreshController,
                isDark: true,
                onRefresh: _refreshPresensi,
                child: SizedBox(
                  height: (context.isMobile)
                      ? context.dh - 200
                      : context.dh > 600
                          ? context.dh
                          : context.dh * 1.2,
                  child: ValueListenableBuilder<DateTime>(
                      valueListenable: _currentDate,
                      builder: (context, dateTime, _) {
                        return BasicEmpty(
                            shrink: false,
                            imageUrl:
                                'ilustrasi_laporan_presensi.png'.illustration,
                            title: 'Laporan Presensi',
                            subTitle: "Data tidak ditemukan",
                            emptyMessage:
                                "Sobat belum hadir dan memindai QR-Code presensi "
                                "di tanggal ${DataFormatter.dateTimeToString(dateTime, 'dd MMMM yyyy')}");
                      }),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  ListView _buildListPresence(List<LaporanPresensiInfo> listPresence) {
    return ListView.builder(
      itemCount: listPresence.length,
      itemBuilder: (context, index) {
        final presence = listPresence[index];

        return _buildCard(context, presence);
      },
    );
  }

  /// [_buildCard] fungsi yang digunakan untuk membuat Card Widget yang akan digunakan untuk menampilkan
  /// data yang telah diperoleh dari API.
  Widget _buildCard(BuildContext context, LaporanPresensiInfo listPresence) {
    return CustomCard(
      elevation: 3,
      margin: EdgeInsets.symmetric(
        horizontal: (context.isMobile) ? context.dp(18) : context.dp(7),
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
          _buildHeader(context, listPresence),
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
                  _buildWaktuKegiatan(context, listPresence),
                  _buildInformasiKegiatan(context, listPresence),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  /// [_buildInformasiKegiatan] digunakan untuk menampilkan informasi data kegiatan.
  Expanded _buildInformasiKegiatan(
      BuildContext context, LaporanPresensiInfo listPresence) {
    return Expanded(
      flex: 5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // RichText(
          //   maxLines: 1,
          //   overflow: TextOverflow.fade,
          //   textScaleFactor: context.textScale12,
          //   text: TextSpan(
          //     text: 'Jam Presensi: ',
          //     style: context.text.labelMedium,
          //     children: [
          //       TextSpan(
          //           text: DateFormat.Hm()
          //               .format(DateTime.parse(listPresence.presenceTime!)),
          //           style: context.text.labelMedium
          //               ?.copyWith(color: context.hintColor))
          //     ],
          //   ),
          // ),
          const SizedBox(height: 4),
          RichText(
            maxLines: 1,
            overflow: TextOverflow.fade,
            textScaler: TextScaler.linear(context.textScale12),
            text: TextSpan(
              text: 'Lokasi: ',
              style: context.text.labelMedium,
              children: [
                TextSpan(
                    text: listPresence.buildingName,
                    style: context.text.labelMedium
                        ?.copyWith(color: context.hintColor))
              ],
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            maxLines: 1,
            overflow: TextOverflow.fade,
            textScaler: TextScaler.linear(context.textScale12),
            text: TextSpan(
              text: 'Kelas GO: ',
              style: context.text.labelMedium,
              children: [
                TextSpan(
                    text: listPresence.className,
                    style: context.text.labelMedium
                        ?.copyWith(color: context.hintColor))
              ],
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            maxLines: 1,
            overflow: TextOverflow.fade,
            textScaler: TextScaler.linear(context.textScale12),
            text: TextSpan(
              text: 'Mata Pelajaran: ',
              style: context.text.labelMedium,
              children: [
                TextSpan(
                    text: listPresence.lesson,
                    style: context.text.labelMedium
                        ?.copyWith(color: context.hintColor))
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pengajar:',
            style: context.text.labelMedium,
            maxLines: 1,
            overflow: TextOverflow.fade,
          ),
          const SizedBox(height: 4),
          Text(
            listPresence.teacherName!,
            style: context.text.labelMedium?.copyWith(color: context.hintColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '(${listPresence.teacherId})',
            style: context.text.bodySmall?.copyWith(color: context.hintColor),
            maxLines: 1,
            overflow: TextOverflow.fade,
          ),
        ],
      ),
    );
  }

  /// [_buildWaktuKegiatan] digunakan untuk menampilkan widget data waktu aktivitas.
  Expanded _buildWaktuKegiatan(
      BuildContext context, LaporanPresensiInfo listPresence) {
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
                      offset: const Offset(1, 1),
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
                (listPresence.scheduleStart == null)
                    ? '-'
                    : listPresence.scheduleStart!,
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
              child: Text(
                (listPresence.scheduleFinish == null)
                    ? '-'
                    : listPresence.scheduleFinish!,
                style: context.text.labelMedium,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  /// [_buildHeader] digunakan untuk membangun tajuk daftar laporan kehadiran.
  /// <br> Namun hanya siswa yg bisa mengisi feedback presensi
  Row _buildHeader(BuildContext context, LaporanPresensiInfo listPresence) {
    bool isSudahFeedback = listPresence.isFeedback == true;
    bool isBolehFeedback = listPresence.feedbackPermission == true &&
        listPresence.isFeedback != true;
    return Row(
      children: [
        _buildIconPresensiBloc(context),
        Expanded(
          child: Row(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth:
                      (context.isMobile) ? context.dw * 0.5 : context.dw * 0.9,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listPresence.activity!,
                      style: context.text.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Pertemuan ke-${listPresence.session}',
                      style: context.text.labelSmall
                          ?.copyWith(color: context.hintColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (widget.userData.isSiswa) ...[
                const Spacer(),
                (isBolehFeedback)
                    ? GestureDetector(
                        onTap: () async {
                          await Navigator.of(context).pushNamed(
                            Constant.kRouteFeedback,
                            arguments: {
                              "idRencana": listPresence.planId,
                              "namaPengajar": listPresence.teacherName,
                              "tanggal": listPresence.date,
                              "kelas": listPresence.className,
                              "mapel": listPresence.lesson,
                              "flag": listPresence.flag,
                              "done": listPresence.isFeedback,
                            },
                          );
                          _refreshPresensi();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: context.primaryColor,
                            borderRadius: BorderRadius.circular(300),
                            boxShadow: [
                              BoxShadow(
                                  offset: const Offset(-1, -1),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                  color:
                                      context.primaryColor.withOpacity(0.42)),
                              BoxShadow(
                                offset: const Offset(1, 1),
                                blurRadius: 4,
                                spreadRadius: 1,
                                color: context.primaryColor.withOpacity(0.42),
                              ),
                            ],
                          ),
                          child: Text(
                            "Feedback",
                            style: context.text.labelMedium
                                ?.copyWith(color: context.background),
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                            color: (isSudahFeedback)
                                ? Colors.green
                                : context.disableColor,
                            borderRadius: BorderRadius.circular(300),
                            boxShadow: [
                              BoxShadow(
                                  offset: const Offset(-1, -1),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                  color: (isSudahFeedback)
                                      ? Colors.green
                                      : context.disableColor),
                              BoxShadow(
                                offset: const Offset(1, 1),
                                blurRadius: 4,
                                spreadRadius: 1,
                                color: (isSudahFeedback)
                                    ? Colors.green
                                    : context.disableColor,
                              ),
                            ]),
                        child: Text(
                          (isSudahFeedback) ? "Done" : "Expired",
                          style: context.text.labelMedium
                              ?.copyWith(color: context.background),
                        ),
                      )
              ]
            ],
          ),
        ),
      ],
    );
  }

  /// [_buildIconPresensiBloc] widget untuk membangun icon PresensiBloc
  Container _buildIconPresensiBloc(BuildContext context) {
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
        semanticLabel: 'ic_PresensiBloc_siswa',
      ),
    );
  }

  Future<dynamic> _showModalPilihTanggal() async {
    return await showModalBottomSheet<dynamic>(
        context: context,
        constraints: BoxConstraints(maxWidth: min(650, context.dw)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        builder: (context) {
          final now = DateTime.now().serverTimeFromOffset;
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                top: (context.isMobile) ? context.dp(20) : context.dp(10),
                bottom: (context.isMobile) ? context.dp(20) : context.dp(1),
                left: context.dp(18),
                right: context.dp(18),
              ),
              child: SizedBox(
                width: context.dw,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Pilih Tanggal',
                      style: context.text.titleMedium,
                    ),
                    Container(
                      height: context.dh / 3,
                      margin:
                          EdgeInsets.only(bottom: (context.isMobile) ? 0 : 10),
                      child: CupertinoDatePicker(
                        initialDateTime: _currentDate.value,
                        onDateTimeChanged: _setTempDate,
                        use24hFormat: true,
                        maximumDate: now,
                        minimumYear: 2019,
                        maximumYear: now.year,
                        mode: CupertinoDatePickerMode.date,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: _setCurrentDate,
                          child: const Text('Pilih'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Padding _buildPresensiDatePicker() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: GestureDetector(
        child: Container(
            decoration: BoxDecoration(
                borderRadius: gDefaultShimmerBorderRadius,
                border: Border.all(color: context.disableColor)),
            child: ListTile(
              title: Text('Pilih Tanggal Presensi',
                  style: context.text.bodyMedium),
              subtitle: Text(
                DataFormatter.dateTimeToString(
                    _currentDate.value, 'dd MMMM yyyy'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.edit),
            )),
        onTap: () async {
          final res = await _showModalPilihTanggal();

          if (res == false) return;

          _refreshPresensi(isRefresh: false);
        },
      ),
    );
  }

  /// [_setTempDate] digunakan untuk mengubah variable temporary
  void _setTempDate(DateTime date) {
    tempDate = date;
  }

  /// [_setCurrentDate] digunakan untuk mengubah variable current date
  void _setCurrentDate() {
    setState(() {
      _currentDate.value = tempDate;
    });
    Navigator.pop(
      context,
      DataFormatter.dateTimeToString(_currentDate.value, 'yyyy-MM-dd'),
    );
  }
}
