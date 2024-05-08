import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/home/presentation/bloc/ptn/ptn_bloc.dart';
import 'package:gokreasi_new/features/laporan/module/tobk/model/laporan_tryout_pilihan_model.dart';
import 'package:gokreasi_new/features/ptn/module/ptnclopedia/entity/kampus_impian.dart';

import '../../../model/laporan_tryout_nilai_model.dart';
import '../../../../../../../core/shared/widget/empty/no_data_found.dart';

class LaporanTryoutLaporanSTANWidget extends StatefulWidget {
  final String? namaTOB;
  final String? kodeTOB;
  final String? penilaian;
  final String? jenisTO;
  final List<LaporanTryoutPilihanModel> listPilihan;
  final List<LaporanTryoutNilaiModel> listNilai;

  const LaporanTryoutLaporanSTANWidget({
    super.key,
    this.namaTOB,
    this.kodeTOB,
    this.penilaian,
    this.jenisTO,
    required this.listNilai,
    required this.listPilihan,
  });

  @override
  State<LaporanTryoutLaporanSTANWidget> createState() =>
      _LaporanTryoutLaporanAKMWidgetState();
}

class _LaporanTryoutLaporanAKMWidgetState
    extends State<LaporanTryoutLaporanSTANWidget> {
  UserModel? userData;
  List<KampusImpian>? listKampusImpian;

  @override
  void initState() {
    super.initState();
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

  Widget _buildNilaiList(List<LaporanTryoutNilaiModel> listNilai) {
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
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Text(
                    listNilai[i].nilai,
                  ),
                ],
              ),
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

  @override
  Widget build(BuildContext context) {
    if (widget.listNilai.isEmpty) {
      return NoDataFoundWidget(
          imageUrl:
              '${dotenv.env["BASE_URL_IMAGE"]}/arsip-mobile/img/ilustrasi_data_not_found.png',
          subTitle: widget.namaTOB.toString(),
          emptyMessage: "Laporan Tryout masih belum tersedia saat ini Sobat");
    }

    return ListView(
      children: <Widget>[
        _buildNilaiList(widget.listNilai),
      ],
    );
  }
}
