import 'dart:convert';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gokreasi_new/core/config/enum.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/profile/domain/entity/kelompok_ujian.dart';
import 'package:gokreasi_new/features/profile/domain/entity/mapel_pilihan.dart';
import 'package:gokreasi_new/features/profile/presentation/bloc/profile/profile_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

import 'pilih_kelompok_ujian.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/helper/hive_helper.dart';
import '../../../../core/shared/widget/refresher/custom_smart_refresher.dart';

class BiodataWidget extends StatefulWidget {
  final UserModel? userData;
  final void Function(RefreshController controller) onRefresh;

  const BiodataWidget({
    Key? key,
    required this.userData,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<BiodataWidget> createState() => _BiodataWidgetState();
}

class _BiodataWidgetState extends State<BiodataWidget> {
  late AuthBloc authBloc;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  bool isShowChooseMapel = false;
  List<MapelPilihan> listCurrentMapel = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      if (!HiveHelper.isBoxOpen<KelompokUjian>(
          boxName: HiveHelper.kKelompokUjianPilihanBox)) {
        await HiveHelper.openBox<KelompokUjian>(
            boxName: HiveHelper.kKelompokUjianPilihanBox);
      }
    });

    authBloc = context.read<AuthBloc>();
    authBloc.add(AuthGetGedungKomarSiswa(
      isRefresh: true,
      userData: widget.userData,
    ));
  }

  @override
  void dispose() {
    HiveHelper.closeBox<KelompokUjian>(
        boxName: HiveHelper.kKelompokUjianPilihanBox);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isSiswa = widget.userData != null && widget.userData?.siapa == 'SISWA';

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileFailedSaveMapel) {
          Future.delayed(Duration.zero, () {
            gShowTopFlash(
              context,
              state.err,
              dialogType: DialogType.error,
            );
          });
        }
      },
      builder: (context, state) {
        if (state is ProfileNotValid) {
          isShowChooseMapel = false;
        }

        if (state is LoadedGetCurrentMapel) {
          isShowChooseMapel = true;
          listCurrentMapel = state.listMapelPilihan;
        }

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(context.textScale12),
          ),
          child: CustomSmartRefresher(
            isDark: true,
            controller: _refreshController,
            onRefresh: () async => widget.onRefresh(_refreshController),
            child: Container(
              width: (context.isMobile) ? context.dw : double.infinity,
              margin: EdgeInsets.only(
                top: min(14, context.dp(10)),
                right: min(24, context.dp(20)),
                left: min(24, context.dp(20)),
                bottom: min(36, context.dp(32)),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: min(20, context.dp(16)),
                vertical: min(24, context.dp(16)),
              ),
              decoration: BoxDecoration(
                color: context.background,
                borderRadius: BorderRadius.circular(
                    (context.isMobile) ? 24 : context.dp(12)),
                boxShadow: const [
                  BoxShadow(
                    offset: Offset(1, 2),
                    color: Colors.black26,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._buildSimpleItem(context, 'Email',
                      decodeString(widget.userData?.email ?? '')),
                  ..._buildKelasWidget(context),
                  ..._buildSimpleItem(
                      context, 'Kota', (widget.userData?.namaKota ?? '-')),
                  ..._buildSimpleItem(context, 'Nomor Handphone',
                      decodeString(widget.userData?.nomorHp ?? '')),
                  ..._buildSimpleItem(
                      context,
                      'Asal Sekolah',
                      widget.userData?.namaSekolah ??
                          'Asal sekolah belum terdata'),
                  ..._buildSimpleItem(
                      context,
                      'Email Ortu',
                      (widget.userData?.emailOrtu ??
                          'Email orang tua belum terdata')),
                  ..._buildSimpleItem(
                      context,
                      'Nomor Handphone Ortu',
                      widget.userData?.nomorHpOrtu ??
                          'Nomor handphone orang tua belum terdata'),
                  if (isSiswa && isShowChooseMapel)
                    _buildPilihanMataUji(listCurrentMapel),
                  Container(
                    width: double.infinity,
                    height: min(36, context.dp(32)),
                    alignment: Alignment.bottomCenter,
                    child: RichText(
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                        ),
                        children: [
                          TextSpan(text: '$gKreasiVersion\n'),
                          TextSpan(
                              text: (dotenv.env['WEB-URL'] ?? '')
                                  .replaceFirst('https://', ''),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async => _launchUrl()),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(dotenv.env['WEB-URL'] ?? '');
    if (!await launchUrl(url)) {
      if (!context.mounted) return;

      gShowTopFlash(
        context,
        'Could not launch $url',
        dialogType: DialogType.error,
      );
    }
  }

  // Future<void> _openKelompokUjianBox() async {
  //   if (!HiveHelper.isBoxOpen<KelompokUjian>(
  //       boxName: HiveHelper.kKelompokUjianPilihanBox)) {
  //     await HiveHelper.openBox<KelompokUjian>(
  //         boxName: HiveHelper.kKelompokUjianPilihanBox);
  //   }
  // }

  void _onClickPilihKelompokUjian() {
    // Membuat variableTemp guna mengantisipasi rebuild saat scroll
    Widget? childWidget;
    showModalBottomSheet(
      context: context,
      elevation: 4,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: context.background,
      constraints: BoxConstraints(
        minHeight: 10,
        maxHeight: context.dh * 0.86,
        maxWidth: min(650, context.dw),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        childWidget ??= PilihKelompokUjian(
          currentMapel: listCurrentMapel,
        );
        return childWidget!;
      },
    );
  }

  List<Widget> _buildSimpleItem(
          BuildContext context, String title, String subTitle) =>
      [
        Text(title,
            style: context.text.labelMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(subTitle, style: context.text.bodyMedium),
        const Divider()
      ];

  List<Widget> _buildKelasWidget(BuildContext context) => [
        Text('Kelas',
            style: context.text.labelMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is LoadedUser && state.user?.namaKelas != null) {
              return Text(
                state.user!.namaKelas!,
                style: context.text.bodyMedium,
              );
            }

            return Text('-', style: context.text.bodyMedium);
          },
        ),
        // if (widget.userData?.namaKelasGO == null ||
        //     (widget.userData?.namaKelasGO?.isEmpty ?? false))
        //   Text('-', style: context.text.bodyMedium),
        // if (widget.userData?.namaKelasGO != null ||
        //     (widget.userData?.namaKelasGO?.isNotEmpty ?? false))
        //   ...List<Widget>.generate(
        //       widget.userData?.namaKelasGO?.length ?? 0,
        //       (index) => Text(
        //           '${index + 1}. ${widget.userData?.namaKelasGO?[index]}',
        //           style: context.text.bodyMedium)),
        const Divider()
      ];

  Widget _buildKelompokUjianPilihanWidget(
    VoidCallback onClickPilihMataUji,
    List<MapelPilihan> kelompokUjianPilihan,
  ) =>
      InkWell(
        borderRadius: gDefaultShimmerBorderRadius,
        onTap: onClickPilihMataUji,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              maxLines: 1,
              overflow: TextOverflow.fade,
              textScaler: TextScaler.linear(context.textScale12),
              text: TextSpan(
                  text: 'Mata Uji Pilihan ',
                  style: context.text.labelMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                  children: [
                    if (kelompokUjianPilihan.isNotEmpty)
                      TextSpan(
                        text: '(Ubah Pilihan)',
                        style: context.text.labelSmall?.copyWith(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            decorationThickness: 1),
                      )
                  ]),
            ),
            const SizedBox(height: 2),
            if (kelompokUjianPilihan.isEmpty)
              Row(
                children: [
                  Expanded(
                    child: Text('Pilih mata uji pilihan kamu',
                        style: context.text.bodyMedium),
                  ),
                  const Icon(Icons.chevron_right_rounded)
                ],
              ),
            if (kelompokUjianPilihan.isNotEmpty)
              ...List<Widget>.generate(
                  kelompokUjianPilihan.length,
                  (index) => Text(
                      '  ${index + 1}. ${kelompokUjianPilihan[index].namaKelompokUjian}',
                      style: context.text.bodyMedium)),
            const Divider()
          ],
        ),
      );

  Widget _buildPilihanMataUji(List<MapelPilihan> listMapel) {
    return _buildKelompokUjianPilihanWidget(
        _onClickPilihKelompokUjian, listMapel);

    // FutureBuilder<void>(
    //   future: _openKelompokUjianBox(),
    //   builder: (context, snapshot) =>
    //       (snapshot.connectionState == ConnectionState.waiting) ||
    //               (!HiveHelper.isBoxOpen(
    //                   boxName: HiveHelper.kKelompokUjianPilihanBox))
    //           ? ShimmerWidget.rounded(
    //               width: double.infinity,
    //               height: context.dp(96),
    //               borderRadius: gDefaultShimmerBorderRadius)
    //           : ValueListenableBuilder<Box<KelompokUjian>>(
    //               valueListenable: HiveHelper.listenableKelompokUjian(),
    //               builder: (context, box, _) {
    //                 List<KelompokUjian> listKelompokUjianPilihan =
    //                     box.values.toList();
    //
    //                 return _buildKelompokUjianPilihanWidget(
    //                     _onClickPilihKelompokUjian, listKelompokUjianPilihan);
    //               },
    //             ),
    // );
  }

  String decodeString(String input) {
    try {
      return jsonDecode(input);
    } catch (_) {
      return input;
    }
  }
}
