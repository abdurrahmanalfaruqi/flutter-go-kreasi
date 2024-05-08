import 'package:flutter/material.dart';
import 'package:gokreasi_new/core/config/global.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/presentation/bloc/tobk/tobk_bloc.dart';
import '../../../../../../core/config/extensions.dart';
import 'package:provider/provider.dart';

import '../widget/tob_list.dart';
import '../../../../../../core/shared/screen/basic_screen.dart';

class TobkScreen extends StatefulWidget {
  final int idJenisProduk;
  final String namaJenisProduk;
  final UserModel? userData;

  /// [selectedKodeTOB] merupakan kodeTOB yang didapat dari rencana belajar
  /// atau onClick Notification
  final String? selectedKodeTOB;

  /// [selectedKodeTOB] merupakan namaTOB yang didapat dari rencana belajar
  /// atau onClick Notification
  final String? selectedNamaTOB;

  /// Untuk keperluan handle push and pop
  final String? diBukaDari;

  const TobkScreen({
    Key? key,
    required this.idJenisProduk,
    required this.namaJenisProduk,
    required this.userData,
    this.selectedKodeTOB,
    this.selectedNamaTOB,
    this.diBukaDari,
  }) : super(key: key);

  @override
  State<TobkScreen> createState() => _TobkScreenState();
}

class _TobkScreenState extends State<TobkScreen> {
  late TOBKBloc tobkBloc;
  UserModel? userData;

  @override
  void initState() {
    super.initState();
    tobkBloc = context.read<TOBKBloc>();
    final authState = context.read<AuthBloc>().state;
    if (authState is LoadedUser) {
      userData = authState.user;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasicScreen(
      title: 'TOBK',
      jumlahBarisTitle: 2,
      subTitle: 'Try Out Berbasis Komputer',
      actions: [
        IconButton(
          onPressed: _onRefreshTOB,
          icon: const Icon(Icons.refresh_rounded),
          style: IconButton.styleFrom(foregroundColor: context.onPrimary),
        ),
      ],
      body: TOBList(
        idJenisProduk: widget.idJenisProduk,
        namaJenisProduk: widget.namaJenisProduk,
        selectedKodeTOB: widget.selectedKodeTOB,
        selectedNamaTOB: widget.selectedNamaTOB,
        diBukaDari: widget.diBukaDari,
      ),
    );
  }

  // On Refresh Function
  Future<void> _onRefreshTOB([bool refresh = true]) async {
    // Function load and refresh data
    List<int> listIdProduk =
        userData?.listIdProduk == null ? [] : (userData?.listIdProduk ?? []);

    Map<String, dynamic> params = {}
      ..['list_id_produk'] = listIdProduk
      ..['no_register'] = userData?.noRegistrasi;
    tobkBloc.add(TOBKGetDaftarTOB(
      isRefresh: refresh,
      params: params,
      idJenisProduk: widget.idJenisProduk,
      idBundlingAktif: userData?.idBundlingAktif ?? 0,
    ));

    await gSetServerTimeOffset();
  }
}
