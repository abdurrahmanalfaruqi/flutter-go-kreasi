import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/core/config/enum.dart';
import 'package:gokreasi_new/core/config/extensions.dart';
import 'package:gokreasi_new/core/config/global.dart';
import 'package:gokreasi_new/features/home/presentation/bloc/ptn/ptn_bloc.dart';
import 'package:gokreasi_new/features/ptn/module/ptnclopedia/entity/jurusan.dart';
import 'package:gokreasi_new/features/ptn/module/ptnclopedia/entity/ptn.dart';
import 'package:gokreasi_new/features/ptn/module/ptnclopedia/presentation/widget/ptn_jurusan_search_delegate.dart';
import 'package:gokreasi_new/features/ptn/module/ptnclopedia/presentation/widget/ptn_search_delegate.dart';
import 'package:gokreasi_new/features/ptn/module/simulasi/model/pilihan_model.dart';
import 'package:gokreasi_new/features/ptn/module/simulasi/presentation/provider/simulasi_pilihan_provider.dart';
import 'package:provider/provider.dart';

class SimulasiPilihanPTNWidget extends StatefulWidget {
  final List<PilihanModel> listPilihanPTN;
  final String? errorPilihan;

  const SimulasiPilihanPTNWidget({
    super.key,
    required this.listPilihanPTN,
    required this.errorPilihan,
  });

  @override
  State<SimulasiPilihanPTNWidget> createState() =>
      _SimulasiPilihanPTNWidgetState();
}

class _SimulasiPilihanPTNWidgetState extends State<SimulasiPilihanPTNWidget> {
  late final _simulasiPilihanProvider =
      Provider.of<SimulasiPilihanProvider>(context, listen: false);
  PTN? selectedPTN;
  Jurusan? selectedJurusan;

  @override
  void initState() {
    super.initState();
    _simulasiPilihanProvider.updateListPilihanJurusan(widget.listPilihanPTN);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.errorPilihan != null) {
      return Text(
        widget.errorPilihan!,
        style: context.text.bodySmall?.copyWith(color: context.hintColor),
        textAlign: TextAlign.left,
      );
    }

