import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/bookmark/domain/entity/bookmark.dart';
import 'package:gokreasi_new/features/soal/module/bundel_soal/domain/entity/bundel_soal.dart';
import 'package:gokreasi_new/features/soal/module/bundel_soal/service/bundel_soal_service_api.dart';
import 'package:gokreasi_new/features/soal/module/paket_soal/data/model/jawaban_buku_sakti.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/entity/jawaban_siswa.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/model/jawaban_siswa_model.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/service/tob_service_api.dart';
// import 'dart:collection';

import '../../entity/soal.dart';
import '../../entity/sobat_tips_bab.dart';
import '../../model/sobat_tips_bab_model.dart';
import '../../service/api/soal_service_api.dart';
import '../../../../core/config/global.dart';
import '../../../../core/helper/hive_helper.dart';
import '../../../../core/util/app_exceptions.dart';
import '../../../../core/util/data_formatter.dart';
import '../../../../core/shared/provider/disposable_provider.dart';

class SoalProvider extends DisposableProvider {
  final String errorGagalMenyimpanJawaban =
      'Hai Sobat, terjadi kesalahan saat menyimpan jawaban, '
      'mohon tunggu sebentar dan refresh kembali ya';

  final String errorGagalMenyiapkanSoal =
      'Hai Sobat, aplikasi kamu tidak terkoneksi ke database, '
      'Coba ulangi lagi atau kembali nanti yaa!';

  // int _totalBenar = 0;
  // int _totalSalah = 0;
  // int _totalKosong = 0;
  int indexSoal = 0;
  int indexPaket = 0;
  dynamic kunciJawaban;

  /// [cacheKey] merupakan key dari ListSoal yang mau diambil.<br>
  /// Format-nya tergantung dari tipe soalnya.
  String? cacheKey;
  bool _isLoadingJawaban = false;

  String _errorGetTips = 'Belum ada teori terkait dengan soal ini Sobat';
  String get errorGetTips => _errorGetTips;

  /// Key dari [listSoal] merupakan [cacheKey]
  Map<String, List<Soal>> listSoal = {};

  /// Key dari [_listSobatTips] merupakan idSoal
  final Map<String, List<SobatTipsBab>> _listSobatTips = {};

  String get lastUpdateNowFormatted => DataFormatter.formatLastUpdate();

  Soal get soal => listSoal[cacheKey]![indexSoal];
  bool get isSoalExist =>
      cacheKey != null && (listSoal[cacheKey]?.isNotEmpty == true);

  UnmodifiableListView<Soal> get daftarSoal =>
      UnmodifiableListView(listSoal[cacheKey] ?? []);

  UnmodifiableListView<SobatTipsBab> getSobatTipsByIsSoal(String idSoal) =>
      UnmodifiableListView(_listSobatTips[idSoal] ?? []);

  Soal getSoalByIndex(int index) => listSoal[cacheKey]![index];

  Map<String, dynamic> get jsonOpsi => jsonDecode(soal.opsi);

  bool get isLoadingJawaban => _isLoadingJawaban;
  bool get isFirstSoal => indexSoal == 0;
  bool get isLastSoal => indexSoal == jumlahSoal - 1;

  int get jumlahSoal => listSoal[cacheKey]?.length ?? 0;
  // int get totalBenar => _totalBenar;
  // int get totalSalah => _totalSalah;
  // int get totalKosong => _totalKosong;

  Future<void> jumpToSoalNomor(int jumpToIndex) async {
    indexSoal = jumpToIndex;
    notifyListeners();
  }

  Future<void> setNextSoal({
    String? kodePaket,
    required String noRegister,
    required String tahunAjaran,
    int urutan = 1,
    required int idJenisProduk,
  }) async {
    if (kDebugMode) {
      logger.log(
          'SOAL_PROVIDER-SetNextSoal: jawaban siswa sebelum >> ${soal.jawabanSiswa}');
    }
    if (isLastSoal) return;
    indexSoal++;

    notifyListeners();
    if (kDebugMode) {
      logger.log(
          'SOAL_PROVIDER-SetNextSoal: jawaban siswa setelah >> ${soal.jawabanSiswa}');
    }
  }

  Future<void> setPrevSoal({
    String? kodePaket,
    required String noRegister,
    required String tahunAjaran,
    required int idJenisProduk,
    int urutan = 1,
  }) async {
    if (kDebugMode) {
      logger.log(
          'SOAL_PROVIDER-SetPrevSoal: jawaban siswa sebelum >> ${soal.jawabanSiswa}');
    }
    if (isFirstSoal) return;
    indexSoal--;

    notifyListeners();
    if (kDebugMode) {
      logger.log(
          'SOAL_PROVIDER-SetPrevSoal: jawaban siswa setelah >> ${soal.jawabanSiswa}');
    }
  }

