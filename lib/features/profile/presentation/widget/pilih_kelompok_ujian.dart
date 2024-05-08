import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/profile/data/model/mapel_piliihan_model.dart';
import 'package:gokreasi_new/features/profile/domain/entity/kelompok_ujian.dart';
import 'package:gokreasi_new/features/profile/domain/entity/mapel_pilihan.dart';
import 'package:gokreasi_new/features/profile/presentation/bloc/profile/profile_bloc.dart';

import '../../../../core/config/extensions.dart';
import '../../../../core/config/global.dart';
import '../../../../core/shared/widget/loading/shimmer_widget.dart';

class PilihKelompokUjian extends StatefulWidget {
  final bool isFromTOBK;
  final List<MapelPilihan>? currentMapel;

  const PilihKelompokUjian({
    Key? key,
    this.isFromTOBK = false,
    this.currentMapel,
  }) : super(key: key);

  @override
  State<PilihKelompokUjian> createState() => _PilihKelompokUjianState();
}

class _PilihKelompokUjianState extends State<PilihKelompokUjian> {
  UserModel? userData;
  String tingkatSekolah = 'SD';
  List<KelompokUjian> kelompokUjianPilihan = [];
  Map<int, Map<String, String>> opsiPilihan = {};
  int maximalPilihKelompokUjian = 0;
  int minimalPilihKelompokUjian = 0;
  List<MapelPilihan> listMapelTemp = [];

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is LoadedUser) {
      userData = authState.user;
      tingkatSekolah = userData?.getTingkat ?? 'SD';
    }
    context.read<ProfileBloc>().add(ProfileGetOpsiMapel(
          userData?.idSekolahKelas ?? '',
        ));

    for (MapelPilihan current in (widget.currentMapel ?? [])) {
      listMapelTemp.add(current);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileGetOpsiError) {
            Navigator.of(context).pop(false);
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return ShimmerWidget.rounded(
              width: context.dw - 64,
              height: min(114, context.dp(100)),
              borderRadius: gDefaultShimmerBorderRadius,
            );
          }

          if (state is LoadedOpsiMapel) {
            minimalPilihKelompokUjian = state.minimalPilih;
            maximalPilihKelompokUjian = state.maximalPilih;
            kelompokUjianPilihan = (state.listOpsiMapel).map((data) {
              return KelompokUjian(
                idKelompokUjian: data.idKelompokKelas ?? 0,
                namaKelompokUjian: data.namaKelompokUjian ?? '',
                initial: data.singkatan ?? '',
              );
            }).toList();

            for (MapelPilihan data in state.listOpsiMapel) {
              int idKelompokUjian = data.idKelompokKelas ?? 0;
              String nama = data.namaKelompokUjian ?? '';
              String initial = data.singkatan ?? '';
              opsiPilihan[idKelompokUjian] = {
                'nama': nama,
                'initial': initial,
              };
            }
          }

          return ListView(
            // mainAxisSize: MainAxisSize.min,
            // crossAxisAlignment: CrossAxisAlignment.start,
            padding: EdgeInsets.only(
              right: min(22, context.dp(18)),
              left: min(22, context.dp(18)),
              top: min(16, context.dp(12)),
              bottom: min(24, context.dp(20)),
            ),
            shrinkWrap: true,
            children: [
              _buildDecoration(context),
              const SizedBox(height: 12),
              _buildHeader(context, opsiPilihan, tingkatSekolah),
              const Divider(height: 20),
              _buildOpsiPilihanKelompokUjian(opsiPilihan, kelompokUjianPilihan),
              if (opsiPilihan.isNotEmpty) const Divider(height: 20),
              if (opsiPilihan.isNotEmpty)
                Text(' *Minimal $minimalPilihKelompokUjian pilihan',
                    textScaler: TextScaler.linear(context.textScale11),
                    style: context.text.labelSmall
                        ?.copyWith(color: context.hintColor)),
              if (opsiPilihan.isNotEmpty)
                Text(' *Maksimal $maximalPilihKelompokUjian pilihan',
                    textScaler: TextScaler.linear(context.textScale11),
                    style: context.text.labelSmall
                        ?.copyWith(color: context.hintColor)),
              if (opsiPilihan.isNotEmpty) const SizedBox(height: 8),
              if (opsiPilihan.isNotEmpty)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '  Dipilih: ${listMapelTemp.length}'
                        '/$maximalPilihKelompokUjian',
                        textScaler: TextScaler.linear(context.textScale12),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed:
                            (listMapelTemp.length < minimalPilihKelompokUjian)
                                ? null
                                : _simpanPilihan,
                        child: Text(
                            '${widget.isFromTOBK ? 'Konfirmasi' : 'Simpan'} '
                            'Mata Uji Pilihan'),
                      ),
                    ),
                  ],
                )
            ],
          );
        },
      ),
    );
  }

  Future<void> _simpanPilihan() async {
    context.read<ProfileBloc>().add(
          ProfileSaveMapel(
              noRegistrasi: userData?.noRegistrasi ?? '',
              listSelectedMapel: listMapelTemp),
        );
    Navigator.of(context).pop(true);
  }

  Center _buildDecoration(BuildContext context) => Center(
        child: Container(
          width: min(200, context.dw * 0.26),
          height: min(8, context.dp(6)),
          decoration: BoxDecoration(
              color: context.disableColor,
              borderRadius: BorderRadius.circular(60)),
        ),
      );

  Row _buildHeader(
    BuildContext context,
    Map<int, Map<String, String>> opsiPilihan,
    String tingkatSekolah,
  ) =>
      Row(
        children: [
          Icon(
            Icons.checklist_rounded,
            color: context.primaryColor,
            size: min(34, context.dp(32)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              textScaler: TextScaler.linear(context.textScale12),
              text: TextSpan(
                  text: (widget.isFromTOBK)
                      ? 'Konfirmasi Mata Uji Pilihan\n'
                      : 'Mata Uji Pilihan\n',
                  style: context.text.titleMedium,
                  children: [
                    TextSpan(
                        text: (opsiPilihan.isEmpty)
                            ? 'Saat ini belum ada pilihan mata uji untuk tingkat $tingkatSekolah Sobat. '
                                'Hubungi MinGO untuk informasi lebih lanjut yaa!'
                            : 'Pilih dengan hati-hati ya Sobat. Pilihan mata uji ini akan menjadi acuan '
                                'isi TryOut berdasarkan mata uji peminatan yang Sobat pelajari di sekolah. '
                                'Pilihan yang sudah dikonfirmasi tidak dapat diubah kembali.',
                        style: context.text.labelMedium
                            ?.copyWith(color: context.hintColor))
                  ]),
            ),
          ),
        ],
      );

  Widget _buildOptionKelompokUjian(
    BuildContext context, {
    required VoidCallback? onClick,
    required String label,
    required bool isActive,
  }) =>
      InkWell(
        onTap: onClick,
        borderRadius: BorderRadius.circular((context.isMobile) ? 8 : 12),
        child: Container(
          margin: EdgeInsets.all(min(8, context.dp(6))),
          padding: EdgeInsets.symmetric(
            vertical: min(12, context.dp(10)),
            horizontal: min(14, context.dp(12)),
          ),
          decoration: BoxDecoration(
              color: isActive ? context.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular((context.isMobile) ? 8 : 12),
              border: Border.all(
                  color: isActive ? Colors.transparent : context.onBackground)),
          child: Text(
            label,
            textScaler: TextScaler.linear(min(context.ts, 1.16)),
            style: context.text.bodySmall?.copyWith(
                color: isActive ? context.onPrimary : context.onBackground),
          ),
        ),
      );

  Widget _buildOpsiPilihanKelompokUjian(
      Map<int, Map<String, String>> opsiPilihan,
      List<KelompokUjian> kelompokUjianPilihan) {
    return Wrap(
      children: opsiPilihan.entries.map<Widget>((opsi) {
        bool isActive =
            listMapelTemp.any((element) => element.idKelompokKelas == opsi.key);
        bool isNotAllowToUnselect = (widget.currentMapel ?? [])
            .any((element) => element.idKelompokKelas == opsi.key);

        return _buildOptionKelompokUjian(
          context,
          onClick: isNotAllowToUnselect
              ? null
              : () async {
                  MapelPilihanModel newMapel = MapelPilihanModel(
                    idKelompokKelas: opsi.key,
                    namaKelompokUjian: opsi.value['nama'],
                    singkatan: opsi.value['initial'],
                  );
                  if (!isActive &&
                      listMapelTemp.length < 4 &&
                      !isNotAllowToUnselect) {
                    listMapelTemp.add(newMapel);
                  } else {
                    listMapelTemp.remove(newMapel);
                  }
                  setState(() {});
                },
          label: opsi.value['nama'] ?? '-',
          isActive: isActive,
        );
      }).toList(),
    );
  }
}
