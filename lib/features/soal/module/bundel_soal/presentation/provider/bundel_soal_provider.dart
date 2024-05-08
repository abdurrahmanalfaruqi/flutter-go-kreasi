// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:collection';
import 'dart:developer' as logger show log;
import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/bookmark/domain/entity/bookmark.dart';
import 'package:gokreasi_new/features/soal/module/paket_soal/service/paket_soal_service_api.dart';

import '../../domain/entity/bab_soal.dart';
import '../../domain/entity/bundel_soal.dart';
import '../../service/bundel_soal_service_api.dart';
import '../../../../entity/soal.dart';
import '../../../../model/soal_model.dart';
import '../../../../entity/detail_jawaban.dart';
import '../../../../service/api/soal_service_api.dart';
import '../../../../service/local/soal_service_local.dart';
import '../../../../presentation/provider/soal_provider.dart';
import '../../../../../../core/config/enum.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/helper/hive_helper.dart';
import '../../../../../../core/util/app_exceptions.dart';

class BundelSoalProvider extends SoalProvider {
  final _apiService = BundelSoalServiceApi();
  final _soalApiService = SoalServiceAPI();
  final _soalServiceLocal = SoalServiceLocal();

  /// [_timer] digunakan untuk clock waktu simpan jawaban sementara
  Timer? _timer;

  final Map<int, List<BundelSoal>> _listBundelSoal = {};
  final Map<String, List<BabUtamaSoal>> _listBabSoal = {};

  // Local Variable
  bool _isLoadingBundel = true;
  bool _isLoadingBab = true;
  bool _isLoadingSoal = false;
  bool _isLoadingSimpanJawaban = false;
  bool _isSudahDikumpulkanSemua = false;
  bool _isJWT = false;
  String? _loadingKoneksi;

  // Getter
  bool get isLoadingBundel => _isLoadingBundel;
  bool get isLoadingBab => _isLoadingBab;
  bool get isLoadingSoal => _isLoadingSoal;
  bool get isSudahDikumpulkanSemua => _isSudahDikumpulkanSemua;
  bool get isLoadingSimpanJawaban => _isLoadingSimpanJawaban;
  String? get loadingKoneksi => _loadingKoneksi;

  // UnmodifiableListView<BundelSoal> getListBundelByJenisProduk(
  //         int idJenisProduk) =>
  //     UnmodifiableListView(_listBundelSoal[idJenisProduk] ?? []);

  Map<String, List<BundelSoal>> getListBundelByJenisProduk(int idJenisProduk) {
    final List<BundelSoal> listBundleSoal =
        _listBundelSoal[idJenisProduk] ?? [];

    final groupBy = listBundleSoal.fold<Map<String, List<BundelSoal>>>(
      {},
      (prev, bundle) {
        prev.putIfAbsent(bundle.namaKelompokUjian, () => []).add(bundle);
        return prev;
      },
    );

    return groupBy;
  }

  UnmodifiableListView<BabUtamaSoal> getListBabByIdBundel(String idBundel) =>
      UnmodifiableListView(_listBabSoal[idBundel] ?? []);

  UnmodifiableListView<Soal> getListSoal({
    required OpsiUrut opsiUrut,
    required String idBundel,
    required String kodeBab,
  }) =>
      UnmodifiableListView(
          listSoal['${opsiUrut.name}-$idBundel-$kodeBab'] ?? []);

  @override
  void disposeValues() {
    _listBundelSoal.clear();
    _listBabSoal.clear();
    super.disposeValues();
  }

  Future<void> toggleRaguRagu({
    required String tahunAjaran,
    required String idSekolahKelas,
    String? noRegistrasi,
    String? tipeUser,
    required String kodePaket,
  }) async {
    // Toggle soal ragu-ragu
    soal.isRagu = !soal.isRagu;

    if (noRegistrasi != null && tipeUser != null && tipeUser != 'ORTU') {
    } else {
      await _soalServiceLocal.updateRaguRagu(
        kodePaket: kodePaket,
        idSoal: soal.idSoal,
        isRagu: soal.isRagu,
      );
    }
    notifyListeners();
  }