  // Map<String, int>? getMataUjiSelanjutnya() {
  //   var map = <String, int>{};
  //
  //   int indexSoal = 0;
  //   for (var soal in daftarSoal) {
  //     if (map[soal.namaKelompokUjian] == null) {
  //       map[soal.namaKelompokUjian] = indexSoal;
  //     }
  //     indexSoal++;
  //   }
  //
  //   if (kDebugMode) {
  //     logger.log('SOAL_PROVIDER-GetMataUjiSelanjutnya: grup by mata uji >> $map');
  //   }
  //
  //   int indexMataUjiSaatIni = map.keys
  //       .toList()
  //       .indexWhere((element) => element == soal.namaKelompokUjian);
  //
  //   if (kDebugMode) {
  //     logger.log('SOAL_PROVIDER-GetMataUjiSelanjutnya: indexMataUjiSaatIni >> $indexMataUjiSaatIni');
  //   }
  //
  //   int? indexMataUjiSelanjutnya =
  //       (indexMataUjiSaatIni < (map.length - 1)) ? indexMataUjiSaatIni + 1 : null;
  //
  //   String? mataUjiSelanjutnya = (indexMataUjiSelanjutnya != null)
  //       ? map.keys.elementAt(indexMataUjiSelanjutnya)
  //       : null;
  //
  //   int? indexSoalSelanjutnya = (indexMataUjiSelanjutnya != null)
  //       ? map.values.elementAt(indexMataUjiSelanjutnya)
  //       : null;
  //
  //   if (kDebugMode) {
  //     logger.log('SOAL_PROVIDER-GetMataUjiSelanjutnya: Selanjutnya >> $mataUjiSelanjutnya | $indexSoalSelanjutnya');
  //   }
  //
  //   return (mataUjiSelanjutnya != null && indexSoalSelanjutnya != null)
  //       ? {mataUjiSelanjutnya: indexSoalSelanjutnya}
  //       : null;
  // }

  //questionAnswerScript
  dynamic get jsonSoalJawaban {
    final Map<String, dynamic> jsonSoalJawaban = jsonOpsi;
    switch (soal.tipeSoal) {
      case 'ESSAY MAJEMUK':
        return jsonSoalJawaban['soal'].cast<Map<String, dynamic>>();
      case 'PBCT':
        return {
          'max': jsonSoalJawaban['maxpilih'],
          'opsi': jsonSoalJawaban['opsi'],
        };
      case 'PBT':

        /// [kolom] merupakan judul dari masing-masing kolom pada tabel.<br><br>
        /// Contoh json:
        /// {
        ///   "urut": 0,
        ///   "judul": "Pernyataan"
        /// }
        List<dynamic> kolom = jsonSoalJawaban['kolom'];

        /// [opsi] merupakan text pernyataan di tiap row pada tabel.<br><br>
        /// Contoh json:
        /// {
        ///   "text": "<p>Berkonsultasi tentang persoalan organisasi</p>",
        ///   "jawaban": [{"urut": 1,"jawaban": true}]
        /// }
        List<dynamic> opsi = jsonSoalJawaban['opsi'];

        List<dynamic> headers = [];
        List<dynamic> bodies = [];

        kolom.sort((a, b) => a['urut'].compareTo(b['urut']));
        headers.add('Soal');
        for (final judul in kolom) {
          headers.add(judul['judul']);
        }
        for (int i = 0; i < opsi.length; i++) {
          final data = opsi[i];
          bodies.add(data['$i']['text']);
        }

        return {
          'headers': headers,
          'bodies': bodies,
        };
      case 'PBM':

        /// [opsi] berisikan list pertanyaan.<br><br>
        /// Contoh json:
        /// {
        ///   "jodoh": 2,
        ///   "pertanyaan": "<p>Tokoh Utama</p>"
        /// }
        List<dynamic> opsi = jsonSoalJawaban['opsi'];

        /// [jodoh] berisikan list text html jodoh untuk pilihan jawaban.<br><br>
        /// Contoh json:
        /// {
        ///   "jodoh": "<p>Tria Ayu</p>"
        /// }
        List<dynamic> jodoh = jsonSoalJawaban['jodoh'];

        List<dynamic> statements = [];
        List<dynamic> options = [];

        for (int indexPertanyaan = 0;
            indexPertanyaan < opsi.length;
            indexPertanyaan++) {
          statements.add({
            'index': indexPertanyaan,
            'statement': opsi[indexPertanyaan][indexPertanyaan.toString()]
                ['pertanyaan'],
            'jodoh': opsi[indexPertanyaan][indexPertanyaan.toString()]['jodoh'],
          });
        }

        for (int indexOpsi = 0; indexOpsi < jodoh.length; indexOpsi++) {
          options.add({
            'index': indexOpsi,
            'option': jodoh[indexOpsi]['jodoh'],
          });
        }

        return {
          'statement': statements,
          'option': options,
        };
      case 'PBB':
        return jsonSoalJawaban['opsi'];
      default:
        // Default digunakan untuk soal dengan tipe:
        // PGB, PBS, PBK
        return jsonSoalJawaban;
    }
  }

