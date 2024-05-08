import 'dart:math';
import 'dart:developer' as logger show log;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/core/config/enum.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/home/presentation/bloc/ptn/ptn_bloc.dart';
import 'package:gokreasi_new/features/laporan/module/tobk/presentation/bloc/laporan_tobk/laporan_tobk_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../widget/laporan_tryout_chart_widget.dart';
import '../../model/laporan_tryout_tob_model.dart';
import '../../../../../ptn/module/ptnclopedia/entity/kampus_impian.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/constant.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/widget/empty/basic_empty.dart';
import '../../../../../../core/shared/widget/loading/loading_widget.dart';
import '../../../../../../core/shared/widget/loading/shimmer_widget.dart';

class LaporanTryoutScreen extends StatefulWidget {
  const LaporanTryoutScreen({Key? key}) : super(key: key);

  @override
  State<LaporanTryoutScreen> createState() => _LaporanTryoutScreenState();
}

class _LaporanTryoutScreenState extends State<LaporanTryoutScreen> {
  /// [_authProvider] merupakan variabel provider untuk memanggil data login user

  /// [_scrollController] merupakan variabel untuk controller scroll bottomsheet pilihan list jenis Tryout
  final ScrollController _scrollController = ScrollController();

  UserModel? userData;
  List<LaporanTryoutTobModel> listLaporanTOBK = [];
  List<KampusImpian> listKampusImpian = [];
  late LaporanTobkBloc laporanTobkBloc;
  LaporanTryoutTobModel? selectedTryout;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;

    if (authState is LoadedUser) {
      userData = authState.user;
    }

    laporanTobkBloc = context.read<LaporanTobkBloc>();
    laporanTobkBloc
        .add(LoadFristLaporan(noRegister: userData?.noRegistrasi ?? ''));

