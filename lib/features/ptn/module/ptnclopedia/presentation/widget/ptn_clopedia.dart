import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/core/config/enum.dart';
import 'package:gokreasi_new/features/home/presentation/bloc/ptn/ptn_bloc.dart';
import 'line_chart_peminat.dart';
import 'ptn_search_delegate.dart';
import 'ptn_jurusan_search_delegate.dart';
import '../../entity/ptn.dart';
import '../../entity/jurusan.dart';
import '../../entity/kampus_impian.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/theme.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/widget/empty/basic_empty.dart';

class PtnClopediaWidget extends StatefulWidget {
  final int? pilihanKe;
  final KampusImpian? kampusPilihan;
  final EdgeInsetsGeometry? padding;
  final bool isLandscape;
  final bool isSimulasi;

  const PtnClopediaWidget({
    super.key,
    this.pilihanKe,
    this.kampusPilihan,
    this.padding,
    this.isLandscape = false,
    this.isSimulasi = false,
  });

  @override
  State<PtnClopediaWidget> createState() => _PtnClopediaWidgetState();
}

class _PtnClopediaWidgetState extends State<PtnClopediaWidget> {
  late PtnBloc ptnBloc;
  PTN? selectedPTN;
  Jurusan? selectedJurusan;

  @override
  void initState() {
    super.initState();
    ptnBloc = BlocProvider.of<PtnBloc>(context);
    if (widget.kampusPilihan != null) {
      ptnBloc.add(GetDetailJurusan(kampusImpian: widget.kampusPilihan!));
    } else {
      ptnBloc.add(PTNResetSelectedPTN());
    }
  }

