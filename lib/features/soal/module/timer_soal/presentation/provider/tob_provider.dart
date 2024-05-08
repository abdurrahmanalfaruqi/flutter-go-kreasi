// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:collection';
import 'dart:developer' as logger show log;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/ptn/module/ptnclopedia/entity/kampus_impian.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/entity/jawaban_siswa.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/model/jawaban_siswa_model.dart';

import '../../entity/syarat_tobk.dart';
import '../../entity/paket_to.dart';
import '../../entity/hasil_goa.dart';
import '../../entity/kisi_kisi.dart';
import '../../entity/detail_bundel.dart';
import '../../model/kisi_kisi_model.dart';
import '../../service/tob_service_api.dart';
import '../../model/detail_bundel_model.dart';
import '../../../../model/soal_model.dart';
import '../../../../entity/peserta_to.dart';
import '../../../../entity/detail_jawaban.dart';
// import '../../../../model/peserta_to_model.dart';
import '../../../../service/local/soal_service_local.dart';
import '../../../../presentation/provider/soal_provider.dart';
import '../../../../../../core/config/enum.dart';
import '../../../../../../core/config/global.dart';
import '../../../../../../core/config/extensions.dart';
import '../../../../../../core/util/app_exceptions.dart';
import '../../../../../../core/util/data_formatter.dart';
// import '../../../../../../core/helper/firebase_helper.dart';

/// [PaketTimerList] merupakan Widget List Paket Timer selain TOBK.<br><br>
/// Digunakan pada produk-produk berikut:<br>
/// 1. GOA (id: 12).<br>
/// 2. Kuis (id: 16).<br>
/// 3. Racing (id: 80).<br>
/// 4. TOBK (id: 25).
class TOBProvider extends SoalProvider {
  final _apiService = TOBServiceApi();
  final _soalServiceLocal = SoalServiceLocal();

  /// [_timer] digunakan untuk clock waktu simpan jawaban sementara
  Timer? _timer;
  // final _firebaseHelper = FirebaseHelper();

  // final Map<int, List<Tob>> _listTOB = {};
  final Map<String, List<PaketTO>> _listPaketTO = {};
  final Map<String, List<DetailBundel>> _listDetailWaktu = {};
  final Map<String, List<KisiKisi>> _listKisiKisi = {};
  final Map<String, HasilGOA> _laporanGOA = {};
  final Map<String, SyaratTOBK> _listSyaratTOB = {};

  // Local Variable
  bool _isLoadingTOB = true;
  bool _isLoadingPaketTO = true;
  bool _isLoadingSoal = true;
  bool _isLoadingLaporanGOA = true;
  bool _isLoadingSimpanJawaban = false;
  bool _isBlockingTime = false;
  int _indexCurrentMataUji = 0;
  String? _loadingKoneksi;
  Duration? _sisaWaktu;
  DateTime? _serverTime;
  SnackBar? snackbar;
  Duration waktuPengerjaan = const Duration();

  // Getter
  bool get isLoadingTOB => _isLoadingTOB;
  bool get isLoadingPaketTO => _isLoadingPaketTO;
  bool get isLoadingSoal => _isLoadingSoal;
  bool get isLoadingLaporanGOA => _isLoadingLaporanGOA;
  bool get isLoadingSimpanJawaban => _isLoadingSimpanJawaban;
  String? get loadingKoneksi => _loadingKoneksi;
  int get indexCurrentMataUji => _indexCurrentMataUji;
  Duration get sisaWaktu {
    if (_sisaWaktu == null) {
      gShowTopFlash(
          gNavigatorKey.currentState!.context, 'Gagal menyiapkan waktu');
    } else {
      if (kDebugMode) {
        logger.log(
            'TOB_PROVIDER-GetSisaWaktu: Sisa Waktu >> ${_sisaWaktu!.inMinutes} menit ${_sisaWaktu!.inSeconds % 60} detik');
      }
    }
    return _sisaWaktu ?? const Duration(minutes: 1);
  }

  set sisaWaktu(Duration waktu) {
    _sisaWaktu = waktu;
  }

  DateTime get serverTime => _serverTime ?? DateTime.now();
  set serverTime(DateTime time) {
    _serverTime = time;
    notifyListeners();
  }

  // set listKelompokUjian(List<KelompokUjian> list) {
  //   _listKelompokUjian = list;
  //   notifyListeners();
  // }

  SyaratTOBK? getSyaratTOBByKodeTOB(String kodeTOB) => _listSyaratTOB[kodeTOB];

  // UnmodifiableListView<Tob> getListTOBByJenisProduk(int idJenisProduk) =>
  //     UnmodifiableListView(_listTOB[idJenisProduk] ?? []);

  List<PaketTO> getListPaketTOByKodeTOB(String kodeTOB) =>
      (_listPaketTO[kodeTOB] == null) ? [] : [..._listPaketTO[kodeTOB]!];

  UnmodifiableListView<DetailBundel> getListDetailWaktuByKodePaket(
          String kodePaket) =>
      UnmodifiableListView(_listDetailWaktu[kodePaket] ?? []);

  UnmodifiableListView<KisiKisi> getListKisiKisiByKodePaket(String kodePaket) =>
      UnmodifiableListView(_listKisiKisi[kodePaket] ?? []);

  HasilGOA getLaporanGOAByKodePaket(String kodePaket) =>
      _laporanGOA[kodePaket] ?? BelumMengerjakanGOA();

  /// [totalSoalBefore] digunakan untuk menjumlahkan total soal subtest sebelumnya
  int totalSoalBefore(String kodePaket) {
    if (indexPaket == 0 && indexPaket == 1) return 0;

    int total = 0;
    for (int i = 0; i < indexPaket - 1; i++) {
      total += _listDetailWaktu[kodePaket]?[i].jumlahSoal ?? 0;
    }
    return total;
  }

  /// [isLastSubtest] digunakan untuk mengetahui apakah di sub-test terakhir
  bool isLastSubtest(String kodePaket) {
    return indexPaket == getListDetailWaktuByKodePaket(kodePaket).length;
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
    // _listTOB.clear();
    _listPaketTO.clear();
    super.disposeValues();
  }

  @override
  Future<void> setNextSoal({
    String? kodePaket,
    required String noRegister,
    required String tahunAjaran,
    required int idJenisProduk,
    int urutan = 1,
  }) async {
    // hardcode by arifin
    // if (_isBlockingTime) {
    //   canMoveNext = indexSoal >=
    //           _listDetailWaktu[kodePaket!]![_indexCurrentMataUji]
    //               .indexSoalPertama &&
    //       indexSoal <
    //           _listDetailWaktu[kodePaket]![_indexCurrentMataUji]
    //               .indexSoalTerakhir;
    // }

    if (_isLoadingSimpanJawaban) {
      _showLoadingSimpanJawaban();
    } else {
      await super.setNextSoal(
        kodePaket: kodePaket,
        noRegister: noRegister,
        tahunAjaran: tahunAjaran,
        urutan: urutan,
        idJenisProduk: idJenisProduk,
      );
    }
  }

  @override
  Future<void> setPrevSoal({
    String? kodePaket,
    required String noRegister,
    required String tahunAjaran,
    required int idJenisProduk,
    int urutan = 1,
  }) async {
    // hardcode by arifin
    // if (_isBlockingTime) {
    //   canMovePrev = indexSoal >
    //           _listDetailWaktu[kodePaket!]![_indexCurrentMataUji]
    //               .indexSoalPertama &&
    //       indexSoal <=
    //           _listDetailWaktu[kodePaket]![_indexCurrentMataUji]
    //               .indexSoalTerakhir;
    // }

    if (_isLoadingSimpanJawaban) {
      _showLoadingSimpanJawaban();
    } else {
      await super.setPrevSoal(
        kodePaket: kodePaket,
        noRegister: noRegister,
        tahunAjaran: tahunAjaran,
        urutan: urutan,
        idJenisProduk: idJenisProduk,
      );
    }
  }

  // bool setNextMataUjiBlockingTime({
  //   required String kodePaket,
  // }) {
  //   DetailBundel? mataUjiSelanjutnya = getMataUjiSelanjutnya(kodePaket);
  //
  //   if (mataUjiSelanjutnya != null) {
  //     _sisaWaktu = Duration(minutes: mataUjiSelanjutnya.waktuPengerjaan);
  //     _indexCurrentMataUji++;
  //     if (kDebugMode) {
  //       logger.log(
  //           'TOB_PROVIDER-SetNextMataUjiBlockingTime: Atur Sisa Waktu >> '
  //           '${mataUjiSelanjutnya.waktuPengerjaan} menit || '
  //           '${_sisaWaktu!.inMinutes} Menit ${_sisaWaktu!.inSeconds % 60} detik');
  //     }
  //     super.jumpToSoalNomor(mataUjiSelanjutnya.indexSoalPertama);
  //   }
  //
  //   return mataUjiSelanjutnya == null;
  // }

  Future<void> toggleRaguRagu({
    required String tahunAjaran,
    required String idSekolahKelas,
    required String kodePaket,
    required String kodeTOB,
    required String jenisProduk,
    required UserModel? userData,
    required int urutan,
    required int idJenisProduk,
    String? noRegistrasi,
    String? tipeUser,
  }) async {
    // Toggle soal ragu-ragu
    soal.isRagu = !soal.isRagu;

    notifyListeners();
  }

  void _setMulaiTO({
    required String kodeTOB,
    required String kodePaket,
    required int idJenisProduk,
    required int totalWaktuSeharusnya,
    required List<PaketTO> listPaketTO,
  }) {
    int indexPaket =
        listPaketTO.indexWhere((paket) => paket.kodePaket == kodePaket);

    if (indexPaket >= 0) {
      listPaketTO[indexPaket].isPernahMengerjakan = true;
      listPaketTO[indexPaket].tanggalSiswaSubmit = null;
      listPaketTO[indexPaket].kapanMulaiMengerjakan = _serverTime;
      listPaketTO[indexPaket].deadlinePengerjaan =
          _serverTime!.add(Duration(minutes: totalWaktuSeharusnya));
    }
    // if (_listPaketTO.containsKey(kodeTOB)) {
    //   // int indexPaket = _listPaketTO[kodeTOB]!.indexWhere(
    //   //     (paket) => paket.kodeTOB == kodeTOB && paket.kodePaket == kodePaket);
    //   int indexPaket =
    //       listPaketTO.indexWhere((paket) => paket.kodePaket == kodePaket);

    //   if (indexPaket >= 0) {
    //     _listPaketTO[kodeTOB]![indexPaket].isPernahMengerjakan = true;
    //     _listPaketTO[kodeTOB]![indexPaket].tanggalSiswaSubmit = null;
    //     _listPaketTO[kodeTOB]![indexPaket].kapanMulaiMengerjakan = _serverTime;
    //     _listPaketTO[kodeTOB]![indexPaket].deadlinePengerjaan =
    //         _serverTime!.add(Duration(minutes: totalWaktuSeharusnya));
    //   }
    // } else {
    //   // int indexPaket = _listPaketTO['$idJenisProduk']!.indexWhere(
    //   //     (paket) => paket.kodeTOB == kodeTOB && paket.kodePaket == kodePaket);
    //   int indexPaket =
    //       listPaketTO.indexWhere((paket) => paket.kodePaket == kodePaket);

    //   if (indexPaket >= 0) {
    //     _listPaketTO['$idJenisProduk']![indexPaket].isPernahMengerjakan = true;
    //     _listPaketTO['$idJenisProduk']![indexPaket].tanggalSiswaSubmit = null;
    //     _listPaketTO['$idJenisProduk']![indexPaket].kapanMulaiMengerjakan =
    //         _serverTime;
    //     _listPaketTO['$idJenisProduk']![indexPaket].deadlinePengerjaan =
    //         _serverTime!.add(Duration(minutes: totalWaktuSeharusnya));
    //   }
    // }
  }

