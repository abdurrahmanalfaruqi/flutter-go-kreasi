import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/core/config/constant.dart';
import 'package:gokreasi_new/core/config/enum.dart';
import 'package:gokreasi_new/core/config/global.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/home/presentation/bloc/ptn/ptn_bloc.dart';

import '../widget/ptn_clopedia.dart';
import '../../entity/jurusan.dart';
import '../../entity/kampus_impian.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/screen/basic_screen.dart';

class KampusImpianPickerScreen extends StatefulWidget {
  final int pilihanKe;
  final KampusImpian? kampusPilihan;
  final Map<String, dynamic>? paketTOArguments;
  final int? kodeTOB;

  const KampusImpianPickerScreen({
    Key? key,
    required this.pilihanKe,
    this.kampusPilihan,
    this.paketTOArguments,
    this.kodeTOB,
  }) : super(key: key);

  @override
  State<KampusImpianPickerScreen> createState() =>
      _KampusImpianPickerScreenState();
}

class _KampusImpianPickerScreenState extends State<KampusImpianPickerScreen> {
  late PtnBloc ptnBloc;
  String get pilihanKe => (widget.pilihanKe == 1) ? 'Pertama' : 'Kedua';
  UserModel? userData;
  List<KampusImpian> listKampusImpian = [];
  List<int> listIdJurusan = [];

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is LoadedUser) {
      userData = authState.user;
    }
    ptnBloc = BlocProvider.of<PtnBloc>(context);
  }

  int get nomorKampusImpianSebelumnya {
    if (widget.pilihanKe == 1) {
      return 2;
    }

    return 1;
  }

  int get indexKampusImpianSebelumnya {
    if (widget.pilihanKe == 1) {
      return 1;
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return BasicScreen(
      title: 'Pilih Kampus Impian $pilihanKe',
      body: PtnClopediaWidget(
        // isLandscape: !context.isMobile,
        pilihanKe: widget.pilihanKe,
        kampusPilihan: widget.kampusPilihan,
        // padding: EdgeInsets.only(
        //   top: min(32, context.dp(20)),
        //   left: min(20, context.dp(16)),
        //   right: min(20, context.dp(16)),
        //   bottom: (context.isMobile) ? context.dp(120) : 104,
        // ),
      ),
      bottomNavigationBar: BlocConsumer<PtnBloc, PtnState>(
        builder: (context, state) {
          Jurusan? selectedJurusan;
          if (state is PtnDataLoaded) {
            selectedJurusan = state.selectedJurusan;
            listKampusImpian = state.listKampusPilihan;
            listIdJurusan = state.listKampusPilihan
                .map((jurusan) => jurusan.idJurusan)
                .toList();
          }

          bool isShrink = selectedJurusan == null;

          if (selectedJurusan != null && widget.kampusPilihan != null) {
            isShrink =
                selectedJurusan.idJurusan == widget.kampusPilihan!.idJurusan &&
                    selectedJurusan.idPTN == widget.kampusPilihan!.idPTN;
          }
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeInOut,
            transitionBuilder: (child, animation) {
              final position = Tween<Offset>(
                begin: const Offset(0, 100),
                end: const Offset(0, 0),
              ).animate(animation);
              return SlideTransition(
                position: position,
                child: child,
              );
            },
            child: (isShrink)
                ? const SizedBox.shrink()
                : Container(
                    constraints: BoxConstraints(maxWidth: min(650, context.dw)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 14),
                    decoration: BoxDecoration(
                        color: context.background,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24)),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            offset: Offset(0, -1),
                            blurRadius: 14,
                          )
                        ]),
                    child: Row(
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text((widget.kampusPilihan == null)
                                ? 'Apakah ini kampus impian\npilihan ${pilihanKe.toLowerCase()} kamu Sobat?'
                                : 'Apakah kamu ingin mengubah\npilihan ${pilihanKe.toLowerCase()} kamu Sobat?'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () =>
                              _onClickSaveKampusImpian(selectedJurusan),
                          child: const Text('Ya'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text((widget.kampusPilihan == null)
                              ? 'Tidak'
                              : 'Bukan'),
                        )
                      ],
                    ),
                  ),
          );
        },
        listener: (BuildContext context, PtnState state) async {
          if (state is PtnUpdateSuccess) {
            context.read<PtnBloc>().add(GetKampusImpian(
                  role: userData?.siapa ?? '',
                  userData: userData,
                ));
            await gShowTopFlash(
              context,
              "Data Kampus Impian Berhasil Di Update",
              dialogType: DialogType.success,
            );

            if (!mounted) return;

            if (widget.paketTOArguments == null) {
              Navigator.popUntil(context, (route) {
                // Gantilah kondisi berikut sesuai kebutuhan Anda.
                return route.isFirst ||
                    route.settings.name == Constant.kRouteImpian;
              });
              Navigator.pushReplacementNamed(context, Constant.kRouteImpian);
            } else {
              Navigator.of(context).pop();
            }
          } else if (state is PtnUpdateError) {
            await gShowTopFlash(
              context,
              kDebugMode ? state.errorMessage : gPesanError,
              dialogType: DialogType.error,
            );
            if (mounted) {
              Navigator.popUntil(context, (route) {
                return route.isFirst ||
                    route.settings.name == Constant.kRouteImpian;
              });
              Navigator.pushReplacementNamed(context, Constant.kRouteImpian);
            }
          }
        },
      ),
    );
  }

  /// [_checkJurusanDifferent] digunakan untuk mengecek apakah id jurusan berbeda
  /// <br> return true, apabila id jurusan berbeda
  /// <br> return false, apabila id jurusan sama
  bool _checkJurusanDifferent(int selectedIdJurusan) {
    List<int> listIdJurusanImpian = [...listIdJurusan, selectedIdJurusan];
    for (int i = 0; i < listIdJurusanImpian.length; i++) {
      for (int j = i + 1; j < listIdJurusanImpian.length; j++) {
        if (listIdJurusanImpian[i] == listIdJurusanImpian[j]) {
          return false;
        }
      }
    }

    return true;
  }

  /// [_saveKampusImpian] digunakan untuk save kampus impian
  void _saveKampusImpian(Jurusan? selectedJurusan) {
    int kodeTOB = widget.paketTOArguments == null
        ? (widget.kodeTOB ?? 0)
        : int.parse(widget.paketTOArguments?['kodeTOB']);

    context.read<PtnBloc>().add(
          UpdateKampusImpian(
            pilihanKe: widget.pilihanKe,
            noRegistrasi: userData?.noRegistrasi ?? '',
            idJurusan: selectedJurusan?.idJurusan ?? 0,
            kodeTOB: kodeTOB,
          ),
        );
  }

  void _onClickSaveKampusImpian(Jurusan? selectedJurusan) async {
    if (_checkJurusanDifferent(selectedJurusan?.idJurusan ?? 0)) {
      _saveKampusImpian(selectedJurusan);
    } else {
      int index =
          (listKampusImpian.length == 1) ? 0 : indexKampusImpianSebelumnya;
      String namaPTNImpianSebelumnya = listKampusImpian[index].namaPTN;
      String namaJurusanImpianSebelumnya = listKampusImpian[index].namaJurusan;

      await gShowBottomDialogInfo(
        context,
        title: 'Kamu harus memilih beda jurusan, sobat',
        message: 'Karena pilihan kampus impian kamu di pilihan '
            '$nomorKampusImpianSebelumnya adalah '
            '\n\n$namaPTNImpianSebelumnya, \n$namaJurusanImpianSebelumnya',
        dialogType: DialogType.warning,
      );
    }
  }
}
