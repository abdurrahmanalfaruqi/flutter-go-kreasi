import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gokreasi_new/core/config/constant.dart';
import '../../features/auth/data/model/user_model.dart';

import 'global.dart';
import '../util/data_formatter.dart';

// Mockup design size
const mockupHeight = 844;
const mockupWidth = 390;

extension ScreenUtil on BuildContext {
  // Device information
  double get dw => MediaQuery.of(this).size.width;
  double get dh => MediaQuery.of(this).size.height;
  double get dAspectRatio => MediaQuery.of(this).size.aspectRatio;
  double get statusBarHeight => MediaQuery.of(this).viewPadding.top;
  double get bottomBarHeight => MediaQuery.of(this).viewPadding.bottom;
  double get dPixelRatio => MediaQuery.of(this).devicePixelRatio;
  double get dts => MediaQuery.of(this).textScaleFactor;
  Orientation get orientation => MediaQuery.of(this).orientation;
  bool get isPortrait => orientation == Orientation.portrait;
  bool get isLandscape => orientation == Orientation.landscape;

  // Pixel Perfect Ratio
  double get sw => mockupWidth / dw;
  double get sh => mockupHeight / dh;
  double get ts => dw / mockupWidth;
  double get textScale14 => min(ts, 1.4);
  double get textScale12 => min(ts, 1.2);
  double get textScale11 => min(ts, 1.1);
  double dp(double size) => size / mockupWidth * dw;
  double h(double size) => size / mockupHeight * dh;

  ThemeData get themeData => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // Responsive Helper
  bool get isMobile => dw < 600;
  // bool get isMobile => dw < 600 || dh < 900;
  bool get isTablet => dw >= 600;
  bool get isDesktop => dw >= 1100;

  // Padding
  double get pd => isMobile ? 16.0 : 32.0;

  // Text and Color Theme data
  TextTheme get text => Theme.of(this).textTheme;
  Color get primaryColor => Theme.of(this).colorScheme.primary;
  Color get primaryContainer => Theme.of(this).colorScheme.primaryContainer;
  Color get inversePrimary => Theme.of(this).colorScheme.inversePrimary;
  Color get secondaryColor => Theme.of(this).colorScheme.secondary;
  Color get secondaryContainer => Theme.of(this).colorScheme.secondaryContainer;
  Color get tertiaryColor => Theme.of(this).colorScheme.tertiary;
  Color get tertiaryContainer => Theme.of(this).colorScheme.tertiaryContainer;
  Color get surface => Theme.of(this).colorScheme.surface;
  Color get surfaceVariant => Theme.of(this).colorScheme.surfaceVariant;
  Color get inverseSurface => Theme.of(this).colorScheme.inverseSurface;
  Color get errorColor => Theme.of(this).colorScheme.error;
  Color get errorContainer => Theme.of(this).colorScheme.errorContainer;
  Color get background => Theme.of(this).colorScheme.background;
  Color get outline => Theme.of(this).colorScheme.outline;
  Color get hintColor => Theme.of(this).hintColor;
  Color get disableColor => Theme.of(this).disabledColor;

  // Text and Icon Color
  Color get onPrimary => Theme.of(this).colorScheme.onPrimary;
  Color get onPrimaryContainer => Theme.of(this).colorScheme.onPrimaryContainer;
  Color get onSecondary => Theme.of(this).colorScheme.onSecondary;
  Color get onSecondaryContainer =>
      Theme.of(this).colorScheme.onSecondaryContainer;
  Color get onTertiary => Theme.of(this).colorScheme.onTertiary;
  Color get onTertiaryContainer =>
      Theme.of(this).colorScheme.onTertiaryContainer;
  Color get onError => Theme.of(this).colorScheme.onError;
  Color get onErrorContainer => Theme.of(this).colorScheme.onErrorContainer;
  Color get onBackground => Theme.of(this).colorScheme.onBackground;
  Color get onSurface => Theme.of(this).colorScheme.onSurface;
  Color get onSurfaceVariant => Theme.of(this).colorScheme.onSurfaceVariant;
  Color get onInverseSurface => Theme.of(this).colorScheme.onInverseSurface;

  // Widgets theme data
  ElevatedButtonThemeData get elevatedButton =>
      Theme.of(this).elevatedButtonTheme;