  @override
  void dispose() {
    super.dispose();
    selectedPTN = null;
    selectedJurusan = null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PtnBloc, PtnState>(
      listener: (context, state) {
        if (state is PTNErrorPopUp) {
          Future.delayed(Duration.zero, () {
            gShowTopFlash(
              context,
              kDebugMode ? state.err : gPesanError,
              dialogType: DialogType.error,
            );
          });
        }

        if (state is PtnDataLoaded) {
          if (state.stateType == StatePTNType.selectJurusan &&
              state.eventType == EventPTNType.selectPTN) {
            Future.delayed(Duration.zero).then((value) async {
              List<PTN> daftarPTN = state.listPTN ?? [];

              PTN? pilihanPTN = await showSearch<PTN?>(
                context: context,
                delegate: PTNSearchDelegate(daftarPTN),
              );

              if (mounted && pilihanPTN != null) {
                bool setValue = true;
                if (widget.kampusPilihan != null) {
                  setValue = pilihanPTN.idPTN != widget.kampusPilihan!.idPTN;
                }
                if (setValue) {
                  context
                      .read<PtnBloc>()
                      .add(SetSelectedPTN(selectedPtn: pilihanPTN));
                }
              }
            });
          } else if (state.stateType == StatePTNType.selectJurusan &&
              state.eventType == EventPTNType.selectJurusan) {
            Future.delayed(Duration.zero).then((value) async {
              List<Jurusan> listJurusan = state.listJurusan ?? [];

              Jurusan? pilihanJurusan = await showSearch<Jurusan?>(
                context: context,
                delegate: JurusanSearchDelegate(
                    listJurusan), // You can use the listJurusan here
              );
              if (mounted && pilihanJurusan != null) {
                context.read<PtnBloc>().add(SetSelectedJurusan(
                      selectedJurusan: pilihanJurusan,
                      selectedPTN: selectedPTN,
                    ));
              }
            });
          }
        }
      },
      builder: (context, state) {
        if (state is PtnLoading) {
          String detailTextLoading = '';
          if (state.event == EventPTNType.selectPTN) {
            detailTextLoading = 'PTN';
          } else if (state.event == EventPTNType.selectJurusan) {
            detailTextLoading = 'Jurusan';
          } else {
            detailTextLoading = 'Detail Jurusan';
          }

          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text(
                  'Sedang menyiapkan data\n$detailTextLoading...',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (state is PtnError) {
          return SingleChildScrollView(
              child: Padding(
            padding: widget.padding ??
                EdgeInsets.only(
                  top: min(38, context.dp(20)),
                  left: min(28, context.dp(16)),
                  right: min(28, context.dp(16)),
                  bottom: (widget.isLandscape) ? 48 : context.dp(32),
                ),
            child: Column(
              children: [
                ..._buildPickerButton(null, null),
                BasicEmpty(
                  shrink: true,
                  isLandscape: widget.isLandscape,
                  imageUrl: 'ilustrasi_sbmptn.png'.illustration,
                  title: (widget.isSimulasi) ? 'Simulasi SNBT' : 'PTN-Clopedia',
                  subTitle: 'Mau cari info jurusan apa Sobat?',
                  emptyMessage: 'Pilih Jurusan terlebih dahulu ya Sobat',
                ),
              ],
            ),
          ));
        }

        if (state is PtnDataLoaded &&
            state.stateType != StatePTNType.selectJurusan &&
            state.eventType != EventPTNType.selectPTN &&
            state.stateType != StatePTNType.selectJurusan &&
            state.eventType != EventPTNType.selectJurusan) {
          selectedPTN = state.selectedPTN;
          selectedJurusan = state.selectedJurusan;
        }

        return SingleChildScrollView(
          child: Padding(
            padding: widget.padding ??
                EdgeInsets.only(
                  top: min(38, context.dp(20)),
                  left: min(28, context.dp(16)),
                  right: min(28, context.dp(16)),
                  bottom: (widget.isLandscape) ? 48 : context.dp(32),
                ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.isLandscape)
                  Row(
                    children: List<Expanded>.generate(
                      _buildPickerButton(selectedPTN, selectedJurusan).length,
                      (index) => Expanded(
                        child: _buildPickerButton(
                            selectedPTN, selectedJurusan)[index],
                      ),
                    ),
                  ),
                if (!widget.isLandscape)
                  ..._buildPickerButton(selectedPTN, selectedJurusan),
                if (selectedPTN == null &&
                    widget.kampusPilihan == null &&
                    selectedJurusan == null)
                  BasicEmpty(
                    shrink: true,
                    isLandscape: widget.isLandscape,
                    imageUrl: 'ilustrasi_sbmptn.png'.illustration,
                    title:
                        (widget.isSimulasi) ? 'Simulasi SNBT' : 'PTN-Clopedia',
                    subTitle: 'Mau cari info jurusan apa Sobat?',
                    emptyMessage: 'Pilih Jurusan terlebih dahulu ya Sobat',
                  ),
                if ((selectedPTN != null || widget.kampusPilihan != null) &&
                    selectedJurusan == null)
                  BasicEmpty(
                    shrink: true,
                    isLandscape: widget.isLandscape,
                    imageUrl: 'ilustrasi_sbmptn.png'.illustration,
                    title:
                        (widget.isSimulasi) ? 'Simulasi SNBT' : 'PTN-Clopedia',
                    subTitle: 'Mau cari info jurusan apa Sobat?',
                    emptyMessage:
                        'Pilih PTN dan Jurusan terlebih dahulu ya Sobat',
                  ),
                if (!widget.isLandscape &&
                    (selectedPTN != null || widget.kampusPilihan != null) &&
                    selectedJurusan != null &&
                    selectedJurusan?.namaJurusan?.isNotEmpty == true)
                  ..._displayInformasi(
                      selectedPTN?.namaPTN ?? widget.kampusPilihan!.namaPTN,
                      selectedJurusan ?? Jurusan()),
                if (widget.isLandscape &&
                    (selectedPTN != null || widget.kampusPilihan != null) &&
                    selectedJurusan != null &&
                    selectedJurusan?.namaJurusan?.isNotEmpty == true)
                  ..._displayInformationHeader(
                      selectedPTN?.namaPTN ?? widget.kampusPilihan!.namaPTN,
                      selectedJurusan ?? Jurusan()),
                if (widget.isLandscape &&
                    (selectedPTN != null || widget.kampusPilihan != null) &&
                    selectedJurusan != null &&
                    selectedJurusan?.namaJurusan?.isNotEmpty == true)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: _displayInformasi(
                                selectedPTN?.namaPTN ??
                                    widget.kampusPilihan!.namaPTN,
                                selectedJurusan ?? Jurusan()),
                          ),
                        ),
                        const VerticalDivider(width: 32),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: _displayInformasiDeskripsi(
                                selectedJurusan ?? Jurusan()),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onClickPilihJurusan(PTN? selectPTN) async {
    if (selectPTN == null && widget.kampusPilihan == null) {
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        'Silahkan pilih PTN terlebih dahulu!',
        dialogType: DialogType.info,
      );
      return;
    }

    if (!mounted || selectPTN == null) {
      return;
    }

    context.read<PtnBloc>().add(SetSelectedPTN(
          selectedPtn: selectedPTN,
          statePTNType: StatePTNType.selectJurusan,
          from: EventPTNType.selectJurusan,
        ));
  }

  Future<void> _onClickPilihPTN() async {
    context.read<PtnBloc>().add(LoadListPtn(
          from: EventPTNType.selectPTN,
          statePTNType: StatePTNType.selectJurusan,
        ));
  }

  List<Widget> _buildPickerButton(PTN? selectedPTN, Jurusan? selectedJurusan) {
    return [
      _buildOptionButton(
          title: 'Pilihan PTN',
          subTitle: (((selectedPTN?.namaPTN ?? '').isEmpty == true) &&
                  widget.kampusPilihan == null)
              ? 'Pilih Perguruan Tinggi Negeri'
              : (selectedPTN != null && selectedPTN.namaPTN?.isNotEmpty == true)
                  ? selectedPTN.namaPTN
                  : widget.kampusPilihan?.namaPTN ??
                      'Pilih Perguruan Tinggi Negeri',
          margin: (widget.isLandscape)
              ? const EdgeInsets.only(right: 16, bottom: 32)
              : null,
          onClick: _onClickPilihPTN),
      _buildOptionButton(
          title: 'Pilihan Jurusan',
          subTitle: (selectedJurusan?.namaJurusan?.isEmpty ?? true) &&
                  (widget.kampusPilihan == null ||
                      widget.kampusPilihan?.idPTN != selectedPTN?.idPTN)
              ? 'Pilih Jurusan'
              : (selectedJurusan != null &&
                      selectedJurusan.namaJurusan?.isNotEmpty == true)
                  ? selectedJurusan.namaJurusan
                  : widget.kampusPilihan?.namaJurusan ?? 'Pilih Jurusan',
          margin: (widget.isLandscape)
              ? const EdgeInsets.only(left: 16, bottom: 32)
              : EdgeInsets.only(bottom: min(28, context.dp(24))),
          onClick: () async => await _onClickPilihJurusan(selectedPTN)),
    ];
  }

  Widget _buildOptionButton({
    required String? title,
    required String? subTitle,
    required VoidCallback onClick,
    EdgeInsetsGeometry? margin,
  }) =>
      Container(
        margin: margin ?? EdgeInsets.only(bottom: min(16, context.dp(12))),
        decoration: BoxDecoration(
            borderRadius: gDefaultShimmerBorderRadius,
            border: Border.all(color: context.disableColor)),
        child: ListTile(
          onTap: onClick,
          tileColor: Colors.transparent,
          trailing: const Icon(Icons.edit),
          title: Text(title ?? '-', style: context.text.bodyMedium),
          subtitle: Text(
            subTitle ?? '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      );

  Row _buildTitle(BuildContext context, String title,
          {bool isSubTitle = false}) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style:
                isSubTitle ? context.text.titleMedium : context.text.titleLarge,
          ),
          const Expanded(
            child: Divider(
                thickness: 1, indent: 8, endIndent: 8, color: Colors.black26),
          ),
        ],
      );

  List<Widget> _buildItem(String title, String isi) => [
        SizedBox(height: context.dp(20)),
        _buildTitle(context, title, isSubTitle: true),
        SizedBox(height: context.dp(12)),
        Padding(
          padding: EdgeInsets.only(left: context.dp(12)),
          child: Text(
            isi,
            style: context.text.bodyMedium?.copyWith(
              color: context.onBackground.withOpacity(0.76),
            ),
          ),
        ),
      ];

  List<Widget> _displayInformationHeader(
    String namaPTN,
    Jurusan selectedJurusan,
  ) =>
      [
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.tertiaryColor)),
            child: Text(
              selectedJurusan.kelompok ?? '',
              style: context.text.labelLarge
                  ?.copyWith(color: context.tertiaryColor),
            ),
          ),
          title: Text(namaPTN,
              style:
                  context.text.labelLarge?.copyWith(color: context.hintColor)),
          subtitle: Text(selectedJurusan.namaJurusan ?? '',
              style: context.text.titleMedium),
        ),
        const Divider(height: 18, color: Colors.black54),
        Row(
          children: [
            Text('Lintas Jurusan: ', style: context.text.labelMedium),
            Icon(
              (selectedJurusan.lintas == true)
                  ? Icons.check_circle_outline_rounded
                  : Icons.cancel_outlined,
              color: (selectedJurusan.lintas == true)
                  ? Palette.kSuccessSwatch
                  : context.errorColor,
            )
          ],
        ),
      ];

