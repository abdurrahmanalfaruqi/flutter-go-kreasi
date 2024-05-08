import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/home/presentation/bloc/ptn/ptn_bloc.dart';
import 'package:gokreasi_new/features/laporan/module/tobk/model/laporan_tryout_pilihan_model.dart';
import 'package:gokreasi_new/features/ptn/module/ptnclopedia/entity/kampus_impian.dart';
import '../../../../../../../core/shared/widget/empty/no_data_found.dart';
import '../../../../../../../core/config/extensions.dart';

import '../../../model/laporan_tryout_nilai_model.dart';
import '../../../../../../../core/config/constant.dart';
import '../../../../../../../core/shared/widget/chart/radar_chart_widget.dart';
import '../laporan_detail_nilai_chart.dart';

class LaporanTryoutLaporanBSorBWidget extends StatefulWidget {
  final String? namaTOB;
  final String? kodeTOB;
  final String? penilaian;
  final List<LaporanTryoutPilihanModel> listPilihan;
  final List<LaporanTryoutNilaiModel> listNilai;

  const LaporanTryoutLaporanBSorBWidget({
    super.key,
    this.namaTOB,
    this.kodeTOB,
    this.penilaian,
    required this.listNilai,
    required this.listPilihan,
  });

  @override
  State<LaporanTryoutLaporanBSorBWidget> createState() =>
      _LaporanTryoutLaporanBSorBWidgetState();
}

