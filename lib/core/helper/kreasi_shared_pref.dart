import 'dart:convert';
import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import 'package:gokreasi_new/features/home/data/model/promotion_model.dart';
import 'package:gokreasi_new/features/leaderboard/model/capaian_detail_score.dart';
import 'package:gokreasi_new/features/leaderboard/model/capaian_score.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/global.dart';
import '../util/data_formatter.dart';
import '../../features/auth/data/model/user_model.dart';

/// [KreasiSharedPref] merupakan class yang akan meng-handle semua transaksi
/// Shared Preferences yang di lakukan.
class KreasiSharedPref {
  // Initiate storage;
  SharedPreferences? _prefs;
  // Kumpulan Key---------------------------------------------------------------
  static const _keyTokenJWT = 'tokenJWT-kreasi';
  static const _keyRefreshToken = 'refresh-token';
  static const _keyUser = 'user-kreasi';
  static const _keyUserNomorReg = 'user-nomor-reg';
  static const _keyDeviceID = 'deviceId-kreasi';
  static const _keyIdSekolahKelas = 'id-sekolah-kelas';
  static const _keyTingkatKelas = 'tingkat-kelas';
  static const _keySiapa = 'siapa';
  static const _idBeritaPopUp = 'id-berita-pop-up';
  static const _noregOrtu = 'noreg-ortu';
  static const _noregAnak = 'noreg-anak';
  static const _idBundlingAktif = 'bundling-aktif';
  static const _daftarBundling = 'daftar-bundling';
  static const _daftarAnak = 'daftar-anak';
  static const _listIdProduk = 'list-id-produk';
  static const _daftarProduk = 'daftar-produk';
  static const _nomorHpOrtu = 'nomor-hp-ortu';
  static const _profilePhoto = 'profile-photo';
  static const _promoEvent = 'promo-event';
  static const _keyCapaianSkor = 'capaian-skor';
  static const _keyCapaianNilaiDetail = 'capaian-nilai-detail';

  init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static final KreasiSharedPref _instance = KreasiSharedPref._internal();

  factory KreasiSharedPref() => _instance;

  KreasiSharedPref._internal();

  /// [simpanDataLokal] menyimpan data JWT dan user.<br><br>
  /// [gTokenJwt] dan [gUser] merupakan value dari global.dart
  Future<void> simpanDataLokal() async {
    await setTokenJWT(gTokenJwt);
    if (gUser != null) {
      await setUserModel(gUser!);
    }
  }

  /// [setDeviceID] menyimpan data token JWT.
  Future<bool> setDeviceID(String deviceID) async {
    bool isBerhasil = false;

    String encryptedUUID = DataFormatter.encryptString(deviceID);

    final deviceIdStoredData = _prefs!.getString(_keyDeviceID);

    if (deviceIdStoredData != null) {
      return false;
    }

    await _prefs!
        .setString(_keyDeviceID, encryptedUUID)
        .onError((error, stackTrace) {
      isBerhasil = false;
      if (kDebugMode) {
        logger.log(
            'KREASI_SHARED_PREF: ERROR setDeviceID => $error\nSTACKTRACE:$stackTrace');
      }
      return isBerhasil;
    }).then((value) {
      isBerhasil = true;
      if (kDebugMode) {
        logger.log('KREASI_SHARED_PREF: setDeviceID selesai');
      }
    });

    return isBerhasil;
  }

  /// [getDeviceID] mengambil data Token JWT dari Persistent Data.
  Future<String?> getDeviceID() async {
    final uuid = _prefs!.getString(_keyDeviceID);

    String? deviceID;

    if (uuid != null) {
      deviceID = DataFormatter.decryptString(uuid);
    }

    if (kDebugMode) {
      logger.log('KREASI_SHARED_PREF: getDeviceID($deviceID)');
    }
    return deviceID;
  }

  Future<void> setIdSekolahKelas(String idSekolahKelas) async {
    String encryptedIdSekolahKelas =
        DataFormatter.encryptString(idSekolahKelas);

    await _prefs!
        .setString(_keyIdSekolahKelas, encryptedIdSekolahKelas)
        .onError((error, stackTrace) {
      if (kDebugMode) {
        logger.log(
            'KREASI_SHARED_PREF: ERROR setTokenJWT => $error\nSTACKTRACE:$stackTrace');
      }
      return false;
    });
  }

