import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/bookmark/domain/entity/bookmark.dart';
import 'package:gokreasi_new/features/profile/domain/entity/scanner_type.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'hapus_akun.dart';
import '../../../pembayaran/presentation/widget/detail_pembayaran.dart';
import '../../../bookmark/presentation/widget/profile/bookmark_profile_widget.dart';
import '../../../../core/config/enum.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/helper/hive_helper.dart';

class ProfileMenuWidget extends StatefulWidget {
  const ProfileMenuWidget({Key? key}) : super(key: key);

  @override
  State<ProfileMenuWidget> createState() => _ProfileMenuWidgetState();
}

class _ProfileMenuWidgetState extends State<ProfileMenuWidget> {
  final ValueListenable<Box<ScannerType>> _listenableQRScanner =
      HiveHelper.listenableQRScanner();

  var completer = Completer();
  UserModel? userData;
  late AuthBloc authBloc;

  @override
  void initState() {
    super.initState();
    authBloc = context.read<AuthBloc>();
    Future.delayed(Duration.zero, () async {
      if (!HiveHelper.isBoxOpen<BookmarkMapel>(
          boxName: HiveHelper.kBookmarkMapelBox)) {
        await HiveHelper.openBox<BookmarkMapel>(
            boxName: HiveHelper.kBookmarkMapelBox);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is LoadedUser) {
          userData = state.user;
        }

        return Container(
          color: context.background,
          padding: EdgeInsets.symmetric(
            vertical: min(24, context.dp(20)),
            horizontal: min(20, context.dp(16)),
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildQRSettingWidget(context),
              ListTile(
                onTap: _showBookmark,
                dense: true,
                leading: const Icon(Icons.bookmark_border_rounded),
                title: const Text('My Bookmark'),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              ListTile(
                onTap: _showDetailPembayaran,
                dense: true,
                leading: const Icon(Icons.payment_rounded),
                title: const Text('Pembayaran'),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              ListTile(
                onTap: _navigateToTataTertibScreen,
                dense: true,
                leading: const Icon(Icons.report_problem_outlined),
                title: const Text('Tata Tertib Siswa'),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              ListTile(
                onTap: () => _navigateToTerms(context),
                dense: true,
                leading: const Icon(Icons.description_outlined),
                title: const Text('Term and Condition'),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              ListTile(
                onTap: () => _navigateToPrivacyandpolicyScreen(context),
                dense: true,
                leading: const Icon(Icons.lock_outlined),
                title: const Text('Privacy and policy'),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              ListTile(
                onTap: _navigateToBantuanScreen,
                dense: true,
                leading: const Icon(Icons.help_outline_rounded),
                title: const Text('Pusat bantuan'),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              ListTile(
                onTap: _navigateToAboutScreen,
                dense: true,
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('Tentang Go Expert'),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              ListTile(
                onTap: _showHapusAkun,
                dense: true,
                leading: const Icon(Icons.delete_outline),
                title: const Text('Hapus Akun'),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              ListTile(
                onTap: () {
                  _logout(context);
                },
                dense: true,
                title: const Text('Logout'),
                textColor: context.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        );
      },
      listener: (context, state) {
        // if (state is AuthLoading) {
        //   context.showBlockDialog(dismissCompleter: completer);
        // }

        if (state is AuthError) {
          if (!completer.isCompleted) {
            completer.complete();
          }
        }

        if (state is LoadedUser) {
          if (!completer.isCompleted) {
            completer.complete();
          }
        }
      },
    );
  }

  // ON-CLICK ABOUT/TENTANG
  void _navigateToAboutScreen() {
    Navigator.pushNamed(context, Constant.kRouteAboutScreen);
  }

  // ON-CLICK TATA TERTIB
  void _navigateToTataTertibScreen() {
    Navigator.pushNamed(context, Constant.kRouteTataTertibScreen);
  }
  void _navigateToPrivacyandpolicyScreen(BuildContext context) {
  String url = 'https://ganeshaoperation.com'; // Ganti dengan URL kebijakan privasi Anda
  url += '/privacy1.html';
  Navigator.pushNamed(
    context,
    Constant.kRouteBantuanWebViewScreen, // Ganti dengan route untuk layar webview
    arguments: {'title': 'Privacy Policy', 'url': url},
  );
}
void _navigateToTerms(BuildContext context) {
  String url = 'https://ganeshaoperation.com'; // Ganti dengan URL kebijakan privasi Anda
  url += '/term1.html';
  Navigator.pushNamed(
    context,
    Constant.kRouteBantuanWebViewScreen, // Ganti dengan route untuk layar webview
    arguments: {'title': 'Term and Condition', 'url': url},
  );
}

  

  // ON-CLICK PUSAT BANTUAN
  void _navigateToBantuanScreen() {
    Navigator.pushNamed(context, Constant.kRouteBantuanScreen);
  }

  // ON-CLICK-LOGOUT
  Future<void> _logout(BuildContext context) async {
    // Menghilangkan menu bottom sheet
    Navigator.pop(context);
    bool isOrtu = userData.isOrtu;
    bool isKeluar = await gShowBottomDialog(gNavigatorKey.currentState!.context,
        dialogType: DialogType.warning,
        message: 'Apakah ${isOrtu ? 'Anda' : 'Sobat'} yakin ingin keluar?');
    if (isKeluar) {
      authBloc.add(AuthLogout());
    }
  }

  // ON-CLICK-PEMBAYARAN
  void _showDetailPembayaran() {
    Navigator.pop(context);
    // Membuat variableTemp guna mengantisipasi rebuild saat scroll
    Widget? childWidget;
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        minHeight: 10,
        maxHeight: context.dh * 0.86,
        maxWidth: min(650, context.dw),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        childWidget ??= Padding(
          padding: EdgeInsets.only(
            right: min(22, context.dp(18)),
            left: min(22, context.dp(18)),
            top: min(28, context.dp(24)),
          ),
          child: const DetailPembayaran(),
        );
        return childWidget!;
      },
    );
  }

  // ON-CLICK-BOOKMARK
  void _showBookmark() {
    Navigator.pop(context);
    // Membuat variableTemp guna mengantisipasi rebuild saat scroll
    Widget? childWidget;
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        minHeight: 10,
        maxHeight: context.dh * 0.86,
        maxWidth: min(650, context.dw),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        childWidget ??= Padding(
          padding: EdgeInsets.symmetric(vertical: min(28, context.dp(24))),
          child: BookmarkProfileWidget(
            userData: userData,
          ),
        );
        return childWidget!;
      },
    );
  }

  // ON-CLICK-HAPUS AKUN
  void _showHapusAkun() {
    Navigator.pop(context);
    // Membuat variableTemp guna mengantisipasi rebuild saat scroll
    Widget? childWidget;
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      constraints: BoxConstraints(minHeight: 10, maxHeight: context.dh * 0.86),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        childWidget ??= Padding(
          padding: EdgeInsets.all(context.dp(24)),
          child: HapusAkun(context: context),
        );
        return childWidget!;
      },
    );
  }

  ListTile _buildQRSettingWidget(BuildContext context) => ListTile(
        dense: true,
        leading: const Icon(Icons.qr_code_scanner_rounded),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('QR Scanner'),
            const SizedBox(height: 6),
            ValueListenableBuilder<Box<ScannerType>>(
              valueListenable: _listenableQRScanner,
              builder: (_, box, __) {
                final double widthWidget =
                    (context.isMobile) ? context.dw * 0.7 : 500;
                final double heightWidget = min(52, context.dp(46));

                return Container(
                  width: widthWidget,
                  height: heightWidget,
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(300),
                    boxShadow: const [
                      BoxShadow(color: Colors.black38),
                      BoxShadow(
                          color: Colors.white70,
                          spreadRadius: -2.0,
                          blurRadius: 2.0),
                    ],
                  ),
                  child: Stack(
                    children: [
                      AnimatedAlign(
                        curve: Curves.easeOut,
                        duration: const Duration(milliseconds: 400),
                        alignment: (box.get(HiveHelper.kScannerKey) ==
                                ScannerType.flutterBarcodeScanner)
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          width: (widthWidget) / 2,
                          decoration: BoxDecoration(
                              color: context.secondaryColor,
                              borderRadius: BorderRadius.circular(300),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 3,
                                  spreadRadius: 1,
                                  offset: Offset(-1, 0),
                                ),
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 3,
                                  spreadRadius: 1,
                                  offset: Offset(1, 0),
                                )
                              ]),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        heightFactor: heightWidget,
                        widthFactor: (widthWidget) / 2,
                        child: SizedBox(
                          height: heightWidget,
                          width: (widthWidget) / 2,
                          child: TextButton(
                            onPressed: () async =>
                                await HiveHelper.saveScannerSetting(
                              key: HiveHelper.kScannerKey,
                              scannerPilihan: ScannerType.mobileScanner,
                            ),
                            style: TextButton.styleFrom(
                                splashFactory: NoSplash.splashFactory),
                            child: Text('Mobile Scanner',
                                style: context.text.bodySmall
                                    ?.copyWith(color: context.onSecondary)),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        heightFactor: heightWidget,
                        widthFactor: (widthWidget) / 2,
                        child: SizedBox(
                          height: heightWidget,
                          width: (widthWidget) / 2,
                          child: TextButton(
                            onPressed: () async =>
                                await HiveHelper.saveScannerSetting(
                              key: HiveHelper.kScannerKey,
                              scannerPilihan: ScannerType.flutterBarcodeScanner,
                            ),
                            style: TextButton.styleFrom(
                                splashFactory: NoSplash.splashFactory),
                            child: Text('QR Scanner',
                                style: context.text.bodySmall
                                    ?.copyWith(color: context.onSecondary)),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            )
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );
}