class _LaporanTryoutLaporanBSorBWidgetState
    extends State<LaporanTryoutLaporanBSorBWidget> {
  UserModel? userData;
  List<KampusImpian>? listKampusImpian;

  @override
  void didUpdateWidget(covariant LaporanTryoutLaporanBSorBWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.namaTOB != oldWidget.namaTOB) {
      // Properti namaTOB berubah, inisialisasi ulang data.
      _loadData();
    }
  }

  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is LoadedUser) {
      userData = authState.user;
    }
    final ptnState = context.read<PtnBloc>().state;
    if (ptnState is PtnDataLoaded) {
      listKampusImpian = (ptnState.listKampusPilihan.isEmpty)
          ? null
          : ptnState.listKampusPilihan;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// [_buildNilaiList] merupakan widget untuk menampilkan list Detail nilai siswa
  Widget _buildNilaiList(List<LaporanTryoutNilaiModel>? listNilai) {
    List<Widget> listNilaiWidget = [];
    listNilaiWidget.add(
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 5,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                      color: context.tertiaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            offset: const Offset(-1, -1),
                            blurRadius: 4,
                            spreadRadius: 1,
                            color: context.tertiaryColor.withOpacity(0.42)),
                        BoxShadow(
                            offset: const Offset(1, 1),
                            blurRadius: 4,
                            spreadRadius: 1,
                            color: context.tertiaryColor.withOpacity(0.42))
                      ]),
                  child: Icon(
                    CupertinoIcons.chart_bar_circle,
                    size: context.dp(22),
                    color: context.onTertiary,
                  ),
                ),
                Flexible(
                  child: RichText(
                    textScaler: TextScaler.linear(context.textScale12),
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "DETAIL NILAI\n",
                          style: context.text.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: widget.namaTOB!,
                          style: context.text.bodyMedium
                              ?.copyWith(color: context.hintColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 2, top: 10),
            child: Divider(
              height: 0,
              color: context.hintColor,
            ),
          ),
          for (int i = 0; i < listNilai!.length; i++)
            Container(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          listNilai[i].mapel,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: context.secondaryColor),
                          child: Text("Skor : ${listNilai[i].nilai}",
                              style: context.text.labelLarge)),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: DetailNilaiChart(listJawaban: listNilai[i])),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Visibility(
                      visible: (listNilai.length > 1),
                      child: Divider(
                        height: 0,
                        color: context.hintColor,
                      ),
                    ),
                  )
                ],
              ),
            ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: listNilaiWidget,
      ),
    );
  }

  /// [_buildChart] merupakan widget untuk menampilkan data nilai siswa dalam bentu radar chart
  Widget _buildChart(List<LaporanTryoutNilaiModel>? listNilai, dynamic total) {
    final nilaiSiswa = listNilai!
        .map((val) => (val.benar / val.jumlahSoal * 100) < 0
            ? 0
            : (double.parse(
                    ((val.benar / (val.benar + val.salah + val.kosong)) * 100)
                        .toString())
                .toInt()))
        .toList();

    // final labelNilai = listNilai.map((val) {
    //   return Constant.kInitialKelompokUjian.values
    //           .where(
    //               (element) => element.values.elementAt(0).contains(val.mapel))
    //           .isNotEmpty
    //       ? Constant.kInitialKelompokUjian.values
    //           .where(
    //               (element) => element.values.elementAt(0).contains(val.mapel))
    //           .first
    //           .values
    //           .elementAt(1)
    //       : val.mapel;
    // }).toList();
    final List<String> labelNilai = List<String>.from(listNilai.map((val) {
      return val.initial;
    }).toList());

    return Container(
      margin: EdgeInsets.only(
        top: context.dp(16),
        right: context.dp(16),
        left: context.dp(16),
      ),
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: context.background,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
                offset: Offset(0, 2), blurRadius: 4, color: Colors.black26)
          ]),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.only(left: 16, right: 16, top: 5),
            horizontalTitleGap: 0,
            minVerticalPadding: 0,
            title: RichText(
              textScaler: TextScaler.linear(context.textScale12),
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "PROFIL NILAI\n",
                    style: context.text.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  TextSpan(
                    text: widget.namaTOB!,
                    style: context.text.bodyMedium
                        ?.copyWith(color: context.hintColor),
                  ),
                ],
              ),
            ),
            leading: Container(
              padding: const EdgeInsets.all(4),
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                  color: context.tertiaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        offset: const Offset(-1, -1),
                        blurRadius: 4,
                        spreadRadius: 1,
                        color: context.tertiaryColor.withOpacity(0.42)),
                    BoxShadow(
                        offset: const Offset(1, 1),
                        blurRadius: 4,
                        spreadRadius: 1,
                        color: context.tertiaryColor.withOpacity(0.42))
                  ]),
              child: Icon(
                Icons.radar_rounded,
                size: context.dp(22),
                color: context.onTertiary,
              ),
            ),
            trailing: GestureDetector(
                onTap: () async {
                  Navigator.of(context).pushNamed(
                    Constant.kRouteLaporanTryOutShare,
                    arguments: {
                      'chart': _buildChart(listNilai, total),
                      'pilihan': const SizedBox.shrink(),
                    },
                  );
                },
                child: const Icon(Icons.more_vert_rounded)),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 16, top: 0, left: 16, right: 16),
            child: Divider(
              height: 0,
            ),
          ),
          SizedBox(
            width: 300,
            height: 300,
            child: RadarChartWidget(
              values: [nilaiSiswa],
              lables: List<String>.generate(
                labelNilai.length,
                (index) {
                  return labelNilai[index].toString();
                },
              ),
              colors: [Colors.green.shade700],
              ticks: const [20, 40, 60, 80, 100],
            ),
          ),
          Text(
            'Nilai kamu: $total',
            style: context.text.labelLarge,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final userId = userData?.noRegistrasi;
    // final userClassLevelId = userData?.idSekolahKelas;
    // final userType = userData?.siapa;
    // final userPtn1Id = userData?.idJurusanPilihan1.toString();
    // final userPtn2Id = userData?.idJurusanPilihan2.toString();
    // final kodeTOB = widget.kodeTOB;
    // final penilaian = widget.penilaian;
    // return BlocBuilder<LaporanTobkBloc, LaporanTobkState>(
    //     builder: (context, state) {
    //   if (state is LaporanTobkDataLoaded) {
    if (widget.listNilai.isEmpty) {
      return NoDataFoundWidget(
          imageUrl:
              '${dotenv.env["BASE_URL_IMAGE"]}/arsip-mobile/img/ilustrasi_data_not_found.png',
          subTitle: widget.namaTOB.toString(),
          emptyMessage: "Laporan Tryout masih belum tersedia saat ini Sobat");
    }

    final daftarNilai = widget.listNilai
        .map((element) => double.tryParse(element.nilai) ?? 0)
        .toList();
    double totalNilai =
        (daftarNilai.reduce((v, e) => v + e) / widget.listNilai.length)
            .ceilToDouble();

    return ListView(
      children: <Widget>[
        if (widget.penilaian != 'Ujian Sekolah') ...[
          _buildChart(widget.listNilai, totalNilai),
        ],
        Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: const EdgeInsets.only(left: 16, right: 16),
            decoration: BoxDecoration(
                color: context.background,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                      offset: Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black26)
                ]),
            child: _buildNilaiList(widget.listNilai)),
      ],
    );
    // }

    // });
  }
}
