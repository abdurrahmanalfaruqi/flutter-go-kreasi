import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/ptn/module/simulasi/presentation/bloc/simulasi/simulasi_bloc.dart';
import 'package:gokreasi_new/features/ptn/module/simulasi/presentation/widget/simulasi_pilihan_ptn_widget.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../../../core/config/enum.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/widget/empty/no_data_found.dart';
import '../../../../../../core/shared/widget/loading/shimmer_widget.dart';
import '../../../../../../core/shared/widget/refresher/custom_smart_refresher.dart';
import '../../model/nilai_model.dart';
import '../provider/simulasi_pilihan_provider.dart';
import '../provider/simulasi_hasil_provider.dart';
import '../provider/simulasi_nilai_provider.dart';
import '../widget/simulasi_hasil_widget.dart';

class SimulasiScreen extends StatefulWidget {
  const SimulasiScreen({Key? key}) : super(key: key);

  @override
  State<SimulasiScreen> createState() => _SimulasiScreenState();
}

class _SimulasiScreenState extends State<SimulasiScreen> {
  StepperType stepperType = StepperType.vertical;
  int _currentStep = 0;
  final ScrollController scrollController = ScrollController();

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  late final SimulasiBloc _simulasiBloc =
      BlocProvider.of<SimulasiBloc>(context);
  late final _simulasiPilihanProvider =
      Provider.of<SimulasiPilihanProvider>(context, listen: false);
  UserModel? userdata;

  /// [nilaiAkhir] ,
  /// [kodeTOB] ,
  /// [detailNilai] digunakan untuk request body ke BE save pilihan PTN
  int? nilaiAkhir;
  int? kodeTOB;
  String? detailNilai;

  @override
  void initState() {
    super.initState();
    final authstate = context.read<AuthBloc>().state;
    if (authstate is LoadedUser) {
      userdata = authstate.user;
    }

    /// The below code is getting the user data from the auth provider.

    /// Calling the prepareData() function.
    prepareData(true);
  }

