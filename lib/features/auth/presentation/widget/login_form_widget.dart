import 'dart:developer' as logger show log;

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gokreasi_new/core/config/enum.dart';

import '../../../../core/config/extensions.dart';
import '../../../../core/shared/widget/form/custom_text_form_field.dart';
import '../../../../core/util/form_validator.dart';
// import 'radio_group_otp_widget.dart';

class LoginFormWidget extends StatefulWidget {
  final TextEditingController nomorRegistrasiTextController;
  final ValueNotifier<AuthRole> pilihanRoleController;

  const LoginFormWidget({
    Key? key,
    required this.nomorRegistrasiTextController,
    required this.pilihanRoleController,
  }) : super(key: key);

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  @override
  void setState(VoidCallback fn) => (mounted) ? super.setState(fn) : fn();

  @override
  Widget build(BuildContext context) {
    return (context.isMobile)
        ? ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            children: _buildForm(),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildForm(),
          );
  }

  GestureDetector _buildDaftarSebagai() {
    return GestureDetector(
      onTap: () => showAdaptiveActionSheet(
        context: context,
        title: Text('Login Sebagai', style: context.text.headlineSmall),
        androidBorderRadius: (context.isMobile) ? 24 : 32,
        actions: AuthRole.values
            .map<BottomSheetAction>(
              (role) => BottomSheetAction(
                  title: Text(role.name.capitalize(),
                      style: context.text.bodyLarge),
                  onPressed: (ctx) {
                    setState(() {
                      widget.pilihanRoleController.value = role;
                      Navigator.pop(ctx);
                    });
                  }),
            )
            .toList(),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: context.dp(10),
        ),
        padding: (context.isMobile)
            ? EdgeInsets.all(context.dp(12))
            : EdgeInsets.all(context.dp(8)),
        decoration: BoxDecoration(
            color: context.background,
            borderRadius: BorderRadius.circular(context.dp(10)),
            border: Border.all(color: context.hintColor)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Login Sebagai',
              style: context.text.labelLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            ValueListenableBuilder<AuthRole>(
              valueListenable: widget.pilihanRoleController,
              builder: (context, pilihanRole, _) => Text(
                AuthRole.values
                    .singleWhere((role) => role == pilihanRole)
                    .name
                    .capitalize(),
                style: context.text.labelLarge
                    ?.copyWith(color: context.disableColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildForm() => [
        Container(
          color: context.background,
          margin: EdgeInsets.only(
            top: (context.isMobile)
                ? context.dp(24)
                : (context.dh > 650)
                    ? context.h(140)
                    : 16,
            bottom: (context.isMobile) ? context.dp(10) : 14,
          ),
          child: Text(
            'Hi Sobat GO',
            style: context.text.headlineLarge?.copyWith(
              fontSize: (context.isMobile) ? 32 : 28,
              color: context.onBackground,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        // Padding(
        //   padding: EdgeInsets.symmetric(horizontal: context.dp(10)),
        //   child: Text(
        //     'Masukkan nomor registrasi yang terdaftar untuk masuk kedalam aplikasi.',
        //     style: context.text.bodyMedium?.copyWith(
        //       color: context.hintColor,
        //       fontSize: (context.isMobile) ? 14 : 12,
        //     ),
        //     textAlign: TextAlign.center,
        //     maxLines: 2,
        //   ),
        // ),
        _buildDaftarSebagai(),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: (context.isMobile) ? context.dp(10) : 12,
            vertical: (context.isMobile) ? context.dp(20) : 36,
          ),
          child: CustomTextFormField(
            enabled: true,
            controller: widget.nomorRegistrasiTextController,
            onFieldSubmitted: (nomorRegistrasi) {
              logger.log('Login Form Widget Nomor Registrasi: '
                  '$nomorRegistrasi');
            },
            keyboardType: TextInputType.number,
            hintText: isSiswa
                ? 'Masukkan Nomor Registrasi Kamu'
                : 'Masukkan Nomor Handphone Anda',
            inputFormatters: [
              LengthLimitingTextInputFormatter(12),
              FilteringTextInputFormatter.digitsOnly,
            ],
            validator: (noRegistrasi) => isOrtu
                ? FormValidator.validatePhoneNumber(noRegistrasi, isOrtu)
                : FormValidator.validateNoRegistrasi(
                    noRegistrasi,
                    isOrtu,
                  ),
            prefixText: isOrtu ? '+62' : null,
          ),
        ),

        // hardcode waiting for imei
        // const RadioGroupOtpWidget(),
      ];

  bool get isOrtu {
    return widget.pilihanRoleController.value == AuthRole.ortu;
  }

  bool get isSiswa {
    return widget.pilihanRoleController.value == AuthRole.siswa;
  }
}
