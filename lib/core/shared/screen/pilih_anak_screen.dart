import 'dart:async';
import 'dart:math';

import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/core/config/constant.dart';
import 'package:gokreasi_new/core/config/enum.dart';
import 'package:gokreasi_new/core/config/extensions.dart';
import 'package:gokreasi_new/core/config/global.dart';
import 'package:gokreasi_new/core/config/theme.dart';
import 'package:gokreasi_new/core/helper/kreasi_shared_pref.dart';
import 'package:gokreasi_new/core/shared/builder/responsive_builder.dart';
import 'package:gokreasi_new/core/shared/widget/expanded/custom_expansion_tile.dart';
import 'package:gokreasi_new/core/shared/widget/loading/shimmer_list_tiles.dart';
import 'package:gokreasi_new/features/auth/data/model/bundling_model.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/pilih_anak/pilih_anak_bloc.dart';
import 'package:gokreasi_new/features/profile/presentation/widget/user_avatar.dart';

class PilihAnakScreen extends StatefulWidget {
  final String nomorHpOrtu;
  final String? noRegistrasiRefresh;
  final UserModel? userData;
  final bool isRefresh;
  const PilihAnakScreen({
    super.key,
    required this.nomorHpOrtu,
    this.noRegistrasiRefresh,
    this.userData,
    this.isRefresh = false,
  });

  @override
  State<PilihAnakScreen> createState() => _PilihAnakScreenState();
}

class _PilihAnakScreenState extends State<PilihAnakScreen> {
  late final _navigator = Navigator.of(context);
  List<Anak> listAnak = [];
  Bundling? selectedBundling;
  var completer = Completer();