  String? getIdSekolahKelas() {
    final encriptedId = _prefs!.getString(_keyIdSekolahKelas);
    String? idSekolahKelas;

    if (encriptedId != null) {
      idSekolahKelas = DataFormatter.decryptString(encriptedId);
    }

    return idSekolahKelas;
  }

  /// [setTokenJWT] menyimpan data token JWT.
  Future<void> setTokenJWT(String tokenJwt) async {
    String encryptedTokenJWT = DataFormatter.encryptString(tokenJwt);

    await _prefs!
        .setString(_keyTokenJWT, encryptedTokenJWT)
        .onError((error, stackTrace) {
      if (kDebugMode) {
        logger.log(
            'KREASI_SHARED_PREF: ERROR setTokenJWT => $error\nSTACKTRACE:$stackTrace');
      }
      return false;
    }).then((value) {
      if (kDebugMode) {
        logger.log('KREASI_SHARED_PREF: setTokenJWT selesai');
      }
    });
  }

  /// [getTokenJWT] mengambil data Token JWT dari Persistent Data.
  String? getTokenJWT() {
    final encryptedToken = _prefs!.getString(_keyTokenJWT);
    String? tokenJWT;

    if (encryptedToken != null) {
      tokenJWT = DataFormatter.decryptString(encryptedToken);
    }
    if (kDebugMode) {
      logger.log('KREASI_SHARED_PREF: getTokenJWT($tokenJWT)');
    }
    return tokenJWT;
  }

  /// [setRefreshToken] menyimpan data refresh access token
  Future<void> setRefreshToken(String refreshToken) async {
    String encryptedRefreshToken = DataFormatter.encryptString(refreshToken);

    await _prefs!
        .setString(_keyRefreshToken, encryptedRefreshToken)
        .onError((error, stackTrace) {
      if (kDebugMode) {
        logger.log(
            'KREASI_SHARED_PREF: ERROR setTokenJWT => $error\nSTACKTRACE:$stackTrace');
      }
      return false;
    }).then((value) {
      if (kDebugMode) {
        logger.log('KREASI_SHARED_PREF: setTokenJWT selesai');
      }
    });
  }

  String? getRefreshToken() {
    try {
      final encryptedRefreshToken = _prefs!.getString(_keyRefreshToken);
      String? refreshToken;

      if (encryptedRefreshToken != null) {
        refreshToken = DataFormatter.decryptString(encryptedRefreshToken);
      }
      if (kDebugMode) {
        logger.log('KREASI_SHARED_PREF: getTokenJWT($refreshToken)');
      }

      return refreshToken;
    } catch (e) {
      return null;
    }
  }

  /// [setUserModel] menyimpan data User.
  Future<void> setUserModel(UserModel userModel) async {
    String encryptedUser =
        DataFormatter.encryptString(jsonEncode(userModel.toJson()));

    await _prefs!
        .setString(_keyUser, encryptedUser)
        .onError((error, stackTrace) {
      if (kDebugMode) {
        logger.log(
            'KREASI_SHARED_PREF: ERROR setUserModel => $error\nSTACKTRACE:$stackTrace');
      }
      return false;
    }).then((value) async {
      if (kDebugMode) {
        logger.log('KREASI_SHARED_PREF: setUserModel selesai');
      }
    });
  }

  /// [getUser] mengambil data user dari Persistent Data.
  Future<UserModel?> getUser() async {
    try {
      final encryptedUser = _prefs!.getString(_keyUser);
      String? user;

      if (encryptedUser != null) {
        user = DataFormatter.decryptString(encryptedUser);
      }
      if (user?.isNotEmpty ?? false) {
        gTokenJwt = getTokenJWT() ?? '';
        var userModel = UserModel.fromJson(json.decode(user!));
        gUser = userModel;
        gNoRegistrasi = userModel.noRegistrasi ?? '';
        if (kDebugMode) {
          logger.log(
              'KREASI_SHARED_PREF-GetUser: Produk Dibeli >> ${userModel.daftarProdukDibeli}');
        }
        return userModel;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        logger.log('KREASI_SHARED_PREF-GetUser: ERROR >> $e');
      }
      return null;
    }
  }

