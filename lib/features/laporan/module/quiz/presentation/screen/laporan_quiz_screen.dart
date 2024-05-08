import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/laporan/module/quiz/presentation/bloc/laporan_kuis/laporan_kuis_bloc.dart';

import '../widget/detail_nilai_kuis_widget.dart';
import '../widget/category_and_score_widget.dart';
import '../../model/laporan_kuis_model.dart';
import '../../../../../soal/entity/detail_jawaban.dart';
import '../../../../../../core/config/theme.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/widget/empty/no_data_found.dart';
import '../../../../../../core/shared/widget/loading/loading_widget.dart';
import '../../../../../../core/shared/widget/empty/basic_empty.dart';

class LaporanQuizScreen extends StatefulWidget {
  const LaporanQuizScreen({super.key});

  @override
  State<LaporanQuizScreen> createState() => _LaporanQuizScreenState();
}

class _LaporanQuizScreenState extends State<LaporanQuizScreen> {
  /// [_authProvider] merupakan variable provider
  /// yang diperlukan untuk memanggil data login user

  /// [listkodesoal] merupakan variable yang menampung data list kode soal
  List<Info> listkodesoal = [];

  /// Kumpulan variable initialize data user
  String? noRegistrasi, idSekolahKelas, userType, ta;

  /// Kumpulan variable picker dan nilai awal nya
  int selectedindexmapel = 0;
  int selectedindexkode = 0;
  String kodesoalterpilih = "Pilih Kode Soal";
  String mapelterpilih = "Pilih Mata Pelajaran";

  /// Kumpulan variable untuk memeriksa kondisi data
  List<DetailJawaban> listAnswer = [];
  bool isloading = false;
  bool kosongkah = true;
  bool adanilai = false;

  int? selectedType;

  /// [scrollController] merupakan controller untuk scroll bottomSheet picker
  final ScrollController scrollController = ScrollController();

