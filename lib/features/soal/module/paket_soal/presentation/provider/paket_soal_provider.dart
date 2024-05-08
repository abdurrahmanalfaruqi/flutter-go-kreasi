// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'dart:developer' as logger show log;

import 'package:flash/flash_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/bookmark/domain/entity/bookmark.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/entity/detail_bundel.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/model/detail_bundel_model.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/model/tob_model.dart';

import '../../../timer_soal/entity/tob.dart';
import '../../service/paket_soal_service_api.dart';
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
// import '../../../../../../core/helper/firebase_helper.dart';

class PaketSoalProvider extends SoalProvider {
  final _apiService = PaketSoalServiceApi();
  final _soalApiService = SoalServiceAPI();
  // final _firebaseHelper = FirebaseHelper();
  final _soalServideLocal = SoalServiceLocal();

  /// [_timer] digunakan untuk clock waktu simpan jawaban sementara
  Timer? _timer;

  /// [_listPaketSoal] merupakan cache paket soal.
  // final Map<int, List<PaketSoal>> _listPaketSoal = {};
  final Map<String, List<Tob>> _listTOBBersyarat = {};
  final Map<String, List<DetailBundel>> _listDetailWaktu = {};

  // Local Variable
  bool _isLoadingPaket = true;
  bool _isLoadingSoal = true;
  bool _isLoadingSimpanJawaban = false;
  bool _isJWT = false;
  bool _isSudahDikumpulkanSemua = false;
  DateTime? _serverTime;
  String? _loadingKoneksi;

  // Getter
  bool get isLoadingPaket => _isLoadingPaket;
  bool get isLoadingSoal => _isLoadingSoal;
  bool get isLoadingSimpanJawaban => _isLoadingSimpanJawaban;
  String? get loadingKoneksi => _loadingKoneksi;
  // bool get isSudahDikumpulkanSemua => _isSudahDikumpulkanSemua;
  DateTime get serverTime => _serverTime ?? DateTime.now();

  /// [totalSoalBefore] digunakan untuk menjumlahkan total soal subtest sebelumnya
  int totalSoalBefore(String kodePaket) {
    if (indexPaket == 0 && indexPaket == 1) return 0;

    int total = 0;
    for (int i = 0; i < indexPaket - 1; i++) {
      total += _listDetailWaktu[kodePaket]?[i].jumlahSoal ?? 0;
    }
    return total;
  }

  UnmodifiableListView<Tob> getListDaftarTOBBersyarat(String kodePaket) =>
      UnmodifiableListView(_listTOBBersyarat[kodePaket] ?? []);

  UnmodifiableListView<DetailBundel> getListDetailWaktuByKodePaket(
          String kodePaket) =>
      UnmodifiableListView(_listDetailWaktu[kodePaket] ?? []);

  // UnmodifiableListView<PaketSoal> getListPaketByJenisProduk(
  //         int idJenisProduk) =>
  //     UnmodifiableListView(_listPaketSoal[idJenisProduk] ?? []);

  UnmodifiableListView<Soal> getListSoal({required String kodePaket}) =>
      UnmodifiableListView(listSoal[kodePaket] ?? []);

  bool isSudahDikumpulkanSemua({required String kodePaket}) {
    if (!_isSudahDikumpulkanSemua) {
      _isSudahDikumpulkanSemua =
          (listSoal[kodePaket]?.every((soal) => soal.sudahDikumpulkan) ??
              false);
    }
    return _isSudahDikumpulkanSemua;
  }

  DetailBundel? getCurrentMataUji(String kodePaket) {
    if (_listDetailWaktu[kodePaket] == null || indexPaket == 0) return null;

    return _listDetailWaktu[kodePaket]?[indexPaket - 1];
  }

  DetailBundel? getMataUjiSebelumnya(String kodePaket) {
    if (_listDetailWaktu[kodePaket] == null || indexPaket <= 1) return null;
    final mataUjiSebelumnya = _listDetailWaktu[kodePaket]?[indexPaket - 2];

    return mataUjiSebelumnya;
  }

  DetailBundel? getMataUjiSelanjutnya(String kodePaket) {
    if (_listDetailWaktu[kodePaket] == null ||
        indexPaket == _listDetailWaktu[kodePaket]?.length) return null;
    final mataUjiSelanjutnya = _listDetailWaktu[kodePaket]?[indexPaket];

    return mataUjiSelanjutnya;
  }