  Future<void> setNomorReg(String nomorReg) async {
    String encryptedPhoneNumber = DataFormatter.encryptString(nomorReg);

    await _prefs!
        .setString(_keyUserNomorReg, encryptedPhoneNumber)
        .onError((error, stackTrace) {
      if (kDebugMode) {
        logger.log(
            'KREASI_SHARED_PREF: ERROR setUserModel => $error\nSTACKTRACE:$stackTrace');
      }
      return false;
    }).then((value) async {
      if (kDebugMode) {
        logger.log('KREASI_SHARED_PREF: setUserModel selesai');
      }
    });
  }

  String? getNomorReg() {
    try {
      final encryptedPhoneNumber = _prefs!.getString(_keyUserNomorReg);
      String? nomorReg;

      if (encryptedPhoneNumber != null) {
        nomorReg = DataFormatter.decryptString(encryptedPhoneNumber);
      }

      if (nomorReg?.isNotEmpty == true) {
        return nomorReg;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        logger.log('KREASI_SHARED_PREF-GetUserPhoneNumber: ERROR >> $e');
      }
      return null;
    }
  }

  Future<void> setSiapa(String? siapa) async {
    String encryptedSiapa = DataFormatter.encryptString(siapa ?? 'siswa');

    await _prefs!
        .setString(_keySiapa, encryptedSiapa)
        .onError((error, stackTrace) => false);
  }

  String? getSiapa() {
    try {
      final encryptedSiapa = _prefs!.getString(_keySiapa);
      String? siapa;

      if (encryptedSiapa != null) {
        siapa = DataFormatter.decryptString(encryptedSiapa);
      }

      return siapa;
    } catch (e) {
      return null;
    }
  }

  Future<void> setIdBeritaPopUp(int idBeritaPopUp) async {
    String encryptedBerita =
        DataFormatter.encryptString(idBeritaPopUp.toString());

    await _prefs!
        .setString(_idBeritaPopUp, encryptedBerita)
        .onError((error, stackTrace) => false);
  }

  int? getIdBeritaPopUp() {
    try {
      final encryptedBerita = _prefs!.getString(_idBeritaPopUp);
      int? idBeritaPopUp;

      if (encryptedBerita != null) {
        final decryptedBerita = DataFormatter.decryptString(encryptedBerita);
        idBeritaPopUp =
            (decryptedBerita.isEmpty) ? 0 : int.tryParse(decryptedBerita);
      }

      return idBeritaPopUp;
    } catch (e) {
      return null;
    }
  }

  Future<void> setNoregOrtu(String noreg) async {
    String encryptedNoreg = DataFormatter.encryptString(noreg);
    await _prefs!.setString(_noregOrtu, encryptedNoreg);
  }

  String? getNoregOrtu() {
    try {
      final encryptedNoreg = _prefs!.getString(_noregOrtu);
      String? noregOrtu;

      if (encryptedNoreg != null) {
        final decryptedNoreg = DataFormatter.decryptString(encryptedNoreg);
        noregOrtu = decryptedNoreg;
      }

      return noregOrtu;
    } catch (e) {
      return null;
    }
  }

  Future<void> setNoregAnak(String noregAnak) async {
    String encryptedNoregAnak = DataFormatter.encryptString(noregAnak);
    await _prefs!.setString(_noregAnak, encryptedNoregAnak);
  }

  String? getNoregAnak() {
    try {
      final encryptedNoregAnak = _prefs!.getString(_noregAnak);
      String? noregAnak;
      if (encryptedNoregAnak != null) {
        final decrypt = DataFormatter.decryptString(encryptedNoregAnak);
        noregAnak = decrypt;
      }

      return noregAnak;
    } catch (e) {
      return null;
    }
  }

  Future<void> setIdBundlingAktif(int idBundlingAktif) async {
    String encrypt = DataFormatter.encryptString(idBundlingAktif.toString());
    await _prefs!.setString(_idBundlingAktif, encrypt);
  }

  int? getIdBundlingAktif() {
    try {
      final encrypt = _prefs!.getString(_idBundlingAktif);
      int? idBundlingAktif;

      if (encrypt != null) {
        final decrypt = DataFormatter.decryptString(encrypt);
        idBundlingAktif = (decrypt.isEmpty) ? null : int.tryParse(decrypt);
      }

      return idBundlingAktif;
    } catch (e) {
      return null;
    }
  }

