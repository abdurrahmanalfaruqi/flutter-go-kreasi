import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:provider/provider.dart';

import 'user_avatar.dart';
import '../../../auth/data/model/user_model.dart';
import '../../../../core/config/extensions.dart';

class SwitchAccountList extends StatefulWidget {
  final String noRegistrasiAktif;
  final List<Anak> daftarAnak;

  const SwitchAccountList({
    Key? key,
    required this.daftarAnak,
    required this.noRegistrasiAktif,
  }) : super(key: key);

  @override
  State<SwitchAccountList> createState() => _SwitchAccountListState();
}

class _SwitchAccountListState extends State<SwitchAccountList> {
  UserModel? userData;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is LoadedUser) {
      userData = authState.user;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(context.textScale12),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom +
              min(24, context.dp(18)),
        ),
        itemCount: widget.daftarAnak.length + 1,
        separatorBuilder: (_, index) => (index == 0)
            ? const SizedBox.shrink()
            : const Divider(indent: 20, endIndent: 20),
        itemBuilder: (_, index) {
          bool akunAktif = false;
          if (index > 0 && index <= widget.daftarAnak.length) {
            akunAktif = (widget.daftarAnak[index - 1].noRegistrasi ==
                widget.noRegistrasiAktif);
          }
          return (index == 0)
              ? Center(
                  child: Container(
                    width: min(84, context.dp(80)),
                    height: min(10, context.dp(8)),
                    margin:
                        EdgeInsets.symmetric(vertical: min(10, context.dp(8))),
                    decoration: BoxDecoration(
                        color: context.disableColor,
                        borderRadius: BorderRadius.circular(30)),
                  ),
                )
              : Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: min(16, context.dp(12))),
                  decoration: BoxDecoration(
                      color: (akunAktif) ? context.secondaryContainer : null,
                      borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    // waiting for switch account
                    // onTap: (akunAktif)
                    //     ? null
                    //     : () => _onSwitchAkun(
                    //         widget.daftarAnak[index - 1].noRegistrasi),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: min(12, context.dp(8))),
                    title: Text(widget.daftarAnak[index - 1].namaLengkap),
                    subtitle: Text(widget.daftarAnak[index - 1].noRegistrasi),
                    leading: UserAvatar(
                      key: ValueKey(
                          'SWITCH_USER_AVATAR-${widget.daftarAnak[index - 1].noRegistrasi}'
                          '-${widget.daftarAnak[index - 1].namaLengkap}'),
                      anak: widget.daftarAnak[index - 1],
                      size: (context.isMobile) ? 54 : 32,
                      borderColor: akunAktif
                          ? context.secondaryContainer
                          : context.hintColor,
                      fromSwitchAccount: true,
                    ),
                  ),
                );
        },
      ),
    );
  }

  // Future<void> _onTambahAkun(String noRegistrasi) async {
  //   // Switch Account Anak
  //   bool isBerhasil = await _authOtpProvider.switchAccount(
  //     isTambahAkun: true,
  //     noRegistrasi: noRegistrasi,
  //   );

  //   if (isBerhasil) {
  //     // update list data
  //     logger.log(
  //         // ignore: use_build_context_synchronously
  //         'Daftar Anak Baru >> ${userData?.daftarAnak}');
  //     setState(() {});
  //   }
  // }

  // Future<void> _onSwitchAkun(String noRegistrasi) async {
  //   // Switch Account Anak
  //   await _authOtpProvider.switchAccount(
  //     isTambahAkun: false,
  //     noRegistrasi: noRegistrasi,
  //   );
  // }
}
