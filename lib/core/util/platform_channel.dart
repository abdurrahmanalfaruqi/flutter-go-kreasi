import 'dart:developer' as logger show log;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:screen_protector/screen_protector.dart';

import '../config/constant.dart';

class PlatformChannel {
  static const MethodChannel methodChannel =
      MethodChannel('com.go_expert.app/secure_screen');
  // List daftar route name screen yg akan diproteksi.
  // Jangan lupa mematikan secure screen saat On Will Pop Scope.
  static const List<String> secureRouteName = [
    Constant.kRouteVideoPlayer,
    Constant.kRouteBukuTeoriContent,
    Constant.kRouteSoalBasicScreen,
    Constant.kRouteSoalTimerScreen,
  ];
  // bool _screenSecurityStatus = false;

  // static Future<void> setSecureScreen(
  //   String routeName, [
  //   bool isPop = false,
  // ]) async {
  //   String screenSecurityLog;
  //   try {
  //     if (isPop) {
  //       await Future.delayed(const Duration(seconds: 1));
  //     }

  //     bool screenSecurityStatus = false;
  //     if (secureRouteName.contains(routeName)) {
  //       // if routeNamed exist in secureRouteName, maka _screenSecurityStatus bernilai true.
  //       screenSecurityStatus = true;
  //     }
  //     // invoke method dengan _screenSecurityStatus value.
  //     final bool result = await methodChannel.invokeMethod(
  //         'setSecureScreen', screenSecurityStatus);
  //     // If true = Screen Protected; if false = Screen Unprotected.
  //     screenSecurityLog = 'SCREEN SECURITY STATUS: $result';

  //     if (kDebugMode) {
  //       logger.log('PLATFORM_CHANNEL-SetSecureScreen: $screenSecurityLog');
  //     }
  //   } on PlatformException catch (e) {
  //     screenSecurityLog =
  //         'Failed to set screen security.\nPLATFORM CHANNEL EXCEPTION: ${e.code} | ${e.message}';

  //     if (kDebugMode) {
  //       logger.log('PLATFORM_CHANNEL-SetSecureScreen: $screenSecurityLog');
  //     }
  //   }
  // }

  static Future<void> setSecureScreen(
    String routeName, [
    bool isPop = false,
  ]) async {
    String screenSecurityLog;
    try {
      if (isPop) {
        await Future.delayed(const Duration(seconds: 1));
      }

      bool screenSecurityStatus = secureRouteName.contains(routeName);

      if (screenSecurityStatus) {
        switch (Platform.operatingSystem) {
          case 'android':
            await ScreenProtector.protectDataLeakageOn();
            break;
          case 'ios':
            await ScreenProtector.preventScreenshotOn();
            break;
          default:
        }
      } else {
        switch (Platform.operatingSystem) {
          case 'android':
            await ScreenProtector.protectDataLeakageOff();
            break;
          case 'ios':
            await ScreenProtector.preventScreenshotOff();
            break;
          default:
        }
      }
      // If true = Screen Protected; if false = Screen Unprotected.
      screenSecurityLog = 'SCREEN SECURITY STATUS: $screenSecurityStatus';

      if (kDebugMode) {
        logger.log('PLATFORM_CHANNEL-SetSecureScreen: $screenSecurityLog');
        print('PLATFORM_CHANNEL-SetSecureScreen: $screenSecurityLog');
      }
    } on PlatformException catch (e) {
      screenSecurityLog =
          'Failed to set screen security.\nPLATFORM CHANNEL EXCEPTION: ${e.code} | ${e.message}';

      if (kDebugMode) {
        logger.log('PLATFORM_CHANNEL-SetSecureScreen: $screenSecurityLog');
      }
    }
  }
}
