import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/core/shared/widget/empty/basic_empty.dart';
import 'package:gokreasi_new/features/menu/presentation/provider/menu_provider.dart';
import 'package:gokreasi_new/features/soal/presentation/bloc/soal_bloc/soal_bloc.dart';

import '../widget/buku_soal_menu.dart';
import '../../module/timer_soal/presentation/widget/paket_timer_list.dart';
import '../../module/bundel_soal/presentation/widget/bundel_soal_list.dart';
import '../../../menu/entity/menu.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/shared/screen/drop_down_action_screen.dart';

class BukuSoalScreen extends StatefulWidget {
  /// [idJenisProduk] dikirim dari rencana belajar notification
  /// untuk keperluan Kuis dan Racing
  final int? idJenisProduk;

  /// [kodeTOB] dikirim dari rencana belajar notification
  /// untuk keperluan Kuis dan Racing
  final String? kodeTOB;

  /// [kodePaket] dikirim dari rencana belajar notification
  /// untuk keperluan Kuis dan Racing
  final String? kodePaket;

  /// UNtuk keperluan Pop. Isi dengan route name.
  final String? diBukaDari;

  const BukuSoalScreen({
    Key? key,
    this.idJenisProduk,
    this.kodeTOB,
    this.kodePaket,
    this.diBukaDari,
  }) : super(key: key);

  @override
  State<BukuSoalScreen> createState() => _BukuSoalScreenState();
}

class _BukuSoalScreenState extends State<BukuSoalScreen> {
  late Menu _selectedBukuSoal;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SoalBloc, SoalState, SoalState>(
      selector: (state) => state,
      builder: (context, soalState) {
        List<Menu> listBukuSoal =
            (soalState.bukuSoal?.listBukuPaket?.isEmpty == true)
                ? [MenuProvider.emptyMenuBukuSoal]
                : soalState.bukuSoal!.listBukuPaket!;
        _selectedBukuSoal =
            soalState.selectedMenu ?? MenuProvider.emptyMenuBukuSoal;

        return DropDownActionScreen(
          title: 'Buku Soal',
          dropDownItems: listBukuSoal,
          selectedItem: _selectedBukuSoal,
          isWatermarked: false,
          onChanged: (newValue) {
            if (newValue?.idJenis != _selectedBukuSoal.idJenis) {
              context
                  .read<SoalBloc>()
                  .add(SetSelectedMenu(selectedMenu: newValue));
            }
          },
          body: _buildBody(),
          floatingActionButton:
              (_selectedBukuSoal.idJenis == 80) ? _leaderboardRacing() : null,
        );
      },
    );
  }

  // FAB Leaderboard Racing
  Widget _leaderboardRacing() {
    return ElevatedButton.icon(
      key: const ValueKey('Leaderboard Racing'),
      onPressed: () {
        Navigator.pushNamed(context, Constant.kRouteLeaderBoardRacing);
      },
      icon: const Icon(Icons.leaderboard_outlined),
      label: const Text('Leaderboard Racing'),
      style: ElevatedButton.styleFrom(
        backgroundColor: context.secondaryContainer,
        foregroundColor: context.onSecondaryContainer,
        padding: EdgeInsets.only(
          right: (context.isMobile) ? context.dp(18) : 24,
          left: (context.isMobile) ? context.dp(14) : 18,
          top: (context.isMobile) ? context.dp(12) : 16,
          bottom: (context.isMobile) ? context.dp(12) : 16,
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedBukuSoal.idJenis) {
      case 0:
        return BukuSaktiWidget(
          idJenisProduk: widget.idJenisProduk,
          kodeTOB: widget.kodeTOB,
          kodePaket: widget.kodePaket,
          diBukaDari: widget.diBukaDari,
        );
      case 77: // Paket Intensif
      case 78: // Paket Soal Koding
      case 79: // Pendalaman Materi
      case 82: // Soal Referensi
        return BundelSoalList(
          idJenisProduk: _selectedBukuSoal.idJenis,
          namaJenisProduk: _selectedBukuSoal.namaJenisProduk,
        );
      case 80: // Racing
      case 16: // Kuis
        return PaketTimerList(
          idJenisProduk: _selectedBukuSoal.idJenis,
          namaJenisProduk: _selectedBukuSoal.namaJenisProduk,
          kodeTOB: widget.kodeTOB,
          kodePaket: widget.kodePaket,
        );
      default:
        return _getIllustrationImage();
    }
  }

  // Get Illustration Image Function
  Widget _getIllustrationImage() {
    String imageUrl = 'ilustrasi_data_not_found.png'.illustration;
    String title = 'Buku Soal';

    Widget basicEmpty = BasicEmpty(
      shrink: (context.dh < 600) ? !context.isMobile : false,
      imageUrl: imageUrl,
      title: title,
      subTitle: 'Sobat belum membeli produk',
      emptyMessage: 'Beli produk yuk sobat, '
          'cukup hubungi cabang Ganesha Operation terdekat.',
    );

    return (context.isMobile || context.dh > 600)
        ? basicEmpty
        : SingleChildScrollView(
            child: basicEmpty,
          );
  }
}
