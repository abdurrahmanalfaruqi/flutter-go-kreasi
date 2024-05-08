import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/home/presentation/bloc/ptn/ptn_bloc.dart';
import 'package:gokreasi_new/features/laporan/module/tobk/presentation/bloc/laporan_tobk/laporan_tobk_bloc.dart';
import 'package:gokreasi_new/features/ptn/module/ptnclopedia/entity/kampus_impian.dart';

import '../../../../../../../core/shared/widget/empty/no_data_found.dart';
import '../../../model/laporan_tryout_nilai_model.dart';
import '../../../model/laporan_tryout_pilihan_model.dart';
import '../../../../../../../core/config/constant.dart';
import '../../../../../../../core/shared/widget/chart/radar_chart_widget.dart';
import '../../../../../../../core/shared/widget/loading/loading_widget.dart';

class LaporanTryoutLaporan4BSWidget extends StatefulWidget {
  final String? namaTOB;
  final String? kodeTOB;
  final String? penilaian;
  final List<LaporanTryoutPilihanModel> listPilihan;
  final List<LaporanTryoutNilaiModel> listNilai;

  const LaporanTryoutLaporan4BSWidget({
    super.key,
    this.namaTOB,
    this.kodeTOB,
    this.penilaian,
    required this.listPilihan,
    required this.listNilai,
  });

  @override
  State<LaporanTryoutLaporan4BSWidget> createState() =>
      _LaporanTryoutLaporan4BSWidgetState();
}

class _LaporanTryoutLaporan4BSWidgetState
    extends State<LaporanTryoutLaporan4BSWidget> {
  UserModel? userData;
  List<KampusImpian>? listKampusImpian;

  @override
  void didUpdateWidget(covariant LaporanTryoutLaporan4BSWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.namaTOB != oldWidget.namaTOB) {
      // Properti namaTOB berubah, inisialisasi ulang data.
      _loadData();
    }
  }

  void _loadData() {
    final ptnState = context.read<PtnBloc>().state;
    if (ptnState is PtnDataLoaded) {
      listKampusImpian = (ptnState.listKampusPilihan.isEmpty)
          ? null
          : ptnState.listKampusPilihan;
    }
    final authState = context.read<AuthBloc>().state;
    if (authState is LoadedUser) {
      userData = authState.user;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LaporanTobkBloc, LaporanTobkState>(
        builder: (context, state) {
      if (state is LaporanTobkLoading) {
        return const LoadingWidget();
      }

      if (widget.listNilai == []) {
        return NoDataFoundWidget(
            imageUrl:
                '${dotenv.env["BASE_URL_IMAGE"]}/arsip-mobile/img/ilustrasi_data_not_found.png',
            subTitle: widget.namaTOB.toString(),
            emptyMessage: "Laporan Tryout masih belum tersedia saat ini Sobat");
      }

      return PageView(
        children: <Widget>[
          LaporanTryoutLaporan4BSWidgetPage1(widget.namaTOB!, {
            "nilai": widget.listNilai,
            "penilaian": widget.listPilihan,
          }),
          LaporanTryoutLaporan4BSWidgetPage2(widget.listNilai),
        ],
      );
    });
  }
}

class LaporanTryoutLaporan4BSWidgetPage1 extends StatelessWidget {
  final String namaTOB;
  final Map<String, dynamic> _data;

  const LaporanTryoutLaporan4BSWidgetPage1(this.namaTOB, this._data,
      {super.key});

  @override
  Widget build(BuildContext context) {
    final listPilihan = _data['pilihan'] as List<LaporanTryoutPilihanModel>;
    final listNilai = _data['nilai'] as List<LaporanTryoutNilaiModel>;

    final nilaiSiswa =
        listNilai.map((val) => double.parse(val.nilai).ceil()).toList();
    final List<String> chartLable = List<String>.from(listNilai.map((val) {
      return val.initial;
    }).toList());

    Widget chartWidget = _buildChart(
      namaTOB: namaTOB,
      listNilaiSiswa: nilaiSiswa,
      listLable: chartLable,
    );
    Widget pilihanWidget = _buildPilihanList(context, listPilihan);

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: chartWidget,
                ),
                pilihanWidget,
              ],
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.share),
            label: const Text("Share"),
            onPressed: () async {
              Navigator.of(context).pushNamed(
                Constant.kRouteLaporanTryOutShare,
                arguments: {'chart': chartWidget, 'pilihan': pilihanWidget},
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChart({
    String? namaTOB,
    List<int>? listNilaiSiswa,
    List<String>? listLable,
  }) {
    return Column(
      children: [
        Text(
          'Profil Nilai $namaTOB',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 300,
          height: 300,
          child: RadarChartWidget(
            values: [listNilaiSiswa!],
            lables: listLable,
            colors: [Colors.green.shade700],
            ticks: const [0, 4, 8, 12],
          ),
        ),
      ],
    );
  }

  Widget _buildPilihanList(
      BuildContext context, List<LaporanTryoutPilihanModel> listPilihan) {
    List<Widget> listPilihanWidget = [];

    for (int i = 0; i < listPilihan.length; i++) {
      listPilihanWidget.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
          decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Expanded(flex: 1, child: Text('PTN')),
                  Expanded(flex: 2, child: Text(': ${listPilihan[i].ptn}')),
                ],
              ),
              Row(
                children: <Widget>[
                  const Expanded(flex: 1, child: Text('Pilihan Prodi')),
                  Expanded(flex: 2, child: Text(': ${listPilihan[i].jurusan}')),
                ],
              ),
              Row(
                children: <Widget>[
                  const Expanded(flex: 1, child: Text('PG')),
                  Expanded(flex: 2, child: Text(': ${listPilihan[i].pg}%')),
                ],
              ),
              Row(
                children: <Widget>[
                  const Expanded(flex: 1, child: Text('Nilai Siswa')),
                  Expanded(flex: 2, child: Text(': ${listPilihan[i].nilai}%')),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        const Text(
          'Informasi Umum',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10.0),
        ...listPilihanWidget,
      ],
    );
  }
}

class LaporanTryoutLaporan4BSWidgetPage2 extends StatelessWidget {
  final List<LaporanTryoutNilaiModel> _listNilai;

  const LaporanTryoutLaporan4BSWidgetPage2(this._listNilai, {super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const Text(
              'Detail Nilai',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            _buildNilaiList(context, _listNilai),
          ],
        ),
      ),
    );
  }

  Widget _buildNilaiList(
      BuildContext context, List<LaporanTryoutNilaiModel> listNilai) {
    List<Widget> listNilaiWidget = [];

    for (int i = 0; i < listNilai.length; i++) {
      listNilaiWidget.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
          decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor)),
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
                  Text('${listNilai[i].nilai}%',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Text('Benar : ${listNilai[i].benar}'),
              Text('Salah : ${listNilai[i].salah}'),
              Text('Kosong : ${listNilai[i].kosong}'),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: listNilaiWidget,
      ),
    );
  }
}
