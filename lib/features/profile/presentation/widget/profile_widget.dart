import 'dart:math';
import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/model/kelompok_ujian_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'produk_widget.dart';
import 'biodata_widget.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/helper/hive_helper.dart';

class ProfileWidget extends StatefulWidget {
  final Widget? headerMenu;
  final Widget? profileHeader;

  const ProfileWidget({
    Key? key,
    this.headerMenu,
    this.profileHeader,
  }) : super(key: key);

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget>
    with SingleTickerProviderStateMixin {
  UserModel? userData;
  late AuthBloc authBloc;

  @override
  void initState() {
    super.initState();
    authBloc = context.read<AuthBloc>();
  }

  @override
  void dispose() {
    Future.delayed(Duration.zero, () async {
      if (HiveHelper.isBoxOpen<KelompokUjian>(
          boxName: HiveHelper.kKelompokUjianPilihanBox)) {
        HiveHelper.closeBox<KelompokUjian>(
            boxName: HiveHelper.kKelompokUjianPilihanBox);
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is LoadedUser) {
          userData = state.user;
        }

        return DefaultTabController(
          initialIndex: 0,
          length: 2,
          child: (context.isMobile)
              ? Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTabBar(context),
                      _buildTabBarView(),
                    ],
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      flex: (context.dw > 1100) ? 3 : 4,
                      child: Column(
                        children: [
                          widget.headerMenu ?? const SizedBox.shrink(),
                          const SizedBox(height: 24),
                          widget.profileHeader ?? const SizedBox.shrink(),
                          _buildTabBar(context),
                        ],
                      ),
                    ),
                    const VerticalDivider(indent: 32, endIndent: 32),
                    _buildTabBarView(),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildTabBarView() {
    if (kDebugMode) {
      logger.log('PROFILE_WIDGET-DaftarProduk: Result Daftar Produk '
          '>> ${userData?.daftarProdukGroupByBundel}');
    }
    return Expanded(
      flex: (context.isMobile) ? 1 : 6,
      child: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          BiodataWidget(
            onRefresh: _onRefreshProfile,
            userData: userData,
          ),
          ProdukWidget(
              namaBundlingAktif: userData?.namaBundlingAktif ?? "N/a",
              onRefresh: _onRefreshProfile,
              daftarProdukDibeli: userData?.daftarProdukGroupByBundel ?? {}),
        ],
      ),
    );
  }

  Container _buildTabBar(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: min(24, context.dp(16)),
        right: min(24, context.dp(20)),
        left: min(24, context.dp(20)),
        bottom: min(14, context.dp(10)),
      ),
      decoration: BoxDecoration(
          color: context.background,
          borderRadius: BorderRadius.circular(300),
          boxShadow: const [
            BoxShadow(
                offset: Offset(0, 2), blurRadius: 4, color: Colors.black26)
          ]),
      child: TabBar(
        labelColor: context.onBackground,
        indicatorColor: context.secondaryColor,
        labelStyle: context.text.bodyMedium,
        unselectedLabelStyle: context.text.bodyMedium,
        unselectedLabelColor: context.hintColor,
        indicatorSize: TabBarIndicatorSize.tab,
        splashBorderRadius: BorderRadius.circular(300),
        indicator: BoxDecoration(
            color: context.secondaryColor,
            borderRadius: BorderRadius.circular(300)),
        indicatorPadding: EdgeInsets.zero,
        labelPadding: (context.isMobile)
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(vertical: 8),
        tabs: const [Tab(text: 'Biodata'), Tab(text: 'Produk')],
      ),
    );
  }

  Future<void> _onRefreshProfile(RefreshController controller) async {
    authBloc.add(AuthGetGedungKomarSiswa(
      isRefresh: true,
      userData: userData,
    ));

    controller.refreshCompleted();
  }
}