  UserModel? userData;
  late LaporanKuisBloc laporanKuisBloc;
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is LoadedUser) {
      userData = authState.user;
    }
    final bulanSekarang = DateTime.now().month;
    final tahunSekarang = DateTime.now().year;
    final tahunDepan = tahunSekarang + 1;
    final tahunKemarin = tahunSekarang - 1;

    /// Initialization data Siswa
    noRegistrasi = userData?.noRegistrasi;
    idSekolahKelas = userData?.idSekolahKelas;
    userType = userData?.siapa;
    ta = (bulanSekarang < 7)
        ? '$tahunKemarin/$tahunSekarang'
        : '$tahunSekarang/$tahunDepan';

    laporanKuisBloc = BlocProvider.of<LaporanKuisBloc>(context);
    laporanKuisBloc.add(LoadListLaporanKuis(
        noRegistrasi: noRegistrasi!,
        idSekolahKelas: idSekolahKelas!,
        tahunAjaran: ta ?? ''));
  }

  /// [getJawabanSiswa] merupakan method untuk mendapatkan nilai kuis siswa
  getJawabanSiswa(String kodePaket) async {
    setState(() {
      isloading = true;
    });
    if (kodesoalterpilih != "Pilih Kode Soal") {
      Timer(const Duration(milliseconds: 100), () async {
        context.read<LaporanKuisBloc>().add(LoadListHasilKuis(
            noRegistrasi: noRegistrasi!,
            idSekolahKelas: idSekolahKelas!,
            tahunAjaran: ta ?? '',
            kodeQuiz: kodePaket));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LaporanKuisBloc, LaporanKuisState>(
      builder: (context, state) {
        List<LaporanKuisModel> value = [];
        Map<String, dynamic> kategori = {};
        if (state is LaporanKuisLoading) {
          return SizedBox(
            height: context.dh,
            child: const LoadingWidget(),
          );
        } else if (state is LaporanKuisDataLoaded) {
          value = state.listLaporanKuis;
          listAnswer = state.listHasilKuis;
          kategori = gettotal();
        }
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(context.pd),
            child: Column(
              children: [
                /// LaporanKuisPicker merupakan widget
                /// untuk memilih mata pelajaran dan kode soal
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () async {
                        if (value.isEmpty) {
                          await gShowBottomDialogInfo(context,
                              message:
                                  "Anda belum mengerjakan Soal Kuis, Ayo kerjakan soal kuis sekarang!");
                          return;
                        }
                        var selectedType =
                            await bottomSheetMapel(context, value);
                        if (selectedType != null) {
                          setState(() {
                            listkodesoal = [];
                            selectedindexmapel = selectedType;
                            mapelterpilih =
                                value[selectedindexmapel].cnamamapel!;
                            listkodesoal = value[selectedindexmapel].info!;
                            if (listkodesoal.isNotEmpty) {
                              if (listkodesoal[0].cKodeSoal !=
                                  "Pilih Kode Soal") {
                                Info f = Info(cKodeSoal: "Pilih Kode Soal");
                                listkodesoal.insert(0, f);
                              }
                            }
                          });
                          kodesoalterpilih = "Pilih Kode Soal";
                          selectedindexkode = 0;
                          laporanKuisBloc.add(const ClearlistHasilKuis());
                        }
                      },
                      child: Container(
                        padding: context.isMobile
                            ? EdgeInsets.zero
                            : EdgeInsets.all(context.dp(4)),
                        decoration: BoxDecoration(
                          borderRadius: gDefaultShimmerBorderRadius,
                          border: Border.all(color: context.disableColor),
                        ),
                        child: ListTile(
                          title: Text('Mata Pelajaran',
                              style: context.text.bodyMedium),
                          subtitle: Text(
                            mapelterpilih,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          trailing: const Icon(Icons.edit),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: context.isMobile ? context.dp(12) : context.dp(6),
                    ),
                    InkWell(
                      onTap: () async {
                        if (selectedindexmapel == 0) {
                          await gShowBottomDialogInfo(context,
                              message:
                                  "Mohon Pilih Mata Pelajarannya terlebih dahulu");
                          return;
                        }

                        selectedType = await bottomSheetKodeSoal(context);

                        if (selectedType != null) {
                          setState(() {
                            selectedindexkode = selectedType!;
                            kodesoalterpilih =
                                listkodesoal[selectedindexkode].cKodeSoal!;
                            if (selectedindexkode > 0) {
                              getJawabanSiswa(kodesoalterpilih);
                            }
                          });
                        }
                      },
                      child: Container(
                        padding: context.isMobile
                            ? EdgeInsets.zero
                            : EdgeInsets.all(context.dp(4)),
                        decoration: BoxDecoration(
                            borderRadius: gDefaultShimmerBorderRadius,
                            border: Border.all(color: context.disableColor)),
                        child: ListTile(
                          title:
                              Text('Kode Soal', style: context.text.bodyMedium),
                          subtitle: Text(
                            kodesoalterpilih,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          trailing: const Icon(Icons.edit),
                        ),
                      ),
                    ),
                  ],
                ),

                /// [KategoriScoreAndChartWidget] merupakan widget
                /// untuk menampilkan nilai siswa dalam bentuk chart
                /// dan kategori nilai kuis
                (state is LaporanHasilKuisLoading)
                    ? SizedBox(
                        height: context.dh - 300, child: const LoadingWidget())
                    : Column(
                        children: [
                          (listAnswer.isNotEmpty)
                              ? SizedBox(
                                  height: 500,
                                  child: KategoriScoreAndChartWidget(
                                    mapel: mapelterpilih,
                                    kodeSoal: kodesoalterpilih,
                                    listJawaban: listAnswer,
                                    kategori: kategori,
                                  ),
                                )
                              : const SizedBox.shrink(),

                          /// [DetailNilaiKuisWidget] merupakan widget
                          /// untuk menampilkan nilai siswa dalam bentuk tabel
                          (listAnswer.isNotEmpty)
                              ? DetailNilaiKuisWidget(
                                  listJawaban: listAnswer,
                                  kategori: kategori,
                                )
                              : const SizedBox.shrink(),
                          (listAnswer.isEmpty)
                              ? (kodesoalterpilih == 'Pilih Kode Soal' ||
                                      mapelterpilih == 'Pilih Mata Pelajaran')
                                  ? SizedBox(
                                      height: context.dh - 200,
                                      child: BasicEmpty(
                                        shrink: true,
                                        // isLandscape: !context.isMobile,
                                        imageUrl: 'ilustrasi_soal_quiz.png'
                                            .illustration,
                                        title: 'Laporan Kuis',
                                        subTitle:
                                            'Pantau hasil kuis Sobat disini',
                                        emptyMessage: (kodesoalterpilih ==
                                                    "Pilih Kode Soal" ||
                                                mapelterpilih ==
                                                    "Pilih Mata Pelajaran")
                                            ? "Pilih Mata Pelajaran dan kode soal terlebih dahulu"
                                            : "Sepertinya sobat belum mengerjakan $kodesoalterpilih",
                                      ),
                                    )
                                  : SingleChildScrollView(
                                      child: NoDataFoundWidget(
                                          imageUrl:
                                              '${dotenv.env["BASE_URL_IMAGE"]}/arsip-mobile/img/ilustrasi_data_not_found.png',
                                          shrink: true,
                                          subTitle:
                                              'Sepertinya sobat belum mengerjakan kuis $mapelterpilih($kodesoalterpilih)',
                                          emptyMessage:
                                              'Ayo kerjakan soal kuis sekarang sobat, dan lihat hasil pencapaian sobat disini'),
                                    )
                              : const SizedBox.shrink(),
                        ],
                      )
              ],
            ),
          ),
        );
      },
    );
  }

  /// [bottomSheetKodeSoal] merupakan widget yang menampilkan bottomsheet pilihan mata pelajaran
  Future<int?> bottomSheetMapel(
      BuildContext context, List<LaporanKuisModel> value) {
    return showModalBottomSheet<int>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        builder: (context) {
          return Container(
            width: context.dw,
            padding: EdgeInsets.only(top: context.pd),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(25.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoScrollbar(
                      controller: scrollController,
                      thickness: 4,
                      radius: const Radius.circular(14),
                      child: ListView.builder(
                        shrinkWrap: true,
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedindexmapel = index;
                                  });
                                  Navigator.of(context).pop(selectedindexmapel);
                                },
                                child: Container(
                                  width: context.dw,
                                  alignment: Alignment.center,
                                  padding: (context.isMobile)
                                      ? const EdgeInsets.all(8.0)
                                      : EdgeInsets.all(context.pd),
                                  child: Text(
                                    value[index].cnamamapel!,
                                    style: context.text.bodyLarge,
                                  ),
                                ),
                              ),
                              const Divider(),
                            ],
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
  }

  /// [bottomSheetKodeSoal] merupakan widget yang menampilkan bottomsheet pilihan kode soal
  Future<int?> bottomSheetKodeSoal(BuildContext context) {
    return showModalBottomSheet<int>(
        constraints: BoxConstraints(
          maxWidth:
              (context.isMobile) ? context.dw : context.dw - context.dp(0),
        ),
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        builder: (context) {
          return Container(
            width: context.dw,
            padding: EdgeInsets.only(top: context.pd),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(25.0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoScrollbar(
                    controller: scrollController,
                    // thumbVisibility: true,
                    thickness: 4,
                    radius: const Radius.circular(14),
                    child: ListView.builder(
                      shrinkWrap: true,
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: listkodesoal.length,
                      itemBuilder: (context, index) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedindexkode = index;
                                });
                                Navigator.of(context).pop(selectedindexkode);
                              },
                              child: Padding(
                                padding: (context.isMobile)
                                    ? const EdgeInsets.all(8.0)
                                    : EdgeInsets.all(context.pd),
                                child: Text(
                                  listkodesoal[index].cKodeSoal!,
                                  style: context.text.bodyLarge,
                                ),
                              ),
                            ),
                            const Divider(),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  /// [gettotal] merupakan fungsi untuk menentukan kategori nilai kuis
  Map<String, dynamic> gettotal() {
    Map<String, dynamic> kategori = <String, dynamic>{};
    double ttl = 0;
    int benar = 0;
    Color color = Colors.blue;
    String status = "";
    for (var element in listAnswer) {
      if (element.kunciJawaban == element.jawabanSiswa) benar++;
    }
    ttl = 100 / listAnswer.length * benar;
    if (ttl <= 40) {
      status = "Waspada";
      color = context.primaryColor;
    } else if (ttl > 40 && ttl < 80) {
      status = "Berjuang";
      color = context.secondaryColor;
    } else {
      status = "Merdeka";
      color = Palette.kSuccessSwatch;
    }
    kategori['status'] = status;
    kategori['nilai'] = ttl.toStringAsFixed(2);
    kategori['warna'] = color;
    return kategori;
  }
}