  Future<void> setTempJawaban({
    required String tahunAjaran,
    required String idSekolahKelas,
    required String kodePaket,
    required String kodeTOB,
    required String jenisProduk,
    required UserModel? userData,
    required int urutan,
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

      if (jawabanSiswa != null) {
        // setNilai(jawabanSiswa: jawabanSiswa);
        // soal.jawabanSiswaEPB = setJawabanEPB(
        //   soal.tipeSoal,
        //   soal.jawabanSiswa,
        //   soal.translatorEPB,
        // );
        soal.lastUpdate = lastUpdateNowFormatted;
      }

      // DetailJawaban detailJawabanSiswa = DetailJawaban(
      //     jenisProduk: jenisProduk,
      //     kodePaket: kodePaket,
      //     idBundel: soal.idBundle!,
      //     kodeBab: null,
      //     idSoal: soal.idSoal,
      //     nomorSoalDatabase: soal.nomorSoal,
      //     nomorSoalSiswa: indexSoal + 1,
      //     idKelompokUjian: soal.idKelompokUjian,
      //     namaKelompokUjian: soal.namaKelompokUjian,
      //     tipeSoal: soal.tipeSoal,
      //     tingkatKesulitan: soal.tingkatKesulitan,
      //     jawabanSiswa: (jawabanSiswa == '' || jawabanSiswa == null)
      //         ? null
      //         : jawabanSiswa,
      //     kunciJawaban: soal.kunciJawaban,
      //     translatorEPB: soal.translatorEPB,
      //     kunciJawabanEPB: soal.kunciJawabanEPB,
      //     jawabanSiswaEPB: (jawabanSiswa == null) ? null : soal.jawabanSiswaEPB,
      //     infoNilai: jsonOpsi['nilai'] as Map<String, dynamic>,
      //     nilai: (jawabanSiswa == null) ? null : soal.nilai,
      //     isRagu: soal.isRagu,
      //     sudahDikumpulkan: false,
      //     lastUpdate: soal.lastUpdate);

      bool isSuccess = false;

      await Future.delayed(const Duration(milliseconds: 200));

      if (userData?.noRegistrasi != null && !userData.isOrtu) {
        // final listDetailJawaban = await _soalServiceLocal.setTempJawabanSiswa(
        //   kodePaket: kodePaket,
        //   idSoal: (soalTemp ?? soal).idSoal,
        //   jsonSoalJawabanSiswa: detailJawabanSiswa.toJson(),
        // );

        Map<String, dynamic> payload = {
          "no_register": userData?.noRegistrasi,
          "tahun_ajaran": userData?.tahunAjaran,
          "kode_paket": kodePaket,
          "id_soal": int.tryParse(soal.idSoal),
          "tipe_soal": soal.tipeSoal,
          "nomor_soal_siswa": indexSoal + 1 + totalSoalBefore(kodePaket),
          "jawaban_siswa": jawabanSiswa,
          "is_ragu": soal.isRagu,
          "id_kelompok_ujian": int.tryParse(soal.idKelompokUjian),
          "urutan": urutan,
        };

        isSuccess = await _apiService.storeJawabanSiswa(
          jawabanSiswa: payload,
          idJenisProduk: idJenisProduk,
        );
        // Penyimpanan untuk SISWA dan TAMU.
        // await _firebaseHelper.setTempJawabanSiswa(
        //   tahunAjaran: tahunAjaran,
        //   idSekolahKelas: idSekolahKelas,
        //   noRegistrasi: noRegistrasi,
        //   tipeUser: tipeUser,
        //   kodePaket: kodePaket,
        //   idSoal: (soalTemp ?? soal).idSoal,
        //   jsonSoalJawabanSiswa: detailJawabanSiswa.toJson(),
        // );
      }

      soal.jawabanSiswa =
          (jawabanSiswa == '' || !isSuccess) ? null : jawabanSiswa;

      // if (isSuccess && isKumpulkanSemuaJawaban) {
      //   listSoal[cacheKey]?.forEach((soal) => soal.sudahDikumpulkan = true);
      //   // 2023-04-08 20:55:14
      //   // 2023-04-08 20:25:43
      //   // await _firebaseHelper.updateKumpulkanJawabanSiswa(
      //   //   tahunAjaran: tahunAjaran,
      //   //   noRegistrasi: noRegistrasi,
      //   //   idSekolahKelas: idSekolahKelas,
      //   //   tipeUser: tipeUser,
      //   //   isKumpulkan: true,
      //   //   onlyUpdateNull: false,
      //   //   kodePaket: kodePaket,
      //   // );

      //   // String paketKey = kodeTOB;

      // DateTime waktuMengumpulkan = await gGetServerTime();

      // for (var paketTO in listPaketTO) {
      //   if (paketTO.nomorUrut == urutan && paketTO.kodePaket == kodePaket) {
      //     int indexPaket = listPaketTO.indexWhere((paket) =>
      //         paket.nomorUrut == urutan && paket.kodePaket == kodePaket);

      //     if (indexPaket >= 0) {
      //       listPaketTO[indexPaket].isSelesai = true;
      //       listPaketTO[indexPaket].tanggalSiswaSubmit = waktuMengumpulkan;

      //       if (kDebugMode) {
      //         logger.log(
      //             'TOB_PROVIDER-UpdatePesertaTOPaket After Kumpulkan >> ${listPaketTO[indexPaket]}');
      //       }
      //     }
      //   }
      // }

      //   _listPaketTO.forEach((kodeTOB, daftarPaket) async {
      //     for (PaketTO paketTO in daftarPaket) {
      //       if (paketTO.kodePaket == kodePaket) {
      //         int indexPaket = _listPaketTO[kodeTOB]!.indexWhere((paket) =>
      //             paket.kodeTOB == kodeTOB && paket.kodePaket == kodePaket);

      //         if (indexPaket >= 0) {
      //           _listPaketTO[kodeTOB]![indexPaket].isSelesai = true;
      //           _listPaketTO[kodeTOB]![indexPaket].tanggalSiswaSubmit =
      //               waktuMengumpulkan;

      //           if (kDebugMode) {
      //             logger.log(
      //                 'TOB_PROVIDER-UpdatePesertaTOPaket After Kumpulkan >> ${_listPaketTO[kodeTOB]![indexPaket]}');
      //           }
      //         }
      //       }
      //     }
      //   });

      //   // if (_listPaketTO.containsKey(kodeTOB)) {
      //   //   DateTime waktuMengumpulkan = await gGetServerTime();

      //   //   _listPaketTO.forEach((kodeTOB, daftarPaket) async {
      //   //     for (PaketTO paketTO in daftarPaket) {
      //   //       if (paketTO.kodePaket == kodePaket) {
      //   //         int indexPaket = _listPaketTO[kodeTOB]!.indexWhere((paket) =>
      //   //             paket.kodeTOB == kodeTOB && paket.kodePaket == kodePaket);

      //   //         if (indexPaket >= 0) {
      //   //           _listPaketTO[kodeTOB]![indexPaket].isSelesai = true;
      //   //           _listPaketTO[kodeTOB]![indexPaket].tanggalSiswaSubmit =
      //   //               waktuMengumpulkan;

      //   //           if (kDebugMode) {
      //   //             logger.log(
      //   //                 'TOB_PROVIDER-UpdatePesertaTOPaket After Kumpulkan >> ${_listPaketTO[kodeTOB]![indexPaket]}');
      //   //           }
      //   //         }
      //   //       }
      //   //     }
      //   //   });
      //   // } else {
      //   //   // paketKey = '$idJenisProduk';
      //   //   int indexPaket = _listPaketTO['$idJenisProduk']!.indexWhere(
      //   //       (paket) =>
      //   //           paket.kodeTOB == kodeTOB && paket.kodePaket == kodePaket);

      //   //   if (indexPaket >= 0) {
      //   //     _listPaketTO['$idJenisProduk']![indexPaket].isSelesai = true;
      //   //     _listPaketTO['$idJenisProduk']![indexPaket].tanggalSiswaSubmit =
      //   //         await gGetServerTime();

      //   //     if (kDebugMode) {
      //   //       logger.log('TOB_PROVIDER-UpdatePesertaTOPaket After Kumpulkan '
      //   //           '>> ${_listPaketTO['$idJenisProduk']![indexPaket]}');
      //   //     }
      //   //   }
      //   // }

      //   await gShowTopFlash(gNavigatorKey.currentState!.context,
      //       'Yeey, Jawaban kamu berhasil dikumpulkan Sobat',
      //       dialogType: DialogType.success);
      // }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        logger.log('TOB-FatalException-SetTempJawaban: $e');
      }
      gShowTopFlash(
        gNavigatorKey.currentState!.context,
        kDebugMode ? e.toString() : gPesanError,
        dialogType: DialogType.error,
      );
    } finally {
      _loadingKoneksi = null;
      _timer?.cancel();
      _isLoadingSimpanJawaban = false;
      notifyListeners();
    }
  }

  // Future<void> submitJawabanSiswa({required int kodePaket}) async {
  //   try {
  //     final listDetailJawaban = HiveHelper.getListDetailJawaban(kodePaket);

  //     await _apiService.storeJawabanSiswa(
  //       jawabanSiswa: jawabanModel,
  //     );
  //   } on NoConnectionException catch (e) {
  //   } on DataException catch (e) {
  //   } catch (e) {}
  // }

  Future<List<DetailJawaban>> _getDetailJawabanSiswa({
    required String kodePaket,
    required String tahunAjaran,
    required String idSekolahKelas,
    String? noRegistrasi,
    String? tipeUser,
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
      //   kumpulkanSemua: true,
      // );
      final jawaban = [];
      final List<DetailJawaban> daftarJawaban =
          jawaban.map((json) => DetailJawaban.fromJson(json)).toList();
      return daftarJawaban;
    } else {
      // Penyimpanan untuk Teaser No User dan Ortu.
      return await _soalServiceLocal.getJawabanSiswaByKodePaket(
        kodePaket: kodePaket,
        kumpulkanSemua: true,
      );
    }
  }

  // Future<SyaratTOBK?> cekBolehTO({
  //   String? noRegistrasi,
  //   required String kodeTOB,
  //   required String namaTOB,
  // }) async {
  //   // if (_listKodeTOBMemenuhiSyarat.contains(kodeTOB)) {
  //   //   return getSyaratTOBByKodeTOB(kodeTOB);
  //   // }
  //   var completer = Completer();
  //   gNavigatorKey.currentState!.context
  //       .showBlockDialog(dismissCompleter: completer);

  //   bool isBolehTO = false;
  //   try {
  //     final response = await _apiService.cekBolehTO(
  //       noRegistrasi: noRegistrasi,
  //       kodeTOB: kodeTOB,
  //       namaTOB: namaTOB,
  //     );

  //     isBolehTO = response['status'];

  //     completer.complete();

  //     if (kDebugMode) {
  //       logger.log('TOB_PROVIDER-CekBolehTO: response >> $response');
  //     }

  //     if (response['data'] != null) {
  //       _listSyaratTOB[kodeTOB] = SyaratTOBK.fromJson(response['data']);
  //     }

  //     if (isBolehTO && !_listKodeTOBMemenuhiSyarat.contains(kodeTOB)) {
  //       _listKodeTOBMemenuhiSyarat.add(kodeTOB);
  //       await Future.delayed(const Duration(milliseconds: 300));
  //     }

  //     // if (!isBolehTO) {
  //     //   gShowBottomDialogInfo(
  //     //     gNavigatorKey.currentState!.context,
  //     //     title: 'Tidak bisa TryOut',
  //     //     message: response['message'],
  //     //   );
  //     // }

  //     return getSyaratTOBByKodeTOB(kodeTOB);
  //   } on NoConnectionException catch (e) {
  //     if (kDebugMode) {
  //       logger.log('NoConnectionException-CekBolehTO: $e');
  //     }
  //     completer.complete();
  //     await gShowTopFlash(
  //         gNavigatorKey.currentState!.context, gPesanErrorKoneksi);
  //     // notifyListeners();

  //     return getSyaratTOBByKodeTOB(kodeTOB);
  //   } on DataException catch (e) {
  //     if (kDebugMode) {
  //       logger.log('Exception-CekBolehTO: $e');
  //     }
  //     completer.complete();
  //     await gShowTopFlash(gNavigatorKey.currentState!.context, '$e');
  //     // notifyListeners();

  //     return getSyaratTOBByKodeTOB(kodeTOB);
  //   } catch (e) {
  //     if (kDebugMode) {
  //       logger.log('FatalException-CekBolehTO: ${e.toString()}');
  //     }
  //     completer.complete();
  //     await gShowTopFlash(gNavigatorKey.currentState!.context, e.toString());
  //     // notifyListeners();

  //     return getSyaratTOBByKodeTOB(kodeTOB);
  //   }
  // }

  // Future<void> getDaftarTOB({
  //   String? noRegistrasi,
  //   required String idSekolahKelas,
  //   required int idJenisProduk,
  //   String roleTeaser = 'No User',
  //   bool isProdukDibeli = false,
  //   bool isRefresh = false,
  // }) async {
  //   // Update serverTime
  //   // _serverTime = await gGetServerTime();
  //   // Jika tidak refresh dan data sudah ada di cache [_listTOB]
  //   // maka return List dari [_listTOB].
  //   if (!isRefresh && (_listTOB[idJenisProduk]?.isNotEmpty ?? false)) {
  //     // notifyListeners();
  //     return;
  //   }
  //   if (isRefresh) {
  //     _isLoadingTOB = true;
  //     notifyListeners();
  //     _listTOB[idJenisProduk]?.clear();
  //   }
  //   try {
  //     final responseData = await _apiService.fetchDaftarTOB(
  //         noRegistrasi: noRegistrasi,
  //         idSekolahKelas: idSekolahKelas,
  //         idJenisProduk: '$idJenisProduk',
  //         roleTeaser: roleTeaser,
  //         isProdukDibeli: isProdukDibeli);

  //     // Jika [_listTOB] tidak memiliki key idJenisProduk tertentu maka buat key valuenya dulu;
  //     if (!_listTOB.containsKey(idJenisProduk)) {
  //       _listTOB[idJenisProduk] = [];
  //     }
  //     // Cek apakah response data memiliki data atau tidak
  //     if (responseData.isNotEmpty) {
  //       for (Map<String, dynamic> dataTOB in responseData) {
  //         // Konversi dataTOB menjadi BundelSoalModel dan store ke cache [_listTOB]
  //         _listTOB[idJenisProduk]!.add(TobModel.fromJson(dataTOB));
  //       }
  //     }

  //     _isLoadingTOB = false;
  //     notifyListeners();
  //   } on NoConnectionException catch (e) {
  //     if (kDebugMode) {
  //       logger.log('NoConnectionException-GetDaftarTOB: $e');
  //     }
  //     _isLoadingTOB = false;
  //     notifyListeners();
  //   } on DataException catch (e) {
  //     if (kDebugMode) {
  //       logger.log('Exception-GetDaftarTOB: $e');
  //     }
  //     _isLoadingTOB = false;
  //     notifyListeners();
  //   } catch (e) {
  //     if (kDebugMode) {
  //       logger.log('FatalException-GetDaftarTOB: ${e.toString()}');
  //     }
  //     _isLoadingTOB = false;
  //     notifyListeners();
  //   }
  // }

  /// [kodeTOB] digunakan hanya untuk TOBK.
  /// Function ini untuk mengambil paket timer dari jenis produk manapun.
  // Future<void> getDaftarPaketTO({
  //   String? noRegistrasi,
  //   String? tahunAjaran,
  //   String? idSekolahKelas,
  //   String? kodeTOB,
  //   int? idJenisProduk,
  //   String? teaserRole,
  //   bool isProdukDibeli = false,
  //   bool isRefresh = false,
  // }) async {
  //   if (kDebugMode) {
  //     logger.log('TOB_PROVIDER-GetDaftarPaketTO: START');
  //   }
  //   // Update serverTime
  //   // _serverTime = await gGetServerTime();
  //   // Jika tidak refresh dan data sudah ada di cache [_listPaketTO]
  //   // maka return List dari [_listPaketTO].
  //   String cacheKey = kodeTOB ?? '$idJenisProduk';
  //   if (!isRefresh && (_listPaketTO[cacheKey]?.isNotEmpty ?? false)) {
  //     // notifyListeners();
  //     if (_isLoadingPaketTO) {
  //       _isLoadingPaketTO = false;
  //       await Future.delayed(const Duration(milliseconds: 300));
  //       notifyListeners();
  //     }
  //     return;
  //   }
  //   if (isRefresh) {
  //     _isLoadingPaketTO = true;
  //     _listPaketTO[cacheKey]?.clear();
  //     notifyListeners();
  //   }
  //   try {
  //     if (kDebugMode) {
  //       logger.log('TOB_PROVIDER-GetDaftarPaketTO: START');
  //     }
  //     final responseData = await _apiService.fetchDaftarPaketTO(
  //       kodeTOB: kodeTOB,
  //       noRegistrasi: noRegistrasi,
  //       idJenisProduk: '$idJenisProduk',
  //       idSekolahKelas: idSekolahKelas,
  //       isProdukDibeli: isProdukDibeli,
  //       teaserRole: teaserRole,
  //       isTryout: (idJenisProduk == null || idJenisProduk == 25),
  //     );

  //     if (kDebugMode) {
  //       logger.log('TOB_PROVIDER-GetDaftarPaketTO: data >> $responseData');
  //     }

  //     // Jika [_listPaketTO] tidak memiliki key kodeTOB tertentu maka buat key valuenya dulu.
  //     if (!_listPaketTO.containsKey(cacheKey)) {
  //       _listPaketTO[cacheKey] = [];
  //     }
  //     // Cek apakah response data memiliki data atau tidak
  //     if (responseData.isNotEmpty && _listPaketTO[cacheKey]!.isEmpty) {
  //       for (Map<String, dynamic> dataPaketTO in responseData) {
  //         // Jika Bukan GOA(12) dan Bukan Racing(80)
  //         if (idJenisProduk != 12 && idJenisProduk != 80) {
  //           // Lakukan Sync data antara db GO dengan firebase
  //           // PesertaTO? pesertaFirebase = (noRegistrasi != null)
  //           //     ? await _firebaseHelper.getPesertaTOByKodePaket(
  //           //         noRegistrasi: noRegistrasi,
  //           //         tipeUser: teaserRole ?? 'No-User',
  //           //         kodePaket: dataPaketTO['kodePaket'],
  //           //       )
  //           //     : null;
  //           PesertaTO? pesertaFirebase = null;
  //           // Jika di firebase exist, maka lakukan sync ke Object local
  //           if (pesertaFirebase != null) {
  //             dataPaketTO.update(
  //               'tanggalMulai',
  //               (value) => pesertaFirebase.kapanMulaiMengerjakan?.sqlFormat,
  //               ifAbsent: () =>
  //                   pesertaFirebase.kapanMulaiMengerjakan?.sqlFormat,
  //             );
  //             dataPaketTO.update(
  //               'tanggalDeadline',
  //               (value) => pesertaFirebase.deadlinePengerjaan?.sqlFormat,
  //               ifAbsent: () => pesertaFirebase.deadlinePengerjaan?.sqlFormat,
  //             );
  //             dataPaketTO.update(
  //               'tanggalMengumpulkan',
  //               (value) => pesertaFirebase.tanggalSiswaSubmit?.sqlFormat,
  //               ifAbsent: () => pesertaFirebase.tanggalSiswaSubmit?.sqlFormat,
  //             );
  //             dataPaketTO.update(
  //               'isSelesai',
  //               (value) => pesertaFirebase.isSelesai ? 'y' : 'n',
  //               ifAbsent: () => pesertaFirebase.isSelesai ? 'y' : 'n',
  //             );
  //             dataPaketTO.update(
  //               'isPernahMengerjakan',
  //               (value) => pesertaFirebase.isPernahMengerjakan ? 'y' : 'n',
  //               ifAbsent: () => pesertaFirebase.isPernahMengerjakan ? 'y' : 'n',
  //             );
  //             bool isWaktuHabis = false;
  //             DateTime now = DateTime.now().serverTimeFromOffset;

  //             if (pesertaFirebase.deadlinePengerjaan != null) {
  //               isWaktuHabis = now.isAfter(pesertaFirebase.deadlinePengerjaan!);
  //             }

  //             dataPaketTO.update(
  //               'waktuHabis',
  //               (value) => isWaktuHabis ? 'y' : 'n',
  //               ifAbsent: () => isWaktuHabis ? 'y' : 'n',
  //             );
  //           } else if (dataPaketTO['tanggalMulai'] != null &&
  //               dataPaketTO['tanggalMulai'] != '-' &&
  //               noRegistrasi != null) {
  //             Map<String, dynamic> jsonPeserta = {
  //               'cNoRegister': noRegistrasi,
  //               'cKodeSoal': dataPaketTO['kodePaket'],
  //               'cTanggalTO': dataPaketTO['tanggalMengumpulkan'],
  //               'cSudahSelesai': dataPaketTO['isSelesai'],
  //               'cOK': dataPaketTO['isPernahMengerjakan'],
  //               'cTglMulai': dataPaketTO['tanggalMulai'],
  //               'cTglSelesai': dataPaketTO['tanggalDeadline'],
  //               'cKeterangan': (dataPaketTO['cKeterangan'] != null)
  //                   ? jsonDecode(dataPaketTO['cKeterangan'])
  //                   : null,
  //               'cPersetujuan': 0,
  //               'cFlag': (dataPaketTO['cFlag'] is String)
  //                   ? int.tryParse('${dataPaketTO['cFlag']}') ?? 0
  //                   : 0,
  //               'cPilihanSiswa': (dataPaketTO['cPilihanSiswa'] != null)
  //                   ? jsonDecode(dataPaketTO['cPilihanSiswa'])
  //                   : null,
  //             };

  //             if (kDebugMode) {
  //               logger.log(
  //                   'TOB_PROVIDER-GetDaftarPaketTO: JsonPeserta >> $jsonPeserta');
  //             }

  //             // TODO: Lakukan sync data ke firebase jika ternyata data peserta pada db GO Exist tapi di firebase tidak.
  //             // await _firebaseHelper.setPesertaTOFirebase(
  //             //   noRegistrasi: noRegistrasi,
  //             //   tipeUser: teaserRole ?? 'No-User',
  //             //   kodePaket: dataPaketTO['kodePaket'],
  //             //   pesertaTO: PesertaTOModel.fromJson(jsonPeserta),
  //             // );
  //           }
  //         }
  //         // END OF SYNC FIREBASE

  //         // Konversi dataPaketTO menjadi BundelSoalModel dan store ke cache [_listPaketTO]
  //         _listPaketTO[cacheKey]!.add(PaketTOModel.fromJson(dataPaketTO));
  //       }
  //       //
  //     }

  //     if (idJenisProduk == 12 && noRegistrasi != null) {
  //       // TODO: Cek apakah benar mengambil laporan GOA dari last list
  //       await getLaporanGOA(
  //         noRegistrasi: noRegistrasi,
  //         kodePaket: _listPaketTO[cacheKey]!.first.kodePaket,
  //       );

  //       await Future.delayed(const Duration(milliseconds: 300));
  //     }

  //     if (kDebugMode) {
  //       logger.log(
  //           'TOB_PROVIDER-GetDaftarPaketTO: data in cache >> ${_listPaketTO[cacheKey]}');
  //     }

  //     _isLoadingLaporanGOA = false;
  //     _isLoadingPaketTO = false;
  //     notifyListeners();
  //   } on NoConnectionException catch (e) {
  //     if (kDebugMode) {
  //       logger.log('NoConnectionException-GetDaftarPaketTO: $e');
  //     }
  //     _isLoadingLaporanGOA = false;
  //     _isLoadingPaketTO = false;
  //     notifyListeners();
  //   } on DataException catch (e) {
  //     if (kDebugMode) {
  //       logger.log('Exception-GetDaftarPaketTO: $e');
  //     }
  //     _isLoadingLaporanGOA = false;
  //     _isLoadingPaketTO = false;
  //     notifyListeners();
  //   } catch (e) {
  //     if (kDebugMode) {
  //       logger.log('FatalException-GetDaftarPaketTO: ${e.toString()}');
  //     }
  //     _isLoadingLaporanGOA = false;
  //     _isLoadingPaketTO = false;
  //     notifyListeners();
  //   }
  // }

  Future<void> getKisiKisiPaket({
    required String kodePaket,
    required int idJenisProduk,
    bool isRefresh = false,
  }) async {
    try {
      if (!isRefresh && (_listKisiKisi[kodePaket]?.isNotEmpty ?? false)) {
        return;
      }
      if (isRefresh) {
        _listKisiKisi[kodePaket]?.clear();
      }

      final responseData = await _apiService.fetchKisiKisi(
        kodePaket: kodePaket,
        idJenisProduk: idJenisProduk,
      );

      if (kDebugMode) {
        logger.log(
            'TOB_PROVIDER-GetKisiKisiPaket: response data >> $responseData');
      }

      if (!_listKisiKisi.containsKey(kodePaket)) {
        _listKisiKisi[kodePaket] = [];
      }

      if (responseData.isNotEmpty && _listKisiKisi[kodePaket]!.isEmpty) {
        for (Map<String, dynamic> kisiKisi in responseData) {
          _listKisiKisi[kodePaket]!.add(KisiKisiModel.fromJson(kisiKisi));
        }
      }

      notifyListeners();
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-GetKisiKisiPaket: $e');
      }
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-GetKisiKisiPaket: $e');
      }
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-GetKisiKisiPaket: ${e.toString()}');
      }
    }
  }

  // Future<HasilGOA> getLaporanGOA({
  //   required String noRegistrasi,
  //   required String kodePaket,
  //   bool isRefresh = false,
  // }) async {
  //   try {
  //     if (!isRefresh && _laporanGOA[kodePaket] != null) {
  //       return getLaporanGOAByKodePaket(kodePaket);
  //     }
  //     if (isRefresh) {
  //       _isLoadingLaporanGOA = true;
  //       _laporanGOA.remove(kodePaket);
  //       notifyListeners();
  //       await Future.delayed(const Duration(milliseconds: 300));
  //     }

  //     // final responseData = await _apiService.fetchLaporanGOA(
  //     //   noRegistrasi: noRegistrasi,
  //     //   kodePaket: kodePaket,
  //     // );

  //     if (kDebugMode) {
  //       logger
  //           .log('TOB_PROVIDER-GetLaporanGOA: response data >> $responseData');
  //     }

  //     // Jika data tidak di temukan, maka responseData akan berbentuk int dengan value 0.
  //     if (responseData != 0 && !_laporanGOA.containsKey(kodePaket)) {
  //       _laporanGOA[kodePaket] = HasilGOAModel.fromJson(responseData);
  //     }

  //     if (kDebugMode) {
  //       logger.log(
  //           'TOB_PROVIDER-GetLaporanGOA: laporan GOA >> ${_laporanGOA[kodePaket]}');
  //     }

  //     _isLoadingLaporanGOA = false;
  //     notifyListeners();
  //     return getLaporanGOAByKodePaket(kodePaket);
  //   } on NoConnectionException catch (e) {
  //     if (kDebugMode) {
  //       logger.log('NoConnectionException-GetLaporanGOA: $e');
  //     }
  //     _isLoadingLaporanGOA = false;
  //     notifyListeners();
  //     return getLaporanGOAByKodePaket(kodePaket);
  //   } on DataException catch (e) {
  //     if (kDebugMode) {
  //       logger.log('Exception-GetLaporanGOA: $e');
  //     }
  //     _isLoadingLaporanGOA = false;
  //     notifyListeners();
  //     return getLaporanGOAByKodePaket(kodePaket);
  //   } catch (e) {
  //     if (kDebugMode) {
  //       logger.log('FatalException-GetLaporanGOA: ${e.toString()}');
  //     }
  //     _isLoadingLaporanGOA = false;
  //     notifyListeners();
  //     return getLaporanGOAByKodePaket(kodePaket);
  //   }
  // }

  // // Menghitung siswa waktu dan indexing nomor soal.
  // Future<void> _setIndexingSoalBlockingTime({
  //   required String kodePaket,
  //   required int totalWaktuSeharusnya,
  //   int? sisaWaktuResponse,
  // }) async {
  //   int waktuBerlalu = (totalWaktuSeharusnya * 60) - _sisaWaktu!.inSeconds;
  //   int sisaWaktuBundel = _sisaWaktu!.inSeconds;
  //
  //   if (kDebugMode) {
  //     logger.log('TOB_Provider-SetIndexingSoalBlockingTime: '
  //         'Waktu Berlalu >> $waktuBerlalu detik | '
  //         'Sisa Waktu Total ${_sisaWaktu!.inMinutes} menit');
  //   }
  //
  //   int indexMataUjiAktif = 0;
  //   if (sisaWaktuResponse != null && sisaWaktuResponse > 0) {
  //     for (var detail in _listDetailWaktu[kodePaket]!) {
  //       // Di kali 60 agar menjadi satuan detik.
  //       int waktuBundel = detail.waktuPengerjaan * 60;
  //       if (waktuBundel < waktuBerlalu) {
  //         // kurangi waktu temp
  //         waktuBerlalu -= waktuBundel;
  //
  //         if (indexMataUjiAktif < _listDetailWaktu[kodePaket]!.length - 1) {
  //           // Ubah ke mata uji selanjutnya.
  //           indexMataUjiAktif++;
  //         }
  //       }
  //     }
  //   }
  //   int waktuBundelAktif =
  //       _listDetailWaktu[kodePaket]![indexMataUjiAktif].waktuPengerjaan * 60;
  //
  //   if (waktuBerlalu < waktuBundelAktif) {
  //     // sisa waktu blocking time = waktuBundelAktif - sisa temp waktu.
  //     sisaWaktuBundel = waktuBundelAktif - waktuBerlalu;
  //   } else {
  //     sisaWaktuBundel = waktuBundelAktif;
  //   }
  //
  //   _indexCurrentMataUji = indexMataUjiAktif;
  //   indexSoal =
  //       _listDetailWaktu[kodePaket]![indexMataUjiAktif].indexSoalPertama;
  //   _sisaWaktu = Duration(seconds: sisaWaktuBundel);
  //   if (kDebugMode) {
  //     logger.log('TOB_Provider-SetIndexingSoalBlockingTime: '
  //         'Sisa Waktu >> $_sisaWaktu detik | '
  //         'index aktif >> $indexMataUjiAktif | $_indexCurrentMataUji');
  //   }
  // }

  Future<void> _setSisaWaktuFirebase({
    required String noRegistrasi,
    required String tipeUser,
    required String kodePaket,
    int totalWaktuSeharusnya = -1,
  }) async {
    // Get Peserta TO in Firebase
    // PesertaTO? pesertaFirebase = await _firebaseHelper.getPesertaTOByKodePaket(
    //   noRegistrasi: noRegistrasi,
    //   tipeUser: tipeUser,
    //   kodePaket: kodePaket,
    // );
    PesertaTO? pesertaFirebase = null;
    final now = DateTime.now().serverTimeFromOffset;
    if (pesertaFirebase == null) {
      // Siapkan Peserta TO baru,
      // final deadline = now.add(Duration(minutes: totalWaktuSeharusnya));
      // Map<String, dynamic> jsonPeserta = {
      //   'cNoRegister': noRegistrasi,
      //   'cKodeSoal': kodePaket,
      //   'cTanggalTO': null,
      //   'cSudahSelesai': 'n',
      //   'cOK': 'y',
      //   'cTglMulai': now.sqlFormat,
      //   'cTglSelesai': deadline.sqlFormat,
      //   'cKeterangan': null,
      //   'cPersetujuan': 0,
      //   'cFlag': 0,
      //   'cPilihanSiswa': null,
      // };
      // TODO: Lakukan sync data ke firebase jika ternyata data peserta pada db GO Exist tapi di firebase tidak.
      // await _firebaseHelper.setPesertaTOFirebase(
      //   noRegistrasi: noRegistrasi,
      //   tipeUser: tipeUser,
      //   kodePaket: kodePaket,
      //   pesertaTO: PesertaTOModel.fromJson(jsonPeserta),
      // );
      // totalWaktu merupakan waktu dari Object PaketTO, satuan menit.
      _sisaWaktu = Duration(minutes: totalWaktuSeharusnya);
    } else {
      // Jika Peserta TO Firebase Exist.
      // Hitung sisa wakti dari peserta TO firebase.
      bool belumBerakhir = now.isBefore(pesertaFirebase.deadlinePengerjaan!);

      if (belumBerakhir) {
        _sisaWaktu = pesertaFirebase.deadlinePengerjaan!.difference(now);
      } else {
        // Sekedar Formalitas, kondisi ini akan terpenuhi jika boleh melihat solusi.
        _sisaWaktu = Duration(minutes: totalWaktuSeharusnya);
      }
    }
  }

  /// [getDaftarSoalTO] merupakan function untuk mengambil list soal yang menggunakan timer.
  Future<void> getDaftarSoalTO({
    required String kodeTOB,
    required String kodePaket,
    required int idJenisProduk,
    required String namaJenisProduk,
    required String tahunAjaran,
    required String idSekolahKelas,
    String? noRegistrasi,
    String? tipeUser,
    bool isAwalMulai = true,
    required int totalWaktu,
    DateTime? tanggalSelesai,
    DateTime? tanggalSiswaSubmit,
    required DateTime tanggalKedaluwarsaTOB,
    required bool isBlockingTime,
    required bool isTOBBerakhir,
    required bool isRandom,
    required bool isRemedialGOA,
    bool isRefresh = false,
    int nomorSoalAwal = 1,
    required int urutan,
    List<int>? listIdBundleSoal,
    required List<PaketTO> listPaketTO,
    required bool isNextPaket,
    UserModel? userData,
  }) async {
    // Update serverTime
    await gSetServerTimeOffset();
    _serverTime = DateTime.now().serverTimeFromOffset;
    // Set _isBlockingTime
    _isBlockingTime = (isTOBBerakhir) ? false : isBlockingTime;
    // Set value indexSoal dan cacheKey pada soal_provider.dart
    cacheKey = '$kodeTOB-$kodePaket';
    indexSoal = (nomorSoalAwal > 0) ? nomorSoalAwal - 1 : 0;
    // Get laporan GOA
    final HasilGOA laporanGOA = getLaporanGOAByKodePaket(kodePaket);
    isRemedialGOA = laporanGOA.isRemedial;

    // untuk clear list ketika klik next paket to
    if (isNextPaket) {
      listSoal['$kodeTOB-$kodePaket']?.clear();
    }

    // Jika tidak refresh dan data sudah ada di cache [listSoal]
    // maka return List dari [listSoal].
    if (!isRefresh &&
        (listSoal['$kodeTOB-$kodePaket']?.isNotEmpty ?? false) &&
        (idJenisProduk != 12 && idJenisProduk != 80)) {
      if (noRegistrasi != null) {
        await _setSisaWaktuFirebase(
          noRegistrasi: noRegistrasi,
          tipeUser: tipeUser ?? 'No User',
          kodePaket: kodePaket,
          totalWaktuSeharusnya: totalWaktu,
        );

        // Jika baru membuka soal set mulai mengerjakan.
        // if (!isTOBBerakhir) {
        //   if (_isBlockingTime) {
        //     await _setIndexingSoalBlockingTime(
        //       kodePaket: kodePaket,
        //       sisaWaktuResponse: _sisaWaktu?.inSeconds ?? -1,
        //       totalWaktuSeharusnya: totalWaktu,
        //     );
        //   }
        // }
      }
      notifyListeners();
      // return getListDetailWaktuByKodePaket(kodePaket);
    }
    if (isRefresh && (idJenisProduk != 12 && idJenisProduk != 80)) {
      _isLoadingSoal = true;
      notifyListeners();
      listSoal[cacheKey]?.clear();
    } else if (!isRefresh && (idJenisProduk == 12 || idJenisProduk == 80)) {
      _isLoadingSoal = true;
      notifyListeners();
      listSoal[cacheKey]?.clear();
    } else {
      notifyListeners();
    }
    try {
      // Total waktu seharusnya akan di kirim ke parameter get soal karena
      // jika remedial GOA total waktunya akan berubah sesuai mata uji yang remedial.
      int totalWaktuSeharusnya = totalWaktu;
      // Mengambil detail waktu terlebih dahulu untuk keperluan Remedial GOA.
      final responseDetailWaktu = await _apiService.fetchDetailWaktu(
        kodePaket: kodePaket,
        idJenisProduk: idJenisProduk,
        userData: userData,
      );

      // Jika [_listDetailWaktu] tidak memiliki key kodePaket
      if (!_listDetailWaktu.containsKey(kodePaket)) {
        _listDetailWaktu[kodePaket] = [];
      }

      // if (isRemedialGOA &&
      //     tanggalSiswaSubmit != null &&
      //     (_listDetailWaktu[kodePaket]?.isNotEmpty ?? false)) {
      //   _listDetailWaktu[kodePaket]!.clear();
      // }

      if (responseDetailWaktu.isNotEmpty &&
          _listDetailWaktu[kodePaket]!.isEmpty) {
        int jumlahSoalTemp = 0;

        int indexSoalPertama = 0;
        int indexSoalTerakhir = 0;

        // if (isRemedialGOA) {
        //   // Menghapus detail waktu jika mata uji telah lulus saat remedial
        //   responseDetailWaktu.removeWhere(
        //     (detailWaktu) => laporanGOA.detailHasilGOA.any((detailHasil) {
        //       bool isLulus = detailHasil.namaKelompokUjian ==
        //               detailWaktu['c_namakelompokujian'] &&
        //           detailHasil.isLulus;
        //
        //       if (isLulus) {
        //         // Kurangi total waktu seharusnya dengan waktu mata uji yang sudah lulus.
        //         totalWaktuSeharusnya -=
        //             int.parse(detailWaktu['c_waktupengerjaan'].toString());
        //       }
        //
        //       if (kDebugMode) {
        //         logger.log(
        //             'TOB_PROVIDER-GetDaftarSoalTO: Total Waktu setelah pengurangan GOA lulus >> $totalWaktuSeharusnya'
        //             '\nMata Uji: ${detailWaktu['c_namakelompokujian']} (Lulus: $isLulus) | '
        //             '${detailWaktu['c_waktupengerjaan']}');
        //       }
        //       return isLulus;
        //     }),
        //   );
        //
        //   if (kDebugMode) {
        //     logger.log(
        //         'TOB_PROVIDER-GetDaftarSoalTO: detail waktu setelah pengurangan >> $responseDetailWaktu');
        //   }
        // }

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

        if (kDebugMode) {
          logger.log(
              'TOB_PROVIDER-GetDaftarSoalTO: Total Waktu Seharusnya >> $totalWaktuSeharusnya');
          logger.log(
              'TOB_PROVIDER-GetDaftarSoalTO: List Detail Waktu >> ${_listDetailWaktu[kodePaket]}');
        }
      }

      /// digunakan untuk memastikan siswa berada di urutan subtest yang benar
      /// dan menghindari bug lompat subtest
      if (isBlockingTime && !isLastSubtest(kodePaket) && !isTOBBerakhir) {
        final responseUrutanAktif = await _apiService.fetchUrutanAktif(
          idJenisProduk: idJenisProduk,
          noRegistrasi: noRegistrasi ?? '',
          kodePaket: kodePaket,
        );

        if (responseUrutanAktif != null) {
          urutan = responseUrutanAktif;
        }
      }

      final response = await _apiService.fetchDaftarSoalTO(
        noRegistrasi: noRegistrasi,
        kodeTOB: kodeTOB,
        isRemedialGOA: (idJenisProduk == 12) ? isRemedialGOA : false,
        kodePaket: kodePaket,
        jenisStart: isAwalMulai ? 'awal' : 'lanjutan',
        waktu: (idJenisProduk == 12) ? '$totalWaktuSeharusnya' : '$totalWaktu',
        tanggalSiswaSubmit: (tanggalSiswaSubmit != null)
            ? DataFormatter.dateTimeToString(tanggalSiswaSubmit)
            : null,
        tanggalSelesai: (tanggalSelesai != null)
            ? DataFormatter.dateTimeToString(tanggalSelesai)
            : null,
        tanggalKedaluwarsaTOB:
            DataFormatter.dateTimeToString(tanggalKedaluwarsaTOB),
        urutan: urutan,
        idJenisProduk: idJenisProduk,
        listIdBundleSoal: listIdBundleSoal,
      );

      // Get daftar soal
      List<dynamic> responseData = response['data'];

      if (isRemedialGOA) {
        // Menghapus daftar soal jika mata uji telah lulus saat remedial
        responseData.removeWhere(
          (detailSoal) => laporanGOA.detailHasilGOA.any((detailHasil) =>
              detailHasil.namaKelompokUjian ==
                  detailSoal['c_namakelompokujian'] &&
              detailHasil.isLulus),
        );
      }

      // TODO: Hitung sisa waktu dari firebase
      // Jika bukan Racing(80) dan GOA(12), hitung sisa waktu dari firebase.
      if ((idJenisProduk != 12 && idJenisProduk != 80) &&
          noRegistrasi != null) {
        await _setSisaWaktuFirebase(
          noRegistrasi: noRegistrasi,
          tipeUser: tipeUser ?? 'No User',
          kodePaket: kodePaket,
          totalWaktuSeharusnya: totalWaktuSeharusnya,
        ).then((value) {
          response.update(
            'sisaWaktu',
            (value) => _sisaWaktu!.inSeconds,
            ifAbsent: () => _sisaWaktu!.inSeconds,
          );
        });
      }

      // Response['sisaWaktu] dalam satuan detik. Lakukan jika bukan TOBK
      if (response['sisaWaktu'] != null &&
          (idJenisProduk == 12 || idJenisProduk == 80)) {
        if (response['sisaWaktu'] < 0) {
          // totalWaktu merupakan waktu dari Object PaketTO, satuan menit.
          _sisaWaktu = Duration(minutes: totalWaktuSeharusnya);
        } else {
          _sisaWaktu = Duration(seconds: response['sisaWaktu']);
        }
      }

      if (kDebugMode) {
        logger.log(
            'TOB_Provider-GetDaftarSoalTO: Sisa Waktu Awal >> $_sisaWaktu | '
            'from response ${response['sisaWaktu']} detik | '
            'total waktu sebenarnya $totalWaktuSeharusnya Menit');
      }

      // Mengambil jawaban siswa yang ada di firebase.
      // Jika belum login atau Akun Ortu maka akan mengambil jawaban dari Hive.
      final List<DetailJawaban> jawabanFirebase = await _getDetailJawabanSiswa(
          kodePaket: kodePaket,
          tahunAjaran: tahunAjaran,
          idSekolahKelas: idSekolahKelas,
          noRegistrasi: noRegistrasi,
          tipeUser: tipeUser);

      if (kDebugMode) {
        logger.log(
            'TOB_PROVIDER-GetDaftarSoalTO: Params >> RemedialGOA($isRemedialGOA) Random($isRandom), blockingTime($isBlockingTime), TOBBerakhir($isTOBBerakhir)');
        logger
            .log('TOB_PROVIDER-GetDaftarSoalTO: responseData >> $responseData');
        logger.log(
            'TOB_PROVIDER-GetDaftarSoalTO: jawabanFirebase >> $jawabanFirebase');
      }

      // Jika [listSoal] tidak memiliki key idBundel tertentu maka buat key valuenya dulu.
      if (!listSoal.containsKey(cacheKey)) {
        listSoal[cacheKey!] = [];
      }

      // Cek apakah response data memiliki data atau tidak
      if (responseData.isNotEmpty && listSoal[cacheKey]!.isEmpty) {
        int nomorSoalSiswa = 1;

        if (isRandom && (jawabanFirebase.isEmpty || idJenisProduk == 12)) {
          var foldedData =
              responseData.fold<Map<String, List>>({}, (prev, dataSoal) {
            prev
                .putIfAbsent(dataSoal['nama_kelompok_ujian'], () => [])
                .add(dataSoal);
            return prev;
          });

          responseData.clear();
          if (laporanGOA is! BelumMengerjakanGOA) {
            foldedData.removeWhere(
              (key, value) => laporanGOA.detailHasilGOA
                  .where((detailHasil) => detailHasil.namaKelompokUjian == key)
                  .any((detailHasil) => !detailHasil.isLulus),
            );
          }
          foldedData.forEach((key, value) {
            logger.log('TOB_PROVIDER-TryFold: Each Result $key >> $value');
            // Acak untuk random soal
            value.shuffle();
            value.shuffle();
            value.shuffle();
            responseData.addAll(value);
            logger.log(
                'TOB_PROVIDER-TryFold: Each Result $key Shuffle >> $value');
          });
        }

        for (Map<String, dynamic> dataSoal in responseData) {
          // Mengambil jawaban firebase berdasarkan id soal.
          // FirstWhere dan SingleWhere throw error jika tidak ada yang cocok, sehingga merusak UI.
          // final List<DetailJawaban> detailJawabanSiswa = jawabanFirebase
          //     .where((jawaban) => jawaban.idSoal == dataSoal['c_idsoal'])
          //     .toList();

          // if (kDebugMode) {
          //   logger.log(
          //       'TOB_PROVIDER-GetDaftarSoalTO: Detail Jawaban >> ${detailJawabanSiswa.first}');
          //   logger.log(
          //       'TOB_PROVIDER-GetDaftarSoalTO: Additional json >> ${detailJawabanSiswa.first.additionalJsonSoal()}');
          // }
          // Menambahkan informasi json SoalModel
          // if (detailJawabanSiswa.isNotEmpty) {
          //   dataSoal.addAll(detailJawabanSiswa.first.additionalJsonSoal());
          // }
          // Menambahkan nomor soal jika data nomor soal tidak ada dari firebase.
          if (!dataSoal.containsKey('nomor_soal') ||
              dataSoal['nomor_soal'] == 0) {
            dataSoal['nomor_soal'] = nomorSoalSiswa;
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
          if (kDebugMode) {
            logger.log(
                'TOB_PROVIDER-GetDaftarSoalTO: Kunci Jawaban >> ${dataSoal['kunciJawaban']}');
            logger.log(
                'TOB_PROVIDER-GetDaftarSoalTO: Translator >> ${dataSoal['translatorEPB']}');
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

          // Konversi dataSoal menjadi SoalModel dan store ke cache [listSoal]
          listSoal[cacheKey]!.add(SoalModel.fromJson(dataSoal));
          nomorSoalSiswa++;
        }

        // to random soal
        if (listSoal[cacheKey]?.isNotEmpty == true && isRandom) {
          final lastNoRegistrasiNumber = noRegistrasi?.substring(
              noRegistrasi.length - 1, noRegistrasi.length);
          int seed = int.parse(lastNoRegistrasiNumber ?? '0');
          final random = Random(seed);

          listSoal[cacheKey]?.shuffle(random);
        }

        if (response['waktuPengerjaan'] is int) {
          waktuPengerjaan = Duration(
            seconds: response['waktuPengerjaan'] * 60,
          );
        } else if (response['waktuPengerjaan'] is double) {
          waktuPengerjaan = Duration(
              seconds:
                  ((response['waktuPengerjaan'] as double) * 60.0).toInt());
        }
        // Jika baru membuka soal set mulai mengerjakan.
        if (!isTOBBerakhir) {
          bool baruMulai = isRemedialGOA
              ? tanggalSiswaSubmit != null
              : tanggalSelesai == null;

          if (kDebugMode) {
            logger
                .log('TOB_Provider-GetDaftarSoalTO: Baru mulai >> $baruMulai');
          }

          if (baruMulai) {
            _setMulaiTO(
                kodeTOB: kodeTOB,
                kodePaket: kodePaket,
                idJenisProduk: idJenisProduk,
                totalWaktuSeharusnya: totalWaktuSeharusnya,
                listPaketTO: listPaketTO);
          }

          if (_isBlockingTime) {
            // waktuPengerjaan = Duration(
            //   seconds: ((response['waktuPengerjaan'] as double) * 60.0).toInt(),
            // );
            // await _setIndexingSoalBlockingTime(
            //   kodePaket: kodePaket,
            //   sisaWaktuResponse: response['sisaWaktu'],
            //   totalWaktuSeharusnya: totalWaktuSeharusnya,
            // );
          }
        }
        if (kDebugMode) {
          logger.log('TOB_Provider-GetDaftarSoalTO: '
              'Sisa Waktu >> $_sisaWaktu detik | '
              'Index aktif >> $_indexCurrentMataUji');
        }
      } else {
        await gShowTopFlash(
            gNavigatorKey.currentState!.context, errorGagalMenyiapkanSoal,
            dialogType: DialogType.error, duration: const Duration(seconds: 2));
        Navigator.of(gNavigatorKey.currentState!.context).pop();
      }

      // Jika jawaban dari firebase masih kosong dan TOB masih berlangsung,
      // maka store jawaban sementara ke firebase.
      // if (jawabanFirebase.isEmpty &&
      //     serverTime.isBefore(tanggalKedaluwarsaTOB)) {
      //   if (kDebugMode) {
      //     logger.log(
      //         'TOB_Provider-GetDaftarSoalTO: Cache Key $cacheKey | $kodeTOB-$kodePaket');
      //     logger.log(
      //         'TOB_Provider-GetDaftarSoalTO: Set Seluruh Jawaban Ke Firestore\n'
      //         'Daftar Soal >> ${listSoal[cacheKey]}');
      //   }
      //   int jumlahSoal = 0;
      //   // ignore: unused_local_variable
      //   for (var soal in listSoal[cacheKey]!) {
      //     await setTempJawaban(
      //         soalTemp: soal,
      //         idSekolahKelas: idSekolahKelas,
      //         tahunAjaran: tahunAjaran,
      //         jenisProduk: namaJenisProduk,
      //         tipeUser: tipeUser,
      //         kodePaket: soal.kodePaket ?? kodePaket,
      //         jawabanSiswa: null,
      //         noRegistrasi: noRegistrasi,
      //         jawabanModel: ,);
      //     jumlahSoal++;
      //   }

      //   if (kDebugMode) {
      //     logger.log(
      //         'TOB_Provider-GetDaftarSoalTO: Selesai Set Seluruh Jawaban ($jumlahSoal Soal)');
      //   }
      // }

      if (kDebugMode) {
        logger.log(
            'TOB_PROVIDER-GetDaftarSoalTO: list soal >> ${listSoal[cacheKey]}');
      }

      _isLoadingSoal = false;
      indexPaket = urutan;
      notifyListeners();
      // return getListDetailWaktuByKodePaket(kodePaket);
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-GetDaftarSoalTO: $e');
      }
      await gShowTopFlash(gNavigatorKey.currentState!.context,
          'Koneksi internet Sobat tidak stabil, coba lagi!');
      _isLoadingSoal = false;
      Navigator.of(gNavigatorKey.currentState!.context).pop();
      notifyListeners();
      // return getListDetailWaktuByKodePaket(kodePaket);
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-GetDaftarSoalTO: $e');
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
      // return getListDetailWaktuByKodePaket(kodePaket);
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-GetDaftarSoalTO: ${e.toString()}');
      }
      await gShowTopFlash(
          gNavigatorKey.currentState!.context, errorGagalMenyiapkanSoal,
          dialogType: DialogType.error, duration: const Duration(seconds: 2));
      _isLoadingSoal = false;
      Navigator.of(gNavigatorKey.currentState!.context).pop();
      notifyListeners();
      // return getListDetailWaktuByKodePaket(kodePaket);
    }
  }

  // Hanya digunakan untuk soal timer selain GOA
  Future<bool> updatePesertaTO(
      {required String tahunAjaran,
      required String idSekolahKelas,
      required String tingkatKelas,
      String? noRegistrasi,
      String? tipeUser,
      required int idJenisProduk,
      required String namaJenisProduk,
      required String kodeTOB,
      required String kodePaket,
      required List<PaketTO> listPaketTO,
      required List<KampusImpian> listKampusImpian}) async {
    try {
      // Untuk men-trigger perubahan pada list paket UI
      _isLoadingPaketTO = true;
      notifyListeners();

      if (noRegistrasi != null && tipeUser != null && tipeUser != 'ORTU') {
        // Update peserta TO di server,
        // Jika berhasil save ke server, baru save ke firebase.
        final bool isBerhasilUpdate =
            (idJenisProduk == 12 || idJenisProduk == 80)
                ? await _apiService.updatePesertaTO(
                    noRegistrasi: noRegistrasi,
                    kodePaket: kodePaket,
                    tahunAjaran: tahunAjaran,
                    idJenisProduk: idJenisProduk,
                    kodeTOB: kodeTOB,
                    listKampusImpian: listKampusImpian,
                  )
                : true;
        // : await _firebaseHelper.updatePesertaTOFirebase(
        //     tipeUser: tipeUser,
        //     noRegistrasi: noRegistrasi,
        //     kodePaket: kodePaket,
        //     idJenisProduk: idJenisProduk,
        //     kodeTOB: kodeTOB,
        //   );

        if (isBerhasilUpdate) {
          listSoal[cacheKey]?.forEach((soal) => soal.sudahDikumpulkan = true);
          // 2023-04-08 20:55:14
          // 2023-04-08 20:25:43
          // await _firebaseHelper.updateKumpulkanJawabanSiswa(
          //   tahunAjaran: tahunAjaran,
          //   noRegistrasi: noRegistrasi,
          //   idSekolahKelas: idSekolahKelas,
          //   tipeUser: tipeUser,
          //   isKumpulkan: true,
          //   onlyUpdateNull: false,
          //   kodePaket: kodePaket,
          // );

          // String paketKey = kodeTOB;

          DateTime waktuMengumpulkan = await gGetServerTime();

          for (var paketTO in listPaketTO) {
            if (paketTO.kodePaket == kodePaket) {
              int indexPaket = listPaketTO
                  .indexWhere((paket) => paket.kodePaket == kodePaket);

              if (indexPaket >= 0) {
                listPaketTO[indexPaket].isSelesai = true;
                listPaketTO[indexPaket].tanggalSiswaSubmit = waktuMengumpulkan;

                if (kDebugMode) {
                  logger.log(
                      'TOB_PROVIDER-UpdatePesertaTOPaket After Kumpulkan >> ${listPaketTO[indexPaket]}');
                }
              }
            }
          }

          _listPaketTO.forEach((kodeTOB, daftarPaket) async {
            for (PaketTO paketTO in daftarPaket) {
              if (paketTO.kodePaket == kodePaket) {
                int indexPaket = _listPaketTO[kodeTOB]!.indexWhere((paket) =>
                    paket.kodeTOB == kodeTOB && paket.kodePaket == kodePaket);

                if (indexPaket >= 0) {
                  _listPaketTO[kodeTOB]![indexPaket].isSelesai = true;
                  _listPaketTO[kodeTOB]![indexPaket].tanggalSiswaSubmit =
                      waktuMengumpulkan;

                  if (kDebugMode) {
                    logger.log(
                        'TOB_PROVIDER-UpdatePesertaTOPaket After Kumpulkan >> ${_listPaketTO[kodeTOB]![indexPaket]}');
                  }
                }
              }
            }
          });

          // if (_listPaketTO.containsKey(kodeTOB)) {
          //   DateTime waktuMengumpulkan = await gGetServerTime();

          //   _listPaketTO.forEach((kodeTOB, daftarPaket) async {
          //     for (PaketTO paketTO in daftarPaket) {
          //       if (paketTO.kodePaket == kodePaket) {
          //         int indexPaket = _listPaketTO[kodeTOB]!.indexWhere((paket) =>
          //             paket.kodeTOB == kodeTOB && paket.kodePaket == kodePaket);

          //         if (indexPaket >= 0) {
          //           _listPaketTO[kodeTOB]![indexPaket].isSelesai = true;
          //           _listPaketTO[kodeTOB]![indexPaket].tanggalSiswaSubmit =
          //               waktuMengumpulkan;

          //           if (kDebugMode) {
          //             logger.log(
          //                 'TOB_PROVIDER-UpdatePesertaTOPaket After Kumpulkan >> ${_listPaketTO[kodeTOB]![indexPaket]}');
          //           }
          //         }
          //       }
          //     }
          //   });
          // } else {
          //   // paketKey = '$idJenisProduk';
          //   int indexPaket = _listPaketTO['$idJenisProduk']!.indexWhere(
          //       (paket) =>
          //           paket.kodeTOB == kodeTOB && paket.kodePaket == kodePaket);

          //   if (indexPaket >= 0) {
          //     _listPaketTO['$idJenisProduk']![indexPaket].isSelesai = true;
          //     _listPaketTO['$idJenisProduk']![indexPaket].tanggalSiswaSubmit =
          //         await gGetServerTime();

          //     if (kDebugMode) {
          //       logger.log('TOB_PROVIDER-UpdatePesertaTOPaket After Kumpulkan '
          //           '>> ${_listPaketTO['$idJenisProduk']![indexPaket]}');
          //     }
          //   }
          // }

          await gShowTopFlash(gNavigatorKey.currentState!.context,
              'Yeey, Jawaban kamu berhasil dikumpulkan Sobat',
              dialogType: DialogType.success);
        } else {
          // Deadline di ubah agar perhitungan sisawaktu berubah.
          DateTime deadlineBaru = DateTime.now().serverTimeFromOffset;
          if (_listPaketTO.containsKey(kodeTOB)) {
            _listPaketTO.forEach((kodeTOB, daftarPaket) async {
              for (PaketTO paketTO in daftarPaket) {
                if (paketTO.kodePaket == kodePaket) {
                  int indexPaket = _listPaketTO[kodeTOB]!.indexWhere((paket) =>
                      paket.kodeTOB == kodeTOB && paket.kodePaket == kodePaket);

                  if (indexPaket >= 0) {
                    _listPaketTO[kodeTOB]![indexPaket].deadlinePengerjaan =
                        deadlineBaru;

                    if (kDebugMode) {
                      logger.log('TOB_PROVIDER-UpdatePesertaTO: Paket '
                          'Gagal Kumpulkan >> ${_listPaketTO[kodeTOB]![indexPaket]}');
                    }
                  }
                }
              }
            });
          } else {
            // paketKey = '$idJenisProduk';
            int indexPaket = _listPaketTO['$idJenisProduk']!.indexWhere(
                (paket) =>
                    paket.kodeTOB == kodeTOB && paket.kodePaket == kodePaket);

            if (indexPaket >= 0) {
              _listPaketTO['$idJenisProduk']![indexPaket].deadlinePengerjaan =
                  deadlineBaru;

              if (kDebugMode) {
                logger.log('TOB_PROVIDER-UpdatePesertaTO: Paket '
                    'Gagal Kumpulkan >> ${_listPaketTO['$idJenisProduk']![indexPaket]}');
              }
            }
          }

          await gShowTopFlash(
            gNavigatorKey.currentState!.context,
            errorGagalMenyimpanJawaban,
            dialogType: DialogType.error,
            duration: const Duration(seconds: 6),
          );
          _isLoadingPaketTO = false;
          notifyListeners();
          return false;
        }

        _isLoadingPaketTO = false;
        notifyListeners();
        return isBerhasilUpdate;
      } else {
        final bool isBerhasilSimpan =
            await _soalServiceLocal.updateKumpulkanJawabanSiswa(
          isKumpulkan: true,
          onlyUpdateNull: false,
          kodePaket: kodePaket,
        );

        if (isBerhasilSimpan) {
          listSoal[cacheKey]?.forEach((soal) => soal.sudahDikumpulkan = true);

          if (_listPaketTO.containsKey(kodeTOB)) {
            DateTime waktuMengumpulkan = await gGetServerTime();

            _listPaketTO.forEach((kodeTOB, daftarPaket) async {
              for (PaketTO paketTO in daftarPaket) {
                if (paketTO.kodePaket == kodePaket) {
                  int indexPaket = _listPaketTO[kodeTOB]!.indexWhere((paket) =>
                      paket.kodeTOB == kodeTOB && paket.kodePaket == kodePaket);

                  if (indexPaket >= 0) {
                    _listPaketTO[kodeTOB]![indexPaket].isSelesai = true;
                    _listPaketTO[kodeTOB]![indexPaket].tanggalSiswaSubmit =
                        waktuMengumpulkan;

                    if (kDebugMode) {
                      logger.log(
                          'TOB_PROVIDER-KumpulkanJawabanSiswa: Paket After Kumpulkan '
                          '>> ${_listPaketTO[kodeTOB]![indexPaket]}');
                    }
                  }
                }
              }
            });
          } else {
            int indexPaket = _listPaketTO['$idJenisProduk']!.indexWhere(
                (paket) =>
                    paket.kodeTOB == kodeTOB && paket.kodePaket == kodePaket);

            if (indexPaket >= 0) {
              _listPaketTO['$idJenisProduk']![indexPaket].isSelesai = true;
              _listPaketTO['$idJenisProduk']![indexPaket].tanggalSiswaSubmit =
                  await gGetServerTime();

              if (kDebugMode) {
                logger.log(
                    'TOB_PROVIDER-KumpulkanJawabanSiswa: Paket After Kumpulkan '
                    '>> ${_listPaketTO['$idJenisProduk']![indexPaket]}');
              }
            }
          }

          await gShowTopFlash(gNavigatorKey.currentState!.context,
              'Yeey, Jawaban kamu berhasil dikumpulkan Sobat',
              dialogType: DialogType.success);
        } else {
          await gShowTopFlash(gNavigatorKey.currentState!.context,
              'Gagal menyimpan jawaban Sobat, coba lagi!',
              dialogType: DialogType.error);
        }
      }
      _isLoadingPaketTO = false;
      notifyListeners();
      return true;
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-UpdatePesertaTO: $e');
      }
      await gShowTopFlash(gNavigatorKey.currentState!.context,
          'Koneksi internet Sobat tidak stabil, coba lagi!',
          dialogType: DialogType.error);
      _isLoadingPaketTO = false;
      notifyListeners();
      return false;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-UpdatePesertaTO: $e');
      }
      await gShowTopFlash(
        gNavigatorKey.currentState!.context,
        errorGagalMenyimpanJawaban,
        dialogType: DialogType.error,
        duration: const Duration(seconds: 6),
      );
      _isLoadingPaketTO = false;
      notifyListeners();
      return false;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-UpdatePesertaTO: ${e.toString()}');
      }
      await gShowTopFlash(
        gNavigatorKey.currentState!.context,
        errorGagalMenyimpanJawaban,
        dialogType: DialogType.error,
        duration: const Duration(seconds: 6),
      );
      _isLoadingPaketTO = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> kumpulkanJawabanGOA(
      {required String tahunAjaran,
      required String idSekolahKelas,
      required String tingkatKelas,
      String? noRegistrasi,
      String? tipeUser,
      required String idKota,
      required String idGedung,
      required int idJenisProduk,
      required String namaJenisProduk,
      required String kodeTOB,
      required String kodePaket,
      required List<KampusImpian> listKampusImpian}) async {
    try {
      // Untuk men-trigger perubahan pada list paket UI
      _isLoadingPaketTO = true;
      notifyListeners();

      final List<DetailJawaban> daftarDetailJawaban =
          await _getDetailJawabanSiswa(
        kodePaket: kodePaket,
        tahunAjaran: tahunAjaran,
        idSekolahKelas: idSekolahKelas,
        noRegistrasi: noRegistrasi,
        tipeUser: tipeUser,
      );

      if (kDebugMode) {
        logger.log(
            'TOB_Provider-KumpulkanJawabanTO: Detail Jawaban Firebase >> $daftarDetailJawaban');
      }

      if (noRegistrasi != null && tipeUser != null && tipeUser != 'ORTU') {
        // Kumpulkan / Simpan jawaban di server,
        // jika berhasil save ke server, baru save ke firebase.
        final bool isBerhasilSimpan = await _apiService.simpanJawabanTO(
          tahunAjaran: tahunAjaran,
          noRegistrasi: noRegistrasi,
          tipeUser: tipeUser,
          idKota: idKota,
          idGedung: idGedung,
          idSekolahKelas: idSekolahKelas,
          tingkatKelas: tingkatKelas,
          idJenisProduk: idJenisProduk,
          kodeTOB: kodeTOB,
          kodePaket: kodePaket,
          detailJawaban: daftarDetailJawaban
              .map<Map<String, dynamic>>(
                  (detailJawaban) => detailJawaban.toJson())
              .toList(),
          listKampusImpian: listKampusImpian,
        );

        if (isBerhasilSimpan) {
          listSoal[cacheKey]?.forEach((soal) => soal.sudahDikumpulkan = true);

          // await _firebaseHelper.updateKumpulkanJawabanSiswa(
          //   tahunAjaran: tahunAjaran,
          //   noRegistrasi: noRegistrasi,
          //   idSekolahKelas: idSekolahKelas,
          //   tipeUser: tipeUser,
          //   isKumpulkan: true,
          //   onlyUpdateNull: false,
          //   kodePaket: kodePaket,
          // );

          String paketKey = kodeTOB;
          if (_listPaketTO.containsKey(kodeTOB)) {
            DateTime waktuMengumpulkan = await gGetServerTime();

            _listPaketTO.forEach((kodeTOB, daftarPaket) async {
              for (PaketTO paketTO in daftarPaket) {
                if (paketTO.kodePaket == kodePaket) {
                  int indexPaket = _listPaketTO[kodeTOB]!.indexWhere((paket) =>
                      paket.kodeTOB == kodeTOB && paket.kodePaket == kodePaket);

                  if (indexPaket >= 0) {
                    _listPaketTO[kodeTOB]![indexPaket].isSelesai = true;
                    _listPaketTO[kodeTOB]![indexPaket].tanggalSiswaSubmit =
                        waktuMengumpulkan;

                    if (kDebugMode) {
                      logger.log(
                          'TOB_PROVIDER-KumpulkanJawabanTO: Paket After Kumpulkan >> ${_listPaketTO[kodeTOB]![indexPaket]}');
                    }
                  }
                }
              }
            });
          } else {
            paketKey = '$idJenisProduk';
            int indexPaket = _listPaketTO['$idJenisProduk']!.indexWhere(
                (paket) =>
                    paket.kodeTOB == kodeTOB && paket.kodePaket == kodePaket);

            if (indexPaket >= 0) {
              _listPaketTO['$idJenisProduk']![indexPaket].isSelesai = true;
              _listPaketTO['$idJenisProduk']![indexPaket].tanggalSiswaSubmit =
                  await gGetServerTime();

              if (kDebugMode) {
                logger.log(
                    'TOB_PROVIDER-KumpulkanJawabanTO: Paket After Kumpulkan '
                    '>> ${_listPaketTO['$idJenisProduk']![indexPaket]}');
              }
            }
          }

          // If ini adalah GOA
          if (idJenisProduk == 12) {
            // TODO: Cek apakah benar mengambil laporan GOA dari last list
            // await getLaporanGOA(
            //   noRegistrasi: noRegistrasi,
            //   kodePaket: _listPaketTO[paketKey]!.last.kodePaket,
            //   isRefresh: true,
            // );

            // Get laporan GOA
            final HasilGOA laporanGOA = getLaporanGOAByKodePaket(
                _listPaketTO[paketKey]!.last.kodePaket);

            logger.log(
                'Laporan GOA >> isBelumMengerjakan ${laporanGOA is BelumMengerjakanGOA}');

            // Jika laporanGOA exist dan paket GOA tanggal submit-nya tidak null
            // maka reset jawaban yang remedial. Tanggal Submit akan di reset saat get soal remedial.
            if (laporanGOA is! BelumMengerjakanGOA && laporanGOA.isRemedial) {
              for (var detailHasil in laporanGOA.detailHasilGOA) {
                if (!detailHasil.isLulus) {
                  // TODO: reset jawaban firebase
                  // await _firebaseHelper.resetRemedialGOA(
                  //   tahunAjaran: tahunAjaran,
                  //   noRegistrasi: noRegistrasi,
                  //   idSekolahKelas: idSekolahKelas,
                  //   tipeUser: tipeUser,
                  //   kodePaket: _listPaketTO[paketKey]!.last.kodePaket,
                  //   namaKelompokUjian: detailHasil.namaKelompokUjian,
                  // );
                }
              }

              // Jika remedial remove soal yang sudah lulus.
              if (laporanGOA.isRemedial &&
                  (listSoal['$kodeTOB-$kodePaket']?.isNotEmpty ?? false)) {
                // Menghapus daftar soal jika mata uji telah lulus saat remedial
                listSoal['$kodeTOB-$kodePaket']!.clear();
              }
            }
            await Future.delayed(const Duration(milliseconds: 300));
          }

          await gShowTopFlash(gNavigatorKey.currentState!.context,
              'Yeey, Jawaban kamu berhasil dikumpulkan Sobat',
              dialogType: DialogType.success);
        } else {
          // Deadline di ubah agar perhitungan sisawaktu berubah.
          DateTime deadlineBaru = DateTime.now().serverTimeFromOffset;
          if (_listPaketTO.containsKey(kodeTOB)) {
            _listPaketTO.forEach((kodeTOB, daftarPaket) async {
              for (PaketTO paketTO in daftarPaket) {
                if (paketTO.kodePaket == kodePaket) {
                  int indexPaket = _listPaketTO[kodeTOB]!.indexWhere((paket) =>
                      paket.kodeTOB == kodeTOB && paket.kodePaket == kodePaket);

                  if (indexPaket >= 0) {
                    _listPaketTO[kodeTOB]![indexPaket].deadlinePengerjaan =
                        deadlineBaru;

                    if (kDebugMode) {
                      logger.log('TOB_PROVIDER-KumpulkanJawabanTO: Paket '
                          'Gagal Kumpulkan >> ${_listPaketTO[kodeTOB]![indexPaket]}');
                    }
                  }
                }
              }
            });
          } else {
            // paketKey = '$idJenisProduk';
            int indexPaket = _listPaketTO['$idJenisProduk']!.indexWhere(
                (paket) =>
                    paket.kodeTOB == kodeTOB && paket.kodePaket == kodePaket);

            if (indexPaket >= 0) {
              _listPaketTO['$idJenisProduk']![indexPaket].deadlinePengerjaan =
                  deadlineBaru;

              if (kDebugMode) {
                logger.log('TOB_PROVIDER-KumpulkanJawabanTO: Paket '
                    'Gagal Kumpulkan >> ${_listPaketTO['$idJenisProduk']![indexPaket]}');
              }
            }
          }

          await gShowTopFlash(
            gNavigatorKey.currentState!.context,
            errorGagalMenyimpanJawaban,
            dialogType: DialogType.error,
            duration: const Duration(seconds: 6),
          );
          _isLoadingPaketTO = false;
          notifyListeners();
          return false;
        }

        _isLoadingPaketTO = false;
        notifyListeners();
        return isBerhasilSimpan;
      } else {
        final bool isBerhasilSimpan =
            await _soalServiceLocal.updateKumpulkanJawabanSiswa(
          isKumpulkan: true,
          onlyUpdateNull: false,
          kodePaket: kodePaket,
        );

        if (isBerhasilSimpan) {
          listSoal[cacheKey]?.forEach((soal) => soal.sudahDikumpulkan = true);

          if (_listPaketTO.containsKey(kodeTOB)) {
            DateTime waktuMengumpulkan = await gGetServerTime();

            _listPaketTO.forEach((kodeTOB, daftarPaket) async {
              for (PaketTO paketTO in daftarPaket) {
                if (paketTO.kodePaket == kodePaket) {
                  int indexPaket = _listPaketTO[kodeTOB]!.indexWhere((paket) =>
                      paket.kodeTOB == kodeTOB && paket.kodePaket == kodePaket);

                  if (indexPaket >= 0) {
                    _listPaketTO[kodeTOB]![indexPaket].isSelesai = true;
                    _listPaketTO[kodeTOB]![indexPaket].tanggalSiswaSubmit =
                        waktuMengumpulkan;

                    if (kDebugMode) {
                      logger.log(
                          'TOB_PROVIDER-KumpulkanJawabanSiswa: Paket After Kumpulkan '
                          '>> ${_listPaketTO[kodeTOB]![indexPaket]}');
                    }
                  }
                }
              }
            });
          } else {
            int indexPaket = _listPaketTO['$idJenisProduk']!.indexWhere(
                (paket) =>
                    paket.kodeTOB == kodeTOB && paket.kodePaket == kodePaket);

            if (indexPaket >= 0) {
              _listPaketTO['$idJenisProduk']![indexPaket].isSelesai = true;
              _listPaketTO['$idJenisProduk']![indexPaket].tanggalSiswaSubmit =
                  await gGetServerTime();

              if (kDebugMode) {
                logger.log(
                    'TOB_PROVIDER-KumpulkanJawabanSiswa: Paket After Kumpulkan '
                    '>> ${_listPaketTO['$idJenisProduk']![indexPaket]}');
              }
            }
          }

          await gShowTopFlash(gNavigatorKey.currentState!.context,
              'Yeey, Jawaban kamu berhasil dikumpulkan Sobat',
              dialogType: DialogType.success);
        } else {
          await gShowTopFlash(gNavigatorKey.currentState!.context,
              'Gagal menyimpan jawaban Sobat, coba lagi!',
              dialogType: DialogType.error);
        }
      }
      _isLoadingLaporanGOA = false;
      _isLoadingPaketTO = false;
      notifyListeners();
      return true;
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-KumpulkanJawabanTO: $e');
      }
      await gShowTopFlash(gNavigatorKey.currentState!.context,
          'Koneksi internet Sobat tidak stabil, coba lagi!',
          dialogType: DialogType.error);
      _isLoadingLaporanGOA = false;
      _isLoadingPaketTO = false;
      notifyListeners();
      return false;
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-KumpulkanJawabanTO: $e');
      }
      await gShowTopFlash(
          gNavigatorKey.currentState!.context, errorGagalMenyimpanJawaban,
          dialogType: DialogType.error, duration: const Duration(seconds: 6));
      _isLoadingLaporanGOA = false;
      _isLoadingPaketTO = false;
      notifyListeners();
      return false;
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-KumpulkanJawabanTO: ${e.toString()}');
      }
      await gShowTopFlash(
          gNavigatorKey.currentState!.context, errorGagalMenyimpanJawaban,
          dialogType: DialogType.error, duration: const Duration(seconds: 6));
      _isLoadingLaporanGOA = false;
      _isLoadingPaketTO = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitJawabanSiswa({
    bool isOutOfTime = false,
    required UserModel? userData,
    required String kodePaket,
    required int idJenisProduk,
    String? kodeTOB,
  }) async {
    try {
      final res = await _apiService.submitTOBK(
        noRegistrasi: userData?.noRegistrasi ?? '',
        tahunAjaran: userData?.tahunAjaran ?? '',
        kodePaket: kodePaket,
        tingkatKelas: int.parse(userData?.tingkatKelas ?? '0'),
        idJenisProduk: idJenisProduk,
        userData: userData,
        kodeTOB: kodeTOB,
      );

      if (!res) throw 'Terjadi Kesalahan, coba lagi nanti';

      if (isOutOfTime) {
        await gShowTopFlash(
          gNavigatorKey.currentState!.context,
          'Yaah waktu sudah habis Sobat, jawaban kamu akan dikumpulkan secara otomatis.',
          dialogType: DialogType.info,
        );
      } else {
        await gShowTopFlash(gNavigatorKey.currentState!.context,
            'Yeey, Jawaban kamu berhasil dikumpulkan Sobat',
            dialogType: DialogType.success);
      }
      notifyListeners();
      return res;
    } on NoConnectionException catch (e) {
      await gShowTopFlash(
        gNavigatorKey.currentState!.context,
        e.toString(),
        dialogType: DialogType.error,
      );
      notifyListeners();
      return false;
    } on DataException catch (e) {
      await gShowTopFlash(
        gNavigatorKey.currentState!.context,
        e.toString(),
        dialogType: DialogType.error,
      );
      notifyListeners();
      return false;
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

  /// [getJawabanPaket] digunakan untuk get jawaban yang sudah disubmit
  /// <br> kecuali TOBK
  Future<bool> getJawabanPaketTimer({
    required String noRegistrasi,
    required int idJenisProduk,
    required int idTingkatKelas,
    required String tahunAjaran,
    required String kodePaket,
  }) async {
    try {
      final res = await _apiService.getJawabanPaketTimer(
        idJenisProduk: idJenisProduk,
        idTingkatKelas: idTingkatKelas,
        noRegistrasi: noRegistrasi,
        tahunAjaran: tahunAjaran,
        kodePaket: kodePaket,
      );

      List<JawabanSiswa> listJawabanSiswa =
          res.map((x) => JawabanSiswaModel.fromJson(x)).toList();

      for (var value in listJawabanSiswa) {
        // iterate lagi karena jika listjawabansiswa ada 30 tapi dalam 1 bundle soal ada 5
        // maka akan err: out off bound exception
        // maka dari itu di limit sebanyak jumlah soal dalam 1 bundle
        for (int i = 0; i < listSoal[cacheKey]!.length; i++) {
          final itemSoal = listSoal[cacheKey]?[i];
          if (value.idSoal == itemSoal?.idSoal) {
            itemSoal?.sudahDikumpulkan = value.jawabanSiswa != null;
            itemSoal?.isRagu = value.isRagu;
            itemSoal?.jawabanSiswa = value.jawabanSiswa;
          }
        }
      }

      return res.isNotEmpty;
    } on NoConnectionException catch (_) {
      return false;
    } on DataException catch (_) {
      return false;
    } catch (e) {
      return false;
    } finally {
      notifyListeners();
    }
  }

  void _showLoadingSimpanJawaban({
    String text = 'Tunggu sebentar ya, sobat.\nKoneksi internet terganggu',
  }) {
    BuildContext context = gNavigatorKey.currentState!.context;
    snackbar ??= SnackBar(
      content: Text(
        text,
        style: context.text.bodyMedium?.copyWith(color: Colors.white),
      ),
      duration: const Duration(milliseconds: 1200),
      backgroundColor: Colors.black,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(context.dp(16)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        snackbar!,
      );
  }
}
