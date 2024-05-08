import 'dart:developer' as logger show log;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/core/shared/widget/expanded/custom_expansion_tile.dart';
import 'package:gokreasi_new/core/shared/widget/loading/shimmer_list_tiles.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/presentation/bloc/laporan_goa/laporan_goa_bloc.dart';
import '../../entity/paket_to.dart';
import '../../entity/hasil_goa.dart';
import '../../../../../../core/config/enum.dart';
import '../../../../../../core/config/theme.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/widget/image/custom_image_network.dart';

class LaporanGOAWidget extends StatefulWidget {
  final PaketTO paketTO;
  final Future<void> Function(PaketTO paketTO) onHarusMengumpulkan;
  final Future<void> Function(PaketTO paketTO, bool isRemedialGOA)
      onClickNavigateTOSoalTimerScreen;

  const LaporanGOAWidget(
      {Key? key,
      required this.paketTO,
      required this.onClickNavigateTOSoalTimerScreen,
      required this.onHarusMengumpulkan})
      : super(key: key);

  @override
  State<LaporanGOAWidget> createState() => _LaporanGOAWidgetState();
}

class _LaporanGOAWidgetState extends State<LaporanGOAWidget> {
  // late final NavigatorState _navigator = Navigator.of(context);
  final _scrollController = ScrollController();
  UserModel? userData;
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;

    if (authState is LoadedUser) {
      userData = authState.user!;
    }