    return BlocListener<PtnBloc, PtnState>(
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

              selectedPTN = await showSearch<PTN?>(
                context: context,
                delegate: PTNSearchDelegate(daftarPTN),
              );

              if (mounted && selectedPTN != null) {
                bool setValue = true;
                // if (widget.kampusPilihan != null) {
                //   setValue = pilihanPTN.idPTN != widget.kampusPilihan!.idPTN;
                // }
                _simulasiPilihanProvider.updatePilihanPTNByIndex(
                  state.index ?? -1,
                  selectedPTN,
                );

                if (setValue) {
                  context
                      .read<PtnBloc>()
                      .add(SetSelectedPTN(selectedPtn: selectedPTN));
                }
              }
            });
          } else if (state.stateType == StatePTNType.selectJurusan &&
              state.eventType == EventPTNType.selectJurusan) {
            Future.delayed(Duration.zero).then((value) async {
              List<Jurusan> listJurusan = state.listJurusan ?? [];

              selectedJurusan = await showSearch<Jurusan?>(
                context: context,
                delegate: JurusanSearchDelegate(
                    listJurusan), // You can use the listJurusan here
              );
              if (mounted && selectedJurusan != null) {
                _simulasiPilihanProvider.updatePilihanJurusanByIndex(
                  state.index ?? -1,
                  selectedJurusan,
                );

                context.read<PtnBloc>().add(SetSelectedJurusan(
                      selectedJurusan: selectedJurusan,
                      selectedPTN: selectedPTN,
                    ));
              }
            });
          }
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: List.generate(
              widget.listPilihanPTN.length,
              (index) {
                final pilihanItem = widget.listPilihanPTN[index];
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.dp(8),
                    vertical: context.dp(10),
                  ),
                  margin: (index != 0)
                      ? EdgeInsets.only(top: context.dp(40))
                      : null,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(context.dp(12)),
                    border: Border.all(
                      color: Colors.black,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Prioritas ${index + 1}',
                            style: context.text.labelSmall,
                          ),
                          const Spacer(),
                          Text(
                            'Pilih ',
                            style: context.text.labelSmall,
                          ),
                          Checkbox(
                            value: pilihanItem.isAktif,
                            onChanged: (val) {
                              _simulasiPilihanProvider.index = index;
                              _simulasiPilihanProvider.toggleSelectPTN();
                            },
                            activeColor: context.secondaryColor,
                            checkColor: context.onSecondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ..._buildPickerButton(
                        index,
                        pilihanItem.namaPTN,
                        pilihanItem.namaJurusan,
                        pilihanItem,
                      ),
                      Text(
                        '*sisa ${pilihanItem.sisaSimulasi} Simulasi',
                        style: context.text.labelSmall,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPickerButton(
    int index,
    PTN? selectedPTN,
    Jurusan? selectedJurusan,
    PilihanModel pilihanPTN,
  ) {
    return [
      _buildOptionButton(
        title: 'Pilihan PTN',
        subTitle: ((selectedPTN?.namaPTN ?? '').isEmpty == true)
            ? 'Pilih Perguruan Tinggi Negeri'
            : (selectedPTN != null && selectedPTN.namaPTN?.isNotEmpty == true)
                ? selectedPTN.namaPTN
                : 'Pilih Perguruan Tinggi Negeri',
        onClick: () => _onClickPilihPTN(index),
        enable: pilihanPTN.isAktif && pilihanPTN.bolehPilihPTN,
      ),
      _buildOptionButton(
        title: 'Pilihan Jurusan',
        subTitle: (selectedJurusan?.namaJurusan?.isEmpty ?? true)
            ? 'Pilih Jurusan'
            : (selectedJurusan != null &&
                    selectedJurusan.namaJurusan?.isNotEmpty == true)
                ? selectedJurusan.namaJurusan
                : 'Pilih Jurusan',
        onClick: () async => await _onClickPilihJurusan(selectedPTN, index),
        enable: pilihanPTN.isAktif && pilihanPTN.bolehPilihPTN,
      ),
    ];
  }

  Widget _buildOptionButton({
    required String? title,
    required String? subTitle,
    required VoidCallback onClick,
    required bool enable,
    EdgeInsetsGeometry? margin,
  }) =>
      Container(
        margin: margin ?? EdgeInsets.only(bottom: min(16, context.dp(12))),
        decoration: BoxDecoration(
          borderRadius: gDefaultShimmerBorderRadius,
          border: Border.all(color: context.disableColor),
          color: (enable) ? null : context.disableColor,
        ),
        child: ListTile(
          onTap: (enable) ? onClick : null,
          tileColor: Colors.transparent,
          trailing: const Icon(Icons.edit),
          title: Text(title ?? '-', style: context.text.bodyMedium),
          subtitle: Text(
            subTitle ?? '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                context.text.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      );

  Future<void> _onClickPilihJurusan(PTN? selectPTN, int index) async {
    _simulasiPilihanProvider.index = index;

    if (selectPTN == null) {
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        'Silahkan pilih PTN terlebih dahulu!',
        dialogType: DialogType.info,
      );
    } else {
      if (mounted) {
        context.read<PtnBloc>().add(SetSelectedPTN(
              selectedPtn: selectPTN,
              statePTNType: StatePTNType.selectJurusan,
              from: EventPTNType.selectJurusan,
              index: index,
            ));
      }
    }
  }

// Add a BlocBuilder to update the UI based on selectedJurusan stat
  Future<void> _onClickPilihPTN(int index) async {
    _simulasiPilihanProvider.index = index;

    context.read<PtnBloc>().add(LoadListPtn(
          from: EventPTNType.selectPTN,
          statePTNType: StatePTNType.selectJurusan,
          index: index,
        ));
  }
}
