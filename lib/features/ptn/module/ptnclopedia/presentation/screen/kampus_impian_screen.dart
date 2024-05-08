import 'dart:developer' as logger show log;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/home/presentation/bloc/ptn/ptn_bloc.dart';
import '../widget/kampus_impian/riwayat_item.dart';
import '../widget/kampus_impian/kampus_pilihan_item.dart';
import '../../entity/kampus_impian.dart';
import '../../../../../../core/config/constant.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/widget/empty/basic_empty.dart';
import '../../../../../../core/shared/widget/separator/dash_divider.dart';

class KampusImpianScreen extends StatefulWidget {
  const KampusImpianScreen({Key? key}) : super(key: key);

  @override
  State<KampusImpianScreen> createState() => _KampusImpianScreenState();
}

class _KampusImpianScreenState extends State<KampusImpianScreen> {
  UserModel? userdata;
  late PtnBloc ptnBloc;
  bool isBoleh = false;
  String? kodeTOB;
  List<KampusImpian> listKampusPilihan = [];
  List<KampusImpian> riwayatPilihan = [];

  @override
  void initState() {
    super.initState();
    final authstate = context.read<AuthBloc>().state;
    if (authstate is LoadedUser) {
      userdata = authstate.user;
    }
    ptnBloc = BlocProvider.of<PtnBloc>(context);
    ptnBloc.add(LoadListPtn());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.primaryColor,
      body: Container(
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
        child: BlocBuilder<PtnBloc, PtnState>(
          builder: (context, state) {
            final bool isLoading = state is PtnLoading;
            if (state is PtnDataLoaded) {
              isBoleh = state.isBoleh && userdata.isSiswa;
              kodeTOB = state.kodeTOB;
              listKampusPilihan = state.listKampusPilihan;
              riwayatPilihan = state.riwayatKampusPilihan;
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                _buildAppBar(context),
                if (!context.isMobile)
                  SliverPadding(
                    padding: const EdgeInsets.only(
                      left: 28,
                      right: 28,
                    ),
                    sliver: SliverFillRemaining(
                      fillOverscroll: false,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildKampusImpianPilihan(
                                context, isLoading, isBoleh),
                          ),
                          _buildDashSeparator(context),
                          Expanded(
                            child: _buildRiwayatPilihan(context, isLoading),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (context.isMobile)
                  _buildKampusImpianPilihan(context, isLoading, isBoleh),
                if (context.isMobile && !isBoleh)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20, left: 20),
                      child: _buildIsAllowToChangePTN(),
                    ),
                  ),
                if (context.isMobile) _buildDashSeparator(context),
                if (context.isMobile) _buildRiwayatPilihan(context, isLoading),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildKampusImpianPilihan(
      BuildContext context, bool isLoading, bool isBoleh) {
    if (!context.isMobile) {
      return (isLoading)
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                KampusPilihanItem(
                  isLoading: true,
                  kodeTOB: kodeTOB,
                ),
                KampusPilihanItem(
                  isLoading: true,
                  pilihanKe: 2,
                  kodeTOB: kodeTOB,
                )
              ],
            )
          : Builder(
              builder: (context) {
                if (listKampusPilihan.isEmpty) {
                  return KampusPilihanItem(
                    isOrtu: userdata.isOrtu,
                    isBoleh: isBoleh,
                    kodeTOB: kodeTOB,
                  );
                }

                if (kDebugMode) {
                  logger.log(
                      'KAMPUS_IMPIAN_SCREEN-KampusImpianPilihan: length >> ${listKampusPilihan.length}');
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: List<Widget>.generate(2, (index) {
                        if (listKampusPilihan.length < 2 && index > 0) {
                          return KampusPilihanItem(
                            pilihanKe: 2,
                            isOrtu: userdata.isOrtu,
                            isBoleh: isBoleh,
                            kodeTOB: kodeTOB,
                          );
                        }

                        return KampusPilihanItem(
                          pilihanKe: index + 1,
                          kampusImpian: listKampusPilihan[index],
                          isOrtu: userdata.isOrtu,
                          isBoleh: isBoleh,
                          kodeTOB: kodeTOB,
                        );
                      }),
                    ),
                    Visibility(
                      visible: !context.isMobile && !isBoleh,
                      child: _buildIsAllowToChangePTN(),
                    )
                  ],
                );
              },
            );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: context.dp(20),
        vertical: context.dp(18),
      ),
      sliver: (isLoading)
          ? SliverList(
              delegate: SliverChildListDelegate.fixed(
                [
                  KampusPilihanItem(
                    isLoading: true,
                    kodeTOB: kodeTOB,
                  ),
                  KampusPilihanItem(
                    isLoading: true,
                    pilihanKe: 2,
                    kodeTOB: kodeTOB,
                  ),
                ],
              ),
            )
          : Builder(
              builder: (context) {
                if (listKampusPilihan.isEmpty) {
                  return SliverToBoxAdapter(
                    child: KampusPilihanItem(
                      isOrtu: userdata.isOrtu,
                      isBoleh: isBoleh,
                      kodeTOB: kodeTOB,
                    ),
                  );
                }

                if (kDebugMode) {
                  logger.log(
                      'KAMPUS_IMPIAN_SCREEN-KampusImpianPilihan: length >> ${listKampusPilihan.length}');
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, index) {
                      if (listKampusPilihan.length < 2 && index > 0) {
                        return KampusPilihanItem(
                          pilihanKe: 2,
                          isOrtu: userdata.isOrtu,
                          isBoleh: isBoleh,
                          kodeTOB: kodeTOB,
                        );
                      }

                      return KampusPilihanItem(
                        pilihanKe: index + 1,
                        kampusImpian: listKampusPilihan[index],
                        isOrtu: userdata.isOrtu,
                        isBoleh: isBoleh,
                        kodeTOB: kodeTOB,
                      );
                    },
                    childCount: 2,
                  ),
                );
              },
            ),
    );
  }

  Widget _buildRiwayatPilihan(BuildContext context, bool isLoading) {
    if (!context.isMobile) {
      return (isLoading)
          ? ListView(
              children: const [
                RiwayatPilihan(),
                RiwayatPilihan(),
                RiwayatPilihan(),
                RiwayatPilihan(),
              ],
            )
          : Builder(
              builder: (context) {
                if (riwayatPilihan.isEmpty) {
                  return BasicEmpty(
                    shrink: true,
                    imageUrl: Constant.kStoryBoard['Impian']!['imgUrl'],
                    title: Constant.kStoryBoard['Impian']!['title'],
                    subTitle: Constant.kStoryBoard['Impian']!['subTitle'],
                    emptyMessage: Constant.kStoryBoard['Impian']!['storyText'],
                  );
                }

                riwayatPilihan
                    .sort((a, b) => a.tanggalPilih.compareTo(b.tanggalPilih));
                riwayatPilihan = riwayatPilihan.reversed.toList();

                return ListView.builder(
                  itemBuilder: (context, index) =>
                      RiwayatPilihan(kampusRiwayat: riwayatPilihan[index]),
                  itemCount: riwayatPilihan.length,
                );
              },
            );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(
        vertical: context.dp(30),
        horizontal: context.dp(20),
      ),
      sliver: (isLoading)
          ? const SliverList(
              delegate: SliverChildListDelegate.fixed(
                [
                  RiwayatPilihan(),
                  RiwayatPilihan(),
                  RiwayatPilihan(),
                  RiwayatPilihan(),
                ],
              ),
            )
          : Builder(
              builder: (context) {
                if (riwayatPilihan.isEmpty) {
                  return SliverToBoxAdapter(
                    child: BasicEmpty(
                      shrink: true,
                      imageUrl: Constant.kStoryBoard['Impian']!['imgUrl'],
                      title: Constant.kStoryBoard['Impian']!['title'],
                      subTitle: Constant.kStoryBoard['Impian']!['subTitle'],
                      emptyMessage:
                          Constant.kStoryBoard['Impian']!['storyText'],
                    ),
                  );
                }

                riwayatPilihan
                    .sort((a, b) => a.tanggalPilih.compareTo(b.tanggalPilih));
                riwayatPilihan = riwayatPilihan.reversed.toList();

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, index) =>
                        RiwayatPilihan(kampusRiwayat: riwayatPilihan[index]),
                    childCount: riwayatPilihan.length,
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDashSeparator(BuildContext context) {
    if (!context.isMobile) {
      return SizedBox(
        width: 82,
        height: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              top: 0,
              bottom: 0,
              child: DashedDivider(
                dashColor: context.onPrimary,
                strokeWidth: 3,
                dash: 6,
                direction: Axis.vertical,
              ),
            ),
            RotatedBox(
              quarterTurns: 3,
              child: Chip(
                label: const Text('Riwayat Pilihan'),
                labelStyle: context.text.bodyMedium,
                backgroundColor: context.background,
                surfaceTintColor: context.onBackground,
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              ),
            )
          ],
        ),
      );
    }

    return SliverToBoxAdapter(
      child: SizedBox(
        width: double.infinity,
        height: context.dp(32),
        child: Stack(
          alignment: Alignment.center,
          children: [
            DashedDivider(
              dashColor: context.onPrimary,
              strokeWidth: 2,
              dash: 6,
              direction: Axis.horizontal,
            ),
            Chip(
              label: const Text('Riwayat Pilihan'),
              labelStyle: context.text.bodyMedium,
              backgroundColor: context.background,
              surfaceTintColor: context.onBackground,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            )
          ],
        ),
      ),
    );
  }

  Theme _buildAppBar(BuildContext context) {
    return Theme(
      data: context.themeData.copyWith(
        colorScheme: context.colorScheme.copyWith(
          onSurface: context.onPrimary,
          onSurfaceVariant: context.onPrimary,
        ),
      ),
      child: SliverAppBar.large(
        pinned: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          iconSize: 32,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        backgroundColor: context.primaryColor,
        title: const Text('Kampus Impian Kamu'),
      ),
    );
  }

  Text _buildIsAllowToChangePTN() => Text(
        (userdata?.isOrtu == true)
            ? "* Hanya siswa yang dapat merubah Pilihan PTN Impian"
            : "* Pilihan kampus impian hanya dapat diganti H-1 & saat periode TOBK Pola UTBK sedang aktif",
        style: const TextStyle(color: Colors.black, fontSize: 12),
      );
}