  // setQuestionAnswerKey
  dynamic setKunciJawabanSoal(
      String tipeSoal, Map<String, dynamic> jsonOpsi, int nomorSoal) {
    switch (tipeSoal) {
      case 'PGB':
        String kunciJawabanPGB = '';

        final data = jsonOpsi['opsi'];
        for (final item in data) {
          for (final key in item.keys) {
            if (item[key]['bobot'] == 100) {
              kunciJawabanPGB = key;
              break;
            }
          }
          if (kunciJawabanPGB.isNotEmpty) {
            break;
          }
        }

        return kunciJawabanPGB;

      case 'PBK':
      case 'PBCT':
        List<dynamic> kunciJawabanKompleks = jsonOpsi['kunci'];

        kunciJawabanKompleks.cast<String>();

        return kunciJawabanKompleks;
      case 'PBT':
        List<dynamic> opsi = jsonOpsi['opsi'];
        List<int> kunciJawabanTabel = [];

        opsi.asMap().forEach((index, value) {
          Map<String, dynamic> data = value[index.toString()];
          List<dynamic> jawaban = data['jawaban'];

          List<dynamic> urut =
              jawaban.where((obj) => obj.containsValue(true)).toList();

          final jawabanValue = urut.isNotEmpty ? urut[0]['urut'] - 1 : -1;

          kunciJawabanTabel.insert(index, jawabanValue);
        });

        return kunciJawabanTabel;
      case 'PBB':
        List<dynamic> opsi = jsonOpsi['opsi'];
        Map<String, dynamic> kunciJawabanAlasan = {};

        opsi.asMap().forEach((key, value) {
          final indexOpsi = value['isbenar'] == true ? key : null;
          final listAlasan = value['isbenar'] == true ? value['alasan'] : null;

          if (indexOpsi != null && listAlasan != null) {
            listAlasan.asMap().forEach((key, value) {
              final isAlasanTrue = value['isbenar'] == true ? 1 : 0;

              listAlasan.insert(key, isAlasanTrue);
            });

            kunciJawabanAlasan['opsi'] = indexOpsi;
            kunciJawabanAlasan['alasan'] = listAlasan;
          }
        });

        if (kDebugMode) {
          logger.log('SOAL_PROVIDER-SetKunciJawabanSoal: Opsi PBB >> $opsi');
          logger.log(
              'SOAL_PROVIDER-SetKunciJawabanSoal: Kunci PBB >> $kunciJawabanAlasan');
        }
        return kunciJawabanAlasan;
      case 'PBM':
        List<dynamic> opsi = jsonOpsi['opsi'];
        List<int> kunciJawabanPasangan = [];
        List<Map<String, dynamic>> listjawaban = [];

        for (final item in opsi) {
          listjawaban.add(item);
        }

        for (final item in listjawaban) {
          final key = item.keys.first;
          final jodohValue = item[key]['jodoh'];
          kunciJawabanPasangan.insert(int.parse(key), jodohValue);
        }

        // opsi.asMap().forEach((key, value) {
        //   kunciJawabanPasangan.insert(key, value['jodoh'] ?? -1);
        // });

        if (kDebugMode) {
          logger.log(
              'SOAL_PROVIDER-SetKunciJawabanSoal: Kunci PBM >> $kunciJawabanPasangan');
        }
        return kunciJawabanPasangan;
      case 'ESSAY':
        if (kDebugMode) {
          logger.log(
              'SOAL_PROVIDER-SetKunciJawabanSoal: Kunci ESSAY >> ${jsonOpsi['keyword']}');
        }
        return jsonOpsi['keyword'];
      case 'ESSAY MAJEMUK':
        List<dynamic> soal = jsonOpsi['soal'];
        List<List<dynamic>> kunciJawabanMajemuk = [];

        soal.asMap().forEach((key, value) {
          kunciJawabanMajemuk.insert(
              key, (value as Map<String, dynamic>)['keywords'] ?? []);
        });

        if (kDebugMode) {
          logger.log(
              'SOAL_PROVIDER-SetKunciJawabanSoal: Kunci ESSAY MAJEMUK >> $kunciJawabanMajemuk');
        }
        return kunciJawabanMajemuk;
      default:
        // Di gunakan untuk tipe soal PBS
        return jsonOpsi['kunci'];
    }
  }

  /// [setJawabanEPB] function untuk membuat display jawaban pada EPB.<br><br>
  /// [jawaban] merupakan kunciJawabanSoal atau jawabanSiswa.<br>
  /// [translator] merupakan bahan yang digunakan untuk mengubah [jawaban]
  /// menjadi sesuai dengan format display pada EPB.
  dynamic setJawabanEPB(
    String tipeSoal,
    dynamic jawaban,
    dynamic translator,
  ) {
    switch (tipeSoal) {
      case 'PBT':
        List<int> jawabanCast =
            (jawaban == null) ? [] : (jawaban as List).cast<int>();
        List<String> translatorCast = (translator as List).cast<String>();
        List<String> jawabanEPB = [];

        if (jawaban == null) return null;

        for (int jawaban in jawabanCast) {
          String formattedJawaban =
              (jawaban < 0) ? ' ' : translatorCast[jawaban];
          jawabanEPB.add(formattedJawaban);
        }

        if (kDebugMode) {
          logger.log('SOAL_PROVIDER-SetKunciJawabanEPB: Jawaban >> $jawaban');
          logger.log('SOAL_PROVIDER-SetKunciJawabanEPB: Cast >> $jawabanCast');
          logger.log(
              'SOAL_PROVIDER-SetKunciJawabanEPB: Translator >> $translator');
          logger
              .log('SOAL_PROVIDER-SetKunciJawabanEPB: Cast >> $translatorCast');
          logger.log(
              'SOAL_PROVIDER-SetKunciJawabanEPB: Kunci PBT >> $jawabanEPB');
        }

        return jawabanEPB;
      default:
        // Format soal AKM lainnya belum pernah di uji coba,
        // sehingga belum mengetahui format EPB yang diinginkan.
        return jawaban;
    }
  }

  /// [setTranslatorEPB] function untuk membuat translator jawaban pada EPB.<br><br>
  /// [jsonOpsi] merupakan opsi soal dari API.
  dynamic setTranslatorEPB(
    String tipeSoal,
    Map<String, dynamic> jsonOpsi,
  ) {
    switch (tipeSoal) {
      case 'PBT':
        final identifier =
            (jsonOpsi.containsKey('kolom')) ? jsonOpsi['kolom'] : null;
        final List kolom = (identifier != null) ? identifier : [];

        if (kolom.isEmpty) return kolom;

        if (kDebugMode) {
          logger.log('SOAL_PROVIDER-setTranslatorEPB: Kolom >> $kolom');
        }

        // Menghilangkan kolom pernyataan
        kolom.removeAt(0);
        if (kDebugMode) {
          logger.log('SOAL_PROVIDER-setTranslatorEPB: After Remove >> $kolom');
        }

        var result = kolom.map<String>((e) {
          int start = '${e['judul']}'.indexOf('(');
          int end = '${e['judul']}'.indexOf(')');
          end = (end < 0) ? start + 2 : end;

          return (start < 0)
              ? '${e['judul']}'.trim().substring(0, 1)
              : '${e['judul']}'.trim().substring(start + 1, end);
        }).toList();
        // kolom.removeAt(0);
        if (kDebugMode) {
          logger.log('SOAL_PROVIDER-setTranslatorEPB: Result >> $result');
        }

        return result;
      default:
        // Format soal AKM lainnya belum pernah di uji coba,
        // sehingga belum mengetahui format EPB yang diinginkan.
        return null;
    }
  }

