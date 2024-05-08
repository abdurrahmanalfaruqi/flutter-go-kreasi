import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/entity/kisi_kisi.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/entity/paket_to.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/presentation/bloc/tobk/tobk_bloc.dart';

import '../../../../core/config/extensions.dart';
import '../../../../core/shared/widget/loading/shimmer_list_tiles.dart';

class KisiKisiWidget extends StatefulWidget {
  final String kodePaket;
  final List<NamaKelompokUjian>? listKelompokUjian;
  final int idJenisProduk;

  const KisiKisiWidget({
    Key? key,
    required this.kodePaket,
    required this.idJenisProduk,
    this.listKelompokUjian,
  }) : super(key: key);

  @override
  State<KisiKisiWidget> createState() => _KisiKisiWidgetState();
}

class _KisiKisiWidgetState extends State<KisiKisiWidget> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<TOBKBloc>().add(TOBKGetKisiKisiPaket(
          kodePaket: widget.kodePaket,
          idJenisProduk: widget.idJenisProduk,
        ));
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TOBKBloc, TOBKState>(
      builder: (context, state) {
        if (state is TOBKErrorResponse || state is TOBKError) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: context.dp(10)),
            decoration: BoxDecoration(
                color: context.background,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24))),
            child: Text(
              'Untuk saat ini belum ada kisi - kisi, Sobat',
              textAlign: TextAlign.center,
              style: context.text.labelMedium,
            ),
          );
        }

        if (state is LoadedListKisiKisi) {
          List<String> listNamaKelompokUjian = (widget.listKelompokUjian ?? [])
              .map((e) => e.namaKelompokUjian ?? '')
              .toList();
          List<KisiKisi> listKisiKisi =
              List.from(state.listKisiKisi[widget.kodePaket] ?? [])
                ..sort((a, b) =>
                    listNamaKelompokUjian.indexOf(a.kelompokUjian) -
                    listNamaKelompokUjian.indexOf(b.kelompokUjian));

          return Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: context.dp(24),
              right: context.dp(8),
            ),
            decoration: BoxDecoration(
                color: context.background,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24))),
            child: Scrollbar(
              controller: scrollController,
              thumbVisibility: true,
              trackVisibility: true,
              thickness: 8,
              radius: const Radius.circular(14),
              child: ListView(
                shrinkWrap: true,
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  bottom: context.dp(24),
                  right: context.dp(12),
                  left: context.dp(20),
                ),
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.list_alt_rounded,
                        color: context.tertiaryColor,
                        size: context.dp(32),
                      ),
                      const SizedBox(width: 8),
                      RichText(
                        textScaler: TextScaler.linear(context.textScale12),
                        text: TextSpan(
                            text: 'Kisi - Kisi\n',
                            style: context.text.titleMedium,
                            children: [
                              TextSpan(
                                  text: '(Paket ${widget.kodePaket})',
                                  style: context.text.labelMedium
                                      ?.copyWith(color: context.hintColor))
                            ]),
                        maxLines: 2,
                      )
                    ],
                  ),
                  SizedBox(height: context.dp(10)),
                  if (state.listKisiKisi[widget.kodePaket] != null &&
                      state.listKisiKisi[widget.kodePaket]!.isNotEmpty)
                    ...[
                      Column(
                        children: listKisiKisi
                            .map<Widget>(
                              (kisi) => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 10),
                                  Text(
                                    kisi.kelompokUjian.capitalizeFirstLetter(),
                                    textAlign: TextAlign.center,
                                    style: context.text.labelLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  ...kisi.daftarBab.map<Widget>(
                                    (bab) => SizedBox(
                                      width: double.infinity,
                                      child: Text(
                                        '(${bab.initialMapel}) ~ ${bab.namaBab}',
                                        textAlign: TextAlign.left,
                                        semanticsLabel:
                                            'Bab dan Sub Bab Kisi-Kisi',
                                        style: context.text.bodyMedium
                                            ?.copyWith(
                                                color: context.hintColor),
                                      ),
                                    ),
                                  ),
                                  Divider(height: context.dp(16))
                                ],
                              ),
                            )
                            .toList(),
                      )
                    ].toList()
                ],
              ),
            ),
          );
        }

        if (state is TOBIsLoading) {
          return const ShimmerListTiles(shrinkWrap: true, jumlahItem: 2);
        }

        return Container();
      },
    );
  }
}