  @override
  void initState() {
    super.initState();

    if (widget.isRefresh) {
      _onRefreshAnak();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          bool isLoading = state is AuthLoading;

          if (isLoading) {
            context.showBlockDialog(dismissCompleter: completer);
          }

          if (!completer.isCompleted && !isLoading) {
            completer.complete();
          }
        },
        child: BlocConsumer<PilihAnakBloc, PilihAnakState>(
          listener: (context, state) {
            if (state is PilihAnakError) {
              Future.delayed(Duration.zero, () {
                gShowTopFlash(
                  context,
                  state.err,
                  dialogType: DialogType.error,
                );
              });
              Navigator.of(context).pop();
            }
          },
          builder: (context, state) {
            if (state is PilihAnakLoading) {
              return _buildLoadingAnak();
            }

            if (state is LoadedListAnak) {
              listAnak = state.listAnak;
            }

            return BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthErrorLogin) {
                  Future.delayed(Duration.zero, () async {
                    await gShowTopFlash(
                      context,
                      state.err,
                      dialogType: DialogType.error,
                    );
                  });
                }

                if (state is LoadedUser &&
                    state.user != null &&
                    widget.noRegistrasiRefresh != null) {
                  Future.delayed(Duration.zero, () async {
                    await gShowTopFlash(
                      context,
                      'Selamat datang ${state.user?.namaLengkap}',
                      dialogType: DialogType.success,
                    );
                    _navigator.pushNamedAndRemoveUntil(
                        Constant.kRouteMainScreen, (route) => false);
                  });
                }
              },
              child: SafeArea(
                child: ResponsiveBuilder(
                  mobile: Column(
                    children: [
                      _buildTitleHeader(context),
                      Flexible(
                        child: _buildExpansionAnak(listAnak),
                      ),
                    ],
                  ),
                  tablet: Row(
                    children: [
                      Expanded(
                        flex: (context.dw > 1100) ? 3 : 4,
                        child: _buildTitleHeader(context),
                      ),
                      Expanded(
                        flex:
                            (context.isLandscape && context.dw > 1100) ? 6 : 6,
                        child: _buildExpansionAnak(listAnak),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildExpansionAnak(List<Anak> listAnak) {
    return ListView.separated(
      itemCount: listAnak.length,
      separatorBuilder: (context, index) => const Divider(
        indent: 20,
        endIndent: 20,
      ),
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        bottom:
            MediaQuery.of(context).viewInsets.bottom + min(24, context.dp(18)),
      ),
      itemBuilder: (context, index) {
        bool selectedAnak =
            widget.userData?.noRegistrasi == listAnak[index].noRegistrasi;
        return CustomExpansionTile(
          title: Text(
            listAnak[index].namaLengkap,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: UserAvatar(
            key: ValueKey('SWITCH_USER_AVATAR-${listAnak[index].noRegistrasi}'
                '-${listAnak[index].nomorHandphone}'),
            tag: listAnak[index].namaLengkap,
            anak: listAnak[index],
            size: (context.isMobile) ? 54 : 32,
            borderColor: (selectedAnak)
                ? Palette.kSuccessSwatch[500]
                : context.hintColor,
            fromSwitchAccount: true,
          ),
          subtitle: Text(listAnak[index].noRegistrasi),
          children: listAnak[index]
                  .listBundling
                  ?.map<Widget>((item) => _buildListBundling(
                        bundling: item,
                        selectedAnak: listAnak[index],
                      ))
                  .toList() ??
              [],
        );
      },
    );
  }

  Widget _buildListBundling({
    required Bundling bundling,
    required Anak selectedAnak,
  }) {
    bool isSelected = widget.userData?.idBundlingAktif == bundling.idBundling;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: min(64, context.dp(18)),
        vertical: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              offset: const Offset(0, 1),
              blurRadius: 6,
              spreadRadius: 1,
              color: context.tertiaryColor.withOpacity(0.2))
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? context.secondaryContainer : Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isSelected
              ? null
              : () {
                  context.read<AuthBloc>().add(AuthLoginOrtu(
                        noRegistrasiRefresh: widget.noRegistrasiRefresh,
                        noregOrtu: selectedAnak.noRegistrasiOrtu ?? '',
                        noregAnak: selectedAnak.noRegistrasi,
                        idBundlingAktif: bundling.idBundling ?? 0,
                        deviceId: selectedAnak.deviceId ?? '',
                        daftarBundling: selectedAnak.daftarBundling ?? [],
                        daftarAnak: selectedAnak.daftarAnak ?? [],
                        listIdProduk: selectedAnak.listIdProduk ?? [],
                        daftarProduk: selectedAnak.daftarProduk ?? [],
                        nomorHpOrtu: widget.nomorHpOrtu,
                      ));
                },
          child: ListTile(
            title: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${bundling.namaBundling}\n',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                      text: '${bundling.tahunAjaran}',
                      style: context.text.labelMedium
                          ?.copyWith(color: Colors.black)),
                  // TextSpan(
                  //     text: bundling.idBundling.toString(),
                  //     style: context.text.labelMedium?.copyWith(color: Colors.black))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding _buildTitleHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: (context.isMobile) ? context.dp(8) : context.dp(5),
        right: (context.isMobile) ? context.dp(24) : context.dp(5),
        top: (context.isMobile) ? context.dp(24) : 0,
        bottom: (context.isMobile) ? context.dp(24) : 0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(
            visible: !context.isMobile,
            child: Image.asset(
              'assets/img/logo_kreasi.webp',
              width: min(120, context.dp(90)),
              height: min(120, context.dp(90)),
            ),
          ),
          Row(
            children: [
              Visibility(
                visible: context.isMobile,
                child: Image.asset(
                  'assets/img/logo_kreasi.webp',
                  width: min(120, context.dp(90)),
                  height: min(120, context.dp(90)),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: context.dp(268),
                      child: FittedBox(
                        child: RichText(
                          text: TextSpan(
                              text: 'Halo Orang Tua dari sobat GO\n',
                              children: [
                                TextSpan(
                                  text: 'Selamat datang di Go Expert',
                                  style: context.text.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                              style: context.text.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          maxLines: 2,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          textScaler: TextScaler.linear(context.textScale14),
                        ),
                      ),
                    ),
                    SizedBox(height: context.h(16)),
                    SizedBox(
                      width: context.dp(268),
                      child: FittedBox(
                        child: Text(
                          'Silahkan pilih anak akun Anda terlebih dahulu.',
                          style: context.text.bodySmall,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingAnak() {
    if (context.isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 45),
          _buildTitleHeader(context),
          Expanded(
            child: ShimmerListTiles(jumlahItem: (context.isMobile) ? 5 : 15),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          flex: (context.dw > 1100) ? 3 : 4,
          child: _buildTitleHeader(context),
        ),
        Expanded(
          flex: (context.isLandscape && context.dw > 1100) ? 6 : 6,
          child: ShimmerListTiles(jumlahItem: (context.isMobile) ? 8 : 15),
        ),
      ],
    );
  }

  void _onRefreshAnak() {
    final nomorHpOrtu = KreasiSharedPref().getNomorHpOrtu() ?? '';
    context.read<PilihAnakBloc>().add(GetAnakList(nomorHpOrtu: nomorHpOrtu));
  }
}
