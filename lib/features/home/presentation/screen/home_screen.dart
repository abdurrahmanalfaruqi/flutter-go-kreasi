import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gokreasi_new/core/helper/hive_helper.dart';
import 'package:gokreasi_new/core/helper/kreasi_shared_pref.dart';
import 'package:gokreasi_new/core/shared/widget/upgrade/upgrade_widget.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/berita/presentation/bloc/news_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/features/bookmark/domain/entity/bookmark.dart';
import 'package:gokreasi_new/features/bookmark/presentation/bloc/bookmark_bloc.dart';
import 'package:gokreasi_new/features/home/presentation/bloc/home/home_bloc.dart';
import 'package:gokreasi_new/features/home/presentation/bloc/pembayaran/pembayaran_bloc.dart';
import 'package:gokreasi_new/features/home/presentation/bloc/ptn/ptn_bloc.dart';
import 'package:gokreasi_new/features/home/presentation/widget/promotion_widget.dart';
import 'package:gokreasi_new/features/leaderboard/presentation/bloc/capaian/capaian_bloc.dart';
import 'package:gokreasi_new/features/leaderboard/presentation/bloc/capaianbar/capaianbar_bloc.dart';
import 'package:gokreasi_new/features/leaderboard/presentation/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:gokreasi_new/features/soal/presentation/bloc/soal_bloc/soal_bloc.dart';
import 'package:gokreasi_new/features/video/presentation/widget/home/teaser_video_home_widget.dart';