  List<Widget> _displayInformasiDeskripsi(
    Jurusan selectedJurusan,
  ) =>
      [
        // if (widget.isLandscape) const SizedBox(height: 120),
        if (selectedJurusan.deskripsi != null)
          ..._buildItem('Deskripsi Jurusan', selectedJurusan.deskripsi!),
        if (selectedJurusan.lapanganPekerjaan != null)
          ..._buildItem('Lapangan Kerja', selectedJurusan.lapanganPekerjaan!),
          const SizedBox(height: 50),
      ];

  List<Widget> _displayInformasi(
    String namaPTN,
    Jurusan selectedJurusan,
  ) =>
      [
        if (!widget.isLandscape)
          ..._displayInformationHeader(namaPTN, selectedJurusan),
        if (selectedJurusan.peminat?.isNotEmpty == true)
          LineChartPeminat(
            peminat: selectedJurusan.peminat ?? [],
            dayaTampung: selectedJurusan.tampung ?? [],
          ),
        if (selectedJurusan.peminat?.isNotEmpty == true)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Chip(
                  label: Text(
                    'Jumlah Peminat',
                    style: context.text.bodySmall
                        ?.copyWith(color: context.onSecondary),
                  ),
                  backgroundColor: context.secondaryColor),
              Chip(
                  label: Text(
                    'Daya Tampung',
                    style: context.text.bodySmall
                        ?.copyWith(color: context.onPrimary),
                  ),
                  backgroundColor: context.primaryColor),
            ],
          ),
        if (!widget.isLandscape) ..._displayInformasiDeskripsi(selectedJurusan),
      ];
}
