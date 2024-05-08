import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/core/config/enum.dart';
import 'package:gokreasi_new/core/config/global.dart';
import 'package:gokreasi_new/core/shared/widget/button/custom_button.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/profile/domain/entity/scanner_type.dart';
import 'package:gokreasi_new/features/profile/presentation/bloc/profile/profile_bloc.dart';

import '../widget/user_avatar.dart';
import '../widget/profile_widget.dart';
import '../widget/profile_menu_widget.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/helper/hive_helper.dart';
import '../../../../core/shared/builder/responsive_builder.dart';
import '../../../../core/shared/widget/loading/shimmer_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  UserModel? userData;
  late final _navigator = Navigator.of(context);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (HiveHelper.isBoxOpen<ScannerType>(boxName: HiveHelper.kSettingBox)) {
      HiveHelper.closeBox<ScannerType>(boxName: HiveHelper.kSettingBox);
    }
    super.dispose();
  }

  Future<bool> _openSettingBox() async {
    if (!HiveHelper.isBoxOpen<ScannerType>(boxName: HiveHelper.kSettingBox)) {
      await HiveHelper.openBox<ScannerType>(boxName: HiveHelper.kSettingBox);
    }
    return HiveHelper.isBoxOpen<ScannerType>(boxName: HiveHelper.kSettingBox);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLogoutError) {
            Future.delayed(Duration.zero, () {
              gShowTopFlash(
                context,
                kDebugMode ? state.err : gPesanError,
                dialogType: DialogType.error,
              );
            });
          }

          if (state is AuthError) {
            // to reset state when error
            context.read<AuthBloc>().add(const AuthGetCurrentUser(
                  isRefresh: true,
                ));
          }

          if (state is LoadedUser) {
            if (state.isFailedLogout == true) {
              Future.delayed(Duration.zero, () async {
                await gShowTopFlash(
                  context,
                  'Terjadi Kesalahan, saat logout. Coba lagi nanti',
                  dialogType: DialogType.error,
                );
              });
            } else if (state.user == null) {
              Future.delayed(Duration.zero, () async {
                await gShowTopFlash(
                  context,
                  'Berhasil Logout',
                  dialogType: DialogType.success,
                );
              });
              _navigator.pushNamedAndRemoveUntil(
                  Constant.kRouteMainScreen, (route) => false);
            }
          }
        },
        builder: (context, state) {
          if (state is LoadedUser) {
            userData = state.user;
            if (userData != null) {
              context.read<ProfileBloc>().add(ProfileGetSekolahKelas(userData));
            }
          }

          return SafeArea(
            child: ResponsiveBuilder(
              mobile: Column(
                children: [
                  _buildHeaderMenu(),
                  _buildProfileHeader(userData),
                  const ProfileWidget(),
                ],
              ),
              tablet: ProfileWidget(
                headerMenu: _buildHeaderMenu(),
                profileHeader: _buildProfileHeader(userData),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onClickUbahProfil() {
    Navigator.pushNamed(
      context,
      Constant.kRouteEditProfileScreen,
    );
  }

  void _showProfileMenuBottomSheet() {
    showModalBottomSheet(
      context: context,
      elevation: 4,
      isDismissible: true,
      isScrollControlled: true,
      clipBehavior: Clip.hardEdge,
      backgroundColor: context.background,
      constraints: BoxConstraints(
        minHeight: 10,
        maxHeight: context.dh * 0.86,
        maxWidth: min(650, context.dw),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const ProfileMenuWidget(),
    );
  }

  Padding _buildHeaderMenu() => Padding(
        padding: EdgeInsets.only(
          top: min(24, context.dp(20)),
          bottom: min(16, context.dp(12)),
          right: min(24, context.dp(20)),
          left: min(24, context.dp(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(300),
                child: const Icon(Icons.chevron_left_rounded, size: 32)),
            Image.asset('assets/img/logo.webp',
                height: min(52, context.dp(48)), fit: BoxFit.fitHeight),
            FutureBuilder(
              future: _openSettingBox(),
              builder: (context, snapshot) =>
                  (snapshot.connectionState == ConnectionState.waiting)
                      ? ShimmerWidget.rounded(
                          width: 32,
                          height: 32,
                          borderRadius: BorderRadius.circular(12),
                        )
                      : InkWell(
                          onTap: _showProfileMenuBottomSheet,
                          borderRadius: BorderRadius.circular(12),
                          child: const Icon(Icons.menu_rounded, size: 32)),
            ),
          ],
        ),
      );

  Row _buildProfileHeader(UserModel? userData) => Row(
        children: [
          SizedBox(width: min(24, context.dp(20))),
          UserAvatar(
            userData: userData,
            size: (context.isMobile) ? 96 : 38,
            padding: 4,
          ),
          SizedBox(width: min(14, context.dp(12))),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'Nama-Lengkap-User',
                  key: const Key('Nama-Lengkap-User'),
                  transitionOnUserGestures: true,
                  child: Text(userData?.namaLengkap ?? 'Sobat GO',
                      style: context.text.titleMedium
                          ?.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      textScaler: TextScaler.linear(context.textScale12),
                      overflow: TextOverflow.ellipsis),
                ),
                Hero(
                  tag: 'No-Registrasi-User',
                  key: const Key('No-Registrasi-User'),
                  transitionOnUserGestures: true,
                  child: Text(
                      '${userData?.noRegistrasi} (${userData?.siapa?.toUpperCase()})',
                      style: context.text.bodyMedium
                          ?.copyWith(color: context.hintColor),
                      maxLines: 1,
                      textScaler: TextScaler.linear(context.textScale12),
                      overflow: TextOverflow.ellipsis),
                ),
                SizedBox(height: min(13, context.dp(9))),
                CustomButton(
                  title: 'Ubah Profil',
                  height: min(context.dp(32), 38),
                  width: min(context.dp(110), 130),
                  onTap: _onClickUbahProfil,
                ),
                SizedBox(width: min(24, context.dp(20))),
              ],
            ),
          ),
        ],
      );
}