  @override
  void disposeValues() {
    // _listPaketSoal.clear();
    listSoal.clear();
    super.disposeValues();
  }

  Future<List<Tob>> getDaftarTOBBersyarat({
    required String kodePaket,
  }) async {
    if (_listTOBBersyarat.containsKey(kodePaket) &&
        (_listTOBBersyarat[kodePaket]?.isNotEmpty ?? false)) {
      return getListDaftarTOBBersyarat(kodePaket);
    }

    var completer = Completer();
    gNavigatorKey.currentState!.context
        .showBlockDialog(dismissCompleter: completer);

    try {
      final responseData = await _apiService.fetchDaftarTOBBersyarat(
        kodePaket: kodePaket,
      );

      completer.complete();

      if (kDebugMode) {
        logger.log('PAKET_SOAL_PROVIDER-GetDaftarTOBBersyarat: '
            'responseData >> $responseData');
      }

      if (!_listTOBBersyarat.containsKey(kodePaket)) {
        _listTOBBersyarat[kodePaket] = [];
      }

      if (responseData.isNotEmpty &&
          (_listTOBBersyarat[kodePaket]?.isEmpty ?? false)) {
        for (Map<String, dynamic> tob in responseData) {
          _listTOBBersyarat[kodePaket]!.add(TobModel.fromJson(tob));
        }
      }

      return getListDaftarTOBBersyarat(kodePaket);
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-GetDaftarTOBBersyarat: $e');
      }
      completer.complete();
      await gShowTopFlash(gNavigatorKey.currentState!.context, e.toString());

      return getListDaftarTOBBersyarat(kodePaket);
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-GetDaftarTOBBersyarat: $e');
      }
      completer.complete();
      // await gShowTopFlash(gNavigatorKey.currentState!.context, '$e');