  Future<void> setNilai({dynamic jawabanSiswa}) async {
    final Map<String, dynamic> jsonOpsi = jsonDecode(soal.opsi);
    // final kunciJawabanSoal = setKunciJawabanSoal(jsonOpsi);
    final kunciJawabanSoal = soal.kunciJawaban;
    int fullCredit, halfCredit, zeroCredit;

    fullCredit = jsonOpsi['nilai']['fullcredit'];
    halfCredit = jsonOpsi['nilai']['halfcredit'];
    zeroCredit = jsonOpsi['nilai']['zerocredit'];
    kunciJawaban = kunciJawabanSoal;

    switch (soal.tipeSoal) {
      case 'PBK':
      case 'PBCT':
        List<String> listJawabanSiswa = jawabanSiswa;
        List<bool> hasilPenilaian = [];

        if (kDebugMode) {
          logger.log('SOAL-SetNilai: Kunci Kompleks >> $kunciJawabanSoal');
          logger
              .log('SOAL-SetNilai: List Jawaban Kompleks >> $listJawabanSiswa');
        }

        if (listJawabanSiswa.isEmpty) {
          soal.nilai = 0.0;
        } else {
          // final Map opsi = jsonOpsi['opsi'];
          for (var jawabanSiswa in listJawabanSiswa) {
            if (kunciJawabanSoal.contains(jawabanSiswa)) {
              hasilPenilaian.add(kunciJawabanSoal.contains(jawabanSiswa));
            }
          }

          if (kDebugMode) {
            logger.log(
                'SOAL-SetNilai: Hasil Penilaian Kompleks >> $hasilPenilaian');
          }

          if (hasilPenilaian.length == fullCredit) {
            soal.nilai = 1.0;
          } else if (hasilPenilaian.length >= halfCredit) {
            soal.nilai = 0.5;
          } else {
            soal.nilai = 0.0;
          }
        }

        break;
      case 'PBT':
        List<int> listJawabanSiswa = jawabanSiswa ?? [];
        List<bool> hasilPenilaian = [];

        if (listJawabanSiswa.isNotEmpty) {
          for (var jawabanSiswa in listJawabanSiswa) {
            for (int i = 0; i < kunciJawabanSoal?.length; i++) {
              final bool? nilai = jawabanSiswa != -1
                  ? jawabanSiswa == kunciJawabanSoal[i]
                  : null;
              if (nilai == true) {
                hasilPenilaian.add(nilai == true);
              }
            }
          }

          if (hasilPenilaian.contains(false)) {
            hasilPenilaian.removeWhere((nilai) => !nilai);
          }

          if (hasilPenilaian.length >= fullCredit) {
            soal.nilai = 1.0;
          } else if (hasilPenilaian.length >= halfCredit &&
              hasilPenilaian.length < fullCredit) {
            soal.nilai = 0.5;
          } else if (hasilPenilaian.length >= zeroCredit &&
              hasilPenilaian.length < halfCredit) {
            soal.nilai = 0.0;
          }
        }

        break;
      case 'PBB':
        Map<String, dynamic> tempJawabanSiswa = jawabanSiswa;
        List<bool> hasilPenilaian = [];

        if (tempJawabanSiswa.isNotEmpty) {
          final opsiPilihanSiswa = tempJawabanSiswa['opsi'];
          final kunciJawabanOpsi = kunciJawabanSoal['opsi'];

          if (kunciJawabanOpsi == opsiPilihanSiswa) {
            final jawabanAlasanSiswa = tempJawabanSiswa['alasan'] as List<int>;
            final kunciJawabanAlasan = kunciJawabanSoal['alasan'] as List<int>;

            jawabanAlasanSiswa.asMap().forEach((index, jawabanAlasan) {
              final nilai = jawabanAlasan != -1
                  ? jawabanAlasan == 0
                      ? false
                      : jawabanAlasan == kunciJawabanAlasan[index]
                  : null;
              if (nilai != null) hasilPenilaian.add(nilai);
            });

            if (!hasilPenilaian.contains(false)) {
              if (hasilPenilaian.length >= fullCredit) {
                soal.nilai = 1.0;
              } else if (hasilPenilaian.length >= halfCredit &&
                  hasilPenilaian.length < fullCredit) {
                soal.nilai = 0.5;
              } else if (hasilPenilaian.length >= zeroCredit &&
                  hasilPenilaian.length < halfCredit) {
                soal.nilai = 0.0;
              }
            }
          }
        }

        break;
      case 'PBM':
        List<int> listJawabanSiswa = jawabanSiswa;
        List<bool> hasilPenilaian = [];

        if (listJawabanSiswa.isNotEmpty) {
          listJawabanSiswa.asMap().forEach((index, jawaban) {
            final nilai =
                (jawaban != -1) ? jawaban == kunciJawabanSoal[index] : null;
            if (nilai != null) hasilPenilaian.add(nilai);
          });

          if (!hasilPenilaian.contains(false)) {
            if (hasilPenilaian.length >= fullCredit) {
              soal.nilai = 1.0;
            } else if (hasilPenilaian.length >= halfCredit &&
                hasilPenilaian.length < fullCredit) {
              soal.nilai = 0.5;
            } else if (hasilPenilaian.length >= zeroCredit &&
                hasilPenilaian.length < halfCredit) {
              soal.nilai = 0.0;
            }
          }
        }

        break;
      case 'ESSAY':
        String formattedJawaban = DataFormatter.formatEssay(jawabanSiswa);

        int totalKeyword = 0;

        for (int i = 0; i < kunciJawabanSoal.length; i++) {
          List<dynamic> keywords = kunciJawabanSoal[i];

          for (int j = 0; j < keywords.length; j++) {
            String keyword = keywords[j].toString().toLowerCase();

            var keywordPosition = formattedJawaban.indexOf(keyword);

            if (keywordPosition >= 0) {
              keywordPosition += keyword.length;
              formattedJawaban = formattedJawaban.substring(keywordPosition);
              totalKeyword++;
              break;
            }
          }
        }

        if (totalKeyword >= fullCredit) {
          soal.nilai = 1.0;
        } else if (halfCredit != 0 &&
            totalKeyword >= halfCredit &&
            totalKeyword < fullCredit) {
          soal.nilai = 0.5;
        } else if (zeroCredit != 0 &&
            totalKeyword >= zeroCredit &&
            totalKeyword < halfCredit) {
          soal.nilai = 0.0;
        }

        break;
      case 'ESSAY MAJEMUK':
        num totalCorrectKeyword = 0;
        List<String> listJawabanSiswa = jawabanSiswa;

        for (int idxAnswer = 0;
            idxAnswer < listJawabanSiswa.length;
            idxAnswer++) {
          String formattedResult =
              DataFormatter.formatEssay(listJawabanSiswa[idxAnswer]);
          int fc = jsonOpsi['soal'][idxAnswer]['fullcredit'];
          int hc = jsonOpsi['soal'][idxAnswer]['halfcredit'];
          int zc = jsonOpsi['soal'][idxAnswer]['zerocredit'];

          int totalKeyword = 0;
          List<dynamic> kunciJawabanKeywords = kunciJawabanSoal[idxAnswer];

          for (int i = 0; i < kunciJawabanKeywords.length; i++) {
            List<dynamic> keywords = kunciJawabanKeywords[i];

            for (int j = 0; j < keywords.length; j++) {
              String keyword = keywords[j].toString().toLowerCase();

              var keywordPosition = formattedResult.indexOf(keyword);

              if (keywordPosition >= 0) {
                keywordPosition += keyword.length;
                formattedResult = formattedResult.substring(keywordPosition);
                totalKeyword++;
                break;
              }
            }
          }

          if (totalKeyword >= fc) {
            totalCorrectKeyword += 1;
          } else if (hc != 0 && totalKeyword >= hc && totalKeyword < fc) {
            totalCorrectKeyword += 1;
          } else if (zc != 0 && totalKeyword >= zc && totalKeyword < hc) {
            soal.nilai = 0.0;
          }
        }

        if (totalCorrectKeyword >= fullCredit) {
          soal.nilai = 1.0;
        } else if (totalCorrectKeyword >= halfCredit &&
            totalCorrectKeyword < fullCredit) {
          soal.nilai = 0.5;
        } else if (totalCorrectKeyword >= zeroCredit &&
            totalCorrectKeyword < halfCredit) {
          soal.nilai = 0.0;
        }

        break;
      case 'PBS':
      case 'PGB':
      default:
        if (jawabanSiswa == kunciJawabanSoal) {
          soal.nilai = 1.0;
        } else {
          soal.nilai = 0.0;
        }
        break;
    }
  }

