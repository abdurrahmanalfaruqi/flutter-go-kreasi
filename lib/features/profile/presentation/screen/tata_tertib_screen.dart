import 'dart:async';
import 'dart:math';

import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:gokreasi_new/core/config/enum.dart';
import 'package:gokreasi_new/core/config/global.dart';
import 'package:gokreasi_new/core/shared/screen/basic_screen.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/profile/presentation/bloc/tata_tertib/tata_tertib_bloc.dart';

import '../../../../core/shared/widget/html/custom_html_widget.dart';
import '../provider/profile_provider.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/shared/widget/html/widget_from_html.dart';

class TataTertibScreen extends StatefulWidget {
  const TataTertibScreen({Key? key}) : super(key: key);

  @override
  State<TataTertibScreen> createState() => _TataTertibScreenState();
}

class _TataTertibScreenState extends State<TataTertibScreen> {
  final ScrollController _scrollController = ScrollController();

  bool _isBottomMessageAppear = false;
  UserModel? userData;
  late TataTertibBlocBloc tataTertibBlocBloc;
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is LoadedUser) {
      userData = authState.user;
    }
    tataTertibBlocBloc = BlocProvider.of<TataTertibBlocBloc>(context);
    tataTertibBlocBloc.add(LoadTataTertib(
      noregister: userData?.noRegistrasi ?? '',
      tahunAjaran: userData?.tahunAjaran ?? '',
    ));
    _scrollController.addListener(_onScrollOffset);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) => (mounted) ? super.setState(fn) : fn();

  void _onScrollOffset() {
    if (_scrollController.offset > 220) {
      if (!_isBottomMessageAppear) {
        setState(() {
          _isBottomMessageAppear = true;
        });
      }
    } else {
      if (_isBottomMessageAppear) {
        setState(() {
          _isBottomMessageAppear = false;
        });
      }
    }
    // logger.log('TATA_TERTIB-OnScroll: Offset >> ${_scrollController.offset}');
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TataTertibBlocBloc, TataTertibBlocState>(
      listener: (context, state) {
        if (state is TataTertibBlocDataLoaded) {
          if (state.hasError) {
            gShowTopFlash(
              context,
              'Terjadi kesalahan saat menyimpan data. Coba lagi nanti ya',
              dialogType: DialogType.error,
            );
          }
        }
      },
      builder: (context, state) {
        if (state is TataTertibBlocLoading) {
          return const BasicScreen(
            title: "Tata Tertib Siswa",
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is TataTertibBlocDataLoaded) {
          return BasicScreen(
              title: "Tata Tertib Siswa",
              body: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(context.textScale11),
                ),
                child: Scaffold(
                  backgroundColor: context.background,
                  floatingActionButtonLocation: (context.isMobile)
                      ? FloatingActionButtonLocation.centerDocked
                      : FloatingActionButtonLocation.endFloat,
                  floatingActionButtonAnimator:
                      FloatingActionButtonAnimator.scaling,
                  floatingActionButton: _buildAnimatedCardMessage(
                    isAppear: _isBottomMessageAppear,
                    isFloating: true,
                    isSudahMenyetujui: context.select<ProfileProvider, bool>(
                        (data) => data.isMenyetujuiAturan),
                  ),
                  body: Scrollbar(
                    controller: _scrollController,
                    thickness: 8,
                    radius: const Radius.circular(14),
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: (context.isMobile)
                              ? EdgeInsets.zero
                              : EdgeInsets.symmetric(
                                  horizontal: (context.dw - 650) / 2),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              _buildAnimatedCardMessage(
                                isAppear: true,
                                isSudahMenyetujui: state.isMenyetujui,
                              ),
                              (state.aturanHtml).contains('table')
                                  ? WidgetFromHtml(
                                      htmlString: state.aturanHtml,
                                    )
                                  : CustomHtml(
                                      htmlString: state.aturanHtml,
                                      replaceStyle: {
                                        'body': Style(
                                          padding: HtmlPaddings.only(
                                            left: min(20, context.dp(14)),
                                            right: min(36, context.dp(28)),
                                          ),
                                        ),
                                        'li': Style(
                                            textAlign: TextAlign.justify,
                                            lineHeight: const LineHeight(1.8)),
                                      },
                                    ),
                              if (!context.isMobile)
                                SizedBox(height: context.dp(38)),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ));
        }
        return BasicScreen(
            title: "Tata Tertib Siswa",
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Gagal Mengambil data data"),
                ElevatedButton(
                  onPressed: () {
                    tataTertibBlocBloc.add(LoadTataTertib(
                      noregister: userData?.noRegistrasi ?? '',
                      tahunAjaran: userData?.tahunAjaran ?? '',
                    ));
                  },
                  child: const Text("Refresh"),
                ),
              ],
            ));
      },
    );
  }

  // Widget _buildAppBar() => Theme(
  //       data: context.themeData.copyWith(
  //         colorScheme: context.colorScheme.copyWith(
  //           onSurface: context.onBackground,
  //           onSurfaceVariant: context.onBackground,
  //           onPrimary: context.onBackground,
  //           surface: context.background,
  //           primary: context.background,
  //           // surfaceTint: context.background,
  //           // surfaceVariant: context.background
  //         ),
  //       ),
  //       child: SliverAppBar.medium(
  //         stretch: true,
  //         centerTitle: true,
  //         automaticallyImplyLeading: false,
  //         title: const Text('Tata Tertib Siswa'),
  //         leading: IconButton(
  //           padding: EdgeInsets.only(
  //             left: min(28, context.dp(24)),
  //             right: min(16, context.dp(12)),
  //           ),
  //           onPressed: () => Navigator.pop(context),
  //           icon: Icon(
  //             Icons.arrow_back_ios_new_rounded,
  //             color: context.onBackground,
  //           ),
  //         ),
  //         backgroundColor: Colors.grey.shade200,
  //         stretchTriggerOffset: 120,
  //         onStretchTrigger: () async {},
  //       ),
  //     );

  SliverToBoxAdapter _buildLoadingWidget() => const SliverToBoxAdapter(
        child: LinearProgressIndicator(),
      );

  Widget _buildAnimatedCardMessage({
    required bool isAppear,
    bool isFloating = false,
    required bool isSudahMenyetujui,
  }) =>
      AnimatedScale(
        curve: Curves.elasticOut,
        scale: isAppear ? 1 : 0,
        duration: const Duration(milliseconds: 800),
        child: _buildCardMessage(isSudahMenyetujui, isFloating),
      );

  Widget _buildCardMessage(bool isSudahMenyetujui, [bool isFloating = false]) {
    return Container(
      constraints: BoxConstraints(
          maxWidth: (context.isMobile)
              ? context.dw
              : (isFloating)
                  ? 460
                  : 650),
      margin: EdgeInsets.symmetric(
        vertical: min(16, context.dp(14)),
        horizontal: min(20, context.dp(18)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: min(18, context.dp(14)),
        vertical: min(16, context.dp(12)),
      ),
      decoration: _messageCardDecoration(isSudahMenyetujui),
      child: _messageCardContentSudahMenyetujui(isSudahMenyetujui),
    );
  }

  BoxDecoration _messageCardDecoration(bool isSudahMenyetujui) => BoxDecoration(
        color: isSudahMenyetujui
            ? context.primaryContainer
            : context.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
            image: AssetImage('assets/img/information.png'),
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            opacity: 0.2),
      );

  Widget _messageCardContentSudahMenyetujui(bool isSudahMenyetujui) {
    if (isSudahMenyetujui) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              '${userData.isOrtu ? 'Anda' : 'Kamu'} telah menyetujui peraturan ini ${userData.isOrtu ? '' : 'Sobat'}!\n',
              maxLines: 1,
              style: context.text.labelLarge
                  ?.copyWith(color: context.onPrimaryContainer)),
          Text(
              '${userData.isOrtu ? 'Anda' : 'Kamu'} sudah mengonfirmasi setuju dengan peraturan ini saat pertama kali mendaftar di Go Expert.',
              style: context.text.labelSmall?.copyWith(
                  color: context.onPrimaryContainer,
                  fontWeight: FontWeight.w400)),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  '${userData.isOrtu ? 'Anda' : 'Kamu'} belum menyetujui peraturan ini ${userData.isOrtu ? '' : 'Sobat'}!',
                  style: context.text.labelLarge
                      ?.copyWith(color: context.onSecondaryContainer)),
              const SizedBox(height: 6),
              Text(
                  '${userData.isOrtu ? 'Anda' : 'Kamu'} harus menyetujui peraturan ini untuk bisa menikmati fasilitas Ganesha Operation. Klik "Saya Setuju" untuk menyetujui Aturan!',
                  textAlign: TextAlign.justify,
                  style: context.text.labelSmall?.copyWith(
                      color: context.onSecondaryContainer,
                      fontWeight: FontWeight.w400)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
            onPressed: () async {
              var completer = Completer();
              context.showBlockDialog(dismissCompleter: completer);

              tataTertibBlocBloc.add(
                  StujuiTataTertib(noregister: userData?.noRegistrasi ?? ''));

              completer.complete();
            },
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 18)),
            child: const Text('Saya\nSetuju', textAlign: TextAlign.center)),
      ],
    );
  }
}