  Future<void> setDaftarBundling(
      List<Map<String, dynamic>> daftarBundling) async {
    String encrypt = DataFormatter.encryptString(jsonEncode(daftarBundling));
    await _prefs!.setString(_daftarBundling, encrypt);
  }

  List<Map<String, dynamic>>? getDaftarBundling() {
    try {
      final encrypt = _prefs!.getString(_daftarBundling);
      List<Map<String, dynamic>> daftarBundling = [];

      if (encrypt != null) {
        String decrypt = DataFormatter.decryptString(encrypt);
        List<dynamic> decryptList = jsonDecode(decrypt) as List<dynamic>;
        for (Map<String, dynamic> data in decryptList) {
          daftarBundling.add(data);
        }
      }

      return daftarBundling;
    } catch (e) {
      return null;
    }
  }

  Future<void> setDaftarAnak(List<Map<String, dynamic>> daftarAnak) async {
    String encrypt = DataFormatter.encryptString(jsonEncode(daftarAnak));
    await _prefs!.setString(_daftarAnak, encrypt);
  }

  List<Map<String, dynamic>>? getDaftarAnak() {
    try {
      final encrypt = _prefs!.getString(_daftarAnak);
      List<Map<String, dynamic>> daftarAnak = [];

      if (encrypt != null) {
        String decrypt = DataFormatter.decryptString(encrypt);
        List<dynamic> decryptList = jsonDecode(decrypt) as List<dynamic>;
        for (Map<String, dynamic> data in decryptList) {
          daftarAnak.add(data);
        }
      }

      return daftarAnak;
    } catch (e) {
      return null;
    }
  }

  Future<void> setListIdProduk(List<int> listIdProduk) async {
    String encrypt = DataFormatter.encryptString(jsonEncode(listIdProduk));
    await _prefs!.setString(_listIdProduk, encrypt);
  }

  List<int>? getListIdProduk() {
    try {
      final encrypt = _prefs!.getString(_listIdProduk);
      List<int> listIdProduk = [];

      if (encrypt != null) {
        final decrypt = DataFormatter.decryptString(encrypt);
        List<dynamic> decryptList = jsonDecode(decrypt) as List<dynamic>;
        for (int data in decryptList) {
          listIdProduk.add(data);
        }
      }

      return listIdProduk;
    } catch (e) {
      return null;
    }
  }

  Future<void> setDaftarProduk(List<Map<String, dynamic>> daftarProduk) async {
    String encrypt = DataFormatter.encryptString(jsonEncode(daftarProduk));
    await _prefs!.setString(_daftarProduk, encrypt);
  }

  List<Map<String, dynamic>>? getDaftarProduk() {
    try {
      final encrypt = _prefs!.getString(_daftarProduk);
      List<Map<String, dynamic>> daftarProduk = [];

      if (encrypt != null) {
        final decrypt = DataFormatter.decryptString(encrypt);
        List<dynamic> decryptList = jsonDecode(decrypt);
        for (Map<String, dynamic> data in decryptList) {
          daftarProduk.add(data);
        }
      }

      return daftarProduk;
    } catch (e) {
      return null;
    }
  }

  Future<void> setNomorHpOrtu(String nomorHp) async {
    String encrypt = DataFormatter.encryptString(nomorHp);
    await _prefs!.setString(_nomorHpOrtu, encrypt);
  }

  String? getNomorHpOrtu() {
    try {
      final encrypt = _prefs!.getString(_nomorHpOrtu);
      String? nomorHp;

      if (encrypt != null) {
        final decrypt = DataFormatter.decryptString(encrypt);
        nomorHp = decrypt;
      }

      return nomorHp;
    } catch (e) {
      return null;
    }
  }

  Future<void> setProfilePhoto(String photo) async {
    String encrypt = DataFormatter.encryptString(photo);
    await _prefs!.setString(_profilePhoto, encrypt);
  }

  String? getProfilePhoto() {
    try {
      final encrypt = _prefs!.getString(_profilePhoto);
      String? profilePhoto;

      if (encrypt != null) {
        final decrypt = DataFormatter.decryptString(encrypt);
        profilePhoto = decrypt;
      }

      return profilePhoto;
    } catch (e) {
      return null;
    }
  }

