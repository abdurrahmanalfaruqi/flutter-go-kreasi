import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/home/presentation/bloc/ptn/ptn_bloc.dart';
import 'package:gokreasi_new/features/leaderboard/presentation/bloc/capaian/capaian_bloc.dart';
import 'package:gokreasi_new/features/leaderboard/presentation/bloc/capaianbar/capaianbar_bloc.dart';

import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/config/theme.dart';
import '../../../../core/shared/builder/responsive_builder.dart';
import '../../../../core/shared/widget/animation/custom_rect_tween.dart';
import '../../entity/menu.dart';
import '../provider/menu_provider.dart';

class Menu3B extends StatefulWidget {
  const Menu3B({Key? key, required this.heroTag}) : super(key: key);

  final String heroTag;

  @override
  State<Menu3B> createState() => _Menu3BState();
}

class _Menu3BState extends State<Menu3B> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  UserModel? userData;

  @override
  void initState() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    Future.delayed(const Duration(milliseconds: 340))
        .then((value) => _animController.forward());
    super.initState();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil data isLogin dari Auth Provider.
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is LoadedUser) {
          userData = state.user;
        }

        return _buildBody(context);
      },
    );
  }

  void _navigateTo({
    required String label,
    required int idJenisProduk,
    required String namaJenisProduk,
  }) {
    bool isLogin = userData?.isLogin == true;
    bool isSiswa = userData?.isSiswa == true;
    if (isLogin) {
      switch (label) {
        case 'Soal':
          if (isSiswa) {
            Navigator.pushNamed(context, Constant.kRouteBukuSoalScreen)
                .then((_) {
              _refreshCapaian();
            });
            return;
          }
          break;
        case 'Teori':
          if (isSiswa) {
            Navigator.pushNamed(context, Constant.kRouteBukuTeoriScreen);
            return;
          }
          break;
        case 'TOBK':
          if (isSiswa) {
            Navigator.pushNamed(context, Constant.kRouteTobkScreen, arguments: {
              'idJenisProduk': idJenisProduk,
              'namaJenisProduk': namaJenisProduk,
              'userData': userData,
            }).then((_) {
              _refreshCapaian();
            });
            return;
          }
          break;
        case 'Rencana':
          // Navigator.pushNamed(
          //   context,
          //   Constant.kRouteStoryBoardScreen,
          //   arguments: Constant.kStoryBoard[label]!,
          // );
          // di tutup sampai di kembangkan
          if (isSiswa) {
            Navigator.pushNamed(context, Constant.kRouteRencanaBelajar);
            return;
          }
          break;

        case 'Laporan':
          Navigator.pushNamed(context, Constant.kRouteLaporan);
          return;
        case 'Jadwal':
          if (isLogin) {
            Navigator.pushNamed(context, Constant.kRouteJadwal);
            return;
          }
          break;
        case 'SNBT':
          if (isLogin) {
            context.read<PtnBloc>().add(LoadListPtn());
            Navigator.pushNamed(context, Constant.kRouteSNBT);
          } else {
            Navigator.pushNamed(
              context,
              Constant.kRouteStoryBoardScreen,
              arguments: Constant.kStoryBoard[label]!,
            );
          }
          return;
        case 'Profiling':
          if (isSiswa) {
            Navigator.pushNamed(context, Constant.kRouteProfilingScreen)
                .then((_) {
              _refreshCapaian();
            });
            return;
          }
          break;
        default:
          // Default di atur agar menuju ke 404 Screen.
          Navigator.pushNamed(context, '/$label');
          return;
      }
    }
    // Navigate ke story board saat tidak login.
    Navigator.pushNamed(
      context,
      Constant.kRouteStoryBoardScreen,
      arguments: Constant.kStoryBoard[label]!,
    );
  }

  Align _buildBody(BuildContext context) {
    return Align(
      alignment:
          (context.isMobile) ? Alignment.bottomCenter : Alignment.bottomRight,
      child: Padding(
        padding: EdgeInsets.only(
          right: (context.isMobile) ? 0 : 28,
          bottom: (context.isMobile) ? context.dp(78) : 20,
        ),
        child: Hero(
          tag: widget.heroTag,
          createRectTween: (begin, end) =>
              CustomRectTween(begin: begin, end: end),
          child: Material(
            elevation: 4,
            color: Palette.kSecondarySwatch[400],
            borderRadius: BorderRadius.circular((context.isMobile) ? 32 : 64),
            child: ResponsiveBuilder(
              mobile: _buildMenu3B(
                context,
                BoxConstraints(
                  minWidth: 100,
                  minHeight: 100,
                  maxHeight: context.dh * 0.5,
                  maxWidth: context.dw,
                ),
              ),
              tablet: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 100,
                  minHeight: 100,
                  maxWidth: 650,
                  maxHeight: 460,
                ),
                child: LayoutBuilder(
                  builder: (context, constraint) =>
                      _buildMenu3B(context, constraint),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  SingleChildScrollView _buildMenu3B(
      BuildContext context, BoxConstraints constraint) {
    double maxWidth = (constraint.maxWidth != double.infinity)
        ? constraint.maxWidth
        : (context.isMobile)
            ? context.dw
            : context.dh;

    return SingleChildScrollView(
      padding: EdgeInsets.all(
        (context.isMobile) ? context.dp(20) : context.dp(12),
      ),
      child: AnimatedBuilder(
        animation: _animController.view,
        builder: (_, child) =>
            Opacity(opacity: _animController.value, child: child),
        child: Wrap(
          clipBehavior: Clip.hardEdge,
          spacing: (context.isMobile) ? context.dp(12) : context.dp(6),
          runSpacing: (context.isMobile) ? context.dp(8) : context.dp(4),
          children: [
            _buildMenuTitle(
              context,
              'belajar',
              maxWidth - context.dp(48),
            ),
            _buildSubMenu(
              context,
              MenuProvider.listMenuBelajar,
              (maxWidth - context.dp(85)) / 4,
              maxWidth - context.dp(48),
            ),
            _buildMenuTitle(
              context,
              'berlatih',
              (maxWidth - context.dp(54)) / 2,
            ),
            _buildMenuTitle(
              context,
              'bertanding',
              (maxWidth - context.dp(54)) / 2,
            ),
            _buildSubMenu(
              context,
              MenuProvider.listMenuBerlatih,
              (maxWidth - context.dp(85)) / 4,
              (maxWidth - context.dp(54)) / 2,
            ),
            _buildSubMenu(
              context,
              MenuProvider.listMenuBertanding,
              (maxWidth - context.dp(85)) / 4,
              (maxWidth - context.dp(54)) / 2,
            ),
          ],
        ),
      ),
    );
  }

  /// [_buildMenuTitle] merupakan function untuk menampilkan title dari pengelompokan menu 3B.
  Widget _buildMenuTitle(BuildContext context, String menu, double width) {
    final baseUrl = dotenv.env['BASE_URL_IMAGE'];
    return FittedBox(
      fit: BoxFit.fitWidth,
      child: Image.network(
        '$baseUrl/arsip-mobile/img/txt_$menu.webp',
        width: width,
        height: (context.isMobile) ? context.dp(20) : context.dp(9),
        alignment: Alignment.centerLeft,
      ),
    );
  }

  /// [_buildSubMenu] merupakan function untuk menampilkan subMenu dari masing-masing kelompokan menu 3B.
  Widget _buildSubMenu(BuildContext context, List<Menu> subMenus,
          double subMenuWidth, double containerWidth) =>
      FittedBox(
        fit: BoxFit.fitWidth,
        child: Container(
          width: containerWidth,
          padding: EdgeInsets.symmetric(
            vertical: (context.isMobile) ? context.dp(10) : context.dp(6),
            horizontal: (subMenus.length == 2)
                ? context.dp(6)
                : (context.isMobile)
                    ? context.dp(12)
                    : context.dp(8),
          ),
          decoration: BoxDecoration(
            color: context.surface.withOpacity(0.54),
            borderRadius: BorderRadius.circular((context.isMobile) ? 12 : 32),
          ),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: subMenus
                  .map<Widget>(
                    (subMenu) => GestureDetector(
                      onTap: () => _navigateTo(
                          label: subMenu.label,
                          idJenisProduk: subMenu.idJenis,
                          namaJenisProduk: subMenu.namaJenisProduk),
                      child: CachedNetworkImage(
                        imageUrl: subMenu.iconPath ?? '',
                        width: subMenuWidth,
                        height: subMenuWidth,
                        placeholder: (context, url) => SizedBox(
                          height: 10,
                          width: 10,
                          child: CircularProgressIndicator(
                            color: Palette.kPrimarySwatch[500],
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          return Center(
                            child: Text(
                              'tidak dapat\nmemuat\ngambar',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8,
                                color: Palette.kTertiarySwatch[900],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                  .toList()),
        ),
      );

  void _refreshCapaian() {
    context.read<CapaianBloc>().add(LoadCapaian(
          userData: userData,
          isRefresh: false,
        ));

    context.read<CapaianBarBloc>().add(LoadCapaianBar(
          userData: userData,
          isRefresh: true,
        ));
  }
}
