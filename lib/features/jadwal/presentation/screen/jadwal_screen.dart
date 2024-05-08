import 'dart:async';
import 'dart:developer' as logger show log;

import 'package:flash/flash_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/core/config/extensions.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/jadwal/presentation/bloc/scan_qr/scan_qr_bloc.dart';
import 'package:gokreasi_new/features/profile/domain/entity/scanner_type.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// import '../provider/jadwal_provider.dart';
import '../widget/jadwal_list_widget.dart';
import '../../../menu/entity/menu.dart';
import '../../../menu/presentation/provider/menu_provider.dart';
import '../../../standby/presentation/widget/standby_widget.dart';
import '../../../video/presentation/widget/jadwal/video_jadwal_widget.dart';
import '../../../../core/config/enum.dart';
import '../../../../core/config/global.dart';
import '../../../../core/helper/hive_helper.dart';
import '../../../../core/util/app_exceptions.dart';
import '../../../../core/util/data_formatter.dart';
import '../../../../core/util/custom_scan_qr_util.dart';
import '../../../../core/util/custom_location_util.dart';
import '../../../../core/shared/widget/loading/shimmer_widget.dart';
import '../../../../core/shared/screen/drop_down_action_screen.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({Key? key}) : super(key: key);

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  late Menu _selectedJadwal;

  late ScanQrBloc scanQrBloc;
  UserModel? userData;

  @override
  void initState() {
    super.initState();
    scanQrBloc = context.read<ScanQrBloc>();
    final authState = context.read<AuthBloc>().state;
    if (authState is LoadedUser) {
      userData = authState.user;
    }
    _selectedJadwal = (userData.isSiswa)
        ? MenuProvider.listMenuJadwal[0]
        : MenuProvider.listMenuJadwalOrtu[0];
  }

  late final String _noRegistrasi = userData?.noRegistrasi ?? '';
  late final List<String> _idKelasGO = userData?.idKelasGO ?? [];

  @override
  void dispose() {
    if (HiveHelper.isBoxOpen<ScannerType>(boxName: HiveHelper.kSettingBox)) {
      HiveHelper.closeBox<ScannerType>(boxName: HiveHelper.kSettingBox);
    }
    super.dispose();
  }

  Future<bool> _openSettingBox() async {
    if (!HiveHelper.isBoxOpen<ScannerType>(boxName: HiveHelper.kSettingBox)) {
      await HiveHelper.openBox<ScannerType>(boxName: HiveHelper.kSettingBox);
    }
    return HiveHelper.isBoxOpen<ScannerType>(boxName: HiveHelper.kSettingBox);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScanQrBloc, ScanQrState>(
      listener: (context, state) {
        if (state is ScanQRError) {
          Future.delayed(Duration.zero, () {
            gShowTopFlash(
              context,
              state.err,
              dialogType: DialogType.error,
            );
          });
        }

        if (state is ScanQRSuccess) {
          Future.delayed(Duration.zero, () {
            gShowTopFlash(
              context,
              state.message,
              dialogType: DialogType.success,
            );
          });
        }
      },
      child: DropDownActionScreen(
        isWatermarked: false,
        title: (userData.isSiswa) ? 'Jadwal & Video' : 'Jadwal',
        dropDownItems: (userData.isSiswa)
            ? MenuProvider.listMenuJadwal
            : MenuProvider.listMenuJadwalOrtu,
        selectedItem: _selectedJadwal,
        onChanged: (newValue) {
          setState(() => _selectedJadwal = newValue!);
        },
        body: (_selectedJadwal.label == "Jadwal")
            ? const JadwalListWidget()
            : (_selectedJadwal.label == "Video")
                ? const VideoJadwalWidget()
                : const StandbyWidget(),
        floatingActionButton: FutureBuilder<bool>(
          future: _openSettingBox(),
          builder: (_, snapshot) => (snapshot.connectionState ==
                  ConnectionState.waiting)
              ? ShimmerWidget.rounded(
                  width: 32,
                  height: 32,
                  borderRadius: BorderRadius.circular(12),
                )
              : ValueListenableBuilder<Box<ScannerType>>(
                  valueListenable: HiveHelper.listenableQRScanner(),
                  builder: (_, box, qrIcon) => AnimatedSwitcher(
                    duration: const Duration(seconds: 1),
                    layoutBuilder: (currentChild, previousChildren) => Stack(
                      alignment: Alignment.centerRight,
                      children: <Widget>[
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    ),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    transitionBuilder: (child, anim) => SlideTransition(
                      position: Tween(
                        begin: const Offset(2.0, 0.0),
                        end: const Offset(0.0, 0.0),
                      ).animate(anim),
                      child: child,
                    ),
                    child:
                        (_selectedJadwal.label != 'Video' && userData.isSiswa)
                            ? FloatingActionButton(
                                onPressed: () async =>
                                    await _scanQRPresensi(box.get(
                                  HiveHelper.kScannerKey,
                                  defaultValue: ScannerType.mobileScanner,
                                )!),
                                child: qrIcon,
                              )
                            : const SizedBox(),
                  ),
                  child: const Icon(Icons.qr_code_scanner, size: 30),
                ),
        ),
      ),
    );
  }

  Future<void> _scanQRPresensi(ScannerType scannerPilihan) async {
    var completer = Completer();
    try {
      // final jadwalProvider = context.read<JadwalProvider>();
      String message = 'Berhasil melakukan kehadiran';

      if (kDebugMode) {
        logger.log('JADWAL_LIST_WIDGET-OnClickQrScanner: START');
      }

      final Map dataQR =
          await CustomScanQrUtils.scanBarcode(context, scannerPilihan);

      // ignore: use_build_context_synchronously
      context.showBlockDialog(dismissCompleter: completer);
      if (kDebugMode) {
        logger.log('SCANNER RESULT >> $dataQR\n'
            'cek data from ${dataQR['from']}\n'
            'cek data isTst ${dataQR['from'] == 'tst'}');
      }

      if (!['teaching', 'tst'].contains(dataQR['from'])) {
        completer.complete();
        throw DataException(message: "QRCode tidak sesuai");
      }

      final String waktuPresensi = DataFormatter.formatLastUpdate();

      if (dataQR['from'] == 'teaching') {
        final coordinate = await CustomLocationUtil.getLocation();
        final tanggalPresensi = waktuPresensi.split(' ')[0];
        int flag = 0;
        String idSekolahKelas = "";

        for (int i = 0; i < _idKelasGO.length; i++) {
          if (kDebugMode) {
            logger.log(
                'JADWAL_LIST_WIDGET-OnClickQrScanner(teaching): Class Id >> '
                '$i ${dataQR['class_id']} | $i ${_idKelasGO[i]}');
          }

          if (dataQR['class_id'] == _idKelasGO[i]) {
            flag++;
            idSekolahKelas = _idKelasGO[i];
          }
        }

        Map<String, dynamic> params = {
          "id_rencana": int.parse(dataQR['uid']),
          "no_register": _noRegistrasi,
          "id_gedung": int.parse(dataQR['loc_code']),
          "latitude": coordinate.latitude,
          "longitude": coordinate.longitude,
          "tanggal": tanggalPresensi,
          "waktu_kehadiran": waktuPresensi,
          "id_device": await gGetIdDevice(),
          "id_kelas": int.parse(dataQR['class_id']),
          "nama_kelas": dataQR['class'],
          "id_kelas_siswa": idSekolahKelas.isEmpty
              ? int.parse(_idKelasGO.first)
              : int.parse(idSekolahKelas),
          "sesi": int.parse(dataQR['session']),
          "flag_kelas": (flag > 0) ? "Sama" : "Tidak Sama",
          "nik_pengajar": dataQR['person'],
          "nama_pengajar": dataQR['person_name'],
          "jam_awal": dataQR['start'],
          "jam_akhir": dataQR['finish'],
          "tingkat_kelas": int.parse(userData?.tingkatKelas ?? '0'),
        };

        if (kDebugMode) {
          logger.log('JADWAL_LIST_WIDGET-OnClickQrScanner(teaching):\n'
              'Data Presensi >> $params\n'
              'FLAG >> ${(flag > 0) ? 'Sama' : 'Tidak Sama'}\n'
              'KELAS GO >> ${_idKelasGO[0]}');
        }

        scanQrBloc.add(ScanQRKBM(params));
        // message = await jadwalProvider.setPresensiSiswa(params);
        // gShowTopFlash(
        //   gNavigatorKey.currentContext!,
        //   message,
        //   dialogType: DialogType.success,
        // );

        /// Pencegahan jika presensi dengan tingkat kelas yang berbeda
        /// Belum bisa digunakan karena harus menunggu perbaikan dari aplikasi pengajar
        // if (dataQR['id_sekolah_kelas'] ==
        //     userData?.idSekolahKelas) {
        //   message = await jadwalProvider.setPresensiSiswa(dataPresensi);
        //   gShowTopFlash(
        //     gNavigatorKey.currentContext!,
        //     message,
        //     dialogType: DialogType.success,
        //   );
        // } else {
        //     logger.log(
        //       "${dataQR['id_sekolah_kelas']} == ${userData?.idSekolahKelas}");
        //   gShowBottomDialogInfo(gNavigatorKey.currentContext!,
        //       message: "Oops! Tingkat kelasnya berbeda Sobat");
        // }
        if (kDebugMode) {
          logger.log('MESSAGE TEACHING >> $message');
        }
      }

      if (dataQR['from'] == 'tst') {
        final Map<String, dynamic> dataPresensi = {
          "id_permintaan":
              (dataQR['uid'] is int) ? dataQR['uid'] : int.parse(dataQR['uid']),
          "no_register": _noRegistrasi,
          "waktu_kehadiran": waktuPresensi
        };

        if (kDebugMode) {
          logger.log('dataQR >> $dataQR');
          logger.log(
              'JADWAL_LIST_WIDGET-OnClickQrScanner(tst): Data Presensi >> $dataPresensi');
        }

        scanQrBloc.add(ScanQRTST(dataPresensi));
      }

      if (!completer.isCompleted) {
        completer.complete();
      }
    } on QRException catch (e) {
      if (!completer.isCompleted) {
        completer.complete();
      }
      if (e.toString().contains('QR Code tidak terbaca')) {
        List<String> titleMessage = e.toString().split('|');
        gShowBottomDialogInfo(
          gNavigatorKey.currentContext!,
          title: titleMessage[0],
          message: titleMessage[1],
        );
      } else {
        gShowTopFlash(
          gNavigatorKey.currentContext!,
          e.toString(),
        );
      }
      if (kDebugMode) {
        logger.log('JADWAL_LIST_WIDGET-QRException: $e');
      }
    } on LocationException catch (e) {
      if (!completer.isCompleted) {
        completer.complete();
      }
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        e.toString(),
      );
      if (kDebugMode) {
        logger.log('JADWAL_LIST_WIDGET-LocationException: $e');
      }
    } on DataException catch (e) {
      if (!completer.isCompleted) {
        completer.complete();
      }
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        e.toString(),
      );
      if (kDebugMode) {
        logger.log('JADWAL_LIST_WIDGET-DataException: $e');
      }
    } on PlatformException catch (e) {
      if (!completer.isCompleted) {
        completer.complete();
      }
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        'Terjadi kesalahan saat scan QR Presensi',
      );
      if (kDebugMode) {
        logger.log('JADWAL_LIST_WIDGET-PlatformException: $e');
      }
    } catch (e) {
      if (!completer.isCompleted) {
        completer.complete();
      }
      gShowBottomDialogInfo(
        gNavigatorKey.currentContext!,
        message: e.toString(),
      );

      if (kDebugMode) {
        logger.log('JADWAL_LIST_WIDGET-FatalException: $e');
      }
    }
  }
}