      return getListDaftarTOBBersyarat(kodePaket);
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-GetDaftarTOBBersyarat: ${e.toString()}');
      }
      completer.complete();
      await gShowTopFlash(gNavigatorKey.currentState!.context, e.toString());

      return getListDaftarTOBBersyarat(kodePaket);
    }
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
      // await _firebaseHelper.updateRaguRagu(
      //   tahunAjaran: tahunAjaran,
      //   noRegistrasi: noRegistrasi,
      //   idSekolahKelas: idSekolahKelas,
      //   tipeUser: tipeUser,
      //   kodePaket: kodePaket,
      //   idSoal: soal.idSoal,
      //   isRagu: soal.isRagu,
      // );
    } else {
      await _soalServideLocal.updateRaguRagu(
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
    Soal? soalTemp,
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
        logger.log(
            'PAKET_SOAL_PROVIDER-SetTempJawaban: params($tahunAjaran, $noRegistrasi, $tipeUser, $kodePaket, $jenisProduk, $jawabanSiswa)');
      }
      if (soalTemp == null) {
        setNilai(jawabanSiswa: jawabanSiswa);

        soal.jawabanSiswa = (jawabanSiswa == '') ? null : jawabanSiswa;
        soal.jawabanSiswaEPB = setJawabanEPB(
          soal.tipeSoal,
          soal.jawabanSiswa,
          soal.translatorEPB,
        );
        soal.lastUpdate = lastUpdateNowFormatted;
      } else {
        final Map<String, dynamic> jsonOpsi = jsonDecode(soalTemp.opsi);
        var nilai = jsonOpsi['nilai']['zerocredit'];

        soalTemp.nilai = (nilai is double)
            ? nilai
            : (int.tryParse('$nilai'.trim()) ?? 0).toDouble();
        soalTemp.lastUpdate = lastUpdateNowFormatted;
        soalTemp.jawabanSiswaEPB = setJawabanEPB(
          soalTemp.tipeSoal,
          soalTemp.jawabanSiswa,
          soalTemp.translatorEPB,
        );
      }

      DetailJawaban detailJawabanSiswa = DetailJawaban(
          jenisProduk: jenisProduk,
          kodePaket: kodePaket,
          idBundel: (soalTemp ?? soal).idBundle!,
          kodeBab: null,
          idSoal: (soalTemp ?? soal).idSoal,
          nomorSoalDatabase: (soalTemp ?? soal).nomorSoal,
          nomorSoalSiswa: (soalTemp ?? soal).nomorSoalSiswa,
          idKelompokUjian: (soalTemp ?? soal).idKelompokUjian,
          namaKelompokUjian: (soalTemp ?? soal).namaKelompokUjian,
          tipeSoal: (soalTemp ?? soal).tipeSoal,
          tingkatKesulitan: (soalTemp ?? soal).tingkatKesulitan,
          jawabanSiswa: (jawabanSiswa == '') ? null : jawabanSiswa,
          kunciJawaban:
              (soalTemp == null) ? soal.kunciJawaban : soalTemp.kunciJawaban,
          translatorEPB:
              (soalTemp == null) ? soal.translatorEPB : soalTemp.translatorEPB,
          kunciJawabanEPB: (soalTemp == null)
              ? soal.kunciJawabanEPB
              : soalTemp.kunciJawabanEPB,
          jawabanSiswaEPB: (soalTemp == null)
              ? soal.jawabanSiswaEPB
              : soalTemp.jawabanSiswaEPB,
          infoNilai: (soalTemp == null)
              ? jsonOpsi['nilai'] as Map<String, dynamic>
              : jsonDecode(soalTemp.opsi)['nilai'],
          nilai: (soalTemp ?? soal).nilai,
          isRagu: (soalTemp ?? soal).isRagu,
          sudahDikumpulkan: false,
          lastUpdate: (soalTemp ?? soal).lastUpdate);

      bool result = true;

      await Future.delayed(const Duration(milliseconds: 200));

      if (idJenisProduk != 65) {
        Map<String, dynamic> payload = {
          "no_register": noRegistrasi,
          "tahun_ajaran": tahunAjaran,
          "kode_paket": kodePaket,
          "id_kelompok_ujian": int.parse(soal.idKelompokUjian),
          "id_soal": int.parse(soal.idSoal),
          "tipe_soal": soal.tipeSoal,
          "nomor_soal_siswa": indexSoal + 1 + totalSoalBefore(kodePaket),
          "jawaban_siswa": jawabanSiswa,
          "is_ragu": soal.isRagu,
          "urutan": indexPaket,
        };

        result = await _apiService.storeJawabanSiswa(
          jawabanSiswa: payload,
          idJenisProduk: idJenisProduk,
        );
      } else {
        final res = await _soalServideLocal.setTempJawabanSiswa(
          kodePaket: kodePaket,
          idSoal: (soalTemp ?? soal).idSoal,
          jsonSoalJawabanSiswa: detailJawabanSiswa.toJson(),
        );

        result = res.isNotEmpty;
      }

      // if (noRegistrasi != null && tipeUser != null && tipeUser != 'ORTU') {
      //   // Penyimpanan untuk SISWA dan TAMU.
      //   // await _firebaseHelper.setTempJawabanSiswa(
      //   //   tahunAjaran: tahunAjaran,
      //   //   idSekolahKelas: idSekolahKelas,
      //   //   noRegistrasi: noRegistrasi,
      //   //   tipeUser: tipeUser,
      //   //   kodePaket: kodePaket,
      //   //   idSoal: (soalTemp ?? soal).idSoal,
      //   //   jsonSoalJawabanSiswa: detailJawabanSiswa.toJson(),
      //   // );
      // } else {
      //   // Penyimpanan untuk Teaser No User dan Ortu.
      //   await _soalServideLocal.setTempJawabanSiswa(
      //     kodePaket: kodePaket,
      //     idSoal: (soalTemp ?? soal).idSoal,
      //     jsonSoalJawabanSiswa: detailJawabanSiswa.toJson(),
      //   );
      // }
      if (soalTemp != null) {
        soalTemp.jawabanSiswa =
            (jawabanSiswa == '' || !result) ? null : jawabanSiswa;
      }

      soal.jawabanSiswa = (jawabanSiswa == '' || !result) ? null : jawabanSiswa;

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        logger.log('PAKETSOAL-FatalException-SetTempJawaban: $e');
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

  Future<List<DetailJawaban>> _getDetailJawabanSiswa({
    required String kodePaket,
    required String tahunAjaran,
    required String idSekolahKelas,
    String? noRegistrasi,
    String? tipeUser,
    required bool kumpulkanSemua,
  }) async {
    // Jika user login
    if (noRegistrasi != null && tipeUser != null && tipeUser != 'ORTU') {
      // Penyimpanan untuk SISWA dan TAMU.
      // return await _firebaseHelper.getJawabanSiswaByKodePaket(
      //   tahunAjaran: tahunAjaran,
      //   noRegistrasi: noRegistrasi,
      //   tipeUser: tipeUser,
      //   kodePaket: kodePaket,
      //   idSekolahKelas: idSekolahKelas,
      //   kumpulkanSemua: kumpulkanSemua,
      // );
      return [];
    } else {
      // Penyimpanan untuk Teaser No User dan Ortu.
      return await _soalServideLocal.getJawabanSiswaByKodePaket(
        kodePaket: kodePaket,
        kumpulkanSemua: kumpulkanSemua,
      );
    }
  }

  // Future<void> getDaftarPaketSoal({
  //   String? noRegistrasi,
  //   required String idSekolahKelas,
  //   required int idJenisProduk,
  //   String roleTeaser = 'No User',
  //   bool isProdukDibeli = false,
  //   bool isRefresh = false,
  // }) async {
  //   // Jika tidak refresh dan data sudah ada di cache [_listPaketSoal]
  //   // maka return List dari [_listPaketSoal].
  //   if (!isRefresh && (_listPaketSoal[idJenisProduk]?.isNotEmpty ?? false)) {
  //     return;
  //   }
  //   if (isRefresh) {
  //     _isLoadingPaket = true;
  //     notifyListeners();
  //     _listPaketSoal[idJenisProduk]?.clear();
  //   }
  //   try {
  //     // Untuk jwt request soal
  //     _isJWT = noRegistrasi != null;

  //     final responseData = await _apiService.fetchDaftarPaketSoal(
  //         noRegistrasi: noRegistrasi,
  //         idSekolahKelas: idSekolahKelas,
  //         idJenisProduk: '$idJenisProduk',
  //         roleTeaser: roleTeaser,
  //         isProdukDibeli: isProdukDibeli);

  //     // Jika [_listPaketSoal] tidak memiliki key idJenisProduk tertentu maka buat key valuenya dulu;
  //     if (!_listPaketSoal.containsKey(idJenisProduk)) {
  //       _listPaketSoal[idJenisProduk] = [];
  //     }
  //     // Cek apakah response data memiliki data atau tidak
  //     if (responseData.isNotEmpty) {
  //       for (Map<String, dynamic> dataPaket in responseData) {
  //         // Konversi dataPaket menjadi PaketSoalModel dan store ke cache [_listPaketSoal]
  //         _listPaketSoal[idJenisProduk]!
  //             .add(PaketSoalModel.fromJson(dataPaket));
  //       }
  //     }

  //     _isLoadingPaket = false;
  //     notifyListeners();
  //   } on NoConnectionException catch (e) {
  //     if (kDebugMode) {
  //       logger.log('NoConnectionException-GetDaftarPaketSoal: $e');
  //     }
  //     _isLoadingPaket = false;
  //     notifyListeners();
  //     rethrow;
  //   } on DataException catch (e) {
  //     if (kDebugMode) {
  //       logger.log('Exception-GetDaftarPaketSoal: $e');
  //     }
  //     _isLoadingPaket = false;
  //     notifyListeners();
  //     rethrow;
  //   } catch (e) {
  //     if (kDebugMode) {
  //       logger.log('FatalException-GetDaftarPaketSoal: ${e.toString()}');
  //     }
  //     _isLoadingPaket = false;
  //     notifyListeners();
  //     rethrow;
  //   }
  // }

  Future<void> getDaftarSoal({
    required String kodePaket,
    required String jenisProduk,
    required String tahunAjaran,
    required String idSekolahKelas,
    required List<int> listIdBundelSoal,
    required int idJenisProduk,
    String? noRegistrasi,
    String? tipeUser,
    bool isKumpulkan = false,
    bool isRefresh = false,
    int? urutan = 1,
    bool isKedaluwarsa = false,
    int nomorSoalAwal = 1,
    bool isBookmarked = false,
  }) async {
    if (!_isLoadingSoal) {
      _isLoadingSoal = true;
      notifyListeners();
    }
    // Update Server Time untuk cek empati wajib
    _serverTime = await gGetServerTime();
    // Set value indexSoal dan cacheKey pada soal_provider.dart
    cacheKey = kodePaket;
    indexSoal = (nomorSoalAwal > 0) ? nomorSoalAwal - 1 : 0;
    bool isMoveSubtest = idJenisProduk != 71 && idJenisProduk != 72;
    // Jika tidak refresh dan data sudah ada di cache [listSoal]
    // maka return List dari [listSoal].
    listSoal[kodePaket]?.clear();
    if (!isRefresh &&
        (listSoal[kodePaket]?.isNotEmpty == true) &&
        isMoveSubtest) {
      if (isKedaluwarsa) {
        for (var soal in listSoal[kodePaket]!) {
          soal.sudahDikumpulkan = true;
        }
      }

      // Jika semua soal sudah di jawab, maka _isSudahDikumpulkanSemua = true
      _isSudahDikumpulkanSemua = isKedaluwarsa ||
          (listSoal[kodePaket]?.every((soal) => soal.sudahDikumpulkan) ??
              false);

      if (kDebugMode) {
        logger.log('SUDAH DIKUMPULKAN SEMUA: $_isSudahDikumpulkanSemua');
      }

      // Mengambil seluruh data bookmark dari hive
      List<BookmarkMapel> daftarBookmarkMapel =
          await HiveHelper.getDaftarBookmarkMapel();

      for (var soal in listSoal[kodePaket]!) {
        soal.isBookmarked = daftarBookmarkMapel.any(
          (bookmarkMapel) => bookmarkMapel.listBookmark.any((bookmarkSoal) =>
              bookmarkSoal.kodePaket == kodePaket &&
              bookmarkSoal.idSoal == soal.idSoal),
        );
      }

      _isLoadingSoal = false;
      notifyListeners();
      return;
    }
    if (isRefresh) {
      listSoal[kodePaket]?.clear();
    } else {
      notifyListeners();
    }
    try {
      if (idJenisProduk != 65) {
        final responseDetailWaktu = await _apiService.fetchDetailWaktu(
          kodePaket: kodePaket,
          idJenisProduk: idJenisProduk,
        );

        // Jika [_listDetailWaktu] tidak memiliki key kodePaket
        if (!_listDetailWaktu.containsKey(kodePaket)) {
          _listDetailWaktu[kodePaket] = [];
        }

        if (responseDetailWaktu.isNotEmpty &&
            _listDetailWaktu[kodePaket]!.isEmpty) {
          int jumlahSoalTemp = 0;

          int indexSoalPertama = 0;
          int indexSoalTerakhir = 0;

          for (Map<String, dynamic> detailWaktu in responseDetailWaktu) {
            int jumlahSoalDetail = (detailWaktu['jumlah_soal'] == null)
                ? 0
                : (detailWaktu['jumlah_soal'] is int)
                    ? detailWaktu['jumlah_soal']
                    : int.parse(detailWaktu['jumlah_soal'].toString());

            indexSoalPertama = jumlahSoalTemp;
            jumlahSoalTemp += jumlahSoalDetail;
            indexSoalTerakhir = jumlahSoalTemp - 1;

            DetailBundel detailBundel = DetailBundelModel.fromJson(
              json: detailWaktu,
              indexSoalPertama: indexSoalPertama,
              indexSoalTerakhir: indexSoalTerakhir,
              urutan: urutan ?? 1,
            );

            _listDetailWaktu[kodePaket]!.add(detailBundel);

            if (kDebugMode) {
              logger.log(
                  'TOB_PROVIDER-GetDaftarSoalTO: Detail Waktu >> $jumlahSoalTemp | '
                  '$indexSoalPertama | $indexSoalTerakhir | ${detailWaktu['c_namakelompokujian']}');
              logger.log(
                  'TOB_PROVIDER-GetDaftarSoalTO: Detail Object >> $detailBundel');
            }
          }
        }
      }

      final responseData = await _apiService.fetchDaftarSoal(
        isJWT: _isJWT,
        kodePaket: kodePaket,
        listId: listIdBundelSoal,
        idJenisProduk: idJenisProduk,
        urutan: urutan,
      );

      // Mengambil jawaban siswa yang ada di firebase.
      // Jika belum login atau Akun Ortu maka akan mengambil jawaban dari Hive.
      // final List<DetailJawaban> jawabanFirebase = await _getDetailJawabanSiswa(
      //   kodePaket: kodePaket,
      //   tahunAjaran: tahunAjaran,
      //   idSekolahKelas: idSekolahKelas,
      //   noRegistrasi: noRegistrasi,
      //   tipeUser: tipeUser,
      //   kumpulkanSemua: true,
      // );

      if (kDebugMode) {
        logger.log(
            'PAKET_SOAL_PROVIDER-GetDaftarSoal: responseData >> $responseData');
        // logger.log(
        //     'PAKET_SOAL_PROVIDER-GetDaftarSoal: jawabanFirebase >> $jawabanFirebase');
      }
      // Jika [listSoal] tidak memiliki key idBundel tertentu maka buat key valuenya dulu.
      if (!listSoal.containsKey(kodePaket)) {
        listSoal[kodePaket] = [];
      }

      // jika emma, emwa pindah subtest maka hapus list soal sebelumnya
      if (responseData.isNotEmpty && listSoal[kodePaket]?.isNotEmpty == true) {
        listSoal[kodePaket]?.clear();
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

          // if (kDebugMode) {
          //   logger.log(
          //       'PAKET_SOAL_PROVIDER-GetDaftarSoalTO: Detail Jawaban >> ${detailJawabanSiswa.first}');
          //   logger.log(
          //       'PAKET_SOAL_PROVIDER-GetDaftarSoalTO: Additional json >> ${detailJawabanSiswa.first.additionalJsonSoal()}');
          // }
          // Menambahkan informasi json SoalModel
          // if (detailJawabanSiswa.isNotEmpty) {
          //   dataSoal.addAll(detailJawabanSiswa.first.additionalJsonSoal());
          // }
          // Jika paket kedaluwarsa, maka akan dianggap sudah mengumpulkan.
          if (isKedaluwarsa) {
            dataSoal['sudahDikumpulkan'] = true;
          }
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
            logger.log(
                'PAKET_SOAL_PROVIDER-GetDaftarSoal: bookmark hive >> ${daftarBookmarkMapel.toString()}');
            logger.log(
                'PAKET_SOAL_PROVIDER-GetDaftarSoal: soal bookmark >> ${dataSoal['c_IdSoal']} | ${dataSoal['isBookmarked']}');
          }

          // Konversi dataSoal menjadi SoalModel dan store ke cache [listSoal]
          listSoal[kodePaket]!.add(SoalModel.fromJson(dataSoal));
          nomorSoalSiswa++;
        }

        // Jika semua soal sudah di jawab, maka _isSudahDikumpulkanSemua = true
        if (listSoal[kodePaket]!.every((soal) => soal.sudahDikumpulkan)) {
          _isSudahDikumpulkanSemua = true;
        }

        if (isBookmarked) {
          for (Soal soal in listSoal[kodePaket] ?? []) {
            soal.isBookmarked = soal.nomorSoal == nomorSoalAwal;
          }
        }

        if (kDebugMode) {
          logger.log('SUDAH DIKUMPULKAN SEMUA: $_isSudahDikumpulkanSemua');
        }
      } else {
        await gShowTopFlash(
            gNavigatorKey.currentState!.context, errorGagalMenyiapkanSoal,
            dialogType: DialogType.error, duration: const Duration(seconds: 2));
        Navigator.of(gNavigatorKey.currentState!.context).pop();
      }

      // Jika Paket merupakan jenis yang harus dikumpulkan keseluruhan,
      // maka set temp jawaban siswa di seluruh soal.
      // if (isKumpulkan && jawabanFirebase.isEmpty) {
      // if (isKumpulkan) {
      //   // ignore: unused_local_variable
      //   for (var soal in listSoal[kodePaket]!) {
      //     await setTempJawaban(
      //         idSekolahKelas: idSekolahKelas,
      //         tahunAjaran: tahunAjaran,
      //         jenisProduk: jenisProduk,
      //         tipeUser: tipeUser,
      //         kodePaket: kodePaket,
      //         jawabanSiswa: null,
      //         noRegistrasi: noRegistrasi);
      //   }
      // }

      if (kDebugMode) {
        logger.log(
            'PAKET_SOAL_PROVIDER-GetDaftarSoal: list soal >> ${listSoal[kodePaket]}');
      }

      _isLoadingSoal = false;
      if (idJenisProduk == 71 || idJenisProduk == 72) {
        indexPaket = urutan ?? 1;
      }
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
              ? 'Yaah, soal paket $kodePaket belum disiapkan Sobat. '
                  'Coba hubungi cabang GO terdekat untuk info lebih lanjut yaa!'
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

  Future<bool> kumpulkanJawabanSiswa({
    required bool isKumpulkan,
    required String tahunAjaran,
    required String idSekolahKelas,
    String? noRegistrasi,
    String? tipeUser,
    String? idKota,
    String? idGedung,
    required int idJenisProduk,
    required String namaJenisProduk,
    required String kodeTOB,
    required String kodePaket,
    required UserModel? userData,
  }) async {
    if (kDebugMode) {
      logger.log('PAKET_SOAL_PROVIDER-KumpulkanJawabanSiswa: START');
    }
    List<String> soalYangDiSimpan = [];
    listSoal[cacheKey]?.forEach((soal) {
      if (!soal.sudahDikumpulkan) {
        soalYangDiSimpan.add(soal.idSoal);
      }
      if (soal.jawabanSiswa != null) {
        soal.sudahDikumpulkan = true;
      } else {
        if (isKumpulkan) {
          setTempJawaban(
            soalTemp: soal,
            tahunAjaran: tahunAjaran,
            noRegistrasi: noRegistrasi,
            tipeUser: tipeUser,
            idSekolahKelas: idSekolahKelas,
            kodePaket: kodePaket,
            jenisProduk: namaJenisProduk,
            jawabanSiswa: null,
            idJenisProduk: idJenisProduk,
          );
        }
      }
    });

    try {
      if (noRegistrasi != null && tipeUser != null && tipeUser != 'ORTU') {
        final List<DetailJawaban> daftarDetailJawaban =
            await _getDetailJawabanSiswa(
          kodePaket: kodePaket,
          tahunAjaran: tahunAjaran,
          idSekolahKelas: idSekolahKelas,
          noRegistrasi: noRegistrasi,
          tipeUser: tipeUser,
          kumpulkanSemua: isKumpulkan,
        );

        if (kDebugMode) {
          logger.log(
              'PAKET_SOAL_PROVIDER-SimpanJawaban: Jawaban Firebase >> $daftarDetailJawaban');
        }

        List<Map<String, dynamic>>? listDetail = listSoal[cacheKey]?.map((x) {
          return DetailJawaban(
            jenisProduk: namaJenisProduk,
            kodePaket: kodePaket,
            idBundel: x.idBundle!,
            kodeBab: null,
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

        // Jika berhasil simpan ke server, maka update status sudah di kumpulkan yang jawabannya null
        if (isBerhasilSimpan) {
          if (idJenisProduk == 65 ||
              idJenisProduk == 71 ||
              idJenisProduk == 72) {
            int tingkatKelas = int.parse(userData?.tingkatKelas ?? '0');
            await _apiService.setSelesaiTO(
              idJenisProduk: idJenisProduk,
              kodePaket: kodePaket,
              tingkatKelas: tingkatKelas,
              userData: userData,
            );
          }

          listSoal[cacheKey]?.forEach((soal) {
            soal.sudahDikumpulkan = true;
          });

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
        bool isBerhasilSimpan = false;

        if (isKumpulkan) {
          listSoal[cacheKey]?.forEach((soal) => soal.sudahDikumpulkan = true);

          isBerhasilSimpan =
              await _soalServideLocal.updateKumpulkanJawabanSiswa(
            kodePaket: kodePaket,
            isKumpulkan: true,
            onlyUpdateNull: false,
          );
        } else {
          // Update firebase dulu jika jawaban siswa not null, baru ke server
          isBerhasilSimpan =
              await _soalServideLocal.updateKumpulkanJawabanSiswa(
            kodePaket: kodePaket,
            isKumpulkan: false,
            onlyUpdateNull: false,
          );
        }

        // Jika berhasil simpan ke server, maka update status sudah di kumpulkan yang jawabannya null
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

  Future<bool> submitJawabanSiswa({
    required UserModel? userData,
    required String kodePaket,
    required int idJenisProduk,
  }) async {
    try {
      final res = await _apiService.setSelesaiTO(
        idJenisProduk: idJenisProduk,
        kodePaket: kodePaket,
        tingkatKelas: int.parse(userData?.tingkatKelas ?? '0'),
        userData: userData,
      );

      if (!res) throw 'Terjadi Kesalahan, coba lagi nanti';

      await gShowTopFlash(
        gNavigatorKey.currentState!.context,
        'Yeey, Jawaban kamu berhasil dikumpulkan Sobat',
        dialogType: DialogType.success,
      );
      notifyListeners();
      return res;
    } catch (e) {
      await gShowTopFlash(
        gNavigatorKey.currentState!.context,
        e.toString(),
        dialogType: DialogType.error,
      );
      notifyListeners();
      return false;
    }
  }
}
