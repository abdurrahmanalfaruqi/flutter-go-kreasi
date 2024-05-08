import 'dart:convert';
import 'dart:math';

import 'package:encrypt/encrypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

import '../config/extensions.dart';
import '../config/global.dart';

class DataFormatter {
  static String encryptString(String textToEncrypt) {
    final key = Key.fromUtf8(dotenv.env['KREASI_FERNET_KEY']!);
    final initVector =
        IV.fromUtf8(dotenv.env['KREASI_FERNET_KEY']!.substring(0, 16));

    final encrypter = Encrypter(AES(key, mode: AESMode.ctr, padding: null));
    final encrypted = encrypter.encrypt(textToEncrypt, iv: initVector);
    final ciphertext = encrypted.base64;
    return ciphertext;
  }

  static String decryptString(String textToDecrypt) {
    try {
      final key = Key.fromUtf8(dotenv.env['KREASI_FERNET_KEY']!);
      final initVector =
          IV.fromUtf8(dotenv.env['KREASI_FERNET_KEY']!.substring(0, 16));
      final decrypter = Encrypter(AES(key, mode: AESMode.ctr, padding: null));
      final decrypted = decrypter
          .decryptBytes(Encrypted.fromBase64(textToDecrypt), iv: initVector);
      final decryptedData = utf8.decode(decrypted);
      return decryptedData;
    } catch (_) {
      return '';
    }
  }

  static Map<String, dynamic> decodeBarcode(String barcode) {
    return json.decode(
        utf8.decode(base64.decode(utf8.decode(base64.decode(barcode)))));
  }

  static String setOTP(String code1, String code2, String code3, String code4,
          String code5, String code6) =>
      code1 + code2 + code3 + code4 + code5 + code6;

  static Future<String> formatLastUpdateServerTime() async {
    DateTime serverTime = await gGetServerTime();

    return DateFormat('yyyy-MM-dd HH:mm:ss').format(serverTime);
  }

  static String formatLastUpdate() => DateFormat('yyyy-MM-dd HH:mm:ss')
      .format(DateTime.now().serverTimeFromOffset);

  /// Function untuk mengubah DateTime to String dengan format SQL.
  static String dateTimeToString(DateTime dateTime,
      [String format = 'yyyy-MM-dd HH:mm:ss', String locale = 'ID']) {
    return DateFormat(format, locale).format(dateTime);
  }

  /// Function untuk formatting int number menjadi format Rupiah
  static String formatIDR(int num, [String? symbol]) => NumberFormat.currency(
        locale: 'id_ID',
        symbol: symbol ?? 'Rp ',
        decimalDigits: 0,
      ).format(num);

  /// Function untuk mengubah format sebuah tanggal.
  static String formatDate(String date,
      [String format = 'dd MMMM y', String locale = 'ID']) {
    DateTime tempDate = stringToDate(date);
    return DateFormat(format, locale).format(tempDate);
  }

  /// Function untuk mengubah String menjadi DateTime
  static DateTime stringToDate(String date,
          [String format = 'yyyy-MM-dd HH:mm:ss', String locale = 'ID']) =>
      DateFormat(format, locale).parse(date);

  static String formatNIS({
    required int roleIndex,
    required String userId,
  }) {
    final trimmedNis = userId.replaceAll(RegExp(r"\s+"), '');

    return trimmedNis;
  }

  static String formatPhoneNumber({
    required String phoneNumber,
  }) {
    if (phoneNumber.isEmpty) return '';

    String formattedPhoneNumber = phoneNumber;

    if (phoneNumber.startsWith('62') || phoneNumber.startsWith('+62')) {
      formattedPhoneNumber =
          phoneNumber.replaceAll('+', '').replaceFirst('62', '0');
    } else if (!phoneNumber.startsWith('0') || phoneNumber.startsWith('8')) {
      formattedPhoneNumber = '0$phoneNumber';
    } else if (phoneNumber.startsWith('0')) {
      formattedPhoneNumber.substring(1, phoneNumber.length);
    }

    return formattedPhoneNumber.trim();
  }

  static String formatOTP({
    required String otp,
  }) {
    int? min, max;
    String formattedOTP = otp;
    Random random = Random();

    if (otp.length == 1) {
      min = 10000;
      max = 100000;
    } else if (otp.length == 2) {
      min = 1000;
      max = 10000;
    } else if (otp.length == 3) {
      min = 100;
      max = 1000;
    } else if (otp.length == 4) {
      min = 10;
      max = 100;
    } else if (otp.length == 5) {
      min = 0;
      max = 10;
    }

    if (min != null && max != null) {
      final randomNumber = min + random.nextInt(max - min);
      formattedOTP = formattedOTP + randomNumber.toString();
    }

    return formattedOTP;
  }

  static String formatHTMLAKM(String htmlCode) {
    String froala =
        '<p data-f-id="pbf" style="text-align: center; font-size: 14px; margin-top: 30px; opacity: 0.65; font-family: sans-serif;">Powered by <a href="https://www.froala.com/wysiwyg-editor?pb=1" title="Froala Editor">Froala Editor</a></p>';
    String baseUrlBankSoal = dotenv.env['BASE_URL_BANK_SOAL']!;
    return htmlCode
        .replaceAll('&nbsp;', '')
        .replaceAll('&quotes', '"')
        .replaceAll('&amp;quotes;', '&quotes;')
        .replaceAll('&quot;', "'")
        .replaceAll('&quotes;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('â€¦', '...')
        .replaceAll('â€™', "'")
        .replaceAll('â€“', "-")
        .replaceAll("â€’", "-")
        .replaceAll('âˆ’', '-')
        .replaceAll('Â·', 'x')
        .replaceAll('Ã—', 'x')
        .replaceAll('â€š', '=')
        .replaceAll('â€°', '‰')
        .replaceAll('â€¢', '•')
        .replaceAll('â€˜', "'")
        .replaceAll('â€”', '-')
        .replaceAll('â€?', '"')
        .replaceAll('â€œ', '"')
        .replaceAll('{{root_media}}/', '$baseUrlBankSoal/')
        .replaceAll('{{root_media}}', '$baseUrlBankSoal/')
        .replaceAll(froala, '')
        .replaceAll('&hellip', '...')
        .replaceAll('.;', '...')
        .replaceAll('&ndash;', '-');
  }

  static String formatHTMLRemove(String htmlCode) {
    RegExp regex = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlCode.contains('<img src')
        ? htmlCode
        : htmlCode.replaceAll(regex, '');
  }

  static String formatEssay(String essay) {
    RegExp regex = RegExp(r'(?:_|[^\w\s])+');

    return essay.toLowerCase().replaceAll(regex, '').replaceAll('  ', ' ');
  }

  static String formatCamelCase(String text) {
    final lowerCase = text.toLowerCase();
    return lowerCase
        .replaceAll(RegExp(' +'), ' ')
        .split(" ")
        .map((str) =>
            str.isNotEmpty ? '${str[0].toUpperCase()}${str.substring(1)}' : '')
        .join(" ");
  }
}
