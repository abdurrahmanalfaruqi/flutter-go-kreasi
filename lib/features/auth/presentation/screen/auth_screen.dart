// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer' as logger;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gokreasi_new/core/shared/screen/pilih_anak_screen.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/pilih_anak/pilih_anak_bloc.dart';
import 'package:gokreasi_new/features/home/presentation/bloc/home/home_bloc.dart';
import 'package:gokreasi_new/features/home/presentation/widget/promotion_widget.dart';

import '../widget/login_form_widget.dart';
import '../../../../core/config/enum.dart';
import '../../../../core/config/global.dart';
import '../../../../core/config/constant.dart';
import '../../../../core/config/extensions.dart';
import '../../../../core/helper/kreasi_shared_pref.dart';
import '../../../../core/shared/builder/responsive_builder.dart';

class AuthScreen extends StatefulWidget {
  final AuthMode authMode;

  const AuthScreen({Key? key, required this.authMode}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Local Variable
  bool _login = true;
  bool? _initLogin;
  String? deviceId;
  bool? isErrorOrtu;

  final _scrollController = ScrollController();
  late final _navigator = Navigator.of(context);

  // Form Controller And Notifier
  final _loginFormKey = GlobalKey<FormState>();
  final _regisFormKey = GlobalKey<FormState>();

  final _pilihanRole = ValueNotifier<AuthRole>(AuthRole.siswa);
  final _noRegController = TextEditingController();
  final _noRegistrasiController = TextEditingController();
  final _namaLengkapController = TextEditingController();
  final _emailController = TextEditingController();
  final _tanggalLahirController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initLogin = true;
    String? role = KreasiSharedPref().getSiapa();
    String? savedPhoneNumber = KreasiSharedPref().getNomorReg();
    String? nomorHpOrtu = KreasiSharedPref().getNomorHpOrtu();

    if (role != null && role == 'ORTU' && nomorHpOrtu != null) {
      _pilihanRole.value = AuthRole.ortu;
      _noRegController.text = nomorHpOrtu;
    } else if (savedPhoneNumber != null && savedPhoneNumber.isNotEmpty) {
      _noRegController.text = savedPhoneNumber;
    }

    _pilihanRole.addListener(_setTextFormFieldValue);

    // to get promotion event
    context.read<HomeBloc>().add(GetPromotionEvent());
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) _showPromotionPopUp();
    });
  }

  @override
  void dispose() {
    _pilihanRole.dispose();
    _noRegController.dispose();
    _noRegistrasiController.dispose();
    _namaLengkapController.dispose();
    _emailController.dispose();
    _tanggalLahirController.dispose();

    if (kDebugMode) {
      logger.log('USER_INFO_APP_BAR: On Click Navigate to Main Screen');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<PilihAnakBloc, PilihAnakState>(
        listener: (context, anakState) {
          if (anakState is LoadedListAnak) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PilihAnakScreen(
                nomorHpOrtu: _noRegController.text,
              ),
            ));
          }

          if (anakState is PilihAnakError) {
            Future.delayed(Duration.zero, () {
              gShowTopFlash(
                context,
                anakState.err,
                dialogType: DialogType.error,
              );
            });
          }

          if (anakState is PilihAnakErrResponse) {
            Future.delayed(Duration.zero, () {
              gShowTopFlash(
                context,
                anakState.err,
                dialogType: DialogType.error,
              );
            });
          }
        },
        builder: (context, anakState) {
          if (anakState is PilihAnakErrResponse) {
            isErrorOrtu = true;
            anakState.err.contains('login') ||
                    anakState.err.contains('terdaftar')
                ? deviceId = anakState.deviceId
                : deviceId = null;
          }

          return BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) async {
              if (state is AuthErrorLogin) {
                Future.delayed(Duration.zero, () {
                  gShowTopFlash(
                    context,
                    state.err,
                    dialogType: DialogType.error,
                  );
                });
              }

              if (state is LoadedOTP) {
                if (_pilihanRole.value == AuthRole.siswa) {
                  context.read<AuthBloc>().add(
                        AuthLogin(
                          userTypeRefresh: _pilihanRole.value.name,
                          nomorReg: _noRegController.text,
                        ),
                      );
                } else {
                  context.read<PilihAnakBloc>().add(GetAnakList(
                        nomorHpOrtu: _noRegController.text,
                      ));
                }
              }

              if (state is LoadedUser) {
                if (state.user != null) {
                  // Simpan data user di local storage agar persistent.
                  await KreasiSharedPref().simpanDataLokal();

                  if (kDebugMode) logger.log("MASUK HOME SCREEN");
                  // Navigate ke HOME SCREEN
                  Future.delayed(gDelayedNavigation).then((_) {
                    if (gRoute != Constant.kRouteMainScreen) {
                      _navigator.pushNamedAndRemoveUntil(
                        Constant.kRouteMainScreen,
                        (route) => false,
                        arguments: {
                          'idSekolahKelas': state.user?.idSekolahKelas,
                          'userModel': state.user,
                        },
                      );
                    }
                  });
                }
              }
            },
            builder: (context, state) {
              if (state is AuthErrorLogin) {
                isErrorOrtu = false;
                state.err.contains('login') || state.err.contains('terdaftar')
                    ? deviceId = state.deviceId
                    : deviceId = null;
              }

              return GestureDetector(
                onTap: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);

                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                },
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    width: context.dw,
                    height: context.dh,
                    padding: EdgeInsets.only(
                      top: (context.isMobile) ? context.dp(38) : 32,
                      right: (context.isMobile) ? context.dp(20) : 14,
                      left: min(32, context.dp(20)),
                      bottom: (context.isMobile) ? context.dp(30) : 32,
                    ),
                    child: ResponsiveBuilder(
                      mobile: Column(
                        children: [
                          _buildAnimatedImage(context),
                          _buildForm(context),
                          _buildDeviceIdText(deviceId),
                          _buildMasukDaftarButton(context),
                          _buildStorageCheckText(),
                        ],
                      ),
                      tablet: Row(
                        children: [
                          _buildAnimatedImage(context),
                          Expanded(
                            child: Scrollbar(
                              controller: _scrollController,
                              thickness: 8,
                              thumbVisibility: true,
                              trackVisibility: true,
                              radius: const Radius.circular(14),
                              child: ListView(
                                controller: _scrollController,
                                padding: const EdgeInsets.only(
                                  left: 12,
                                  right: 12,
                                ),
                                children: [
                                  _buildForm(context),
                                  const SizedBox(height: 32),
                                  _buildDeviceIdText(deviceId),
                                  _buildMasukDaftarButton(context),
                                  _buildStorageCheckText(),
                                  const SizedBox(height: 82),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// NOTE: Tempat function - function fungsional-------------------------------
  void _onClickedChangeLogin() => setState(() => _login = !_login);

  /// [_onClickedMasuk] Function on click Masuk Button
  void _onClickedMasuk(BuildContext context) async {
    if (!_login) {
      _onClickedChangeLogin();
      return;
    }

    if (!_loginFormKey.currentState!.validate()) return;

    if (_noRegController.text.isEmpty) {
      gShowTopFlash(
          context,
          (_pilihanRole.value.name == 'siswa')
              ? 'Isi dulu nomor registrasi kamu ya Sobat'
              : 'Mohon isi terlebih dahulu nomor registrasi anda');
      return;
    }

    setState(() {
      _initLogin = false;
    });

    context.read<AuthBloc>().add(AuthGenerateOTP());
  }

  /// [_onClickedDaftar] Function on click Daftar Button
  // void _onClickedDaftar(BuildContext context) async {
  //   if (_login) {
  //     _onClickedChangeLogin();
  //     return;
  //   }

  //   if (kDebugMode) {
  //     logger.log('AUTH_SCREEN-ON_CLICK_REGISTER: User Input >> '
  //         '(${_noRegistrasiController.text}, ${_noHpController.text}, '
  //         '${_pilihanRole.value.name})');
  //     logger.log('AUTH_SCREEN-ON_CLICK_REGISTER: User Input Tamu >> '
  //         '(${_emailController.text},'
  //         ' ${_namaLengkapController.text},'
  //         '${_tanggalLahirController.text})');
  //   }

  //   if (_noRegistrasiController.text.isEmpty &&
  //       _pilihanRole.value.name != 'tamu') {
  //     if (_pilihanRole.value.name == 'siswa') {
  //       gShowTopFlash(context, 'Isi dulu no registrasi kamu ya Sobat');
  //     } else {
  //       gShowBottomDialogInfo(context,
  //           dialogType: DialogType.error,
  //           message:
  //               'Mohon isi terlebih dahulu no registrasi putra/putri anda');
  //     }
  //     return;
  //   }
  //   if (_noHpController.text.isEmpty) {
  //     if (_pilihanRole.value.name == 'ORTU') {
  //       gShowBottomDialogInfo(context,
  //           dialogType: DialogType.error,
  //           message: 'Mohon isi terlebih dahulu nomor handphone anda');
  //     } else {
  //       gShowTopFlash(context, 'Isi dulu nomor HP kamu ya Sobat');
  //     }
  //     return;
  //   }
  //   if (_pilihanRole.value.name.isEmpty) {
  //     gShowTopFlash(context, 'Mohon pilih daftar sebagai apa');
  //     return;
  //   }
  //   if (_pilihanRole.value.name == 'tamu') {
  //     if (_authOtpProvider.idSekolahKelas.value.isEmpty) {
  //       gShowTopFlash(context, 'Pilih dulu tingkat kelas kamu ya Sobat');
  //       return;
  //     }
  //     if (_namaLengkapController.text.isEmpty) {
  //       gShowTopFlash(context, 'Isi dulu nama kamu ya Sobat');
  //       return;
  //     }
  //     if (_emailController.text.isEmpty) {
  //       gShowTopFlash(context, 'Isi dulu email kamu ya Sobat');
  //       return;
  //     }
  //     if (_tanggalLahirController.text.isEmpty) {
  //       gShowTopFlash(context, 'Isi dulu tanggal lahir kamu ya Sobat');
  //       return;
  //     }
  //   }

  //   var completerAturan = Completer();

  //   context.showBlockDialog(dismissCompleter: completerAturan);

  //   // Jika di tampung di dalam late final, maka hasil generate OTP akan sama,
  //   // Kecuali keluar dari AuthScreen terlebih dahulu.
  //   // Hal tersebut dikarenakan hasil generate OTP sudah di store pada variable late final.
  //   final otp = await _authOtpProvider.generateOTP().onError(
  //     (error, stackTrace) async {
  //       if (kDebugMode) {
  //         logger.log(
  //             'AUTH_SCREEN: ERROR generateOTP >> $error\nSTACKTRACE: $stackTrace');
  //       }
  //       gShowTopFlash(context, 'Gagal Memuat OTP',
  //           dialogType: DialogType.error);
  //       // generate ulang OTP
  //       return await _authOtpProvider.generateOTP();
  //     },
  //   );

  //   bool isOrtu = _pilihanRole.value.name.equalsIgnoreCase('ortu');
  //   bool isTamu = _pilihanRole.value.name.equalsIgnoreCase('tamu');

  //   bool isSetujuAturan = (isTamu)
  //       ? true
  //       : await context.read<ProfileProvider>().loadAturanSiswa(
  //             noRegistrasi: _noRegistrasiController.text,
  //             tipeUser: _pilihanRole.value.name.toUpperCase(),
  //           );

  //   if (!completerAturan.isCompleted) {
  //     completerAturan.complete();
  //   }

  //   if (!isSetujuAturan) {
  //     isSetujuAturan = (await showModalBottomSheet<bool>(
  //           context: context,
  //           isDismissible: true,
  //           isScrollControlled: true,
  //           constraints: BoxConstraints(
  //             minHeight: 10,
  //             maxHeight: context.dh * 0.9,
  //             maxWidth: (context.isMobile) ? context.dw : 650,
  //           ),
  //           shape: const RoundedRectangleBorder(
  //               borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
  //           builder: (context) => TataTertibWidget(
  //             noRegistrasi: _noRegistrasiController.text,
  //             tipeUser: _pilihanRole.value.name.toUpperCase(),
  //           ),
  //         )) ??
  //         false;
  //   }

  //   if (isSetujuAturan || isTamu) {
  //     var completerRegistrasi = Completer();

  //     Future.delayed(
  //       gDelayedNavigation,
  //       () => context.showBlockDialog(dismissCompleter: completerRegistrasi),
  //     );

  //     Map<String, dynamic> responseRegister =
  //         await context.read<AuthOtpProvider>().cekValidasiRegistrasi(
  //               otp: otp,
  //               noRegistrasi: DataFormatter.formatNIS(
  //                 roleIndex: 0,
  //                 userId: _noRegistrasiController.text,
  //               ),
  //               nomorHp: DataFormatter.formatPhoneNumber(
  //                 phoneNumber: _noHpController.text,
  //               ),
  //               namaLengkap: _namaLengkapController.text,
  //               email: _emailController.text,
  //               authRole: _pilihanRole.value,
  //               ttl: (_tanggalLahirController.text.isNotEmpty)
  //                   ? DataFormatter.dateTimeToString(
  //                       DataFormatter.stringToDate(
  //                           _tanggalLahirController.text, 'dd MMM yyyy'),
  //                       'yyyy-MM-dd',
  //                     )
  //                   : null,
  //             );

  //     bool isValidToRegister = responseRegister['status'];
  //     if (kDebugMode) {
  //       logger.log('AUTH_SCREEN-ON_CLICK_REGISTER: Generate OTP >> $otp');
  //       logger.log(
  //           'AUTH_SCREEN-ON_CLICK_REGISTER: Cek Validasi Response >> $isValidToRegister');
  //     }

  //     if (!completerRegistrasi.isCompleted) {
  //       completerRegistrasi.complete();
  //     }

  //     if (isValidToRegister) {
  //       if (responseRegister['message'] == "Sudah pernah terdaftar") {
  //         /// Jika Sudah pernah mendaftar dan imeinya sama maka langsung memanggil fungsi login

  //         await _authOtpProvider.login(
  //           otp: otp,
  //           userTypeRefresh: _pilihanRole.value.toString(),
  //           nomorHp: _noHpController.text,
  //         );
  //         await KreasiSharedPref().simpanDataLokal();
  //         if (kDebugMode) {
  //           logger.log("MASUK HOME SCREEN");
  //         }
  //         Future.delayed(gDelayedNavigation)
  //             .then((value) => _navigator.popUntil((route) => route.isFirst));
  //       } else {
  //         Future.delayed(
  //           gDelayedNavigation,
  //           () => _navigator.pushNamed(Constant.kRouteOTPScreen,
  //               arguments: {'isLogin': _login}),
  //         );
  //       }
  //     }
  //   } else {
  //     await Future.delayed(const Duration(milliseconds: 600));
  //     if (!isSetujuAturan) {
  //       gShowBottomDialogInfo(
  //         context,
  //         message:
  //             'Untuk mendaftar Go Expert, ${isOrtu ? 'anda' : 'kamu'} harus menyetujui peraturan '
  //             'tata tertib yang berlaku di Ganesha Operation!',
  //       );
  //     }
  //   }
  // }

  /// NOTE: Tempat function - function fungsional END---------------------------

  /// NOTE: Kumpulan function widget--------------------------------------------
  // Animated Image Header
  Widget _buildAnimatedImage(BuildContext context) {
    String baseUrlImage = dotenv.env['BASE_URL_IMAGE']!;
    double imgHeightLogin = (context.dh < 550)
        ? context.h(280)
        : (context.dh < 690)
            ? context.h(310)
            : context.h(350);
    // double imgHeightTamu = (context.dh < 550)
    //     ? context.h(80)
    //     : (context.dh < 690)
    //         ? context.h(100)
    //         : context.h(150);
    double imgHeightRegis = (context.dh < 550)
        ? context.h(200)
        : (context.dh < 690)
            ? context.h(220)
            : context.h(300);

    if (!context.isMobile) {
      imgHeightLogin = min(660, context.dh);
      // imgHeightTamu = min(660, context.dh);
      imgHeightRegis = min(660, context.dh);
    }

    return ValueListenableBuilder<AuthRole>(
      valueListenable: _pilihanRole,
      builder: (context, pilihanRole, child) {
        // bool isTamu = pilihanRole == AuthRole.tamu;

        return AnimatedContainer(
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 500),
          width: ((context.isMobile) ? context.dw : context.dw / 2) -
              context.dp(40),
          height: _login ? imgHeightLogin : imgHeightRegis,
          // _login
          //     ? imgHeightLogin
          //     : isTamu
          //         ? imgHeightTamu
          //         : imgHeightRegis,
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.dp(18)),
            gradient: LinearGradient(
              colors: [
                context.primaryColor,
                const Color(0xFFF25C38),
                context.secondaryColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.2, 0.4, 1],
            ),
          ),
          child: Transform.translate(
            offset: Offset(0, (context.isMobile) ? 11 : 14),
            child: CachedNetworkImage(
              imageUrl: '$baseUrlImage/media/auth_illustration.png',
              fit: BoxFit.fitHeight,
              placeholder: (context, url) => const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }

  // Animated Form
  Widget _buildForm(BuildContext context) {
    Widget animatedSwitcher = AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _login
          ? Form(
              key: _loginFormKey,
              child: LoginFormWidget(
                key: const Key('Login-Form-Widget'),
                nomorRegistrasiTextController: _noRegController,
                pilihanRoleController: _pilihanRole,
              ),
            )
          : Form(key: _regisFormKey, child: Container()
              // SignUpFormWidget(
              //   key: const Key('Sign-Up-Form-Widget'),
              //   pilihanRoleController: _pilihanRole,
              //   noRegistrasiController: _noRegistrasiController,
              //   nomorHandphoneController: _noRegController,
              //   namaLengkapController: _namaLengkapController,
              //   emailController: _emailController,
              //   tanggalLahirController: _tanggalLahirController,
              // ),
              ),
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
    );

    return (context.isMobile)
        ? Expanded(child: animatedSwitcher)
        : animatedSwitcher;
  }

  // Animated Button Login dan Sign-Up
  Container _buildMasukDaftarButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: (context.isMobile) ? context.dp(62) : context.dp(32),
      clipBehavior: Clip.hardEdge,
      margin: (context.isMobile)
          ? EdgeInsets.symmetric(horizontal: context.dp(102.5))
          : null,
      decoration: BoxDecoration(
        // color: context.primaryColor,
        borderRadius: (context.isMobile)
            ? BorderRadius.circular(20)
            : BorderRadius.circular(32),
      ),
      child: LayoutBuilder(builder: (context, constraint) {
        double buttonWidth =
            (context.isMobile) ? (context.dw - context.dp(99)) / 2 : 350;

        return Stack(
          children: [
            AnimatedAlign(
              curve: Curves.easeOut,
              duration: const Duration(milliseconds: 500),
              alignment:
                  (context.isMobile) ? Alignment.centerLeft : Alignment.center,
              child: Container(
                width: buttonWidth,
                decoration: BoxDecoration(
                  color: context.secondaryColor,
                  borderRadius: (context.isMobile)
                      ? BorderRadius.circular(20)
                      : BorderRadius.circular(32),
                  boxShadow: (context.isMobile)
                      ? [
                          BoxShadow(
                            color: context.disableColor,
                            blurRadius: 4,
                            spreadRadius: 0,
                            offset: const Offset(-2, 0),
                          ),
                          BoxShadow(
                            color: context.disableColor,
                            blurRadius: 4,
                            spreadRadius: 0,
                            offset: const Offset(2, 0),
                          )
                        ]
                      : null,
                ),
              ),
            ),
            BlocBuilder<PilihAnakBloc, PilihAnakState>(
              builder: (context, anakState) {
                return BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    bool isLoading =
                        state is AuthLoading || anakState is PilihAnakLoading;

                    return Align(
                      alignment: (context.isMobile)
                          ? Alignment.centerLeft
                          : Alignment.center,
                      heightFactor: context.dp(62),
                      widthFactor: buttonWidth,
                      child: TextButton(
                        onPressed: () =>
                            isLoading ? null : _onClickedMasuk(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: (context.isMobile)
                                ? context.dp(16)
                                : context.dp(10),
                            horizontal: (context.isMobile)
                                ? context.dp(40)
                                : context.dp(24),
                          ),
                        ),
                        child: Builder(
                          builder: (context) {
                            Widget loadingWidget = const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                ),
                              ),
                            );

                            return isLoading
                                ? loadingWidget
                                : Text(
                                    'Masuk',
                                    style: context.text.headlineSmall?.copyWith(
                                        fontSize: (context.isMobile) ? 20 : 17),
                                  );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            // Align(
            //   alignment: Alignment.centerRight,
            //   heightFactor: context.dp(62),
            //   widthFactor: buttonWidth,
            //   child: TextButton(
            //     onPressed: () => _onClickedDaftar(context),
            //     style: TextButton.styleFrom(
            //       padding: EdgeInsets.symmetric(
            //         vertical:
            //             (context.isMobile) ? context.dp(16) : context.dp(10),
            //         horizontal:
            //             (context.isMobile) ? context.dp(40) : context.dp(24),
            //       ),
            //     ),
            //     child: Text(
            //       'Daftar',
            //       style: context.text.headlineSmall
            //           ?.copyWith(fontSize: (context.isMobile) ? 20 : 17),
            //     ),
            //   ),
            // )
          ],
        );
      }),
    );
  }

  Widget _buildDeviceIdText(String? deviceId) {
    Widget? deviceIdText;
    bool isValid =
        (_pilihanRole.value == AuthRole.siswa && isErrorOrtu == false) ||
            (_pilihanRole.value == AuthRole.ortu && isErrorOrtu == true);
    deviceIdText ??= Visibility(
      visible: isValid && _initLogin == false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        margin: const EdgeInsets.only(
          bottom: 40,
          right: 10,
          left: 10,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: Colors.red,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Builder(builder: (context) {
              String name =
                  _pilihanRole.value == AuthRole.siswa ? 'Sobat' : 'Anda';
              return Text(
                'Device id $name:',
                textAlign: TextAlign.center,
              );
            }),
            Text(
              deviceId ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
    return (deviceId == null) ? Container() : deviceIdText;
  }

  /// NOTE: Kumpulan function widget END----------------------------------------
  Widget _buildStorageCheckText() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          '* storage minimal tersedia 1 GB',
          style: context.text.labelSmall,
        ),
      ],
    );
  }

  void _setTextFormFieldValue() {
    String? savedPhoneNumber = KreasiSharedPref().getNomorReg() ?? '';
    String? nomorHpOrtu = KreasiSharedPref().getNomorHpOrtu() ?? '';

    _noRegController.text = '';
    if (_pilihanRole.value == AuthRole.siswa && savedPhoneNumber.isNotEmpty) {
      _noRegController.text = savedPhoneNumber;
    } else if (nomorHpOrtu.isNotEmpty) {
      _noRegController.text = nomorHpOrtu;
    }
    setState(() {});
  }

  void _showPromotionPopUp() {
    showDialog(
      context: context,
      builder: (context) => const PromotionWidget(),
    );
  }
}