  Future<void> setPromoEvent(PromotionModel promotion) async {
    String data = jsonEncode(promotion.toJson());
    String encrypt = DataFormatter.encryptString(data);
    await _prefs!.setString(_promoEvent, encrypt);
  }

  PromotionModel? getPromoEvent() {
    try {
      final encrypt = _prefs!.getString(_promoEvent);
      PromotionModel? promotionModel;

      if (encrypt != null) {
        final decrypt = DataFormatter.decryptString(encrypt);

        final data = jsonDecode(decrypt);
        promotionModel = PromotionModel.fromJson(data);
      }

      return promotionModel;
    } catch (e) {
      return null;
    }
  }

  Future<void> setCapaianSkor(Map<String, CapaianScore> capaianSkor) async {
    Map<String, dynamic> mappedCapaian = {};
    capaianSkor.forEach((key, capaian) {
      mappedCapaian[key] = capaian.toJson();
    });

    String data = jsonEncode(mappedCapaian);
    String encrypt = DataFormatter.encryptString(data);
    await _prefs!.setString(_keyCapaianSkor, encrypt);
  }

  Map<String, CapaianScore>? getCapaianSkor() {
    try {
      final encrypt = _prefs!.getString(_keyCapaianSkor);

      if (encrypt == null) throw 'Data kosong';

      final decrypt = DataFormatter.decryptString(encrypt);
      Map<String, dynamic> data = jsonDecode(decrypt);
      Map<String, CapaianScore> capaian = {};

      data.forEach((key, value) {
        capaian[key] = CapaianScore.fromJson(value);
      });

      return capaian;
    } catch (e) {
      return null;
    }
  }

  Future<void> setCapaianNilaiDetail(
    Map<String, List<CapaianDetailScore>> capaianNilaiDetail,
  ) async {
    Map<String, dynamic> mappedCapaianNilai = {};
    capaianNilaiDetail.forEach((key, listCapaianNilai) {
      mappedCapaianNilai[key] = listCapaianNilai
          .map((capaianNilai) => capaianNilai.toJson())
          .toList();
    });

    String data = jsonEncode(mappedCapaianNilai);
    String encrypt = DataFormatter.encryptString(data);
    await _prefs!.setString(_keyCapaianNilaiDetail, encrypt);
  }

  Map<String, List<CapaianDetailScore>>? getCapaianNilaiDetail() {
    try {
      final encrypt = _prefs!.getString(_keyCapaianNilaiDetail);

      if (encrypt == null) throw 'Data kosong';

      final decrypt = DataFormatter.decryptString(encrypt);
      Map<String, dynamic> data = jsonDecode(decrypt);
      Map<String, List<CapaianDetailScore>> capaianNilaiDetail = {};

      data.forEach((key, value) {
        capaianNilaiDetail[key] = value
            .map((x) => CapaianDetailScore.fromJson(x))
            .toList()
            .cast<CapaianDetailScore>();
      });

      return capaianNilaiDetail;
    } catch (e) {
      return null;
    }
  }

  void logout() {
    try {
      String role = getSiapa()?.toLowerCase() ?? '';
      if (role == 'ORTU') {
        _prefs!.remove(_noregAnak);
        _prefs!.remove(_idBundlingAktif);
        _prefs!.remove(_daftarBundling);
        _prefs!.remove(_daftarAnak);
        _prefs!.remove(_listIdProduk);
        _prefs!.remove(_daftarProduk);
      }

      _prefs!.remove(_keyTokenJWT);
      _prefs!.remove(_keyUser);
      _prefs!.remove(_idBeritaPopUp);
      _prefs!.remove(_keyIdSekolahKelas);
      _prefs!.remove(_keyTingkatKelas);
      _prefs!.remove(_profilePhoto);
      _prefs!.remove(_promoEvent);
      _prefs!.remove(_keyRefreshToken);
      _prefs!.remove(_keyCapaianSkor);
      _prefs!.remove(_keyCapaianNilaiDetail);
    } catch (e) {
      if (kDebugMode) {
        logger.log('KREASI_SHARED_PREF-Logout: ERROR >> $e');
      }
    }
  }
}
