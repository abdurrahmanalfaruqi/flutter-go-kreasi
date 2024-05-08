import 'dart:developer' as logger show log;
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animations/animations.dart';
import 'package:gokreasi_new/api/firebase_api.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/bookmark/domain/entity/bookmark.dart';
import 'package:gokreasi_new/features/home/presentation/bloc/carousel/carousel_bloc.dart';
import 'package:gokreasi_new/features/home/presentation/provider/profile_picture_provider.dart';
import 'package:gokreasi_new/features/profile/domain/entity/kelompok_ujian.dart';

import '../widget/card/custom_card.dart';
import '../widget/navbar/side_nav_bar.dart';
import '../builder/responsive_builder.dart';
import '../widget/animation/hero_dialog_route.dart';
import '../../config/global.dart';
import '../../config/extensions.dart';
import '../../helper/hive_helper.dart';
import '../../../features/auth/data/model/user_model.dart';
import '../../../features/menu/presentation/widget/menu_3b.dart';
import '../../../features/home/presentation/screen/home_screen.dart';
import '../../../features/sosmed/presentation/screen/sosial_screen.dart';
import '../../../features/home/presentation/widget/user_info_app_bar.dart';

class MainScreen extends StatefulWidget {
  final String idSekolahKelas;
  final UserModel? userModel;