  @override
  void dispose() {
    scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  String get _noDataFoundImage {
    return '${dotenv.env["BASE_URL_IMAGE"]}/arsip-mobile/img/ilustrasi_data_not_found.png';
  }

  /// [prepareData] is a function that is used to load data from the API.
  prepareData([bool isRefresh = false]) {
    if (mounted) {
      switch (_currentStep) {
        case 1:
          _simulasiBloc.add(SaveNilaiEvent(
            noRegistrasi: userdata?.noRegistrasi ?? '',
            kodeTOB: kodeTOB ?? 0,
            nilaiAkhir: nilaiAkhir ?? 0,
            detailNilai: detailNilai ?? '',
          ));
          Future.delayed(Duration.zero, () async {
            await context
                .read<SimulasiPilihanProvider>()
                .loadPilihan(noRegistrasi: userdata?.noRegistrasi ?? '');
          });
          break;
        case 2:
          // _simulasiBloc
          //     .add(SavePilihanPTNEvent(listPTNPilihan: listPTNPilihan));
          Future.delayed(Duration.zero, () async {
            await context.read<SimulasiHasilProvider>().loadSimulasi(
                  noRegistrasi: userdata?.noRegistrasi ?? '',
                  nilaiAkhir: nilaiAkhir ?? 0,
                  listPTNPilihan: _simulasiPilihanProvider.listPilihan,
                );
          });
          break;
        default:
          Future.delayed(Duration.zero, () async {
            await context.read<SimulasiNilaiProvider>().loadNilai(
                  noRegistrasi: userdata?.noRegistrasi ?? '',
                  idTingkatKelas: int.parse(userdata?.tingkatKelas ?? '0'),
                  listIdProduk: userdata?.listIdProduk,
                  isRefresh: isRefresh,
                );
            if (!mounted) return;
            // await context
            //     .read<SimulasiPilihanProvider>()
            //     .loadPilihan(noRegistrasi: userdata?.noRegistrasi ?? '');
            // if (!mounted) return;
            // await context.read<SimulasiHasilProvider>().loadSimulasi(
            //       noRegistrasi: userdata?.noRegistrasi ?? '',
            //       nilaiAkhir: nilaiAkhir ?? 0,
            //     );
          });
      }

      _refreshController.refreshCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SimulasiNilaiProvider>(
      builder: (ctxNilai, value, child) => (int.parse(
                  userdata?.tingkatKelas ?? '0') <
              12)
          ? NoDataFoundWidget(
              imageUrl: _noDataFoundImage,
              subTitle: "Simulasi SNBT",
              emptyMessage:
                  "Fitur ini hanya bisa digunakan oleh Siswa Tingkat Akhir Sobat")
          : (!value.isLoading && value.listNilai.isEmpty)
              ? NoDataFoundWidget(
                  imageUrl: _noDataFoundImage,
                  subTitle: "Simulasi SNBT",
                  emptyMessage:
                      "Sobat belum memiliki nilai TO untuk di-Simulasikan, Ayo ikuti TO terlebih dahulu Sobat")
              : CustomSmartRefresher(
                  controller: _refreshController,
                  onRefresh: () => prepareData(true),
                  isDark: true,
                  child: Stepper(
                    type: stepperType,
                    physics: const ScrollPhysics(),
                    currentStep: _currentStep,
                    onStepContinue: continued,
                    onStepCancel: cancel,
                    controlsBuilder: (context, _) {
                      return Row(
                        children: [
                          (_currentStep != 0)
                              ? Container(
                                  alignment: Alignment.centerLeft,
                                  child: InkWell(
                                    onTap: cancel,
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 8),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          color: context.secondaryColor),
                                      child: Text(
                                        'Kembali',
                                        style: context.text.labelLarge
                                            ?.copyWith(color: Colors.black),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                          (_currentStep != 2)
                              ? Container(
                                  padding:
                                      (_currentStep == 2 || _currentStep == 0)
                                          ? EdgeInsets.zero
                                          : EdgeInsets.only(left: context.pd),
                                  alignment: Alignment.centerLeft,
                                  child: InkWell(
                                    onTap: continued,
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 8),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          color: context.primaryColor),
                                      child: Text(
                                        'Lanjut',
                                        style: context.text.labelLarge
                                            ?.copyWith(
                                                color: context.background),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ],
                      );
                    },
                    steps: <Step>[
                      Step(
                        title: Text(
                          'Pilih Nilai Tryout',
                          style: context.text.titleMedium,
                        ),
                        content: value.isLoading
                            ? loadingShimmer(context)
                            : (value.errorNilai != null)
                                ? Text(
                                    value.errorNilai!,
                                    style: context.text.bodySmall
                                        ?.copyWith(color: context.hintColor),
                                    textAlign: TextAlign.left,
                                  )
                                : SingleChildScrollView(
                                    child: Column(
                                      children: <Widget>[
                                        _buildPeriodePicker(
                                            value.listNilai,
                                            value.selectedIndex,
                                            value.nilaiModel),
                                        _buildDetailNilai(),
                                      ],
                                    ),
                                  ),
                        isActive: _currentStep >= 0,
                        state: _currentStep >= 0
                            ? StepState.complete
                            : StepState.disabled,
                      ),
                      Step(
                        title: Text(
                          'Pilih PTN dan Jurusan',
                          style: context.text.titleMedium,
                        ),
                        content: Consumer<SimulasiPilihanProvider>(
                            builder: (context, val, child) {
                          return (val.isLoading)
                              ? loadingShimmerPTN(context)
                              : Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    SimulasiPilihanPTNWidget(
                                      listPilihanPTN: val.listPilihan,
                                      errorPilihan: val.errorPilihan,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      width: context.dw,
                                      child: Text(
                                        "*Sobat hanya memiliki 4 kesempatan untuk setiap prioritas dalam menentukan PTN & Jurusan yang ingin di-Simulasikan.",
                                        style: context.text.bodySmall?.copyWith(
                                            color: context.hintColor),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ],
                                );
                        }),
                        isActive: _currentStep >= 0,
                        state: _currentStep >= 1
                            ? StepState.complete
                            : StepState.disabled,
                      ),
                      Step(
                        title: Text(
                          'Simulasi SNBT',
                          style: context.text.titleMedium,
                        ),
                        content: SafeArea(
                          child: Consumer<SimulasiHasilProvider>(
                            builder: (context, val, child) => val.isLoading
                                ? loadingShimmerPTN(context)
                                : Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: SimulasiHasilWidget(
                                      listHasil: val.listSimulasi,
                                      errorHasil: val.errorHasil,
                                    ),
                                  ),
                          ),
                          // ),
                        ),
                        isActive: _currentStep >= 0,
                        state: _currentStep >= 2
                            ? StepState.complete
                            : StepState.disabled,
                      ),
                    ],
                  ),
                ),
    );
  }

  /// [confrimDialogSetNilai] fungsi yang digunakan untuk menampilkan dialog konfirmasi saat pengguna menginginkan
  /// untuk menyimpan data nilai yang telah dimasukkan.
  ///
  /// Args:
  ///   ctxNilai (BuildContext): BuildContext of the page where the dialog is called
  ///   value (SimulasiNilaiProvider): SimulasiNilaiProvider
  ///   context (BuildContext): The context of the page where the dialog will be displayed.
  Future<bool> confrimDialogSetNilai(BuildContext ctxNilai,
      SimulasiNilaiProvider value, BuildContext context) {
    return gShowBottomDialog(
      ctxNilai,
      message:
          "Apakah Sobat sudah yakin ini adalah nilai untuk di-Simulasikan?",
      actions: (controller) => [
        TextButton(
          onPressed: () async {
            controller.dismiss(true);
            value.setFixValue(true);

            gShowTopFlash(
              context,
              'Data Nilai Sobat berhasil disimpan',
              dialogType: DialogType.success,
            );
            continued();
          },
          child: const Text('Ya'),
        ),
        TextButton(
          onPressed: () {
            controller.dismiss(true);
          },
          child: const Text('Tidak'),
        )
      ],
    );
  }

  /// [_buildPeriodePicker] adalah fungsi yang digunakan untuk menampilkan daftar TO yang telah diselesaikan
  /// oleh pengguna.
  ///
  /// Args:
  ///   listNilai (List<NilaiModel?>): List data nilai yang akan ditampilkan di menu dropdown
  ///   selectedIndex (int): Indeks item yang dipilih dalam daftar.
  ///   nilaiModel (NilaiModel): NilaiModel
  Widget _buildPeriodePicker(
      List<NilaiModel?>? listNilai, int selectedIndex, NilaiModel nilaiModel) {
    final nilai = listNilai?[selectedIndex];
    setDetailNilai(nilai?.detailNilai ?? {});
    setKodeTOB(int.parse(nilai?.kodeTob ?? '0'));
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        child: Container(
            decoration: BoxDecoration(
                borderRadius: gDefaultShimmerBorderRadius,
                border: Border.all(color: context.disableColor)),
            child: ListTile(
              title: Text('Pilih Tryout', style: context.text.bodyMedium),
              subtitle: Text(
                listNilai![selectedIndex]!.tob,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: context.text.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.edit),
            )),
        onTap: () async {
          final selectedType = await showModalBottomSheet<int>(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(25.0),
                ),
              ),
              builder: (context) {
                return Padding(
                  padding: EdgeInsets.only(
                    top: context.dp(10),
                    bottom: context.dp(20),
                    left: context.dp(10),
                    right: context.dp(10),
                  ),
                  child: SizedBox(
                    width: context.dw,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CupertinoScrollbar(
                            controller: scrollController,
                            thumbVisibility: true,
                            thickness: 4,
                            radius: const Radius.circular(14),
                            child: ListView.separated(
                              shrinkWrap: true,
                              controller: scrollController,
                              physics: const BouncingScrollPhysics(),
                              itemCount: listNilai.length + 1,
                              separatorBuilder: (context, index) =>
                                  const Divider(),
                              itemBuilder: (context, index) {
                                bool isSelected = false;

                                if (index > 0 && index <= listNilai.length) {
                                  isSelected = listNilai[index - 1]?.tob ==
                                      listNilai[selectedIndex]?.tob;
                                }

                                return (index == 0)
                                    ? Center(
                                        child: Container(
                                          width: min(84, context.dp(80)),
                                          height: min(10, context.dp(8)),
                                          margin: EdgeInsets.only(
                                              bottom: min(50, context.dp(15))),
                                          decoration: BoxDecoration(
                                              color: context.disableColor,
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                        ),
                                      )
                                    : InkWell(
                                        onTap: (isSelected)
                                            ? null
                                            : () {
                                                context
                                                    .read<
                                                        SimulasiNilaiProvider>()
                                                    .setSelectedIndex(
                                                        index - 1);
                                                Navigator.of(context).pop();
                                                _onButtonPressed(
                                                  listNilai[index - 1]!
                                                      .detailNilai,
                                                  nilaiModel,
                                                  int.parse(
                                                      listNilai[index - 1]!
                                                          .kodeTob),
                                                );
                                              },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: context.dp(10),
                                            vertical: context.dp(8),
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: (isSelected)
                                                ? context.secondaryColor
                                                : null,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 8,
                                                      horizontal: 12),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                          color: context
                                                              .tertiaryColor)),
                                                  child: Icon(
                                                    Icons.donut_small_rounded,
                                                    color:
                                                        context.tertiaryColor,
                                                  )),
                                              const SizedBox(width: 10),
                                              Text(
                                                listNilai[index - 1]!.tob,
                                                style: context.text.bodyMedium,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              });

          if (selectedType != null) {
            if (!mounted) return;
            context
                .read<SimulasiNilaiProvider>()
                .setSelectedIndex(selectedType);
          }
        },
      ),
    );
  }

  /// [loadingShimmer] loading Shimmer Untuk Nilai To
  Widget loadingShimmer(BuildContext context) {
    return Column(
      children: [
        ShimmerWidget.rounded(
          width: context.dw,
          height: 80,
          borderRadius: BorderRadius.circular(24),
        ),
        SizedBox(
          height: context.pd,
        ),
        ShimmerWidget.rounded(
          width: context.dw,
          height: context.dh / 2,
          borderRadius: BorderRadius.circular(24),
        ),
      ],
    );
  }

  /// [loadingShimmerPTN] Loading Shimmer untuk widget pilihan ptn
  Widget loadingShimmerPTN(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < 4; i++)
          Padding(
            padding: EdgeInsets.only(bottom: context.pd),
            child: ShimmerWidget.rounded(
              width: context.dw,
              height: 180,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
      ],
    );
  }

  /// [_onButtonPressed] digunakan untuk menyimpan nilai skor yang telah dimasukkan oleh pengguna.
  ///
  /// Args:
  ///   detailNilai (Map<String, dynamic>): Map<String, dynamic>
  ///   nilaiModel (NilaiModel): NilaiModel
  void _onButtonPressed(
    Map<String, dynamic> detailNilai,
    NilaiModel nilaiModel,
    int kodeTOB,
  ) {
    setKodeTOB(kodeTOB);
    setDetailNilai(detailNilai);
  }

  /// [_buildDetailNilai] fungsi yang digunakan untuk menampilkan detail nilai
  /// Simulasi.
  Widget _buildDetailNilai() {
    return Consumer<SimulasiNilaiProvider>(
      builder: (_, value, child) {
        return Container(
          decoration: BoxDecoration(
            color: context.background,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: context.tertiaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Table(
                  border: TableBorder.symmetric(
                      inside: const BorderSide(width: 1.0, color: Colors.grey)),
                  columnWidths: const <int, TableColumnWidth>{
                    0: FlexColumnWidth(),
                    1: FixedColumnWidth(100),
                  },
                  children: [
                    TableRow(children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        child: const Center(
                            child: Text("Kelompok Ujian",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        child: const Center(
                            child: Text(
                          "Poin",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )),
                      )
                    ])
                  ],
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: value.nilaiModel.detailNilai.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 0,
                ),
                itemBuilder: (_, index) {
                  final lesson =
                      value.nilaiModel.detailNilai.keys.elementAt(index);
                  final nilai = value.nilaiModel.detailNilai[lesson] ?? 0;
                  bool isLastIndex =
                      index == value.nilaiModel.detailNilai.length - 1;

                  if (isLastIndex) {
                    setNilaiAkhir(nilai);
                  }
                  return Table(
                    columnWidths: const <int, TableColumnWidth>{
                      0: FlexColumnWidth(),
                      1: FixedColumnWidth(100),
                    },
                    border: TableBorder.symmetric(
                        inside:
                            const BorderSide(width: 1.0, color: Colors.grey)),
                    children: [
                      TableRow(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          child: Text(
                            lesson,
                            style: TextStyle(
                              fontWeight: isLastIndex ? FontWeight.bold : null,
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              nilai.toString(),
                              style: TextStyle(
                                fontWeight:
                                    isLastIndex ? FontWeight.bold : null,
                              ),
                            ),
                          ),
                        ),
                      ])
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// If the current step is less than 2, then increment the current step by 1
  continued() {
    _currentStep < 2 ? _currentStep += 1 : null;
    prepareData();
    setState(() {});
  }

  /// If the current step is greater than 0, then subtract 1 from the current step
  cancel() {
    _currentStep > 0 ? _currentStep -= 1 : null;
    prepareData();
    setState(() {});
  }

  /// [setNilaiAkhir] digunakan untuk men-set nilai akhir, daripada disimpan ke
  /// local storage
  setNilaiAkhir(int nilai) {
    nilaiAkhir = nilai;
  }

  /// [setKodeTOB] digunakan untuk men-set kode tob, daripada disimpan ke local
  /// storage
  setKodeTOB(int tob) {
    kodeTOB = tob;
  }

  /// [setDetailNilai] digunakan untuk men-set detail nilai, daripada disimpan
  /// ke local storage
  setDetailNilai(Map<String, dynamic> nilai) {
    detailNilai = jsonEncode(nilai);
  }

  /// [validateListPilihan] digunakan untuk mem-validasi apakah id jurusan sama
  /// di setiap prioritas
  // bool validateListPilihan() {
  //   if (_currentStep == 2 && _simulasiPilihanProvider.listPilihan.isNotEmpty) {
  //     bool isSameIdJurusan = false;
  //     final firstIdJurusan =
  //         _simulasiPilihanProvider.listPilihan.first.namaJurusan?.idJurusan;
  //     for (int i = 0; i < _simulasiPilihanProvider.listPilihan.length; i++) {
  //       if (i != 0 &&
  //           _simulasiPilihanProvider.listPilihan[i].namaJurusan?.idJurusan ==
  //               firstIdJurusan) {
  //         isSameIdJurusan = true;
  //       }
  //     }

  //     if (isSameIdJurusan) {
  //       Future.delayed(Duration.zero, () async {
  //         gShowTopFlash(
  //           context,
  //           'Tidak boleh memilih Jurusan yang sama di PTN yang sama, sobat.',
  //           dialogType: DialogType.error,
  //           duration: const Duration(seconds: 5),
  //         );
  //       });
  //       return false;
  //     }
  //   }

  //   return true;
  // }
}
