import 'dart:developer' as logger show log;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gokreasi_new/core/config/enum.dart';
import 'package:flutter/foundation.dart';
import 'package:gokreasi_new/core/helper/hive_helper.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/bookmark/domain/entity/bookmark.dart';

import '../../config/global.dart';
import '../../config/constant.dart';
import '../../config/extensions.dart';
import '../../util/platform_channel.dart';

/// [SplashScreen] ini akan menampilkan iklan selama minimal 2 detik.
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    PlatformChannel.setSecureScreen('POP', true);
    super.initState();
    context
        .read<AuthBloc>()
        .add(const AuthGetCurrentUser(isSplashScreen: true));

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
    gGetDeviceInfo();
    // Set Device Orientation
    gSetDeviceOrientations(isLandscape: !context.isMobile);
    if (kDebugMode) {
      logger.log('SPLASH_SCREEN-Build: Size '
          '${context.dw.toStringAsFixed(2)} x ${context.dh.toStringAsFixed(2)}');
      logger.log('SPLASH_SCREEN-Build: Size Ratio '
          '${(context.dw / context.dh).toStringAsFixed(2)}');
    }

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        // await HiveHelper.openBox<KampusImpian>(
        //     boxName: HiveHelper.kKampusImpianBox);
        // await HiveHelper.openBox<KampusImpian>(
        //     boxName: HiveHelper.kRiwayatKampusImpianBox);

        if (state is LoadedUser) {
          if (state.user == null) return;

          Future.delayed(
            Duration.zero,
            () => Navigator.pushNamedAndRemoveUntil(
                context, Constant.kRouteMainScreen, (route) => false,
                arguments: {
                  'idSekolahKelas': state.user?.idSekolahKelas,
                  'userModel': state.user,
                }),
          );
        }

        if (state is AuthError) {
          Future.delayed(Duration.zero, () {
            gShowTopFlash(
              context,
              kDebugMode ? state.err : gPesanError,
              dialogType: DialogType.error,
            );
          });

          Future.delayed(
            Duration.zero,
            () => Navigator.pushNamedAndRemoveUntil(
                context, Constant.kRouteMainScreen, (route) => false,
                arguments: {'idSekolahKelas': '31'}),
          );
        }

        if (state is AuthErrorLogin) {
          Future.delayed(Duration.zero, () {
            gShowTopFlash(
              context,
              state.err,
              dialogType: DialogType.error,
            );
          });
        }

        if (state is AuthCurrentUserError || state is AuthErrorLogin) {
          Future.delayed(
            Duration.zero,
            () => Navigator.pushNamedAndRemoveUntil(
                context, Constant.kRouteMainScreen, (route) => false,
                arguments: {'idSekolahKelas': '31'}),
          );
        }
      },
      child: _buildSplashScreen(),
    );
  }

  Scaffold _buildSplashScreen() {
    final baseUrlImage = dotenv.env["BASE_URL_IMAGE"] ?? '';
    return Scaffold(
      body: CachedNetworkImage(
        imageUrl: (context.isMobile)
            ? '$baseUrlImage/image/tampilan-depan-mobile.jpg'
            : '$baseUrlImage/arsip-mobile/img/logo.webp',
        width: context.dw,
        height: double.infinity,
        fit: (context.isMobile) ? BoxFit.cover : BoxFit.fitWidth,
      ),
    );
  }
}
