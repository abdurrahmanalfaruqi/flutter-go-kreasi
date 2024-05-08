import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/core/config/enum.dart';
import 'package:gokreasi_new/core/config/extensions.dart';
import 'package:gokreasi_new/core/config/global.dart';
import 'package:gokreasi_new/features/auth/data/model/bundling_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';

class SwitchBundlingList extends StatefulWidget {
  final int idBundleAktif;
  final String noRegistrasi;
  final List<Bundling> daftarBundling;

  const SwitchBundlingList({
    super.key,
    required this.idBundleAktif,
    required this.noRegistrasi,
    required this.daftarBundling,
  });

  @override
  State<SwitchBundlingList> createState() => _SwitchBundlingListState();
}

class _SwitchBundlingListState extends State<SwitchBundlingList> {

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(context.textScale12)),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is LoadedUser) {
            if (state.isSuccessUpdate == true) {
              Future.delayed(Duration.zero, () {
                gShowTopFlash(
                  context,
                  'Berhasil Ganti Bundle menjadi\n${state.updatedBundle}',
                  dialogType: DialogType.success,
                );
              });
              Navigator.pop(context);
            }
          }
        },
        child: ListView.separated(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom +
                min(24, context.dp(18)),
          ),
          separatorBuilder: (_, index) => (index == 0)
              ? const SizedBox.shrink()
              : const Divider(indent: 20, endIndent: 20),
          itemCount: widget.daftarBundling.length + 1,
          itemBuilder: (context, index) {
            bool bundleAktif = false;
            if (index > 0 && index <= widget.daftarBundling.length) {
              bundleAktif = (widget.daftarBundling[index - 1].idBundling ==
                  widget.idBundleAktif);
            }

            return (index == 0)
                ? Center(
                    child: Container(
                      width: min(84, context.dp(80)),
                      height: min(10, context.dp(8)),
                      margin: EdgeInsets.symmetric(
                          vertical: min(10, context.dp(8))),
                      decoration: BoxDecoration(
                          color: context.disableColor,
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  )
                : Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: min(16, context.dp(12))),
                    decoration: BoxDecoration(
                        color:
                            (bundleAktif) ? context.secondaryContainer : null,
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      onTap: (bundleAktif)
                          ? null
                          : () => _onSwitchBundle(
                                index - 1,
                              ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: min(12, context.dp(8))),
                      title: Text(
                          widget.daftarBundling[index - 1].namaBundling ?? '-'),
                      subtitle: Text(
                          widget.daftarBundling[index - 1].deskripsi ?? '-'),
                      // leading: UserAvatar(
                      //   key: ValueKey(
                      //       'SWITCH_USER_AVATAR-${widget.daftarAnak[index - 1].noRegistrasi}'
                      //       '-${widget.daftarAnak[index - 1].namaLengkap}'),
                      //   anak: widget.daftarAnak[index - 1],
                      //   size: (context.isMobile) ? 54 : 32,
                      //   borderColor: akunAktif
                      //       ? context.secondaryContainer
                      //       : context.hintColor,
                      //   fromSwitchAccount: true,
                      // ),
                    ),
                  );
          },
        ),
      ),
    );
  }

  void _onSwitchBundle(int selectedIndex) {
    final selectedBundling = widget.daftarBundling[selectedIndex];
    context.read<AuthBloc>().add(AuthSwitchBundle(
          idBundling: selectedBundling.idBundling ?? 0,
          noRegistrasi: widget.noRegistrasi,
          daftarBundle: widget.daftarBundling,
          selectedBundle: selectedBundling.namaBundling ?? '-',
        ));
  }
}