  // Theme
  bool get isDarkMode =>
      Theme.of(this).colorScheme.brightness == Brightness.dark;
// bool get isDarkModePlatform =>
//     MediaQuery.of(this).platformBrightness == Brightness.dark;
}

extension UserData on UserModel? {
  bool get isSiswa => this != null && this?.siapa?.toUpperCase() == 'SISWA';
  bool get isTamu => this != null && this?.siapa?.toUpperCase() == 'TAMU';
  bool get isOrtu => this != null && this?.siapa?.toUpperCase() == 'ORTU';

  bool get isLogin => this != null;

  String get teaserRole =>
      (!isLogin || isOrtu) ? 'No User' : this?.siapa ?? 'No User';

  bool isProdukDibeliSiswa(int idJenisProduk, {bool ortuBolehAkses = false}) {
    bool isDibeli = this?.daftarProdukDibeli?.any((produk) =>
            produk.idJenisProduk == idJenisProduk && !produk.isExpired) ??
        false;
    return isOrtu ? (ortuBolehAkses && isDibeli) : isDibeli;
  }

  String get getTingkat =>
      Constant.kDataSekolahKelas.singleWhere(
        (sekolah) => sekolah['id'] == this?.idSekolahKelas,
        orElse: () => {
          'id': '0',
          'kelas': 'Undefined',
          'tingkat': 'N/a',
          'tingkatKelas': '0'
        },
      )['tingkat'] ??
      '0';
}

/// [HeroTag] Hero Tag extension on String
extension HeroTag on String {
  String get menu3B => 'MENU-$this';
  String get beritaTitleTag => 'BERITA-TITLE-$this';
  String get beritaImageTag => 'BERITA-IMAGE-$this';
  String get beritaDateTag => 'BERITA-DATE-$this';
  String get beritaDescriptionTag => 'BERITA-DESC-$this';
}

extension ColorString on String {
  Color get warnaRencana => Color(int.parse(replaceAll('#', '0xff')));
}

extension FireImage on String {
  String get sentenceCase => this[0].toUpperCase() + substring(1).toLowerCase();
  String get illustration => '${dotenv.env['BASE_URL_IMAGE']}/ilustrasi/$this';
  String get mapel => '${dotenv.env['BASE_URL_IMAGE']}/mapel/$this';
  String get icon => '${dotenv.env['BASE_URL_IMAGE']}/icon/$this';
  String get imgUrl => '${dotenv.env['BASE_URL_IMAGE']}/image/$this';
  String get avatar => '${dotenv.env['BASE_URL_IMAGE']}/avatar/$this.png';
}

extension DateTimeExtend on DateTime {
  DateTime get serverTimeFromOffset =>
      add(Duration(milliseconds: gOffsetServerTime!));
  String get sqlFormat => DataFormatter.dateTimeToString(this);
  String get hoursMinutesDDMMMYYYY => DataFormatter.formatDate(
      DataFormatter.dateTimeToString(this), '[HH:mm] dd MMM yyyy');
  String get displayDDMMMMYYYY =>
      DataFormatter.formatDate(DataFormatter.dateTimeToString(this));
  String get displayMMMMYYYY => DataFormatter.formatDate(
      DataFormatter.dateTimeToString(this), 'MMMM yyyy');
  String get displayHHMMA =>
      DataFormatter.formatDate(DataFormatter.dateTimeToString(this), 'HH:mm a');
  String get displayEDDMMMMYYYY => DataFormatter.formatDate(
      DataFormatter.dateTimeToString(this), 'EEEE, dd MMM yyyy');
}

extension CapitalizeExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.capitalize())
      .join(' ');

  bool equalsIgnoreCase(String compare) =>
      toLowerCase() == compare.toLowerCase();

  String capitalizeFirstLetter() {
    if (contains('-')) {
      final splittedString = toUpperCase().split('-');
      final firstWord = splittedString[0].trim();
      final secondWord = splittedString[1]
          .trim()
          .toLowerCase()
          .split(' ')
          .map((x) => x.replaceFirst(x[0], x[0].toUpperCase()))
          .join(' ');
      return '$firstWord - $secondWord';
    }
    return toLowerCase()
        .split(' ')
        .map((x) => x.replaceFirst(x[0], x[0].toUpperCase()))
        .join(' ');
  }
}