  Future<void> setTempJawaban({
    required String tahunAjaran,
    required String idSekolahKelas,
    String? noRegistrasi,
    String? tipeUser,
    required String kodePaket,
    required String jenisProduk,
    required int idJenisProduk,
    dynamic jawabanSiswa,
  }) async {
    try {
      // to avoid setState rebuild error
      await Future.delayed(const Duration(milliseconds: 300), () {
        _isLoadingSimpanJawaban = true;
        notifyListeners();
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (timer.tick >= 3) {
          _loadingKoneksi = gPesanErrorSlowConnection;
        }

        if (timer.tick >= 23) {
          _loadingKoneksi = '$_loadingKoneksi Connection timeout (408)';
        }
        notifyListeners();
      });

      if (kDebugMode) {
        logger.log('BUNDEL_SOAL_PROVIDER-SetTempJawaban: '
            'params($tahunAjaran, $noRegistrasi, $tipeUser, $kodePaket, $jenisProduk, $jawabanSiswa)');
        logger.log(
            'BUNDEL_SOAL_PROVIDER-SetTempJawaban: Jawaban Siswa Null >> ${jawabanSiswa == null}');
        logger.log(
            'BUNDEL_SOAL_PROVIDER-SetTempJawaban: Jawaban Siswa Empty >> ${jawabanSiswa == ''}');
      }
      setNilai(jawabanSiswa: jawabanSiswa);

      soal.jawabanSiswaEPB = setJawabanEPB(
        soal.tipeSoal,
        soal.jawabanSiswa,
        soal.translatorEPB,
      );
      soal.lastUpdate = lastUpdateNowFormatted;

      // List<String> cacheKeySplit = cacheKey!.split('-');

      // DetailJawaban detailJawabanSiswa = DetailJawaban(
      //   jenisProduk: jenisProduk,
      //   kodePaket: kodePaket,
      //   idBundel: cacheKeySplit[1],
      //   kodeBab: soal.kodeBab ?? cacheKeySplit[2],
      //   idSoal: soal.idSoal,
      //   nomorSoalDatabase: soal.nomorSoal,
      //   nomorSoalSiswa: soal.nomorSoalSiswa,
      //   idKelompokUjian: soal.idKelompokUjian,
      //   namaKelompokUjian: soal.namaKelompokUjian,
      //   tipeSoal: soal.tipeSoal,
      //   tingkatKesulitan: soal.tingkatKesulitan,
      //   jawabanSiswa: (jawabanSiswa == '') ? null : jawabanSiswa,
      //   kunciJawaban: soal.kunciJawaban,
      //   translatorEPB: soal.translatorEPB,
      //   kunciJawabanEPB: soal.kunciJawabanEPB,
      //   jawabanSiswaEPB: soal.jawabanSiswaEPB,
      //   infoNilai: jsonOpsi['nilai'] as Map<String, dynamic>,
      //   nilai: soal.nilai,
      //   isRagu: soal.isRagu,
      //   sudahDikumpulkan: false,
      //   lastUpdate: soal.lastUpdate,
      // );

      Map<String, dynamic> payload = {
        "no_register": noRegistrasi,
        "tahun_ajaran": tahunAjaran,
        "kode_paket": kodePaket,
        "id_kelompok_ujian": int.parse(soal.idKelompokUjian),
        "id_soal": int.parse(soal.idSoal),
        "nomor_soal_siswa": indexSoal + 1,
        "tipe_soal": soal.tipeSoal,
        "jawaban_siswa": jawabanSiswa,
        "is_ragu": soal.isRagu
      };

      await Future.delayed(const Duration(milliseconds: 200));

      final result = await _apiService.storeJawabanSiswa(
        jawabanSiswa: payload,
        idJenisProduk: idJenisProduk,
      );

      // if (noRegistrasi != null && tipeUser != null && tipeUser != 'ORTU') {
      //   // Penyimpanan untuk SISWA dan TAMU.
      //   Map<String, dynamic> payload = {
      //     "no_register": noRegistrasi,
      //     "tahun_ajaran": tahunAjaran,
      //     "kode_paket": kodePaket,
      //     "id_kelompok_ujian": int.parse(soal.idKelompokUjian),
      //     "id_soal": int.parse(soal.idSoal),
      //     "nomor_soal_siswa": indexSoal + 1,
      //     "tipe_soal": soal.tipeSoal,
      //     "jawaban_siswa": soal.jawabanSiswa,
      //     "is_ragu": soal.isRagu
      //   };

      //   await _apiService.storeJawabanSiswa(
      //     jawabanSiswa: payload,
      //     idJenisProduk: idJenisProduk,
      //   );
      // } else {
      //   // Penyimpanan untuk Teaser No User dan Ortu.
      //   await _soalServiceLocal.setTempJawabanSiswa(
      //     kodePaket: kodePaket,
      //     idSoal: soal.idSoal,
      //     jsonSoalJawabanSiswa: detailJawabanSiswa.toJson(),
      //   );
      // }

      soal.jawabanSiswa = (jawabanSiswa == '' || !result) ? null : jawabanSiswa;

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        logger.log('BUNDEL-FatalException-SetTempJawaban: $e');
      }
      gShowTopFlash(
        gNavigatorKey.currentState!.context,
        kDebugMode ? e.toString() : gPesanError,
        dialogType: DialogType.error,
      );
      notifyListeners();
    } finally {
      _loadingKoneksi = null;
      _timer?.cancel();
      _isLoadingSimpanJawaban = false;
      notifyListeners();
    }
  }

  // Future<List<DetailJawaban>?> _getDetailJawabanSiswa({
  //   required String tahunAjaran,
  //   String? noRegistrasi,
  //   String? tipeUser,
  //   required String kodePaket,
  //   required String jenisProduk,
  //   required String idSekolahKelas,
  //   required bool isSimpan,
  // }) async {
  //   List<String> cacheKeySplit = cacheKey!.split('-');

  //   if (noRegistrasi != null && tipeUser != null && tipeUser != 'ORTU') {
  //     // Penyimpanan untuk SISWA dan TAMU.
  //     if (cacheKeySplit[0] == 'nomor') {
  //       // Get Detail Jawaban By IdBundel.
  //       // return await _firebaseHelper.getJawabanSiswaByIdBundel(
  //       //   tahunAjaran: tahunAjaran,
  //       //   noRegistrasi: noRegistrasi,
  //       //   tipeUser: tipeUser,
  //       //   kodePaket: kodePaket,
  //       //   jenisProduk: jenisProduk,
  //       //   idBundel: cacheKeySplit[1],
  //       //   idSekolahKelas: idSekolahKelas,
  //       //   isSimpan: isSimpan,
  //       // );
  //     }
  //     // By Kode Paket
  //     // return await _firebaseHelper.getJawabanSiswaByKodeBab(
  //     //   tahunAjaran: tahunAjaran,
  //     //   noRegistrasi: noRegistrasi,
  //     //   tipeUser: tipeUser,
  //     //   kodePaket: kodePaket,
  //     //   jenisProduk: jenisProduk,
  //     //   kodeBab: cacheKeySplit[2],
  //     //   idSekolahKelas: idSekolahKelas,
  //     //   isSimpan: isSimpan,
  //     // );
  //     return null;
  //   } else {
  //     // Penyimpanan untuk Teaser No User dan Ortu.
  //     if (cacheKeySplit[0] == 'nomor') {
  //       // Get Detail Jawaban By IdBundel.
  //       return await _soalServiceLocal.getJawabanSiswaByIdBundel(
  //         kodePaket: kodePaket,
  //         jenisProduk: jenisProduk,
  //         idBundel: cacheKeySplit[1],
  //       );
  //     }
  //     // By Kode Bab
  //     return await _soalServiceLocal.getJawabanSiswaByKodeBab(
  //       kodePaket: kodePaket,
  //       jenisProduk: jenisProduk,
  //       kodeBab: cacheKeySplit[2],
  //     );
  //   }
  // }

  // Future<void> getDaftarBundelSoal({
  //   String? noRegistrasi,
  //   required String idSekolahKelas,
  //   required int idJenisProduk,
  //   String roleTeaser = 'No User',
  //   bool isProdukDibeli = false,
  //   bool isRefresh = false,
  // }) async {
  //   // Jika tidak refresh dan data sudah ada di cache [_listBundelSoal]
  //   // maka return List dari [_listBundelSoal].
  //   if (!isRefresh && (_listBundelSoal[idJenisProduk]?.isNotEmpty ?? false)) {
  //     return;
  //   }
  //   if (isRefresh) {
  //     _isLoadingBundel = true;
  //     notifyListeners();
  //     // _listBundelSoal[idJenisProduk]?.clear();
  //   }
  //   try {
  //     // Untuk jwt request soal dan bab
  //     _isJWT = noRegistrasi != null;

  //     if (kDebugMode) {
  //       logger.log('BUNDEL_SOAL_PROVIDER-GetDaftarBundelSoal: START');
  //     }
  //     final responseData = await _apiService.fetchDaftarBundel(
  //       noRegistrasi: noRegistrasi,
  //       idSekolahKelas: idSekolahKelas,
  //       idJenisProduk: '$idJenisProduk',
  //       roleTeaser: roleTeaser,
  //       isProdukDibeli: isProdukDibeli,
  //     );
  //     print(responseData);

  //     if (kDebugMode) {
  //       logger.log(
  //           'BUNDEL_SOAL_PROVIDER-GetDaftarBundelSoal: response data >> $responseData');
  //     }
  //     // Jika [_listBundelSoal] tidak memiliki key idJenisProduk tertentu maka buat key valuenya dulu;
  //     if (!_listBundelSoal.containsKey(idJenisProduk) || isRefresh) {
  //       if (isRefresh) {
  //         _listBundelSoal[idJenisProduk]?.clear();
  //       }
  //       _listBundelSoal[idJenisProduk] = [];
  //     }
  //     // Cek apakah response data memiliki data atau tidak
  //     if (responseData.isNotEmpty) {
  //       // for (Map<String, dynamic> dataBundel in responseData) {
  //       //   // Konversi dataBundel menjadi BundelSoalModel dan store ke cache [_listBundelSoal]
  //       //   _listBundelSoal[idJenisProduk]!
  //       //       .add(BundleSoalModel.fromJson(dataBundel));
  //       // }
  //       for (int i = 0; i < responseData.length; i++) {
  //         Map<String, dynamic> dataBundel = responseData[i];
  //         // Konversi dataBundel menjadi BundelSoalModel dan store ke cache [_listBundelSoal]
  //         _listBundelSoal[idJenisProduk]!
  //             .add(BundleSoalModel.fromJson(dataBundel));
  //       }
  //     }

  //     _isLoadingBundel = false;
  //     notifyListeners();
  //   } on NoConnectionException catch (e) {
  //     if (kDebugMode) {
  //       logger.log('NoConnectionException-GetDaftarBundelSoal: $e');
  //     }

  //     await gShowTopFlash(gNavigatorKey.currentState!.context,
  //         'Koneksi internet Sobat tidak stabil, coba lagi!',
  //         dialogType: DialogType.error);
  //     _isLoadingBundel = false;
  //     notifyListeners();
  //     // rethrow;
  //   } on DataException catch (e) {
  //     if (kDebugMode) {
  //       logger.log('Exception-GetDaftarBundelSoal: $e');
  //     }

  //     if (!'$e'.contains('Belum ada')) {
  //       await gShowTopFlash(
  //         gNavigatorKey.currentState!.context,
  //         '$e',
  //         dialogType: DialogType.error,
  //       );
  //     }
  //     _isLoadingBundel = false;
  //     notifyListeners();
  //     // rethrow;
  //   } catch (e) {
  //     if (kDebugMode) {
  //       logger.log('FatalException-GetDaftarBundelSoal: ${e.toString()}');
  //     }

  //     await gShowTopFlash(
  //       gNavigatorKey.currentState!.context,
  //       e.toString(),
  //       dialogType: DialogType.error,
  //     );
  //     _isLoadingBundel = false;
  //     notifyListeners();
  //     // rethrow;
  //   }
  // }

  // Future<void> getDaftarBabSoal({
  //   required String idBundel,
  //   bool isRefresh = false,
  // }) async {
  //   // Jika tidak refresh dan data sudah ada di cache [_listBundelSoal]
  //   // maka return List dari [_listBundelSoal].
  //   if (!isRefresh && (_listBabSoal[idBundel]?.isNotEmpty ?? false)) {
  //     return;
  //   }
  //   if (isRefresh) {
  //     _isLoadingBab = true;
  //     notifyListeners();
  //     _listBabSoal[idBundel]?.clear();
  //   }
  //   try {
  //     final responseData = await _apiService.fetchDaftarBabSubBab(
  //         isJWT: _isJWT, idBundel: idBundel);

  //     // Jika [_listBabSoal] tidak memiliki key idBundel tertentu maka buat key valuenya dulu.
  //     if (!_listBabSoal.containsKey(idBundel)) {
  //       _listBabSoal[idBundel] = [];
  //     }
  //     // Cek apakah response data memiliki data atau tidak
  //     if (responseData.isNotEmpty) {
  //       for (Map<String, dynamic> dataBab in responseData) {
  //         // Konversi dataBab menjadi BundelSoalModel dan store ke cache [_listBabSoal]
  //         _listBabSoal[idBundel]!.add(BabUtamaSoalModel.fromJson(dataBab));
  //       }
  //     }

  //     _isLoadingBab = false;
  //     notifyListeners();
  //   } on NoConnectionException catch (e) {
  //     if (kDebugMode) {
  //       logger.log('NoConnectionException-GetDaftarBabSoal: $e');
  //     }

  //     await gShowTopFlash(gNavigatorKey.currentState!.context,
  //         'Koneksi internet Sobat tidak stabil, coba lagi!',
  //         dialogType: DialogType.error);
  //     _isLoadingBab = false;
  //     notifyListeners();
  //     rethrow;
  //   } on DataException catch (e) {
  //     if (kDebugMode) {
  //       logger.log('Exception-GetDaftarBabSoal: $e');
  //     }

  //     await gShowTopFlash(
  //       gNavigatorKey.currentState!.context,
  //       '$e',
  //       dialogType: DialogType.error,
  //     );
  //     _isLoadingBab = false;
  //     notifyListeners();
  //     rethrow;
  //   } catch (e) {
  //     if (kDebugMode) {
  //       logger.log('FatalException-GetDaftarBabSoal: ${e.toString()}');
  //     }

  //     await gShowTopFlash(
  //       gNavigatorKey.currentState!.context,
  //       e.toString(),
  //       dialogType: DialogType.error,
  //     );
  //     _isLoadingBab = false;
  //     notifyListeners();
  //     rethrow;
  //   }
  // }

  Future<void> getDaftarSoal({
    required String kodePaket,
    required OpsiUrut opsiUrut,
    required String kodeBab,
    required String idBundel,
    required String jenisProduk,
    required String tahunAjaran,
    required String idSekolahKelas,
    String? noRegistrasi,
    String? tipeUser,
    bool isRefresh = false,
    int nomorSoalAwal = 1,
    bool isBookmarked = false,
  }) async {
    if (!_isLoadingSoal) {
      _isLoadingSoal = true;
      notifyListeners();
    }
    // Set value indexSoal dan cacheKey pada soal_provider.dart
    cacheKey = '${opsiUrut.name}-$idBundel-$kodeBab';
    indexSoal = (nomorSoalAwal > 0) ? nomorSoalAwal - 1 : 0;
    // Jika tidak refresh dan data sudah ada di cache [listSoal]
    // maka return List dari [listSoal].
    listSoal[cacheKey]?.clear();
    if (!isRefresh && (listSoal[cacheKey]?.isNotEmpty ?? false)) {
      // Jika semua soal sudah di jawab, maka _isSudahDikumpulkanSemua = true
      if (listSoal[cacheKey]!.every((soal) => soal.sudahDikumpulkan)) {
        _isSudahDikumpulkanSemua = true;
      }

      // Mengambil seluruh data bookmark dari hive
      List<BookmarkMapel> daftarBookmarkMapel =
          await HiveHelper.getDaftarBookmarkMapel();

      for (var soal in listSoal[cacheKey]!) {
        soal.isBookmarked = daftarBookmarkMapel.any(
          (bookmarkMapel) => bookmarkMapel.listBookmark.any(
            (bookmarkSoal) {
              if (opsiUrut == OpsiUrut.nomor) {
                return bookmarkSoal.idBundel == idBundel &&
                    bookmarkSoal.idSoal == soal.idSoal;
              }
              return bookmarkSoal.idBundel == idBundel &&
                  bookmarkSoal.kodeBab == kodeBab &&
                  bookmarkSoal.idSoal == soal.idSoal;
            },
          ),
        );
      }

      notifyListeners();
      return;
    }
    if (isRefresh) {
      _isLoadingSoal = true;
      notifyListeners();
      listSoal[cacheKey]?.clear();
    }

    try {
      final responseData = await _apiService.fetchDaftarSoal(
        isJWT: _isJWT,
        kodeBab: kodeBab,
        idBundel: idBundel,
        opsiUrut: opsiUrut,
      );

      // Mengambil jawaban siswa yang ada di firebase.
      // Jika belum login atau Akun Ortu maka akan mengambil jawaban dari Hive.
      // final List<DetailJawaban> jawabanFirebase = await _getDetailJawabanSiswa(
      //   tahunAjaran: tahunAjaran,
      //   noRegistrasi: noRegistrasi,
      //   tipeUser: tipeUser,
      //   kodePaket: kodePaket,
      //   jenisProduk: jenisProduk,
      //   idSekolahKelas: idSekolahKelas,
      //   isSimpan: false,
      // );

      if (kDebugMode) {
        logger.log('BUNDEL_SOAL_PROVIDER-GetDaftarSoal: CacheKey >> $cacheKey');
        logger.log(
            'BUNDEL_SOAL_PROVIDER-GetDaftarSoal: responseData >> $responseData');
        // logger.log(
        //     'BUNDEL_SOAL_PROVIDER-GetDaftarSoal: jawabanFirebase >> $jawabanFirebase');
      }

      // Jika [listSoal] tidak memiliki key idBundel tertentu maka buat key valuenya dulu.
      if (!listSoal.containsKey(cacheKey)) {
        listSoal[cacheKey ?? '${opsiUrut.name}-$idBundel-$kodeBab'] = [];
      }
      // Cek apakah response data memiliki data atau tidak
      if (responseData.isNotEmpty) {
        int nomorSoalSiswa = 1;

        // Jika box bookmark belum terbuka, maka open the box.
        if (!HiveHelper.isBoxOpen<BookmarkMapel>(
            boxName: HiveHelper.kBookmarkMapelBox)) {
          await HiveHelper.openBox<BookmarkMapel>(
              boxName: HiveHelper.kBookmarkMapelBox);
        }
        // Mengambil seluruh data bookmark dari hive
        List<BookmarkMapel> daftarBookmarkMapel =
            await HiveHelper.getDaftarBookmarkMapel();

        for (Map<String, dynamic> dataSoal in responseData) {
          // Mengambil jawaban firebase berdasarkan id soal.
          // FirstWhere dan SingleWhere throw error jika tidak ada yang cocok, sehingga merusak UI.
          // final List<DetailJawaban> detailJawabanSiswa = jawabanFirebase
          //     .where((jawaban) => jawaban.idSoal == dataSoal['c_IdSoal'])
          //     .toList();
          // Menambahkan informasi json SoalModel
          // if (detailJawabanSiswa.isNotEmpty) {
          //   dataSoal.addAll(detailJawabanSiswa.first.additionalJsonSoal());
          // }
          // Menambahkan nomor soal jika data nomor soal tidak ada dari firebase.
          if (!dataSoal.containsKey('nomorSoalSiswa') ||
              dataSoal['nomorSoalSiswa'] == null) {
            dataSoal['nomorSoalSiswa'] = nomorSoalSiswa;
          }
          // Menambahkan kunci jawaban jika data kunci tidak ada dari firebase.
          if (!dataSoal.containsKey('kunciJawaban') ||
              dataSoal['kunciJawaban'] == null) {
            dataSoal['kunciJawaban'] = setKunciJawabanSoal(
              dataSoal['tipe_soal'],
              dataSoal['opsi'],
              dataSoal['id_soal'],
            );
          }
          // Menambahkan Translator EPB untuk menjadi translator format jawaban Siswa pada EPB.
          if (!dataSoal.containsKey('translatorEPB') ||
              dataSoal['translatorEPB'] == null) {
            dataSoal['translatorEPB'] =
                setTranslatorEPB(dataSoal['tipe_soal'], dataSoal['opsi']);
          }
          // Menambahkan Kunci Jawaban EPB untuk menjadi display jawaban Siswa pada EPB.
          if (!dataSoal.containsKey('kunciJawabanEPB') ||
              dataSoal['kunciJawabanEPB'] == null) {
            dataSoal['kunciJawabanEPB'] = setJawabanEPB(
              dataSoal['tipe_soal'],
              dataSoal['kunciJawaban'],
              dataSoal['translatorEPB'],
            );
          }

          // Mencari data bookmark dataSoal pada Hive.
          // Jika ada, maka bookmark = true
          dataSoal['isBookmarked'] = daftarBookmarkMapel.any(
            (bookmarkMapel) => bookmarkMapel.listBookmark.any((bookmarkSoal) =>
                bookmarkSoal.kodePaket == kodePaket &&
                bookmarkSoal.idSoal == dataSoal['id_soal']),
          );

          if (kDebugMode) {
            logger.log('BUNDEL_SOAL_PROVIDER-GetDaftarSoal: bookmark hive >>'
                ' ${daftarBookmarkMapel.toString()}');
            logger.log('BUNDEL_SOAL_PROVIDER-GetDaftarSoal: soal bookmark >>'
                ' ${dataSoal['c_IdSoal']} | ${dataSoal['isBookmarked']}');
          }

          // Konversi dataSoal menjadi SoalModel dan store ke cache [listSoal]
          listSoal[cacheKey]!.add(SoalModel.fromJson(dataSoal));

          nomorSoalSiswa++;
        }

        // Jika semua soal sudah di jawab, maka _isSudahDikumpulkanSemua = true
        if (listSoal[cacheKey]!.every((soal) => soal.sudahDikumpulkan)) {
          _isSudahDikumpulkanSemua = true;
        }

        if (isBookmarked) {
          for (int i = 0; i < listSoal[cacheKey]!.length; i++) {
            listSoal[cacheKey]![i].isBookmarked = i == nomorSoalAwal - 1;
          }
        }
      } else {
        await gShowTopFlash(
            gNavigatorKey.currentState!.context, errorGagalMenyiapkanSoal,
            dialogType: DialogType.error, duration: const Duration(seconds: 2));
        Navigator.of(gNavigatorKey.currentState!.context).pop();
      }

      if (kDebugMode) {
        logger.log(
            'BUNDEL_SOAL_PROVIDER-GetDaftarSoal: list soal >> ${listSoal[cacheKey]}');
      }

      _isLoadingSoal = false;
      notifyListeners();
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-GetDaftarSoal: $e');
      }
      await gShowTopFlash(gNavigatorKey.currentState!.context,
          'Koneksi internet Sobat tidak stabil, coba lagi!',
          dialogType: DialogType.error);
      _isLoadingSoal = false;
      Navigator.of(gNavigatorKey.currentState!.context).pop();
      notifyListeners();
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-GetDaftarSoal: $e');
      }
      await gShowTopFlash(
          gNavigatorKey.currentState!.context,
          ('$e'.contains('tidak ditemukan'))
              ? 'Yaah, soal ${(opsiUrut == OpsiUrut.nomor) ? 'bundel ini' : 'bab $kodeBab'} '
                  'belum disiapkan Sobat. Coba hubungi cabang GO terdekat untuk info '
                  'lebih lanjut yaa!'
              : '$e',
          dialogType: DialogType.error,
          duration: const Duration(seconds: 2));
      _isLoadingSoal = false;
      Navigator.of(gNavigatorKey.currentState!.context).pop();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-GetDaftarSoal: ${e.toString()}');
      }
      await gShowTopFlash(
          gNavigatorKey.currentState!.context, errorGagalMenyiapkanSoal,
          dialogType: DialogType.error, duration: const Duration(seconds: 2));
      _isLoadingSoal = false;
      Navigator.of(gNavigatorKey.currentState!.context).pop();
      notifyListeners();
    } finally {
      _isLoadingSoal = false;
      notifyListeners();
    }
  }

  Future<bool> simpanJawabanSiswa({
    required String tahunAjaran,
    required String idSekolahKelas,
    String? noRegistrasi,
    String? tipeUser,
    String? idKota,
    String? idGedung,
    String? kodeBab,
    required int idJenisProduk,
    required String namaJenisProduk,
    required String kodeTOB,
    required String kodePaket,
    required UserModel? userData,
  }) async {
    List<String> soalYangDiSimpan = [];
    listSoal[cacheKey]?.forEach((soal) {
      if (soal.jawabanSiswa != null) {
        if (!soal.sudahDikumpulkan) {
          soalYangDiSimpan.add(soal.idSoal);
        }
        soal.sudahDikumpulkan = true;
      }
    });

    if (soalYangDiSimpan.isEmpty) {
      await gShowTopFlash(gNavigatorKey.currentState!.context,
          'Kerjakan beberapa soal dulu sebelum menyimpan jawaban ya sobat',
          dialogType: DialogType.error);
      return false;
    }

    try {
      if (noRegistrasi != null && tipeUser != null && tipeUser != 'ORTU') {
        List<Map<String, dynamic>>? listDetail = listSoal[cacheKey]?.map((x) {
          return DetailJawaban(
            jenisProduk: namaJenisProduk,
            kodePaket: kodePaket,
            idBundel: x.idBundle!,
            kodeBab: kodeBab ?? x.kodeBab,
            idSoal: x.idSoal,
            nomorSoalDatabase: x.nomorSoal,
            nomorSoalSiswa: x.nomorSoalSiswa,
            idKelompokUjian: x.idKelompokUjian,
            namaKelompokUjian: x.namaKelompokUjian,
            tipeSoal: x.tipeSoal,
            tingkatKesulitan: x.tingkatKesulitan,
            jawabanSiswa: (x.jawabanSiswa == '' || x.jawabanSiswa == null)
                ? null
                : x.jawabanSiswa,
            kunciJawaban: x.kunciJawaban,
            translatorEPB: x.translatorEPB,
            kunciJawabanEPB: x.kunciJawabanEPB,
            jawabanSiswaEPB:
                (x.jawabanSiswa == null) ? null : x.jawabanSiswaEPB,
            infoNilai: jsonOpsi['nilai'] as Map<String, dynamic>,
            nilai: (x.jawabanSiswa == null) ? null : x.nilai,
            isRagu: x.isRagu,
            sudahDikumpulkan: false,
            lastUpdate: x.lastUpdate,
          ).toJson();
        }).toList();

        final detail = {
          'detil': listDetail,
        };

        // Kumpulkan / Simpan jawaban di server,
        // jika berhasil save ke server, baru save ke firebase.
        final bool isBerhasilSimpan = await _soalApiService.simpanJawaban(
            tahunAjaran: tahunAjaran,
            noRegistrasi: noRegistrasi,
            idSekolahKelas: idSekolahKelas,
            tipeUser: tipeUser,
            idKota: idKota!,
            idGedung: idGedung!,
            kodeTOB: kodeTOB,
            kodePaket: kodePaket,
            idJenisProduk: idJenisProduk,
            jumlahSoal: jumlahSoal,
            detailJawaban: detail,
            namaJenisProduk: namaJenisProduk,
            tingkatKelas: userData?.tingkatKelas ?? '');

        if (isBerhasilSimpan) {
          if (idJenisProduk == 65 ||
              idJenisProduk == 71 ||
              idJenisProduk == 72) {
            int tingkatKelas = int.parse(userData?.tingkatKelas ?? '0');
            await PaketSoalServiceApi().setSelesaiTO(
              idJenisProduk: idJenisProduk,
              kodePaket: kodePaket,
              tingkatKelas: tingkatKelas,
              userData: userData,
            );
          }
          await gShowTopFlash(gNavigatorKey.currentState!.context,
              'Yeey, Jawaban kamu berhasil disimpan Sobat',
              dialogType: DialogType.success);
          notifyListeners();
        } else {
          listSoal[cacheKey]?.forEach((soal) {
            if (soalYangDiSimpan.contains(soal.idSoal)) {
              soal.sudahDikumpulkan = false;
            }
          });

          await gShowTopFlash(
              gNavigatorKey.currentState!.context, errorGagalMenyimpanJawaban,
              dialogType: DialogType.error,
              duration: const Duration(seconds: 2));
        }
        return isBerhasilSimpan;
      } else {
        bool isBerhasilSimpan =
            await _soalServiceLocal.updateKumpulkanJawabanSiswa(
          isKumpulkan: false,
          kodePaket: kodePaket,
          onlyUpdateNull: false,
        );

        if (isBerhasilSimpan) {
          await gShowTopFlash(gNavigatorKey.currentState!.context,
              'Yeey, Jawaban kamu berhasil disimpan Sobat',
              dialogType: DialogType.success);
        } else {
          listSoal[cacheKey]?.forEach((soal) {
            if (soalYangDiSimpan.contains(soal.idSoal)) {
              soal.sudahDikumpulkan = false;
            }
          });

          await gShowTopFlash(gNavigatorKey.currentState!.context,
              'Gagal menyimpan jawaban Sobat, coba lagi!',
              dialogType: DialogType.error);
        }
        notifyListeners();
        return isBerhasilSimpan;
      }
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-KumpulkanJawabanSiswa: $e');
      }
      listSoal[cacheKey]?.forEach((soal) {
        if (soalYangDiSimpan.contains(soal.idSoal)) {
          soal.sudahDikumpulkan = false;
        }
      });

      await gShowTopFlash(gNavigatorKey.currentState!.context,
          'Koneksi internet Sobat tidak stabil, coba lagi!',
          dialogType: DialogType.error);
      return false;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-KumpulkanJawabanSiswa: $e');
      }
      listSoal[cacheKey]?.forEach((soal) {
        if (soalYangDiSimpan.contains(soal.idSoal)) {
          soal.sudahDikumpulkan = false;
        }
      });

      await gShowTopFlash(
          gNavigatorKey.currentState!.context, errorGagalMenyimpanJawaban,
          dialogType: DialogType.error, duration: const Duration(seconds: 2));
      return false;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-KumpulkanJawabanSiswa: ${e.toString()}');
      }
      listSoal[cacheKey]?.forEach((soal) {
        if (soalYangDiSimpan.contains(soal.idSoal)) {
          soal.sudahDikumpulkan = false;
        }
      });

      await gShowTopFlash(
          gNavigatorKey.currentState!.context, errorGagalMenyimpanJawaban,
          dialogType: DialogType.error, duration: const Duration(seconds: 2));
      return false;
    }
  }
}