  Future<void> toggleBookmark(
      {required int idJenisProduk,
      required String namaJenisProduk,
      required String kodeTOB,
      required String kodePaket,
      String? idBundel,
      String? kodeBab,
      String? namaBab,
      String? tanggalKedaluwarsa,
      required bool isPaket,
      required bool isSimpan}) async {
    try {
      String keyBookmarkMapel = soal.idKelompokUjian;

      BookmarkSoal bookmarkSoal = BookmarkSoal(
        idSoal: soal.idSoal,
        nomorSoal: soal.nomorSoal,
        nomorSoalSiswa: soal.nomorSoalSiswa,
        kodeTOB: kodeTOB,
        kodePaket: soal.kodePaket ?? kodePaket,
        idBundel: soal.idBundle ?? idBundel!,
        kodeBab: kodeBab,
        namaBab: namaBab,
        idJenisProduk: idJenisProduk,
        namaJenisProduk: namaJenisProduk,
        tanggalKedaluwarsa: tanggalKedaluwarsa,
        isPaket: isPaket,
        isSimpan: isSimpan,
        lastUpdate: DataFormatter.formatLastUpdate(),
      );

      if (kDebugMode) {
        logger.log(
            'SOAL_PROVIDER-ToggleBookmark: sebelum toggle >> ${soal.isBookmarked}');
        logger.log(
            'SOAL_PROVIDER-ToggleBookmark: create bookmark object >> $bookmarkSoal');
      }

      BookmarkMapel? bookmarkMapel =
          await HiveHelper.getBookmarkMapel(keyBookmarkMapel: keyBookmarkMapel);

      if (bookmarkMapel == null) {
        // Jika bookmark mapel null, maka cek terlebih dahulu apakah
        // list bookmark mapel masih belum melebihi batas?
        List<BookmarkMapel> daftarBookmarkMapel =
            await HiveHelper.getDaftarBookmarkMapel();

        // Jika daftar mapel sudah mencapai 30,
        // maka tidak boleh menambahkan mapel lainnya.
        if (daftarBookmarkMapel.isNotEmpty && daftarBookmarkMapel.length > 29) {
          // ignore: use_build_context_synchronously
          gShowBottomDialogInfo(gNavigatorKey.currentState!.context,
              title: 'Mata Pelajaran yang disimpan sudah mencapai batas',
              message:
                  'Hai Sobat, kamu hanya boleh menyimpan bookmark sebanyak 30 jenis mata pelajaran. Bookmark kamu sudah diisi dengan ${daftarBookmarkMapel.length} mata pelajaran Sobat. Hapus salah satunya jika kamu mau menambahkan yang baru!');
          return;
        }

        soal.isBookmarked = true;
      } else {
        // Cek apakah bookmarkSoal sudah ada di dalam hive atau belum.
        BookmarkSoal? bookmarkSoalHive = await HiveHelper.getBookmarkSoal(
            keyBookmarkMapel: keyBookmarkMapel, bookmarkSoal: bookmarkSoal);

        if (kDebugMode) {
          logger.log(
              'SOAL_PROVIDER-ToggleBookmark: list sebelum toggle >> ${bookmarkMapel.listBookmark}');
        }

        // Jika list bookmark soal sudah mencapai 25,
        // maka tidak boleh menambahkan bookmark soal lainnya.
        if (bookmarkMapel.listBookmark.length > 24) {
          // ignore: use_build_context_synchronously
          gShowBottomDialogInfo(gNavigatorKey.currentState!.context,
              title:
                  'Soal pada ${bookmarkMapel.namaKelompokUjian} yang disimpan sudah mencapai batas',
              message:
                  'Hai Sobat, kamu hanya boleh menyimpan bookmark sebanyak 25 soal di setiap mata pelajaran. Bookmark kamu sudah diisi dengan ${bookmarkMapel.listBookmark.length} soal Sobat. Hapus salah satunya jika kamu mau menambahkan yang baru!');
          return;
        }

        // Jika [bookmarkSoalHive] null, maka artinya bookmark false
        // dan lakukan tambahkan data bookmark.
        if (bookmarkSoalHive == null) {
          bookmarkMapel.listBookmark.add(bookmarkSoal);
          bookmarkMapel.listBookmark.sort((a, b) => a.compareTo(b));
          soal.isBookmarked = true;
        } else {
          // [bookmarkSoalHive] exist, maka artinya bookmark true
          // dan lakukan remove from Hive.
          bookmarkMapel.listBookmark.removeWhere((bookmark) =>
              bookmark.idSoal == bookmarkSoal.idSoal &&
              bookmark.nomorSoal == bookmarkSoal.nomorSoal &&
              bookmark.nomorSoalSiswa == bookmarkSoal.nomorSoalSiswa &&
              bookmark.kodePaket == bookmarkSoal.kodePaket &&
              bookmark.idBundel == bookmarkSoal.idBundel &&
              bookmark.kodeBab == bookmarkSoal.kodeBab &&
              bookmark.namaBab == bookmarkSoal.namaBab &&
              bookmark.isPaket == bookmarkSoal.isPaket &&
              bookmark.isSimpan == bookmarkSoal.isSimpan);
          soal.isBookmarked = false;
        }
        if (kDebugMode) {
          logger.log(
              'SOAL_PROVIDER-ToggleBookmark: list setelah toggle >> ${bookmarkMapel.listBookmark}');
        }
      }
      if (kDebugMode) {
        logger.log(
            'SOAL_PROVIDER-ToggleBookmark: sebelum toggle >> ${soal.isBookmarked}');
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        logger.log('SOAL_PROVIDER-ToggleBookmark: Error >> $e');
      }
    }
  }

