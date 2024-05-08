import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gokreasi_new/core/helper/api_helper.dart';
import 'package:gokreasi_new/core/util/injector.dart';
import 'package:gokreasi_new/features/home/presentation/widget/update_version_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:upgrader/upgrader.dart';
import 'package:version/version.dart';

typedef UpgradeWidgetBuilder = Widget Function(
  BuildContext context,
  Upgrader upgrader,
);

class UpgradeWidget extends UpgradeBase {
  // final UpgradeWidgetBuilder builder;
  final Widget child;

  UpgradeWidget({
    Key? key,
    Upgrader? upgrader,
    // required this.builder,
    required this.child,
  }) : super(upgrader ?? Upgrader.sharedInstance, key: key);

  @override
  Widget build(BuildContext context, UpgradeBaseState state) {
    return FutureBuilder<CurrentVersion?>(
        future: _getStoreVersion(),
        builder: (context, snapshot) {
          // Membuat variableTemp guna mengantisipasi rebuild saat scroll
          Widget? childWidget;

          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            final currentVersion = snapshot.data!;
            if (currentVersion.shouldDisplayUpgrade()) {
              Future.delayed(Duration.zero, () async {
                await showModalBottomSheet(
                  context: context,
                  elevation: 0,
                  isDismissible: false,
                  isScrollControlled: false,
                  enableDrag: false,
                  backgroundColor: Colors.transparent,
                  constraints: const BoxConstraints(
                    minHeight: 10,
                    maxHeight: 640,
                  ),
                  builder: (context) {
                    childWidget ??= UpdateVersionWidget(
                      installedVersion: currentVersion.appVersion,
                      storeVersion: currentVersion.storeVersion,
                      releaseNotes: currentVersion.releaseNotes,
                    );
                    return childWidget!;
                  },
                );
              });
              // return builder.call(context, upgrader);
            }
          }

          return child;
        });
  }

  String get _baseUrlIOS {
    return 'https://itunes.apple.com/lookup?bundleId=com.gokreasinew.ganeshaoperation&country=ID&_cb=1707200786920355';
  }

  Future<CurrentVersion?> _getStoreVersion() async {
    try {
      String? storeVersion;
      String? releaseNotes;

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentAppVersion = packageInfo.version;

      if (Platform.isIOS) {
        final apiHelper = locator<ApiHelper>();
        final res = await apiHelper.dio.get(_baseUrlIOS);
        final result = jsonDecode(res.data);
        final storeResult = (result['results'] as List).first;

        storeVersion = storeResult['version'];
        releaseNotes = storeResult['releaseNotes'];

        if (storeVersion == null) return null;
      } else if (Platform.isAndroid) {
        final playStore = PlayStoreSearchAPI();
        final res = await playStore.lookupById(
          'com.gobimbel_online',
          country: 'US',
          language: 'en',
        );

        if (res == null) return null;

        storeVersion = playStore.version(res);
        releaseNotes = playStore.releaseNotes(res);

        if (storeVersion == null) return null;
      }

      return CurrentVersion(
        appVersion: currentAppVersion,
        storeVersion: storeVersion ?? '',
        releaseNotes: releaseNotes ?? '',
      );
    } catch (e) {
      return null;
    }
  }
}

class CurrentVersion {
  final String appVersion;
  final String storeVersion;
  final String releaseNotes;

  const CurrentVersion({
    required this.appVersion,
    required this.storeVersion,
    required this.releaseNotes,
  });

  /// [shouldDisplayUpgrade] digunakan untuk mengecek apakah user harus update aplikasi
  /// jika false maka user sudah terupdate dan tidak harus update aplikasi
  bool shouldDisplayUpgrade() {
    final appStoreVersion = Version.parse(storeVersion);
    final installedVersion = Version.parse(appVersion);

    return appStoreVersion > installedVersion;
  }
}
