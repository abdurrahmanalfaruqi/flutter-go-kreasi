import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/home/presentation/bloc/ptn/ptn_bloc.dart';
import 'package:gokreasi_new/features/laporan/module/tobk/model/laporan_tryout_nilai_model.dart';
import 'package:gokreasi_new/features/laporan/module/tobk/model/laporan_tryout_pilihan_model.dart';
import 'package:gokreasi_new/features/laporan/module/tobk/presentation/bloc/laporan_tobk/laporan_tobk_bloc.dart';
import 'package:gokreasi_new/features/ptn/module/ptnclopedia/entity/kampus_impian.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/shared/builder/responsive_builder.dart';
import 'laporan_tryout_detail_nilai_widget.dart';
import 'laporan_tryout_profil_nilai_widget.dart';

import '../../../../../../core/shared/widget/empty/no_data_found.dart';

class LaporanTryoutLaporanSNBTWidget extends StatefulWidget {
  final String? namaTOB;
  final String? kodeTOB;
  final String? penilaian;
  final String? link;
  final List<LaporanTryoutPilihanModel> listPilihan;
  final List<LaporanTryoutNilaiModel> listNilai;

  const LaporanTryoutLaporanSNBTWidget({
    super.key,
    this.namaTOB,
    this.kodeTOB,
    this.penilaian,
    this.link,
    required this.listPilihan,
    required this.listNilai,
  });

  @override
  State<LaporanTryoutLaporanSNBTWidget> createState() =>
      _LaporanTryoutLaporanSNBTWidgetState();
}

class _LaporanTryoutLaporanSNBTWidgetState
    extends State<LaporanTryoutLaporanSNBTWidget> {
  UserModel? userData;
  List<KampusImpian>? listKampusImpian;
  late LaporanTobkBloc laporanTobkBloc;

  @override
  void initState() {
    super.initState();
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
    laporanTobkBloc = context.read<LaporanTobkBloc>();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.listNilai.isEmpty) {
      return NoDataFoundWidget(
          imageUrl:
              '${dotenv.env["BASE_URL_IMAGE"]}/arsip-mobile/img/ilustrasi_data_not_found.png',
          subTitle: widget.namaTOB.toString(),
          emptyMessage: 'Laporan Tryout masih belum tersedia saat ini');
    }

    Map<String, dynamic> pharam = {};
    final daftarNilai = widget.listNilai
        .map((element) => double.tryParse(element.nilai) ?? 0)
        .toList();
    double totalNilai = daftarNilai.reduce((v, e) => v + e);

    switch (widget.penilaian) {
      case 'IRT':
      case 'STAN':
      case '4B-S':
        pharam = {
          'pilihan': widget.listPilihan,
          'nilai': widget.listNilai,
        };
        break;
      case 'B-S':
      case 'B Saja':
        pharam = {
          'nilai': widget.listNilai,
          'total': totalNilai.toStringAsFixed(2),
        };
        break;
      case 'AKM':
        pharam = {'nilai': widget.listNilai};
    }

    return ResponsiveBuilder(
      tablet: Row(
        children: [
          LaporanTryoutSNBTProfilNilai(
            widget.namaTOB!,
            pharam,
            widget.link!,
          ),
          LaporanTryoutSNBTDetailNilai(
            widget.listNilai,
            widget.namaTOB!,
          ),
        ],
      ),
      mobile: DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(
                top: context.pd,
                right: context.pd,
                left: context.pd,
              ),
              decoration: BoxDecoration(
                  color: context.background,
                  borderRadius: BorderRadius.circular(300),
                  boxShadow: const [
                    BoxShadow(
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        color: Colors.black26)
                  ]),
              child: TabBar(
                labelColor: context.background,
                indicatorColor: context.primaryColor,
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: context.text.bodyMedium,
                unselectedLabelStyle: context.text.bodyMedium,
                dividerColor: Colors.transparent,
                unselectedLabelColor: context.onBackground,
                splashBorderRadius: BorderRadius.circular(300),
                indicator: BoxDecoration(
                    color: context.primaryColor,
                    borderRadius: BorderRadius.circular(300)),
                indicatorPadding: EdgeInsets.zero,
                labelPadding: EdgeInsets.zero,
                tabs: const [
                  Tab(text: 'Profil Nilai'),
                  Tab(text: 'Detail Nilai')
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: context.pd - 5),
                child: TabBarView(
                  physics: const ClampingScrollPhysics(),
                  children: [
                    LaporanTryoutSNBTProfilNilai(
                        widget.namaTOB!,
                        {
                          'nilai': widget.listNilai,
                          'pilihan': widget.listPilihan
                        },
                        widget.link!),
                    LaporanTryoutSNBTDetailNilai(
                      widget.listNilai,
                      widget.namaTOB!,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
