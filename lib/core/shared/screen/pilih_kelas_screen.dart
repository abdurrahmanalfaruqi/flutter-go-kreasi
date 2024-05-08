import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';

import '../builder/responsive_builder.dart';
import '../../config/constant.dart';
import '../../config/extensions.dart';
import '../../helper/kreasi_shared_pref.dart';
// import '../../helper/kreasi_secure_storage.dart';

class PilihKelasScreen extends StatefulWidget {
  const PilihKelasScreen({Key? key}) : super(key: key);

  @override
  State<PilihKelasScreen> createState() => _PilihKelasScreenState();
}

class _PilihKelasScreenState extends State<PilihKelasScreen> {
  UserModel? userData;
  late AuthBloc authBloc;

  @override
  void initState() {
    super.initState();
    authBloc = context.read<AuthBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is LoadedIdSekolahKelas) {
            Navigator.pushReplacementNamed(
              context,
              Constant.kRouteMainScreen,
              arguments: {'idSekolahKelas': state.idSekolahKelas},
            );
          }
        },
        builder: (context, state) {
          if (state is LoadedUser) {
            userData = state.user;
          }

          return SafeArea(
            child: ResponsiveBuilder(
              mobile: Column(
                children: [
                  _buildTitleHeader(context),
                  _buildWrapPilihanKelas(context, userData),
                  _buildButton(context, userData)
                ],
              ),
              tablet: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        const Spacer(flex: 4),
                        _buildTitleHeader(context),
                        const Spacer(),
                        _buildButton(context, userData),
                        const Spacer(flex: 4),
                      ],
                    ),
                  ),
                  VerticalDivider(
                    indent: context.dp(20),
                    endIndent: context.dp(20),
                  ),
                  _buildWrapPilihanKelas(context, userData)
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Padding _buildButton(BuildContext context, UserModel? userData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ElevatedButton(
        onPressed: () async {
          final idSekolahKelas = KreasiSharedPref().getIdSekolahKelas();
          authBloc.add(AuthSetIdSekolahKelas(idSekolahKelas ?? ''));
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Pilih Kelas'),
      ),
    );
  }

  /// NOTE: kumpulan Widget-----------------------------------------------------
  Widget _buildOptionKelas(BuildContext context, VoidCallback onClick,
          String label, bool isActive) =>
      InkWell(
        onTap: onClick,
        borderRadius: BorderRadius.circular(max(8, context.dp(8))),
        child: Container(
          margin: EdgeInsets.all((context.isMobile) ? context.dp(6) : 8),
          padding: EdgeInsets.symmetric(
            vertical: (context.isMobile) ? context.dp(10) : context.dp(6),
            horizontal: (context.isMobile) ? context.dp(12) : context.dp(8),
          ),
          decoration: BoxDecoration(
              color: isActive ? context.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(max(8, context.dp(8))),
              border: Border.all(
                  color: isActive ? Colors.transparent : context.onBackground)),
          child: Text(
            label,
            style: context.text.bodySmall?.copyWith(
              fontSize: (context.isMobile) ? 12 : 10,
              color: isActive ? context.onPrimary : context.onBackground,
            ),
          ),
        ),
      );

  Expanded _buildWrapPilihanKelas(BuildContext context, UserModel? userData) {
    final ScrollController scrollController = ScrollController();
    String idSekolah = '';
    Future.delayed(Duration.zero, () async {
      idSekolah = KreasiSharedPref().getIdSekolahKelas() ?? '';
    });
    final idSekolahKelas = ValueNotifier(idSekolah);

    return Expanded(
      flex: (context.isMobile) ? 1 : 5,
      child: Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        trackVisibility: true,
        thickness: 8,
        radius: const Radius.circular(14),
        child: SingleChildScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(
              top: (context.isMobile) ? 0 : context.dp(10),
              right: (context.isMobile) ? context.dp(18) : context.dp(10),
              left: (context.isMobile) ? context.dp(18) : context.dp(10),
              bottom: (context.isMobile) ? context.dp(24) : context.dp(16),
            ),
            child: ValueListenableBuilder<String?>(
              valueListenable: idSekolahKelas,
              builder: (context, idSekolahKelas, _) {
                return Wrap(
                  children: Constant.kDataSekolahKelas
                      .map<Widget>(
                        (kelas) => _buildOptionKelas(
                          context,
                          () async {
                            await KreasiSharedPref()
                                .setIdSekolahKelas(kelas['id'] ?? '');
                            setState(() {});
                          },
                          kelas['kelas']!,
                          kelas['id']! == idSekolahKelas,
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Padding _buildTitleHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: (context.isMobile) ? context.dp(8) : context.dp(14),
        right: (context.isMobile) ? context.dp(24) : context.dp(14),
        top: (context.isMobile) ? context.dp(24) : 0,
        bottom: (context.isMobile) ? context.dp(24) : 0,
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/img/logo_kreasi.webp',
            width: min(120, context.dp(90)),
            height: min(120, context.dp(90)),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: context.dp(268),
                  child: FittedBox(
                    child: RichText(
                      text: TextSpan(
                          text: 'Halo Sobat\n',
                          children: [
                            TextSpan(
                              text: 'Selamat datang di Go Expert',
                              style: context.text.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                          style: context.text.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      maxLines: 2,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      textScaler: TextScaler.linear(context.textScale14),
                    ),
                  ),
                ),
                SizedBox(height: context.h(16)),
                SizedBox(
                  width: context.dp(268),
                  child: FittedBox(
                    child: Text(
                      'Kamu kelas berapa sobat? Pilih kelas kamu\nuntuk menikmati fitur gratis dari GO.',
                      style: context.text.bodySmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// NOTE: kumpulan Widget END-------------------------------------------------
}