    final ptnState = context.read<PtnBloc>().state;
    if (ptnState is PtnDataLoaded) {
      listKampusImpian = ptnState.listKampusPilihan;
    }
  }

  /// [_selectedIndex] merupakan variabel untuk menampung data index jenis TO yang dipilih
  int _selectedIndex = 0;
  String _jenisTO = "";
  List<Map<String, String>> _opsiJenisTO = [
    {"c_NamaTO": "Pilih Jenis", "c_JenisTO": ""}
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildJenisTOPicker(),

        /// Widget untuk menampilkan laporan data TryOut
        Expanded(
          child: BlocBuilder<LaporanTobkBloc, LaporanTobkState>(
            builder: (context, state) {
              if (state is LaporanTobkLoading) {
                return (context.isMobile)
                    ? _buildShimmer()
                    : const LoadingWidget();
              }

              if (state is LaporanTobkError) {
                return _buildDataNotfound(
                  context,
                  imageUrl: 'ilustrasi_laporan_tobk.png'.illustration,
                  title: 'Laporan TOBK',
                  subtitle: "Ayo pantau hasil Tryout Sobat",
                  emptyMessage: "Yuk Kerjakan Tryout $_jenisTO Sobat",
                );
              }

              if (state is LaporanTobkDataLoaded) {
                listLaporanTOBK = state
                    .listLaporanTryout; // Replace with your data handling logic
              }

              if (listLaporanTOBK.isEmpty) {
                return _buildDataNotfound(
                  context,
                  imageUrl: 'ilustrasi_laporan_tobk.png'.illustration,
                  title: 'Laporan TOBK',
                  subtitle: "Pantau hasil TOBK Sobat disini",
                  emptyMessage: "Pilih Jenis TOBK terlebih dahulu",
                );
              }

              selectedTryout = listLaporanTOBK
                  .firstWhere((laporan) => laporan.isSelected == true);

              return SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 12,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: Column(children: [
                    if (_jenisTO != 'US') ...[
                      _buildTryOutLineChart(listLaporanTOBK),
                    ],
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ..._buildTryoutItem(listLaporanTOBK),
                      ],
                    )
                  ]),
                ),
              );

              // return _buildDataNotfound(
              //   context,
              //   imageUrl: 'ilustrasi_laporan_tobk.png'.illustration,
              //   title: 'Laporan TOBK',
              //   subtitle: "Ayo pantau hasil Tryout Sobat",
              //   emptyMessage: "Pilih jenis Tryout sobat terlebih dahulu",
              // );
            },
          ),
        ),
      ],
    );
  }

  _showModalJenisTO() async {
    if (_opsiJenisTO.length == 1) {
      await gShowBottomDialogInfo(context,
          message: "Tidak Ada List Laporan TOBK yang terdaftar di produk anda");
    } else {
      return await showModalBottomSheet<int>(
          context: context,
          constraints: BoxConstraints(maxWidth: min(650, context.dw)),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25.0),
            ),
          ),
          builder: (context) {
            return Padding(
              padding: EdgeInsets.only(
                top: context.dp(24),
                bottom: context.dp(20),
                left: context.dp(18),
                right: context.dp(18),
              ),
              child: SizedBox(
                width: context.dw,
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  thickness: 4,
                  radius: const Radius.circular(14),
                  child: ListView.separated(
                    shrinkWrap: true,
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _opsiJenisTO.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          setState(() => _selectedIndex = index);
                          Navigator.of(context).pop(_selectedIndex);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              "${_opsiJenisTO[index]['c_NamaTO']}",
                              style: context.text.bodyLarge,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          });
    }
  }

  /// [_buildDataNotfound] widget untuk menampilkan ilustrasi
  /// dan message saat data tidak ditemukan
  SingleChildScrollView _buildDataNotfound(
    BuildContext context, {
    required String imageUrl,
    required String title,
    required String subtitle,
    required String emptyMessage,
  }) {
    return SingleChildScrollView(
      child: SizedBox(
        height: (context.isMobile) ? context.dh * 0.7 : context.dh * 1.2,
        child: BasicEmpty(
          shrink: !context.isMobile,
          imageUrl: imageUrl,
          title: title,
          subTitle: subtitle,
          emptyMessage: emptyMessage,
        ),
      ),
    );
  }

  /// [_buildTryOutLineChart] merupakan widget untuk menampilkan LineChart Nilai TO
  Container _buildTryOutLineChart(List<LaporanTryoutTobModel> snap) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: LaporanTryoutChartWidget(
        jenisTO: _jenisTO,
        listTryout: snap,
        selectedTryout: selectedTryout,
      ),
    );
  }

  /// [_buildJenisTOPicker] widget untuk memilih jenis Try out
  Padding _buildJenisTOPicker() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: GestureDetector(
        child: BlocBuilder<LaporanTobkBloc, LaporanTobkState>(
          builder: (context, state) {
            if (state is LaporanTobkDataLoaded) {
              _opsiJenisTO = state.opsiTOBK;
            }
            return Container(
                decoration: BoxDecoration(
                    borderRadius: gDefaultShimmerBorderRadius,
                    border: Border.all(color: context.disableColor)),
                child: ListTile(
                  title: Text('Jenis Tryout', style: context.text.bodyMedium),
                  subtitle: Text(
                    _opsiJenisTO[_selectedIndex]['c_NamaTO']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.edit),
                ));
          },
        ),
        onTap: () async {
          final selectedType = await _showModalJenisTO();
          if (selectedType != null) {
            try {
              _jenisTO = _opsiJenisTO[_selectedIndex]['c_JenisTO']!;
              if (_jenisTO == '') {
                laporanTobkBloc.add(
                    LoadFristLaporan(noRegister: userData?.noRegistrasi ?? ''));
              } else {
                laporanTobkBloc.add(
                  LoadLaporanTobk(
                    jenisTO: _convertStringToJenisTO(_jenisTO),
                    userData: userData,
                  ),
                );
              }
            } catch (e) {
              logger.log("Error${e.toString()}");
            }
          }
        },
      ),
    );
  }

  /// [_buildTryoutItem] widget untuk menampilkan data list item tryout yang telah dikerjakan
  List<Widget> _buildTryoutItem(List<LaporanTryoutTobModel> listTryout) {
    if (kDebugMode) {
      logger.log('LIST TRYOUT >> $listTryout');
    }
    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "List Tryout",
            style: context.text.titleMedium,
          ),
          const Expanded(
            child: Divider(
                thickness: 1, indent: 8, endIndent: 8, color: Colors.black26),
          ),
        ],
      ),
      const SizedBox(
        height: 10,
      ),
      ...listTryout.map(
        (val) {
          bool isSelected = val.isSelected == true;
          bool isTOBK = _opsiJenisTO[_selectedIndex]['c_JenisTO'] == 'TOBK' ||
              _opsiJenisTO[_selectedIndex]['c_JenisTO'] == 'UTBK';
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: (isSelected && isTOBK)
                    ? null
                    : () {
                        for (var element in listTryout) {
                          if (element.kode == val.kode) {
                            element.isSelected = true;
                          } else {
                            element.isSelected = null;
                          }
                        }
                        setState(() {});
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color:
                        (isSelected && isTOBK) ? context.secondaryColor : null,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: (isSelected && isTOBK)
                        ? [
                            BoxShadow(
                                offset: const Offset(0, 1),
                                blurRadius: 6,
                                spreadRadius: 1,
                                color: context.tertiaryColor.withOpacity(0.2))
                          ]
                        : [],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.tertiaryColor)),
                      child: Icon(
                        Icons.donut_small_rounded,
                        color: context.tertiaryColor,
                      ),
                    ),
                    title: Text(val.nama),
                    subtitle: Text(
                      DateFormat.yMMMMd('ID').format(
                        DateTime.parse(val.tanggalAkhir),
                      ),
                    ),
                    trailing: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          Constant.kRouteLaporanTryOutNilai,
                          arguments: {
                            "penilaian": val.penilaian,
                            "kodeTOB": val.kode,
                            'namaTOB': val.nama,
                            'isExists': val.isExists,
                            'link': val.link,
                            'jenisTO': _opsiJenisTO[_selectedIndex]
                                ['c_JenisTO'],
                            'showEPB': true,
                            'listPilihan': val.pilihan,
                            'listNilai': val.listNilai,
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                offset: const Offset(0, 1),
                                blurRadius: 6,
                                spreadRadius: 1,
                                color: context.tertiaryColor.withOpacity(0.2))
                          ],
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Transform.translate(
                          offset: const Offset(-4, -6),
                          child: const SizedBox(
                            width: 12,
                            height: 12,
                            child: Icon(Icons.arrow_forward_ios),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // const Divider(),
            ],
          );
        },
      ).toList(),
    ];
  }

  /// [_buildShimmer] widget loading shimmer laporan tryout
  Padding _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.only(bottom: context.dp(30)),
        itemBuilder: (_, index) => Column(
          children: [
            if (index == 0)
              Column(
                children: [
                  ShimmerWidget.rounded(
                      borderRadius: gDefaultShimmerBorderRadius,
                      width: context.dw,
                      height: context.dp(250)),
                  const SizedBox(
                    height: 10,
                  )
                ],
              ),
            ListTile(
              leading: ShimmerWidget.rounded(
                  borderRadius: gDefaultShimmerBorderRadius,
                  width: context.dp(50),
                  height: context.dp(50)),
              title: Padding(
                padding: EdgeInsets.only(right: context.dw * 0.3),
                child: ShimmerWidget.rounded(
                    borderRadius: gDefaultShimmerBorderRadius,
                    width: context.dp(80),
                    height: context.dp(18)),
              ),
              subtitle: ShimmerWidget.rounded(
                  borderRadius: gDefaultShimmerBorderRadius,
                  width: context.dp(180),
                  height: context.dp(12)),
              trailing: ShimmerWidget.rounded(
                  borderRadius: gDefaultShimmerBorderRadius,
                  width: context.dp(32),
                  height: context.dp(32)),
            ),
          ],
        ),
        separatorBuilder: (_, index) => const Divider(),
        itemCount: 5,
      ),
    );
  }

  JenisTO _convertStringToJenisTO(String jenisTO) {
    return (jenisTO == 'US' || jenisTO == 'Ujian Sekolah')
        ? JenisTO.ujianSekolah
        : (jenisTO == 'UTBK')
            ? JenisTO.utbk
            : (jenisTO == 'STAN')
                ? JenisTO.stan
                : JenisTO.anbk;
  }
}