  const MainScreen({Key? key, required this.idSekolahKelas, this.userModel})
      : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Local variable
  int _selectedPageIndex = 0;
  final List<String> _labels = ['Home', 'Sosial'];
  final List<String> _iconsActive = [
    'assets/icon/ic_home.webp',
    'assets/icon/ic_social.webp'
  ];
  final List<String> _iconsInactive = [
    'assets/icon/ic_home_inactive.png',
    'assets/icon/ic_social_inactive.png'
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500)).then((value) async {
      // Mengambil versi Kreasi
      gGetKreasiVersion();

      context.read<ProfilePictureProvider>().getProfilePicture(
            namaLengkap: widget.userModel?.namaLengkap ?? '',
            noRegistrasi: widget.userModel?.noRegistrasi ?? '',
            isLogin: widget.userModel != null,
            isMainUser: widget.userModel.isLogin,
          );

      await _registerFirebase();
    });
    context.read<CarouselBloc>().add(CarouselGet(
          widget.userModel?.noRegistrasi ?? '',
        ));
  }

  @override
  void dispose() {
    // if (HiveHelper.isBoxOpen<KampusImpian>(
    //     boxName: HiveHelper.kKampusImpianBox)) {
    //   HiveHelper.closeBox<KampusImpian>(boxName: HiveHelper.kKampusImpianBox);
    // }
    // if (HiveHelper.isBoxOpen<KampusImpian>(
    //     boxName: HiveHelper.kRiwayatKampusImpianBox)) {
    //   HiveHelper.closeBox<KampusImpian>(
    //       boxName: HiveHelper.kRiwayatKampusImpianBox);
    // }
    if (HiveHelper.isBoxOpen<BookmarkMapel>(
        boxName: HiveHelper.kBookmarkMapelBox)) {
      HiveHelper.closeBox<BookmarkMapel>(boxName: HiveHelper.kBookmarkMapelBox);
    }
    if (HiveHelper.isBoxOpen<KelompokUjian>(
        boxName: HiveHelper.kKelompokUjianPilihanBox)) {
      HiveHelper.closeBox<KelompokUjian>(
          boxName: HiveHelper.kKelompokUjianPilihanBox);
    }
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) => (mounted) ? super.setState(fn) : fn();

  @override
  Widget build(BuildContext context) {
    logger.log(
        'LEBAR x TINGGI DEVICE: ${context.dw} x ${context.dh} | ${context.bottomBarHeight}');

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      backgroundColor: context.background,
      body: ResponsiveBuilder(
        mobile: _buildMainScreen(context),
        tablet: Row(
          children: [
            Expanded(
              flex: (context.dw > 1100) ? 3 : 4,
              child: _buildSideBarMenu(context),
            ),
            Expanded(
              flex: (context.isLandscape && context.dw > 1100) ? 6 : 6,
              child: _buildMainScreen(context),
            ),
          ],
        ),
      ),
      // Menu 3B
      floatingActionButton: _buildFloatingActionButton(context),
      //floating action button position to center
      floatingActionButtonLocation: (context.isMobile)
          ? FloatingActionButtonLocation.centerDocked
          : FloatingActionButtonLocation.endFloat,
      bottomNavigationBar:
          (context.isMobile) ? _buildBottomAppBar(context) : null,
    );
  }

  Container _buildSideBarMenu(BuildContext context) {
    return Container(
      color: context.background,
      child: ListView(
        padding: const EdgeInsets.only(
          right: 22,
          left: 32,
          bottom: 32,
        ),
        children: [
          BlocSelector<AuthBloc, AuthState, UserModel?>(
            selector: (state) => (state is LoadedUser) ? state.user : null,
            builder: (context, userData) => SizedBox(
              height: (userData.isLogin && !userData.isTamu)
                  ? 368
                  : (userData.isTamu)
                      ? 180
                      : max(296, context.h(256)),
              child: UserInfoAppBar(userData: userData),
            ),
          ),
          const Divider(indent: 12, endIndent: 12),
          SideNavBar(
            selectedIndex: _selectedPageIndex,
            iconsActive: _iconsActive,
            iconsInactive: _iconsInactive,
            labels: _labels,
            onIndexChange: _selectPage,
          ),
        ],
      ),
    );
  }

  /// NOTE: Tempat method-method fungsional--------------------------------------
  void _selectPage(int index) {
    setState(() => _selectedPageIndex = index);
  }

  void _popUp3BMenu() {
    Navigator.of(context).push(HeroDialogRoute(
      builder: (context) => Menu3B(heroTag: '3B'.menu3B),
    ));
  }

  // void _showUpdateBottomSheet() {
  //   UpdateVersion? update = context.read<DataProvider>().updateVersion;

  //   if (kDebugMode) {
  //     logger.log('SHOW_UPDATE_BOTTOMSHEET: Is Mobile >> ${context.isMobile}');
  //   }

  //   if (context.isMobile) {
  //     // Membuat variableTemp guna mengantisipasi rebuild saat scroll
  //     Widget? childWidget;
  //     showModalBottomSheet(
  //       context: context,
  //       elevation: 0,
  //       isDismissible: !(update?.isWajib ?? false),
  //       isScrollControlled: false,
  //       enableDrag: !(update?.isWajib ?? false),
  //       backgroundColor: Colors.transparent,
  //       constraints: const BoxConstraints(minHeight: 10, maxHeight: 640),
  //       builder: (context) {
  //         childWidget ??= const UpdateVersionWidget();
  //         return childWidget!;
  //       },
  //     );
  //   } else {
  //     Navigator.push(
  //       context,
  //       HeroDialogRoute(
  //         barrierDismissible: !(update?.isWajib ?? false),
  //         builder: (context) => const UpdateVersionWidget(),
  //       ),
  //     );
  //   }
  // }

  /// NOTE: Tempat method-method fungsional END----------------------------------

  /// NOTE: Tempat menyimpan widget method pada class ini------------------------
  // Build Floating Action Button
  Widget _buildFloatingActionButton(BuildContext context) {
    Widget floatingAction = FloatingActionButton(
      onPressed: _popUp3BMenu,
      heroTag: '3B'.menu3B,
      shape: const CircleBorder(),
      backgroundColor: context.secondaryContainer,
      child: Image.asset(
        'assets/icon/ic_3B.webp',
        width: double.infinity,
        fit: BoxFit.fitWidth,
      ),
    );

    return (context.isMobile)
        ? floatingAction
        : CustomCard(
            margin: const EdgeInsets.symmetric(horizontal: 18),
            borderRadius: BorderRadius.circular(context.dp(24)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                floatingAction,
                const SizedBox(width: 12),
                Text('Menu 3B', style: context.text.labelMedium),
                const SizedBox(width: 12),
              ],
            ),
          );
  }

  Container _buildMainScreen(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [
              context.primaryColor,
              context.secondaryColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.3, 1]),
      ),
      child: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) =>
            FadeThroughTransition(
                animation: primaryAnimation,
                secondaryAnimation: secondaryAnimation,
                fillColor: Colors.transparent,
                child: child),
        child: (_selectedPageIndex == 0)
            ? const HomeScreen(key: Key('Home-Screen'))
            : const SosialScreen(key: Key('Sosial-Screen')),
      ),
    );
  }

  // Build Bottom App Bar
  Widget _buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
      // bottom navigation bar on scaffold
      shape: const CircularNotchedRectangle(), // shape of notch
      elevation: 0,
      notchMargin: 8, // notche margin between floating button and bottom appbar
      padding: EdgeInsets.zero,
      color: context.background,
      clipBehavior: Clip.antiAlias,
      surfaceTintColor: Colors.transparent,
      height: 80 + min(20, context.bottomBarHeight),
      child: BottomNavigationBar(
        currentIndex: _selectedPageIndex,
        onTap: _selectPage,
        iconSize: 32,
        elevation: 0,
        backgroundColor: Colors.transparent,
        selectedLabelStyle: context.text.bodyMedium,
        unselectedLabelStyle:
            context.text.bodyMedium?.copyWith(color: context.hintColor),
        items: List.generate(
          _labels.length,
          (index) => BottomNavigationBarItem(
            label: _labels[index],
            activeIcon: Image.asset(
              _iconsActive[index],
              width: min(32, context.dp(32)),
              height: min(32, context.dp(32)),
              fit: BoxFit.fitWidth,
            ),
            icon: Image.asset(
              _iconsInactive[index],
              width: min(32, context.dp(32)),
              height: min(32, context.dp(32)),
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
      ),
    );
  }

  /// NOTE: Tempat menyimpan widget END------------------------------------------
  Future<void> _registerFirebase() async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      await Firebase.initializeApp();
      await FirebaseApi().initNotifications();
      await FirebaseApi().initLocalNotifications();
    } catch (e) {
      if (kDebugMode) {
        print('Firebase error init $e');
      }
    }
  }
}