    context.read<LaporanGoaBloc>().add(LoadLaporanGoa(
          noRegistrasi: userData?.noRegistrasi ?? '',
          paketTO: widget.paketTO,
          ta: userData?.tahunAjaran ?? '',
          kodePaket: widget.paketTO.kodePaket,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LaporanGoaBloc, LaporanGoaState>(
      builder: (context, state) {
        bool isRemedial = false;
        bool pernahMencoba = false;
        bool isBolehRemedial = false;
        bool isHarusMatrikulasi = false;
        int jumlahBintang = 0;
        HasilGOA hasilGOA = HasilGOA(
            isRemedial: isRemedial,
            jumlahPercobaanRemedial: 0,
            detailHasilGOA: [],
            jumlahMaksimalPercobaanRemidial: 2);
        if (state is LaporanGoaLoaded) {
          hasilGOA = state.hasilGOA;
          isRemedial = state.hasilGOA.isRemedial;
          pernahMencoba = state.hasilGOA.jumlahPercobaanRemedial > 0;
          isBolehRemedial = state.hasilGOA.jumlahPercobaanRemedial <
                  state.hasilGOA.jumlahMaksimalPercobaanRemidial &&
              state.hasilGOA.isRemedial;
          isHarusMatrikulasi = state.hasilGOA.jumlahPercobaanRemedial >=
                  state.hasilGOA.jumlahMaksimalPercobaanRemidial &&
              state.hasilGOA.isRemedial;
          jumlahBintang = (isHarusMatrikulasi)
              ? 0
              : 3 - state.hasilGOA.jumlahPercobaanRemedial;

          if (kDebugMode) {
            logger.log(
                'LAPORAN_GOA-Builder: ${state.hasilGOA.jumlahPercobaanRemedial} | $isBolehRemedial | $isHarusMatrikulasi');
          }
        }

        if (!context.isMobile) {
          return Padding(
            padding: EdgeInsets.all(context.dp(12)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      if (!isRemedial || isHarusMatrikulasi)
                        _buildGOAStars(
                            jumlahBintang, context, state is LaporanGoaLoaded),
                      _buildIllustrationImage(
                        context,
                        isRemedial: isRemedial,
                        isHarusMatrikulasi: isHarusMatrikulasi,
                        jumlahBintang: jumlahBintang,
                        isDataAvailable: state is LaporanGoaLoaded,
                      ),
                      SizedBox(height: (isRemedial) ? 26 : 8),
                      _buildTextNarasi(
                        isBolehRemedial,
                        pernahMencoba,
                        isHarusMatrikulasi,
                        context,
                        state,
                      ),
                      if (isRemedial) const SizedBox(height: 8),
                      if (isRemedial)
                        _buildRemedialText(isBolehRemedial, hasilGOA, context),
                    ],
                  ),
                ),
                const VerticalDivider(indent: 24, endIndent: 24, width: 32),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: (hasilGOA.detailHasilGOA.isNotEmpty)
                          ? MainAxisSize.max
                          : MainAxisSize.min,
                      children: [
                        if (state is LaporanGoaLoading) ...[
                          const Expanded(
                            child: ShimmerListTiles(
                              jumlahItem: 3,
                              shrinkWrap: true,
                            ),
                          ),
                        ] else if (state is LaporanGoaError) ...[
                          Text(
                            'Maaf data tidak ditemukan, Sobat',
                            textAlign: TextAlign.center,
                            style: context.text.labelMedium,
                          )
                        ] else ...[
                          if (hasilGOA.detailHasilGOA.isNotEmpty)
                            Expanded(
                              child: Scrollbar(
                                controller: _scrollController,
                                thickness: 8,
                                thumbVisibility: true,
                                trackVisibility: true,
                                radius: const Radius.circular(24),
                                child: ListView(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  children: _detailNilai(hasilGOA),
                                ),
                              ),
                            ),
                          if (isRemedial) const SizedBox(height: 14),
                          if (isBolehRemedial)
                            SizedBox(
                              width: double.infinity,
                              child: _buildElevatedButton(
                                  context, hasilGOA, pernahMencoba),
                            ),
                          if (isRemedial) ...[
                            const SizedBox(height: 8),
                            _buildTextKesempatan(hasilGOA)
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(context.dp(24)),
          children: [
            if (!isRemedial || isHarusMatrikulasi)
              _buildGOAStars(jumlahBintang, context, state is LaporanGoaLoaded),
            _buildIllustrationImage(
              context,
              isRemedial: isRemedial,
              isHarusMatrikulasi: isHarusMatrikulasi,
              jumlahBintang: jumlahBintang,
              isDataAvailable: state is LaporanGoaLoaded,
            ),
            SizedBox(height: (isRemedial) ? 26 : 8),
            _buildTextNarasi(
              isBolehRemedial,
              pernahMencoba,
              isHarusMatrikulasi,
              context,
              state,
            ),
            if (isRemedial) ...[
              const SizedBox(height: 8),
              _buildRemedialText(isBolehRemedial, hasilGOA, context),
            ],
            const Divider(height: 24),
            if (state is LaporanGoaLoading) ...[
              const ShimmerListTiles(
                jumlahItem: 3,
                shrinkWrap: true,
              ),
            ] else if (state is LaporanGoaError) ...[
              Text(
                'Maaf data tidak ditemukan, Sobat',
                textAlign: TextAlign.center,
                style: context.text.labelMedium,
              ),
            ] else ...[
              if (hasilGOA.detailHasilGOA.isNotEmpty) ..._detailNilai(hasilGOA),
              if (isBolehRemedial) ...[
                const Divider(height: 24),
                _buildElevatedButton(context, hasilGOA, pernahMencoba),
              ],
              if (isRemedial) ...[
                const SizedBox(height: 10),
                _buildTextKesempatan(hasilGOA),
              ],
            ],
          ],
        );
      },
    );
  }

  ElevatedButton _buildElevatedButton(
      BuildContext context, HasilGOA hasilGOA, bool pernahMencoba) {
    return ElevatedButton(
        onPressed: () async {
          bool isSiapMengerjakan = false;

          isSiapMengerjakan = await gShowBottomDialog(
            gNavigatorKey.currentState?.context ?? context,
            title:
                'Konfirmasi mulai mengerjakan Remedial Paket ${widget.paketTO.kodePaket}',
            message: 'Pastikan kamu sudah siap dan dalam kondisi nyaman untuk '
                'mengerjakan Remedial Paket ${widget.paketTO.kodePaket}. '
                'Setelah Paket dimulai, kamu tidak dapat keluar dari halaman pengerjaan '
                'sebelum waktu habis / sudah mengumpulkan jawaban. '
                'Siap mengerjakan sekarang Sobat?',
            dialogType: DialogType.warning,
          );

          if (isSiapMengerjakan) {
            widget.onClickNavigateTOSoalTimerScreen(
                widget.paketTO, hasilGOA.isRemedial);
          }
        },
        style: ElevatedButton.styleFrom(
            foregroundColor: context.onSecondary,
            backgroundColor: context.secondaryColor,
            padding: (context.isMobile)
                ? const EdgeInsets.symmetric(vertical: 18, horizontal: 24)
                : const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            textStyle: (context.isMobile) ? null : context.text.labelSmall),
        child:
            Text(pernahMencoba ? 'Coba Remedial Lagi' : 'Remedial Sekarang'));
  }

  Center _buildTextKesempatan(HasilGOA hasilGOA) {
    return Center(
      child: Text(
        'Kesempatan Remedial: ${hasilGOA.jumlahMaksimalPercobaanRemidial - hasilGOA.jumlahPercobaanRemedial}/${hasilGOA.jumlahMaksimalPercobaanRemidial}',
        style: context.text.bodyMedium?.copyWith(
          fontSize: (context.isMobile) ? 14 : 10,
        ),
      ),
    );
  }

  List<Widget> _detailNilai(HasilGOA hasilGOA) => List<Widget>.generate(
        hasilGOA.detailHasilGOA.length,
        (index) {
          var detailHasil = hasilGOA.detailHasilGOA[index];

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: (detailHasil.isLulus)
                ? Palette.kSuccessSwatch[500]
                : context.hintColor,
            child: CustomExpansionTile(
              leading: Icon(detailHasil.isLulus
                  ? Icons.check_circle_outline_rounded
                  : Icons.cancel_outlined),
              title: Text(
                '${detailHasil.namaKelompokUjian} (${detailHasil.isLulus ? 'Lulus' : 'Tidak Lulus'})',
                style: context.text.labelMedium,
              ),
              children: [
                const Divider(
                  indent: 20,
                  endIndent: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 21, bottom: 10),
                  child: RichText(
                    text: TextSpan(style: context.text.labelMedium, children: [
                      const TextSpan(text: 'Target lulus : '),
                      TextSpan(text: '${detailHasil.targetLulus}'),
                    ]),
                  ),
                ),
              ],
            ),
          );

          // return ElevatedButton.icon(
          //   onPressed: null,
          //   icon: Icon(detailHasil.isLulus
          //       ? Icons.check_circle_outline_rounded
          //       : Icons.cancel_outlined),
          //   label: Text(
          //     '${detailHasil.namaKelompokUjian} (${detailHasil.isLulus ? 'Lulus' : 'Tidak Lulus'})',
          //   ),
          //   style: ElevatedButton.styleFrom(
          //     alignment: Alignment.centerLeft,
          //     textStyle: context.text.bodySmall,
          //     disabledBackgroundColor:
          //         detailHasil.isLulus ? Palette.kSuccessSwatch[500] : null,
          //     disabledForegroundColor:
          //         detailHasil.isLulus ? context.background : context.hintColor,
          //   ),
          // );
        },
      );

  Center _buildRemedialText(
      bool isBolehRemedial, HasilGOA hasilGOA, BuildContext context) {
    return Center(
      child: Text(
        isBolehRemedial
            ? 'Tapi tenang, kamu masih punya ${2 - hasilGOA.jumlahPercobaanRemedial} kali '
                'kesempatan untuk mencoba lagi loohh! Semangat Sobat!'
            : 'Kesempatan remedial kamu sudah habis sobat. Kamu harus mengikuti kelas Matrikulasi, '
                'hubungi Customer Service di GO tempat kamu belajar untuk info lebih lanjut ya',
        textAlign: TextAlign.center,
        style: context.text.bodyMedium?.copyWith(
          fontSize: (context.isMobile) ? 14 : 12,
          color: context.hintColor,
        ),
      ),
    );
  }

  Center _buildTextNarasi(
    bool isBolehRemedial,
    bool pernahMencoba,
    bool isHarusMatrikulasi,
    BuildContext context,
    LaporanGoaState laporanGoaState,
  ) {
    return Center(
      child: Text(
        laporanGoaState is LaporanGoaLoading
            ? 'Memuat data...'
            : laporanGoaState is! LaporanGoaLoaded
                ? 'Terjadi Kesalahan'
                : isBolehRemedial
                    ? 'Yaah, Kamu${pernahMencoba ? ' masih' : ''} belum lulus Sobat'
                    : isHarusMatrikulasi
                        ? 'Yaah, kamu masih belum lulus Sobat'
                        : 'Yeay, Kamu lulus GO-Assessment!!!',
        textAlign: TextAlign.center,
        style: context.text.titleMedium,
      ),
    );
  }

  SizedBox _buildIllustrationImage(
    BuildContext context, {
    required bool isRemedial,
    required bool isHarusMatrikulasi,
    required int jumlahBintang,
    required bool isDataAvailable,
  }) {
    return SizedBox(
      width: double.infinity,
      height: (context.isMobile) ? context.dw * 0.5 : 240,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Text(
            widget.paketTO.kodePaket,
            style: TextStyle(
              fontSize: 64,
              color: context.hintColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          CustomImageNetwork(
            isHarusMatrikulasi || !isDataAvailable
                ? 'GOA_gagal.png'.imgUrl
                : isRemedial
                    ? 'GOA_remedial.png'.imgUrl
                    : (jumlahBintang >= 3)
                        ? 'GOA_3_star.png'.imgUrl
                        : (jumlahBintang >= 2)
                            ? 'GOA_3_star.png'.imgUrl
                            : 'GOA_1_star.png'.imgUrl,
            width: (context.isMobile) ? context.dw * 0.5 : 240,
            height: (context.isMobile) ? context.dw * 0.5 : 240,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildGOAStars(
      int jumlahBintang, BuildContext context, bool isDataAvailable) {
    if (!isDataAvailable) {
      return Container();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(
        3,
        (index) => Icon(
          (index < jumlahBintang)
              ? Icons.star_rounded
              : Icons.star_outline_rounded,
          size: min(64, context.dp(62)),
          color: (index < jumlahBintang)
              ? context.secondaryColor
              : context.disableColor,
          semanticLabel: 'Rating-GOA',
        ),
      ),
    );
  }
}