  Future<UnmodifiableListView<SobatTipsBab>> getSobatTips({
    required String idSoal,
    required String idBundel,
    required bool isBeliLengkap,
    required bool isBeliSingkat,
    required bool isBeliRingkas,
    required UserModel? userData,
    bool isRefresh = false,
  }) async {
    try {
      if (!isBeliLengkap && !isBeliSingkat && !isBeliRingkas) {
        return getSobatTipsByIsSoal(idSoal);
      }
      if (!isRefresh && _listSobatTips.containsKey(idSoal)) {
        return getSobatTipsByIsSoal(idSoal);
      }
      if (isRefresh) {
        _listSobatTips[idSoal]?.clear();
      }

      final responseData = await SoalServiceAPI().fetchSobatTips(
        idSoal: idSoal,
        idSekolahKelas: userData?.idSekolahKelas,
        idProdukAktif: userData?.listIdProduk,
      );

      if (kDebugMode) {
        logger
            .log('SOAL_PROVIDER-GetSobatTips: response data >> $responseData');
      }

      if (!_listSobatTips.containsKey(idSoal)) {
        _listSobatTips[idSoal] = [];
      }

      if (responseData.isNotEmpty && _listSobatTips[idSoal]!.isEmpty) {
        for (Map<String, dynamic> jsonSobatTips in responseData) {
          _listSobatTips[idSoal]!
              .add(SobatTipsBabModel.fromJson(jsonSobatTips));
        }
        _listSobatTips[idSoal]!.sort((a, b) => a.kodeBab.compareTo(b.kodeBab));
      }

      notifyListeners();
      return getSobatTipsByIsSoal(idSoal);
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-GetSobatTips: $e');
      }
      return getSobatTipsByIsSoal(idSoal);
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-GetSobatTips: $e');
      }
      _errorGetTips = e.toString();
      if (!_listSobatTips.containsKey(idSoal)) {
        _listSobatTips[idSoal] = [];
      }
      notifyListeners();
      return getSobatTipsByIsSoal(idSoal);
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-GetSobatTips: ${e.toString()}');
      }
      return getSobatTipsByIsSoal(idSoal);
    }
  }

  Future<int> getJawabanSiswaByUrutan({
    required String noRegister,
    required String kodePaket,
    required String tahunAjaran,
    required int urutan,
    required int idJenisProduk,
    bool isSelesai = false,
  }) async {
    try {
      final res = await TOBServiceApi().getSortJawabanSiswa(
        noRegister: noRegister,
        kodePaket: kodePaket,
        tahunAjaran: tahunAjaran,
        urutan: urutan,
        idJenisProduk: idJenisProduk,
      );

      List<JawabanSiswa> listJawabanSiswa =
          res.map((x) => JawabanSiswaModel.fromJson(x)).toList();
      int adaSoalRagu = 0;

      // untuk get semua jawaban siswa yg sudah di post. dan meng-set jawaban sudah dipilh siswa
      for (var value in listJawabanSiswa) {
        // iterate lagi karena jika listjawabansiswa ada 30 tapi dalam 1 bundle soal ada 5
        // maka akan err: out off bound exception
        // maka dari itu di limit sebanyak jumlah soal dalam 1 bundle
        for (int i = 0; i < listSoal[cacheKey]!.length; i++) {
          final itemSoal = listSoal[cacheKey]?[i];
          if (value.idSoal == itemSoal?.idSoal) {
            itemSoal?.sudahDikumpulkan =
                isSelesai && value.jawabanSiswa != null;
            itemSoal?.isRagu = value.isRagu;
            itemSoal?.jawabanSiswa = value.jawabanSiswa;
          }
        }

        // untuk cek apakah ada ragu di setiap soal
        if (value.isRagu) {
          adaSoalRagu += 1;
        }
      }

      notifyListeners();
      return adaSoalRagu;
    } on NoConnectionException catch (_) {
      // await gShowTopFlash(
      //   gNavigatorKey.currentState!.context,
      //   e.toString(),
      //   dialogType: DialogType.error,
      // );
      notifyListeners();
      return 0;
    } on DataException catch (_) {
      // await gShowTopFlash(
      //   gNavigatorKey.currentState!.context,
      //   e.toString(),
      //   dialogType: DialogType.error,
      // );
      notifyListeners();
      return 0;
    } catch (e) {
      // await gShowTopFlash(
      //   gNavigatorKey.currentState!.context,
      //   e.toString(),
      //   dialogType: DialogType.error,
      // );
      notifyListeners();
      return 0;
    }
  }

  Future<Map<String, dynamic>> getJawabanSiswaAll({
    required String noRegister,
    required String kodePaket,
    required String tahunAjaran,
    required int idJenisProduk,
  }) async {
    try {
      final res = await TOBServiceApi().getAllJawabanSiswa(
        noRegister: noRegister,
        kodePaket: kodePaket,
        tahunAjaran: tahunAjaran,
        idJenisProduk: idJenisProduk,
      );

      List<JawabanSiswa> listJawabanSiswa =
          res.map((x) => JawabanSiswaModel.fromJson(x)).toList();
      int adaSoalRagu = 0;

      // untuk get semua jawaban siswa yg sudah di post. dan meng-set jawaban sudah dipilh siswa
      for (var value in listJawabanSiswa) {
        // iterate lagi karena jika listjawabansiswa ada 30 tapi dalam 1 bundle soal ada 5
        // maka akan err: out off bound exception
        // maka dari itu di limit sebanyak jumlah soal dalam 1 bundle
        for (int i = 0; i < listSoal[cacheKey]!.length; i++) {
          final itemSoal = listSoal[cacheKey]?[i];
          if (value.idSoal == itemSoal?.idSoal) {
            itemSoal?.isRagu = value.isRagu;
            itemSoal?.jawabanSiswa = value.jawabanSiswa;
          }
        }

        // untuk cek apakah ada ragu di setiap soal
        if (value.isRagu) {
          adaSoalRagu += 1;
        }
      }

      bool isJawabanKosong =
          listJawabanSiswa.every((x) => x.jawabanSiswa == null);

      notifyListeners();
      return {}
        ..['totalSoalRagu'] = adaSoalRagu
        ..['isJawabanKosong'] = isJawabanKosong;
    } on DataException catch (_) {
      return {}
        ..['totalSoalRagu'] = 0
        ..['isJawabanKosong'] = false;
    } catch (e) {
      return {}
        ..['totalSoalRagu'] = 0
        ..['isJawabanKosong'] = false;
    }
  }

  Future<void> getJawabanSiswaBukuSakti({
    required int idJenisProduk,
    required String noRegistrasi,
    required String idTingkatKelas,
    required String tahunAjaran,
    required String kodePaket,
    bool isBundle = false,
    OpsiUrut opsiUrut = OpsiUrut.bab,
    String? idBundleSoal,
    String? kodeBab,
  }) async {
    try {
      if (!_isLoadingJawaban) {
        _isLoadingJawaban = true;
        notifyListeners();
      }
      if (isBundle) {
        final res = await BundelSoalServiceApi().getAllJawabanSiswa(
          noRegister: noRegistrasi,
          kodePaket: kodePaket,
          tahunAjaran: tahunAjaran,
          idJenisProduk: idJenisProduk,
        );

        List<JawabanSiswa> listJawabanSiswa =
            res.map((x) => JawabanSiswaModel.fromJson(x)).toList();

        for (var value in listJawabanSiswa) {
          // iterate lagi karena jika list jawabansiswa ada 30 tapi dalam 1 bundle soal ada 5
          // maka akan err: out off bound exception
          // maka dari itu di limit sebanyak jumlah soal dalam 1 bundle
          for (int i = 0; i < listSoal[cacheKey]!.length; i++) {
            final itemSoal = listSoal[cacheKey]?[i];
            if (value.idSoal == itemSoal?.idSoal &&
                itemSoal?.sudahDikumpulkan == false) {
              itemSoal?.isRagu = value.isRagu;
              itemSoal?.jawabanSiswa = value.jawabanSiswa;
            }
          }
        }
      } else {
        final res = await TOBServiceApi().getSortJawabanSiswa(
          noRegister: noRegistrasi,
          kodePaket: kodePaket,
          tahunAjaran: tahunAjaran,
          urutan: indexPaket,
          idJenisProduk: idJenisProduk,
        );

        List<JawabanSiswa> listJawabanSiswa =
            res.map((x) => JawabanSiswaModel.fromJson(x)).toList();

        // untuk get semua jawaban siswa yg sudah di post. dan meng-set jawaban sudah dipilh siswa
        for (var value in listJawabanSiswa) {
          // iterate lagi karena jika listjawabansiswa ada 30 tapi dalam 1 bundle soal ada 5
          // maka akan err: out off bound exception
          // maka dari itu di limit sebanyak jumlah soal dalam 1 bundle
          for (int i = 0; i < listSoal[cacheKey]!.length; i++) {
            final itemSoal = listSoal[cacheKey]?[i];
            if (value.idSoal == itemSoal?.idSoal &&
                itemSoal?.sudahDikumpulkan == false) {
              itemSoal?.isRagu = value.isRagu;
              itemSoal?.jawabanSiswa = value.jawabanSiswa;
            }
          }
        }
      }

      final res = await SoalServiceAPI().getJawabanSiswaBukuSakti(
        idJenisProduk: idJenisProduk,
        noRegistrasi: noRegistrasi,
        idTingkatKelas: idTingkatKelas,
        tahunAjaran: tahunAjaran,
        kodePaket: kodePaket,
        kodeBab: kodeBab,
        opsiUrut: opsiUrut,
        idBundleSoal: idBundleSoal,
      );

      for (JawabanBukuSakti jawaban in res) {
        for (int i = 0; i < listSoal[cacheKey]!.length; i++) {
          final itemSoal = listSoal[cacheKey]?[i];
          if (jawaban.idSoal == itemSoal?.idSoal) {
            itemSoal?.sudahDikumpulkan = jawaban.jawabanSiswa != null;
            itemSoal?.isRagu = jawaban.isRagu ?? false;
            itemSoal?.jawabanSiswa = jawaban.jawabanSiswa;
          }
        }
      }

      notifyListeners();
    } on NoConnectionException catch (_) {
      // await gShowTopFlash(
      //   gNavigatorKey.currentState!.context,
      //   e.toString(),
      //   dialogType: DialogType.error,
      // );
      notifyListeners();
    } on DataException catch (_) {
      // await gShowTopFlash(
      //   gNavigatorKey.currentState!.context,
      //   e.toString(),
      //   dialogType: DialogType.error,
      // );
      notifyListeners();
    } catch (e) {
      // await gShowTopFlash(
      //   gNavigatorKey.currentState!.context,
      //   e.toString(),
      //   dialogType: DialogType.error,
      // );
      notifyListeners();
    } finally {
      _isLoadingJawaban = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> olahDataJawaban({
    required UserModel? userData,
    required String kodePaket,
    required int idJenisProduk,
    required String namaJenisProduk,
    String? kodeBab,
    int? idBundle,
  }) async {
    Map<String, dynamic> result = {};
    try {
      List<int>? list = listSoal[cacheKey]
          ?.map((element) =>
              (element.sudahDikumpulkan) ? 0 : int.parse(element.idSoal))
          .toList();

      List<int>? listIdSoal = list?.where((id) => id != 0).toList();

      final res = await TOBServiceApi().olahDataJawaban(
        noRegistrasi: userData?.noRegistrasi ?? '',
        tahunAjaran: userData?.tahunAjaran ?? '',
        kodePaket: kodePaket,
        namaJenisProduk: namaJenisProduk,
        tingkatKelas: int.parse(userData?.tingkatKelas ?? '0'),
        idJenisProduk: idJenisProduk,
        listIdSoal: listIdSoal,
        userData: userData,
        kodeBab: kodeBab,
        idBundle: idBundle,
      );

      if (!res) throw 'Terjadi Kesalahan, coba lagi nanti';

      result
        ..['success'] = true
        ..['message'] = 'Yeey, Jawaban kamu berhasil disimpan Sobat';

      notifyListeners();
      return result;
    } on NoConnectionException catch (_) {
      result
        ..['success'] = false
        ..['message'] = gPesanError;
      notifyListeners();
      return result;
    } on DataException catch (e) {
      result
        ..['success'] = false
        ..['message'] = e.toString();
      notifyListeners();
      return result;
    } catch (e) {
      result
        ..['success'] = false
        ..['message'] = gPesanError;
      notifyListeners();
      return result;
    }
  }

  Future<bool> postReportProblem({
    required String noRegistrasi,
    required String namaJenisProduk,
    required String reason,
    required String stackTrace,
    required int idJenisProduk,
    required String kodePaket,
    required int idSoal,
    required String timeStamp,
    required String zonaWaktu,
    int? idBundel,
  }) async {
    try {
      final Map<String, dynamic> params = {
        "noreg": noRegistrasi,
        "context": 'Menu - $namaJenisProduk',
        "reason": reason,
        "stack_trace": stackTrace,
        "report_meta": {
          "id_jenis_produk": idJenisProduk,
          "nama_jenis_produk": namaJenisProduk,
          "kode_paket": kodePaket,
          "id_bundel": idBundel,
          "id_soal": idSoal,
          "timestamp": timeStamp,
          "zona_waktu": zonaWaktu,
          "versi_os": await gVersiOS(),
          "merk": await gMerkHp(),
          "versi_app": gKreasiVersion,
        }
      };

      final res = await SoalServiceAPI().postReportProblem(params);

      soal.isReportSubmitted = res;

      notifyListeners();
      return res;
    } catch (e) {
      return false;
    }
  }

  @override
  void disposeValues() {
    listSoal.clear();
  }
}