import '../../../../core/config/constant.dart';
import '../../../../core/config/enum.dart';
import '../../../../core/config/global.dart';
import '../../../../core/shared/widget/image/custom_image_network.dart';
import '../widget/carousel_widget.dart';
import '../../../auth/data/model/user_model.dart';
import '../../../home/presentation/widget/user_info_app_bar.dart';
import '../../../ptn/module/ptnclopedia/presentation/widget/home/impian_kuliah_widget.dart';
import '../../../kehadiran/presentation/provider/kehadiran_provider.dart';
import '../../../berita/presentation/widget/promo/promo_home_widget.dart';
import '../../../berita/presentation/widget/go_news/go_news_home_widget.dart';
import '../../../bookmark/presentation/widget/home/bookmark_home_widget.dart';
// import '../../../video/presentation/widget/home/teaser_video_home_widget.dart';
import '../../../leaderboard/presentation/widget/home/leaderboard_home_widget.dart';
import '../../../../core/config/extensions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final _firebaseHelper = FirebaseHelper();
  late AuthBloc authBloc;
  UserModel? userData;

  @override
  void initState() {
    super.initState();
    authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;
    if (authState is LoadedUser) {
      userData = authState.user;
    }
    _showBeritaPopUp();

    // to get promotion event
    context.read<HomeBloc>().add(GetPromotionEvent());
    Future.delayed(const Duration(seconds: 1), () {
      if (context.mounted) _showPromotionPopUp();
    });

    Future.delayed(Duration.zero, () async {
      await _onRefresh(
        context: context,
        userData: gUser,
        isRefresh: false,
      );
    });
  }

  @override
  void setState(VoidCallback fn) => (mounted) ? super.setState(fn) : fn();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LoadedUser && state.isSuccessUpdate == true) {
          Future.delayed(Duration.zero, () async {
            await _onRefresh(
              context: context,
              userData: state.user,
            );
          });
        }
      },
      builder: (_, state) {
        if (state is LoadedUser) {
          userData = state.user;
        }

        final user = ValueNotifier(userData);
        return ValueListenableBuilder<UserModel?>(
          valueListenable: user,
          builder: (context, userData, promoWidget) {
            return UpgradeWidget(
              child: CustomScrollView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  _buildSliverAppBar(context),
                  CupertinoSliverRefreshControl(
                    onRefresh: () async => await _onRefresh(
                      context: context,
                      userData: userData,
                    ),
                  ),
                  _buildCarousal(context),
                  if (!userData.isLogin || userData?.isBolehPTN == true)
                    _buildImpianKuliah(context),
                  _buildJuaraBukuSakti(context, userData),
                  SliverPadding(
                    padding:
                        EdgeInsets.symmetric(vertical: min(28, context.dp(20))),
                    sliver: SliverToBoxAdapter(
                      child: BookmarkHomeWidget(
                        isSiswa: userData.isSiswa,
                        noRegistrasi: userData?.noRegistrasi,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.only(
                        left: (context.isMobile)
                            ? context.dp(24)
                            : context.dp(18),
                        right: (context.isMobile)
                            ? context.dp(24)
                            : context.dp(18),
                        bottom: min(28, context.dp(20))),
                    sliver: SliverToBoxAdapter(
                      child: Builder(builder: (context) {
                        final idSekolahKelas =
                            ValueNotifier(userData?.idSekolahKelas);
                        return ValueListenableBuilder(
                          valueListenable: idSekolahKelas,
                          builder: (context, idSekolahKelas, child) =>
                              TeaserVideoHomeWidget(
                            isLogin: userData.isLogin,
                            isBeliVideoTeori: userData.isProdukDibeliSiswa(88),
                            userType: userData?.siapa ?? 'No User',
                            idSekolahKelas: userData?.idSekolahKelas ?? '14',
                            userData: userData,
                          ),
                        );
                      }),
                    ),
                  ),
                  promoWidget!,
                  SliverToBoxAdapter(
                    child: GoNewsHomeWidget(userData: userData),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                        height: (context.isMobile)
                            ? context.dp(136)
                            : context.h(120)),
                  ),
                ],
              ),
            );
          },
          child: SliverPadding(
            padding: EdgeInsets.only(
              left: (context.isMobile) ? context.dp(24) : context.dp(18),
              right: (context.isMobile) ? context.dp(24) : context.dp(18),
              bottom: min(32, context.dp(20)),
            ),
            sliver: const SliverToBoxAdapter(child: PromoHomeWidget()),
          ),
        );
      },
    );
  }

  Future<void> _onRefresh({
    required BuildContext context,
    required UserModel? userData,
    bool isRefresh = true,
  }) async {
    context.read<SoalBloc>().add(LoadListBukuSoal(
      isRefresh: isRefresh,
      userData: userData,
    ));
    
    context.read<LeaderboardBloc>().add(LoadFristRankLeaderboard(
        noRegistrasi: userData?.noRegistrasi ?? '',
        idBundlingAktif: userData?.idBundlingAktif ?? 0,
        idSekolah: userData?.idSekolahKelas ?? '14',
        idKota: userData?.idKota ?? '1',
        idGedung: userData?.idGedung ?? '1',
        onRefresh: isRefresh));

    if (!userData.isLogin) return;

    context.read<PembayaranBloc>().add(LoadPembayaran(
          isRefresh: isRefresh,
          noRegistrasi: userData?.noRegistrasi ?? '',
          idbundling: userData?.idBundlingAktif ?? 0,
        ));

    final KehadiranProvider kehadiranProvider =
        context.read<KehadiranProvider>();

    kehadiranProvider.getKehadiranMingguIni(
      isRefresh: isRefresh,
      noRegistrasi: userData?.noRegistrasi ?? '',
    );

    // Jika login, ambil data pengerjaan soal siswa
    context.read<CapaianBloc>().add(LoadCapaian(
          userData: userData,
          isRefresh: isRefresh,
        ));

    context.read<CapaianBarBloc>().add(LoadCapaianBar(
          userData: userData,
          isRefresh: isRefresh,
        ));

    if (!HiveHelper.isBoxOpen<BookmarkMapel>(
        boxName: HiveHelper.kBookmarkMapelBox)) {
      HiveHelper.openBox<BookmarkMapel>(boxName: HiveHelper.kBookmarkMapelBox);
    }

    if (userData?.noRegistrasi != null) {
      context.read<BookmarkBloc>().add(LoadBookmark(
          isSiswa: userData.isSiswa,
          noRegistrasi: userData?.noRegistrasi ?? '',
          isrefresh: isRefresh));
    }

    if (userData?.isBolehPTN == true) {
      context.read<PtnBloc>().add(GetKampusImpian(
            role: userData?.siapa ?? '',
            userData: userData,
          ));
    }

    if (userData?.isSiswa == true) {
      context.read<AuthBloc>().add(AuthRefreshProfileSiswa());
    }

    if (!HiveHelper.isBoxOpen<BookmarkMapel>(
        boxName: HiveHelper.kBookmarkMapelBox)) {
      await HiveHelper.openBox<BookmarkMapel>(
          boxName: HiveHelper.kBookmarkMapelBox);
    }
  }

  /// NOTE: Tempat menyimpan widget method pada class ini------------------------
  // Build Sliver App Bar
  Widget _buildSliverAppBar(BuildContext context) {
    if (context.isMobile) {
      return BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthError) {
            Future.delayed(Duration.zero, () {
              gShowTopFlash(
                context,
                state.err,
                dialogType: DialogType.error,
              );
            });
          }
        },
        child: BlocConsumer<NewsBloc, NewsState>(
          listener: (context, state) {
            String? title;
            if (state is NewsDataLoaded && state.beritaPopUp != null) {
              Future.delayed(Duration.zero, () async {
                final popUpNews = state.beritaPopUp!;

                int storedIdBeritaPopUp =
                    KreasiSharedPref().getIdBeritaPopUp() ?? 0;
                int currentIdBeritaPopUp = int.parse(popUpNews.id);

                /// muncul dialog berita hanya ketia id berita yang tersimpan berbeda dengan id berita yang didapatkan
                if (storedIdBeritaPopUp == currentIdBeritaPopUp) {
                  return;
                }

                if (popUpNews.title.trim().isNotEmpty ||
                    popUpNews.title.trim() != "-") {
                  title = popUpNews.title;
                }

                gShowBottomDialogInfo(
                  gNavigatorKey.currentContext!,
                  displayIcon: false,
                  dialogType: DialogType.info,
                  title: title,
                  message: '',
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (popUpNews.image.isNotEmpty)
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: CustomImageNetwork.rounded(
                              popUpNews.image,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        Text(
                          "\n${popUpNews.summary}",
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.justify,
                          style: context.text.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  actions: (controller) => [
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          gNavigatorKey.currentContext!,
                          Constant.kRouteDetailGoNews,
                          arguments: {
                            'berita': popUpNews,
                          },
                        );
                        controller.dismiss(true);
                      },
                      child: const Text('Lihat detail'),
                    ),
                  ],
                );
              });
            }
          },
          builder: (context, state) {
            return SliverAppBar(
              elevation: 4,
              forceElevated: true,
              stretch: false,
              toolbarHeight: (userData.isTamu)
                  ? context.dp(110)
                  : (!userData.isLogin)
                      ? context.dp(150)
                      : context.dp(200),
              expandedHeight: (userData.isTamu)
                  ? context.dp(110)
                  : (!userData.isLogin)
                      ? context.dp(150)
                      : context.dp(200),
              backgroundColor: context.background,
              foregroundColor: context.background,
              surfaceTintColor: context.background,
              shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: UserInfoAppBar(userData: userData),
              ),
            );
          },
        ),
      );
    }

    return const SliverAppBar(
      backgroundColor: Colors.transparent,
      toolbarHeight: 24,
    );
  }

  // Build Carousal Slider
  SliverPadding _buildCarousal(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(vertical: min(28, context.dp(20))),
      sliver: SliverToBoxAdapter(
        child: CarouselWidget(
          noRegistrasi: userData?.noRegistrasi ?? '',
        ),
      ),
    );
  }

  // Build Impian Kuliah
  SliverPadding _buildImpianKuliah(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.only(
        right: (context.isMobile) ? context.dp(24) : context.dp(18),
        left: (context.isMobile) ? context.dp(24) : context.dp(18),
        bottom: min(28, context.dp(20)),
      ),
      sliver: const SliverToBoxAdapter(child: ImpianKuliahWidget()),
    );
  }

  // Build Juara Buku Sakti
  SliverPadding _buildJuaraBukuSakti(
    BuildContext context,
    UserModel? userData,
  ) {
    final idSekolahKelas = ValueNotifier(userData?.idSekolahKelas);
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: context.dp(12)),
      sliver: SliverToBoxAdapter(
        child: ValueListenableBuilder<String?>(
          valueListenable: idSekolahKelas,
          builder: (_, idSekolahKelas, __) => JuaraBukuSaktiWidget(
            isLogin: userData.isLogin,
            isNotTamu: !userData.isTamu,
            userData: userData,
            idSekolahKelas: idSekolahKelas,
            tahunAjaran: tahunAjaran,
          ),
        ),
      ),
    );
  }

  Future<void> _showBeritaPopUp() async {
    context.read<NewsBloc>().add(LoadBeritaPopUp(userData?.siapa ?? 'UMUM'));
  }

  void _showPromotionPopUp() {
    showDialog(
      context: context,
      builder: (context) => const PromotionWidget(),
    );
  }

  String get tahunAjaran {
    final bulanSekarang = DateTime.now().month;
    final tahunSekarang = DateTime.now().year;
    final tahunDepan = tahunSekarang + 1;
    final tahunKemarin = tahunSekarang - 1;

    final defaultTahunAjaran = (bulanSekarang < 7)
        ? '$tahunKemarin/$tahunSekarang'
        : '$tahunSekarang/$tahunDepan';
    return defaultTahunAjaran;
  }
}
