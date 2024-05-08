import 'dart:collection';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as logger show log;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/core/config/extensions.dart';
import 'package:gokreasi_new/core/config/global.dart';
import 'package:gokreasi_new/core/util/app_exceptions.dart';
import 'package:gokreasi_new/core/util/data_formatter.dart';
import 'package:gokreasi_new/features/soal/entity/detail_jawaban.dart';
import 'package:gokreasi_new/features/soal/entity/peserta_to.dart';
import 'package:gokreasi_new/features/soal/entity/soal.dart';
import 'package:gokreasi_new/features/soal/model/soal_model.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/entity/detail_bundel.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/entity/hasil_goa.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/entity/jawaban_siswa.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/entity/kisi_kisi.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/entity/paket_to.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/entity/syarat_tobk.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/entity/tob.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/model/kuis_model.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/model/detail_bundel_model.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/model/jawaban_siswa_model.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/model/kisi_kisi_model.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/model/package_to_model.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/model/paket_to_model.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/model/tob_model.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/service/tob_service_api.dart';
import 'package:gokreasi_new/features/soal/presentation/bloc/soal_bloc/soal_bloc.dart';
import 'package:gokreasi_new/features/soal/service/local/soal_service_local.dart';

part 'tobk_event.dart';

part 'tobk_state.dart';

class TOBKBloc extends Bloc<TOBKEvent, TOBKState> {
  final Map<String, List<Tob>> _listTOB = {};
  final Map<String, List<PaketTO>> _paketTryOut = {};
  final Map<String, int> _listPage = {};
  final Map<String, int> _listJumlahHalaman = {};

  set clearTOBKState(bool isLogout) {
    if (isLogout) {
      _listTOB.clear();
      _paketTryOut.clear();
    }
  }

  TOBKBloc() : super(TOBKInitial()) {
    on<TOBKEvent>((event, emit) async {
      final apiService = TOBServiceApi();
      final soalServiceLocal = SoalServiceLocal();
      final SoalBloc soalBloc = SoalBloc();

      // Local Variable
      bool _isLoadingTOB = true;
      bool _isLoadingPaketTO = true;
      bool _isLoadingSoal = true;
      bool _isLoadingLaporanGOA = true;
      int _indexCurrentMataUji = 0;
      Duration? _sisaWaktu;
      DateTime? _serverTime;

      Future<Duration> _setSisaWaktuFirebase({
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
          return Duration(minutes: totalWaktuSeharusnya);
        } else {
          // Jika Peserta TO Firebase Exist.
          // Hitung sisa wakti dari peserta TO firebase.
          bool belumBerakhir =
              now.isBefore(pesertaFirebase.deadlinePengerjaan!);

          if (belumBerakhir) {
            return pesertaFirebase.deadlinePengerjaan!.difference(now);
          } else {
            // Sekedar Formalitas, kondisi ini akan terpenuhi jika boleh melihat solusi.
            return Duration(minutes: totalWaktuSeharusnya);
          }
        }
      }

      // Menghitung siswa waktu dan indexing nomor soal.
      Future<void> _setIndexingSoalBlockingTime({
        required String kodePaket,
        required int totalWaktuSeharusnya,
        int? sisaWaktuResponse,
      }) async {
        int waktuBerlalu = (totalWaktuSeharusnya * 60) - _sisaWaktu!.inSeconds;
        int sisaWaktuBundel = _sisaWaktu!.inSeconds;

        if (kDebugMode) {
          logger.log('TOB_Provider-SetIndexingSoalBlockingTime: '
              'Waktu Berlalu >> $waktuBerlalu detik | '
              'Sisa Waktu Total ${_sisaWaktu!.inMinutes} menit');
        }

        Map<String, List<DetailBundel>> listDetailWaktu = {};
        if (state is LoadedDetailWaktu) {
          listDetailWaktu = (state as LoadedDetailWaktu).listDetailWaktu;
        }

        int indexMataUjiAktif = 0;
        if (sisaWaktuResponse != null && sisaWaktuResponse > 0) {
          for (var detail in listDetailWaktu[kodePaket]!) {
            // Di kali 60 agar menjadi satuan detik.
            int waktuBundel = detail.waktuPengerjaan * 60;
            if (waktuBundel < waktuBerlalu) {
              // kurangi waktu temp
              waktuBerlalu -= waktuBundel;

              if (indexMataUjiAktif < listDetailWaktu[kodePaket]!.length - 1) {
                // Ubah ke mata uji selanjutnya.
                indexMataUjiAktif++;
              }
            }
          }
        }
        int waktuBundelAktif =
            listDetailWaktu[kodePaket]![indexMataUjiAktif].waktuPengerjaan * 60;

        if (waktuBerlalu < waktuBundelAktif) {
          // sisa waktu blocking time = waktuBundelAktif - sisa temp waktu.
          sisaWaktuBundel = waktuBundelAktif - waktuBerlalu;
        } else {
          sisaWaktuBundel = waktuBundelAktif;
        }
        _indexCurrentMataUji = indexMataUjiAktif;

        _sisaWaktu = Duration(seconds: sisaWaktuBundel);
        if (kDebugMode) {
          logger.log('TOB_Provider-SetIndexingSoalBlockingTime: '
              'Sisa Waktu >> $_sisaWaktu detik | '
              'index aktif >> $indexMataUjiAktif | $_indexCurrentMataUji');
        }
      }

      Future<List<DetailJawaban>> _getDetailJawabanSiswa({
        required String kodePaket,
        required String tahunAjaran,
        required String idSekolahKelas,
        String? noRegistrasi,
        String? tipeUser,
      }) async {
        // Jika user login
        if (noRegistrasi != null &&
            tipeUser != null &&
            tipeUser.toUpperCase() != 'ORTU') {
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
          return await soalServiceLocal.getJawabanSiswaByKodePaket(
            kodePaket: kodePaket,
            kumpulkanSemua: true,
          );
        }
      }

      dynamic setKunciJawabanSoal(
          String tipeSoal, Map<String, dynamic> jsonOpsi) {
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

            final data = opsi[0]['0']['jawaban'];
            for (final item in data) {
              if (item['jawaban']) {
                kunciJawabanTabel.add(item['urut'] - 1);
              }
            }
            // opsi.asMap().forEach((key, value) {
            //   final jawaban = value['jawaban'];

            //   final urut = jawaban
            //       .where((obj) => (obj as Map<String, dynamic>).containsValue(true))
            //       .toList();

            //   final jawabanValue =
            //       urut.length > 0 ? int.parse(urut[0]['urut'].toString()) - 1 : -1;

            //   if (kDebugMode) {
            //     logger.log(
            //         'SOAL_PROVIDER-SetKunciJawabanSoal: Key,Value >> $key | $value');
            //     logger
            //         .log('SOAL_PROVIDER-SetKunciJawabanSoal: Jawaban >> $jawaban');
            //     logger.log('SOAL_PROVIDER-SetKunciJawabanSoal: Urut >> $urut');
            //     logger.log(
            //         'SOAL_PROVIDER-SetKunciJawabanSoal: Jawaban Value >> $jawabanValue');
            //   }

            //   kunciJawabanTabel.insert(key, jawabanValue);
            // });

            if (kDebugMode) {
              logger
                  .log('SOAL_PROVIDER-SetKunciJawabanSoal: Opsi PBT >> $opsi');
              logger.log(
                  'SOAL_PROVIDER-SetKunciJawabanSoal: Kunci PBT >> $kunciJawabanTabel');
            }
            return kunciJawabanTabel;
          case 'PBB':
            List<dynamic> opsi = jsonOpsi['opsi'];
            Map<String, dynamic> kunciJawabanAlasan = {};

            opsi.asMap().forEach((key, value) {
              final indexOpsi = value['isbenar'] == true ? key : null;
              final listAlasan =
                  value['isbenar'] == true ? value['alasan'] : null;

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
              logger
                  .log('SOAL_PROVIDER-SetKunciJawabanSoal: Opsi PBB >> $opsi');
              logger.log(
                  'SOAL_PROVIDER-SetKunciJawabanSoal: Kunci PBB >> $kunciJawabanAlasan');
            }
            return kunciJawabanAlasan;
          case 'PBM':
            List<dynamic> opsi = jsonOpsi['opsi'];
            List<int> kunciJawabanPasangan = [];

            opsi.asMap().forEach((key, value) {
              kunciJawabanPasangan.insert(key, value['jodoh'] ?? -1);
            });

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
              kunciJawabanMajemuk.insert(key, value['keywords'] ?? -1);
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
              logger.log(
                  'SOAL_PROVIDER-setTranslatorEPB: After Remove >> $kolom');
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
              logger
                  .log('SOAL_PROVIDER-SetKunciJawabanEPB: Jawaban >> $jawaban');
              logger.log(
                  'SOAL_PROVIDER-SetKunciJawabanEPB: Cast >> $jawabanCast');
              logger.log(
                  'SOAL_PROVIDER-SetKunciJawabanEPB: Translator >> $translator');
              logger.log(
                  'SOAL_PROVIDER-SetKunciJawabanEPB: Cast >> $translatorCast');
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

      if (event is TOBKGetDaftarTOB) {
        try {
          String tobKey = '${event.idJenisProduk}' '${event.idBundlingAktif}';

          List<Tob> listTOBTemp = [];

          if (_listTOB.containsKey(tobKey)) {
            listTOBTemp = _listTOB[tobKey]!;
          }

          if (!event.isRefresh && listTOBTemp.isNotEmpty) {
            emit(LoadedListTOB(listTOBTemp));
            return;
          }

          emit(TOBIsLoading());

          final res = await apiService.fetchDaftarTOB(params: event.params);

          if (!_listTOB.containsKey(tobKey)) {
            _listTOB[tobKey] = [];
          }

          if ((res['data'] as List<dynamic>).isNotEmpty) {
            _listTOB[tobKey] = (res['data'] as List<dynamic>)
                .map((x) => TobModel.fromJson(x))
                .toList();
          }

          emit(LoadedListTOB(_listTOB[tobKey] ?? []));
        } on NoConnectionException catch (e) {
          emit(TOBKError(err: e.toString()));
        } on DataException catch (e) {
          emit(TOBKErrorResponse(e.toString()));
        } catch (e) {
          emit(TOBKError(err: e.toString()));
        }
      }

      if (event is TOBKCekBolehTO) {
        try {
          emit(TOBKSyaratLoading());

          bool isBolehTO = false;
          Map<String, SyaratTOBK> listSyaratTOB = {};
          List<String> listKodeTOBMemenuhiSyarat = [];

          if (state is LoadedPopUpSyaratTOBK) {
            listSyaratTOB = (state as LoadedPopUpSyaratTOBK).listSyaratTOB;
            listKodeTOBMemenuhiSyarat =
                (state as LoadedPopUpSyaratTOBK).listKodeTOBMemenuhiSyarat;
          }

          if (state is LoadedItemSyaratTOBK) {
            listSyaratTOB = (state as LoadedItemSyaratTOBK).listSyaratTOB;
            listKodeTOBMemenuhiSyarat =
                (state as LoadedItemSyaratTOBK).listKodeTOBMemenuhiSyarat;
          }

          if (event.isPopup) {
            final res = await apiService.cekBolehTO(
              noRegistrasi: event.noRegistrasi,
              kodeTOB: event.kodeTOB,
              namaTOB: event.namaTOB,
            );

            isBolehTO = res['status'];

            if (kDebugMode) {
              logger.log('TOB_PROVIDER-CekBolehTO: response >> $res');
            }

            if (res['data'] != null) {
              listSyaratTOB[event.kodeTOB] = SyaratTOBK.fromJson(res['data']);
            }

            if (res['data'] == null) {
              throw 'Data is Empty';
            }

            if (isBolehTO &&
                !listKodeTOBMemenuhiSyarat.contains(event.kodeTOB)) {
              listKodeTOBMemenuhiSyarat.add(event.kodeTOB);
              await Future.delayed(const Duration(milliseconds: 300));
            }

            emit(
              LoadedPopUpSyaratTOBK(listSyaratTOB, listKodeTOBMemenuhiSyarat),
            );
          } else {
            emit(
              LoadedItemSyaratTOBK(listSyaratTOB, listKodeTOBMemenuhiSyarat),
            );
          }
        } on NoConnectionException catch (e) {
          if (kDebugMode) {
            logger.log('NoConnectionException-CekBolehTO: $e');
          }
          emit(TOBKErrorSyarat(e.toString()));
        } on DataException catch (e) {
          if (kDebugMode) {
            logger.log('Exception-CekBolehTO: $e');
          }
          emit(TOBKErrorSyarat(e.toString()));
        } catch (e) {
          if (kDebugMode) {
            logger.log('FatalException-CekBolehTO: ${e.toString()}');
          }
          emit(TOBKErrorSyarat(e.toString()));
        }
      }

      if (event is TOBKSetServerTime) {
        emit(LoadedServerTimeTOBK(event.serverTime));
      }

      if (event is TOBKToggleRaguRagu) {}

      if (event is TOBKGetDetailJawabanSiswa) {
        try {
          // Jika user login
          List<DetailJawaban> result = [];
          if (event.noRegistrasi != null &&
              event.tipeUser != null &&
              event.tipeUser != 'ORTU') {
            final jawaban = [];
            result =
                jawaban.map((json) => DetailJawaban.fromJson(json)).toList();
          } else {
            result = await soalServiceLocal.getJawabanSiswaByKodePaket(
              kodePaket: event.kodePaket,
              kumpulkanSemua: true,
            );
          }
          emit(LoadedDetailJawabanSiswa(result));
        } catch (e) {
          emit(TOBKError(err: e.toString()));
        }
      }

      if (event is TOBKGetDaftarSoalTO) {
        try {
          int totalWaktuSeharusnya = event.totalWaktu;
          List<DetailBundel> listDetailWaktu = [];
          List<Soal> listSoal = [];
          Duration waktuPengerjaan = const Duration();
          final responseDetailWaktu = await apiService.fetchDetailWaktu(
            kodePaket: event.kodePaket,
            idJenisProduk: event.idJenisProduk,
          );

          if (responseDetailWaktu.isNotEmpty) {
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
              );

              listDetailWaktu.add(detailBundel);
            }
          }

          final response = await apiService.fetchDaftarSoalTO(
            noRegistrasi: event.noRegistrasi,
            kodeTOB: event.kodeTOB,
            // hardcode by arifin
            // isRemedialGOA: (event.idJenisProduk == 12) ? isRemedialGOA : false,
            isRemedialGOA: false,
            kodePaket: event.kodePaket,
            jenisStart: event.isAwalMulai ? 'awal' : 'lanjutan',
            waktu: (event.idJenisProduk == 12)
                ? '$totalWaktuSeharusnya'
                : '${event.totalWaktu}',
            tanggalSiswaSubmit: (event.tanggalSiswaSubmit != null)
                ? DataFormatter.dateTimeToString(event.tanggalSiswaSubmit!)
                : null,
            tanggalSelesai: (event.tanggalSelesai != null)
                ? DataFormatter.dateTimeToString(event.tanggalSelesai!)
                : null,
            tanggalKedaluwarsaTOB:
                DataFormatter.dateTimeToString(event.tanggalKedaluwarsaTOB),
            urutan: event.urutan,
            idJenisProduk: event.idJenisProduk,
            listIdBundleSoal: event.listIdBundleSoal,
          );

          // Get daftar soal
          List<dynamic> responseData = response['data'];

          // Response['sisaWaktu] dalam satuan detik. Lakukan jika bukan TOBK
          if (response['sisaWaktu'] != null &&
              (event.idJenisProduk == 12 || event.idJenisProduk == 80)) {
            if (response['sisaWaktu'] < 0) {
              // totalWaktu merupakan waktu dari Object PaketTO, satuan menit.
              _sisaWaktu = Duration(minutes: totalWaktuSeharusnya);
            } else {
              _sisaWaktu = Duration(seconds: response['sisaWaktu']);
            }
          }

          // Mengambil jawaban siswa yang ada di firebase.
          // Jika belum login atau Akun Ortu maka akan mengambil jawaban dari Hive.
          final List<DetailJawaban> jawabanFirebase =
              await _getDetailJawabanSiswa(
                  kodePaket: event.kodePaket,
                  tahunAjaran: event.tahunAjaran,
                  idSekolahKelas: event.idSekolahKelas,
                  noRegistrasi: event.noRegistrasi,
                  tipeUser: event.tipeUser);

          // Cek apakah response data memiliki data atau tidak
          if (responseData.isNotEmpty && listSoal.isEmpty) {
            int nomorSoalSiswa = 1;

            // if (isRandom && (jawabanFirebase.isEmpty || event.idJenisProduk == 12)) {
            //   var foldedData =
            //   responseData.fold<Map<String, List>>({}, (prev, dataSoal) {
            //     prev
            //         .putIfAbsent(dataSoal['c_namakelompokujian'], () => [])
            //         .add(dataSoal);
            //     return prev;
            //   });
            //
            //   responseData.clear();
            //   if (laporanGOA is! BelumMengerjakanGOA) {
            //     foldedData.removeWhere(
            //           (key, value) => laporanGOA.detailHasilGOA
            //           .where((detailHasil) => detailHasil.namaKelompokUjian == key)
            //           .any((detailHasil) => !detailHasil.isLulus),
            //     );
            //   }
            //   foldedData.forEach((key, value) {
            //     logger.log('TOB_PROVIDER-TryFold: Each Result $key >> $value');
            //     // Acak untuk random soal
            //     value.shuffle();
            //     value.shuffle();
            //     value.shuffle();
            //     responseData.addAll(value);
            //     logger.log(
            //         'TOB_PROVIDER-TryFold: Each Result $key Shuffle >> $value');
            //   });
            // }

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
                    dataSoal['tipe_soal'], dataSoal['opsi']);
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
              listSoal.add(SoalModel.fromJson(dataSoal));
              nomorSoalSiswa++;
            }

            // Jika baru membuka soal set mulai mengerjakan.
            if (!event.isTOBBerakhir) {
              // bool baruMulai = isRemedialGOA
              //     ? tanggalSiswaSubmit != null
              //     : tanggalSelesai == null;
              //
              // if (kDebugMode) {
              //   logger
              //       .log('TOB_Provider-GetDaftarSoalTO: Baru mulai >> $baruMulai');
              // }
              //
              // if (baruMulai) {
              //   _setMulaiTO(
              //       kodeTOB: kodeTOB,
              //       kodePaket: kodePaket,
              //       idJenisProduk: idJenisProduk,
              //       totalWaktuSeharusnya: totalWaktuSeharusnya,
              //       listPaketTO: listPaketTO);
              // }

              if (event.isBlockingTime) {
                waktuPengerjaan = Duration(
                  seconds:
                      ((response['waktuPengerjaan'] as double) * 60.0).toInt(),
                );
              }
            }
            if (kDebugMode) {
              logger.log('TOB_Provider-GetDaftarSoalTO: '
                  'Sisa Waktu >> $_sisaWaktu detik | '
                  'Index aktif >> $_indexCurrentMataUji');
            }
          }

          emit(LoadedSoal(
            listDetailWaktu: listDetailWaktu,
            listSoal: listSoal,
            indexPaket: event.urutan,
            waktuPengerjaan: waktuPengerjaan,
          ));
        } on NoConnectionException catch (e) {
          emit(TOBKError(err: e.toString()));
        } on DataException catch (e) {
          emit(TOBKError(err: e.toString()));
        } catch (e) {
          emit(TOBKError(err: e.toString()));
        }
      }

      if (event is TOBKGetKisiKisiPaket) {
        try {
          Map<String, List<KisiKisi>> listKisiKisi = {};
          if (state is LoadedListKisiKisi) {
            listKisiKisi = (state as LoadedListKisiKisi).listKisiKisi;
          }

          if (!event.isRefresh &&
              (listKisiKisi[event.kodePaket]?.isNotEmpty ?? false)) {
            return;
          }

          emit(TOBIsLoading());

          if (event.isRefresh) {
            listKisiKisi[event.kodePaket]?.clear();
          }

          final res = await apiService.fetchKisiKisi(
            kodePaket: event.kodePaket,
            idJenisProduk: event.idJenisProduk,
          );

          if (kDebugMode) {
            logger.log('TOB_PROVIDER-GetKisiKisiPaket: response data >> $res');
          }

          if (!listKisiKisi.containsKey(event.kodePaket)) {
            listKisiKisi[event.kodePaket] = [];
          }

          if (res.isNotEmpty && listKisiKisi[event.kodePaket]!.isEmpty) {
            for (Map<String, dynamic> kisiKisi in res) {
              listKisiKisi[event.kodePaket]!
                  .add(KisiKisiModel.fromJson(kisiKisi));
            }
          }

          emit(LoadedListKisiKisi(listKisiKisi));
        } on NoConnectionException catch (e) {
          if (kDebugMode) {
            logger.log('NoConnectionException-GetKisiKisiPaket: $e');
          }
          emit(TOBKError(err: e.toString()));
        } on DataException catch (e) {
          if (kDebugMode) {
            logger.log('Exception-GetKisiKisiPaket: $e');
          }
          emit(TOBKErrorResponse(e.toString()));
        } catch (e) {
          if (kDebugMode) {
            logger.log('FatalException-GetKisiKisiPaket: ${e.toString()}');
          }
          emit(TOBKError(err: e.toString()));
        }
      }

      // Di Buat BLOC Sendiri untuk Laporan GOA
      // if (event is TOBKGetLaporanGOA) {
      //   try {
      //     emit(TOBKLoading());
      //     Map<String, HasilGOA> laporanGOA = {};
      //     if (state is LoadedHasilGOA) {
      //       laporanGOA = (state as LoadedHasilGOA).hasilGOA;
      //     }

      //     if (!event.isRefresh && laporanGOA[event.kodePaket] != null) {
      //       emit(LoadedHasilGOA(laporanGOA));
      //       return;
      //     }

      //     if (event.isRefresh) {
      //       laporanGOA.remove(event.kodePaket);
      //       await Future.delayed(const Duration(milliseconds: 300));
      //     }

      //     final responseData = await apiService.fetchLaporanGOA(
      //       noRegistrasi: event.noRegistrasi,
      //       kodePaket: event.kodePaket,
      //     );

      //     if (kDebugMode) {
      //       logger.log(
      //           'TOB_PROVIDER-GetLaporanGOA: response data >> $responseData');
      //     }

      //     // Jika data tidak di temukan, maka responseData akan berbentuk int dengan value 0.
      //     if (responseData != 0 && !laporanGOA.containsKey(event.kodePaket)) {
      //       laporanGOA[event.kodePaket] = HasilGOAModel.fromJson(responseData);
      //     }

      //     if (kDebugMode) {
      //       logger.log(
      //           'TOB_PROVIDER-GetLaporanGOA: laporan GOA >> ${laporanGOA[event.kodePaket]}');
      //     }
      //     emit(LoadedHasilGOA(laporanGOA));
      //   } on NoConnectionException catch (e) {
      //     if (kDebugMode) {
      //       logger.log('NoConnectionException-GetLaporanGOA: $e');
      //     }
      //     emit(TOBKError(err: e.toString()));
      //   } on DataException catch (e) {
      //     if (kDebugMode) {
      //       logger.log('Exception-GetLaporanGOA: $e');
      //     }
      //     emit(TOBKError(err: e.toString()));
      //   } catch (e) {
      //     if (kDebugMode) {
      //       logger.log('FatalException-GetLaporanGOA: ${e.toString()}');
      //     }
      //     emit(TOBKError(err: e.toString()));
      //   }
      // }

      /// [kodeTOB] digunakan hanya untuk TOBK.
      /// Function ini untuk mengambil paket timer dari jenis produk manapun.
      if (event is TOBKGetDaftarPaketTO) {
        if (kDebugMode) {
          logger.log('TOB_PROVIDER-GetDaftarPaketTO: START');
        }
        // Update serverTime
        // _serverTime = await gGetServerTime();
        // Jika tidak refresh dan data sudah ada di cache [_listPaketTO]
        // maka return List dari [_listPaketTO].
        String cacheKey = event.kodeTOB ?? '${event.idJenisProduk}';
        Map<String, List<PaketTO>> listPaketTO = {};
        if (state is LoadedPaketTO) {
          listPaketTO = (state as LoadedPaketTO).listPaketTO;
        }

        if (!event.isRefresh && (listPaketTO[cacheKey]?.isNotEmpty ?? false)) {
          await Future.delayed(const Duration(milliseconds: 300));
          return;
        }
        emit(TOBKLoading());

        if (event.isRefresh) {
          listPaketTO[cacheKey]?.clear();
        }

        try {
          if (kDebugMode) {
            logger.log('TOB_PROVIDER-GetDaftarPaketTO: START');
          }
          final responseData = await apiService.fetchDaftarPaketTO(
            kodeTOB: event.kodeTOB ?? '',
          );

          if (kDebugMode) {
            logger.log('TOB_PROVIDER-GetDaftarPaketTO: data >> $responseData');
          }

          // Jika [_listPaketTO] tidak memiliki key kodeTOB tertentu maka buat key valuenya dulu.
          if (!listPaketTO.containsKey(cacheKey)) {
            listPaketTO[cacheKey] = [];
          }

          // Cek apakah response data memiliki data atau tidak
          if (responseData.isNotEmpty && listPaketTO[cacheKey]!.isEmpty) {
            for (Map<String, dynamic> dataPaketTO in responseData) {
              // Jika Bukan GOA(12) dan Bukan Racing(80)
              if (event.idJenisProduk != 12 && event.idJenisProduk != 80) {
                // Lakukan Sync data antara db GO dengan firebase
                // PesertaTO? pesertaFirebase = (noRegistrasi != null)
                //     ? await _firebaseHelper.getPesertaTOByKodePaket(
                //         noRegistrasi: noRegistrasi,
                //         tipeUser: teaserRole ?? 'No-User',
                //         kodePaket: dataPaketTO['kodePaket'],
                //       )
                //     : null;
                PesertaTO? pesertaFirebase;
                // Jika di firebase exist, maka lakukan sync ke Object local
                if (pesertaFirebase != null) {
                  dataPaketTO.update(
                    'tanggalMulai',
                    (value) => pesertaFirebase.kapanMulaiMengerjakan?.sqlFormat,
                    ifAbsent: () =>
                        pesertaFirebase.kapanMulaiMengerjakan?.sqlFormat,
                  );
                  dataPaketTO.update(
                    'tanggalDeadline',
                    (value) => pesertaFirebase.deadlinePengerjaan?.sqlFormat,
                    ifAbsent: () =>
                        pesertaFirebase.deadlinePengerjaan?.sqlFormat,
                  );
                  dataPaketTO.update(
                    'tanggal_mengumpulkan',
                    (value) => pesertaFirebase.tanggalSiswaSubmit?.sqlFormat,
                    ifAbsent: () =>
                        pesertaFirebase.tanggalSiswaSubmit?.sqlFormat,
                  );
                  dataPaketTO.update(
                    'isSelesai',
                    (value) => pesertaFirebase.isSelesai ? 'y' : 'n',
                    ifAbsent: () => pesertaFirebase.isSelesai ? 'y' : 'n',
                  );
                  dataPaketTO.update(
                    'isPernahMengerjakan',
                    (value) => pesertaFirebase.isPernahMengerjakan ? 'y' : 'n',
                    ifAbsent: () =>
                        pesertaFirebase.isPernahMengerjakan ? 'y' : 'n',
                  );
                  bool isWaktuHabis = false;
                  DateTime now = DateTime.now().serverTimeFromOffset;

                  if (pesertaFirebase.deadlinePengerjaan != null) {
                    isWaktuHabis =
                        now.isAfter(pesertaFirebase.deadlinePengerjaan!);
                  }

                  dataPaketTO.update(
                    'waktuHabis',
                    (value) => isWaktuHabis ? 'y' : 'n',
                    ifAbsent: () => isWaktuHabis ? 'y' : 'n',
                  );
                } else if (dataPaketTO['tanggalMulai'] != null &&
                    dataPaketTO['tanggalMulai'] != '-' &&
                    event.noRegistrasi != null) {
                  Map<String, dynamic> jsonPeserta = {
                    'cNoRegister': event.noRegistrasi,
                    'cKodeSoal': dataPaketTO['kodePaket'],
                    'cTanggalTO': dataPaketTO['tanggal_mengumpulkan'],
                    'cSudahSelesai': dataPaketTO['isSelesai'],
                    'cOK': dataPaketTO['isPernahMengerjakan'],
                    'cTglMulai': dataPaketTO['tanggalMulai'],
                    'cTglSelesai': dataPaketTO['tanggalDeadline'],
                    'cKeterangan': (dataPaketTO['cKeterangan'] != null)
                        ? jsonDecode(dataPaketTO['cKeterangan'])
                        : null,
                    'cPersetujuan': 0,
                    'cFlag': (dataPaketTO['cFlag'] is String)
                        ? int.tryParse('${dataPaketTO['cFlag']}') ?? 0
                        : 0,
                    'cPilihanSiswa': (dataPaketTO['cPilihanSiswa'] != null)
                        ? jsonDecode(dataPaketTO['cPilihanSiswa'])
                        : null,
                  };

                  if (kDebugMode) {
                    logger.log(
                        'TOB_PROVIDER-GetDaftarPaketTO: JsonPeserta >> $jsonPeserta');
                  }

                  // TODO: Lakukan sync data ke firebase jika ternyata data peserta pada db GO Exist tapi di firebase tidak.
                  // await _firebaseHelper.setPesertaTOFirebase(
                  //   noRegistrasi: noRegistrasi,
                  //   tipeUser: teaserRole ?? 'No-User',
                  //   kodePaket: dataPaketTO['kodePaket'],
                  //   pesertaTO: PesertaTOModel.fromJson(jsonPeserta),
                  // );
                }
              }
              // END OF SYNC FIREBASE

              // Konversi dataPaketTO menjadi BundelSoalModel dan store ke cache [_listPaketTO]
              listPaketTO[cacheKey]!.add(PaketTOModel.fromJson(dataPaketTO));
            }
            //
          }

          if (event.idJenisProduk == 12 && event.noRegistrasi != null) {
            // TODO: Cek apakah benar mengambil laporan GOA dari last list
            add(TOBKGetLaporanGOA(
              noRegistrasi: event.noRegistrasi ?? '',
              kodePaket: listPaketTO[cacheKey]!.first.kodePaket,
            ));

            await Future.delayed(const Duration(milliseconds: 300));
          }

          if (kDebugMode) {
            logger.log(
                'TOB_PROVIDER-GetDaftarPaketTO: data in cache >> ${listPaketTO[cacheKey]}');
          }
          emit(LoadedPaketTO(listPaketTO));
        } on NoConnectionException catch (e) {
          if (kDebugMode) {
            logger.log('NoConnectionException-GetDaftarPaketTO: $e');
          }
          emit(TOBKError(err: e.toString()));
        } on DataException catch (e) {
          if (kDebugMode) {
            logger.log('Exception-GetDaftarPaketTO: $e');
          }
          emit(TOBKError(err: e.toString()));
        } catch (e) {
          if (kDebugMode) {
            logger.log('FatalException-GetDaftarPaketTO: ${e.toString()}');
          }
          emit(TOBKError(err: e.toString()));
        }
      }

      // if (event is TOBKKumpulkanJawabanGOA) {
      //   try {
      //     List<DetailJawaban> daftarDetailJawaban = [];
      //     Map<String, List<PaketTO>> listPaketTO;
      //     add(TOBKGetDetailJawabanSiswa(
      //       kodePaket: event.kodePaket,
      //       tahunAjaran: event.tahunAjaran,
      //       idSekolahKelas: event.idSekolahKelas,
      //       noRegistrasi: event.noRegistrasi,
      //       tipeUser: event.tipeUser,
      //     ));

      //     if (state is LoadedDetailJawabanSiswa) {
      //       daftarDetailJawaban =
      //           (state as LoadedDetailJawabanSiswa).listDetailJawabanSiswa;
      //     }

      //     if (state is LoadedPaketTO) {
      //       listPaketTO = (state as LoadedPaketTO).listPaketTO;
      //     }

      //     if (kDebugMode) {
      //       logger.log(
      //           'TOB_Provider-KumpulkanJawabanTO: Detail Jawaban Firebase >> $daftarDetailJawaban');
      //     }

      //     if (event.noRegistrasi != null && event.tipeUser != null && event.tipeUser != 'ORTU') {
      //       // Kumpulkan / Simpan jawaban di server,
      //       // jika berhasil save ke server, baru save ke firebase.
      //       final bool isBerhasilSimpan = await apiService.simpanJawabanTO(
      //         tahunAjaran: event.tahunAjaran,
      //         noRegistrasi: event.noRegistrasi,
      //         tipeUser: event.tipeUser,
      //         idKota: event.idKota,
      //         idGedung: event.idGedung,
      //         idSekolahKelas: event.idSekolahKelas,
      //         tingkatKelas: event.tingkatKelas,
      //         idJenisProduk: event.idJenisProduk,
      //         kodeTOB: event.kodeTOB,
      //         kodePaket: event.kodePaket,
      //         detailJawaban: daftarDetailJawaban
      //             .map<Map<String, dynamic>>(
      //                 (detailJawaban) => detailJawaban.toJson())
      //             .toList(),
      //       );

      //       if (isBerhasilSimpan) {
      //         listSoal[cacheKey]
      //             ?.forEach((soal) => soal.sudahDikumpulkan = true);

      //         // await _firebaseHelper.updateKumpulkanJawabanSiswa(
      //         //   tahunAjaran: tahunAjaran,
      //         //   noRegistrasi: noRegistrasi,
      //         //   idSekolahKelas: idSekolahKelas,
      //         //   tipeUser: tipeUser,
      //         //   isKumpulkan: true,
      //         //   onlyUpdateNull: false,
      //         //   kodePaket: kodePaket,
      //         // );

      //         String paketKey = kodeTOB;
      //         if (_listPaketTO.containsKey(kodeTOB)) {
      //           DateTime waktuMengumpulkan = await gGetServerTime();

      //           _listPaketTO.forEach((kodeTOB, daftarPaket) async {
      //             for (PaketTO paketTO in daftarPaket) {
      //               if (paketTO.kodePaket == kodePaket) {
      //                 int indexPaket = _listPaketTO[kodeTOB]!.indexWhere(
      //                     (paket) =>
      //                         paket.kodeTOB == kodeTOB &&
      //                         paket.kodePaket == kodePaket);

      //                 if (indexPaket >= 0) {
      //                   _listPaketTO[kodeTOB]![indexPaket].isSelesai = true;
      //                   _listPaketTO[kodeTOB]![indexPaket].tanggalSiswaSubmit =
      //                       waktuMengumpulkan;

      //                   if (kDebugMode) {
      //                     logger.log(
      //                         'TOB_PROVIDER-KumpulkanJawabanTO: Paket After Kumpulkan >> ${_listPaketTO[kodeTOB]![indexPaket]}');
      //                   }
      //                 }
      //               }
      //             }
      //           });
      //         } else {
      //           paketKey = '$idJenisProduk';
      //           int indexPaket = _listPaketTO['$idJenisProduk']!.indexWhere(
      //               (paket) =>
      //                   paket.kodeTOB == kodeTOB &&
      //                   paket.kodePaket == kodePaket);

      //           if (indexPaket >= 0) {
      //             _listPaketTO['$idJenisProduk']![indexPaket].isSelesai = true;
      //             _listPaketTO['$idJenisProduk']![indexPaket]
      //                 .tanggalSiswaSubmit = await gGetServerTime();

      //             if (kDebugMode) {
      //               logger.log(
      //                   'TOB_PROVIDER-KumpulkanJawabanTO: Paket After Kumpulkan '
      //                   '>> ${_listPaketTO['$idJenisProduk']![indexPaket]}');
      //             }
      //           }
      //         }

      //         // If ini adalah GOA
      //         if (idJenisProduk == 12) {
      //           // TODO: Cek apakah benar mengambil laporan GOA dari last list
      //           await getLaporanGOA(
      //             noRegistrasi: noRegistrasi,
      //             kodePaket: _listPaketTO[paketKey]!.last.kodePaket,
      //             isRefresh: true,
      //           );

      //           // Get laporan GOA
      //           final HasilGOA laporanGOA = getLaporanGOAByKodePaket(
      //               _listPaketTO[paketKey]!.last.kodePaket);

      //           logger.log(
      //               'Laporan GOA >> isBelumMengerjakan ${laporanGOA is BelumMengerjakanGOA}');

      //           // Jika laporanGOA exist dan paket GOA tanggal submit-nya tidak null
      //           // maka reset jawaban yang remedial. Tanggal Submit akan di reset saat get soal remedial.
      //           if (laporanGOA is! BelumMengerjakanGOA &&
      //               laporanGOA.isRemedial) {
      //             for (var detailHasil in laporanGOA.detailHasilGOA) {
      //               if (!detailHasil.isLulus) {
      //                 // TODO: reset jawaban firebase
      //                 // await _firebaseHelper.resetRemedialGOA(
      //                 //   tahunAjaran: tahunAjaran,
      //                 //   noRegistrasi: noRegistrasi,
      //                 //   idSekolahKelas: idSekolahKelas,
      //                 //   tipeUser: tipeUser,
      //                 //   kodePaket: _listPaketTO[paketKey]!.last.kodePaket,
      //                 //   namaKelompokUjian: detailHasil.namaKelompokUjian,
      //                 // );
      //               }
      //             }

      //             // Jika remedial remove soal yang sudah lulus.
      //             if (laporanGOA.isRemedial &&
      //                 (listSoal['$kodeTOB-$kodePaket']?.isNotEmpty ?? false)) {
      //               // Menghapus daftar soal jika mata uji telah lulus saat remedial
      //               listSoal['$kodeTOB-$kodePaket']!.clear();
      //             }
      //           }
      //           await Future.delayed(const Duration(milliseconds: 300));
      //         }

      //         await gShowTopFlash(gNavigatorKey.currentState!.context,
      //             'Yeey, Jawaban kamu berhasil dikumpulkan Sobat',
      //             dialogType: DialogType.success);
      //       } else {
      //         // Deadline di ubah agar perhitungan sisawaktu berubah.
      //         DateTime deadlineBaru = DateTime.now().serverTimeFromOffset;
      //         if (_listPaketTO.containsKey(kodeTOB)) {
      //           _listPaketTO.forEach((kodeTOB, daftarPaket) async {
      //             for (PaketTO paketTO in daftarPaket) {
      //               if (paketTO.kodePaket == kodePaket) {
      //                 int indexPaket = _listPaketTO[kodeTOB]!.indexWhere(
      //                     (paket) =>
      //                         paket.kodeTOB == kodeTOB &&
      //                         paket.kodePaket == kodePaket);

      //                 if (indexPaket >= 0) {
      //                   _listPaketTO[kodeTOB]![indexPaket].deadlinePengerjaan =
      //                       deadlineBaru;

      //                   if (kDebugMode) {
      //                     logger.log('TOB_PROVIDER-KumpulkanJawabanTO: Paket '
      //                         'Gagal Kumpulkan >> ${_listPaketTO[kodeTOB]![indexPaket]}');
      //                   }
      //                 }
      //               }
      //             }
      //           });
      //         } else {
      //           // paketKey = '$idJenisProduk';
      //           int indexPaket = _listPaketTO['$idJenisProduk']!.indexWhere(
      //               (paket) =>
      //                   paket.kodeTOB == kodeTOB &&
      //                   paket.kodePaket == kodePaket);

      //           if (indexPaket >= 0) {
      //             _listPaketTO['$idJenisProduk']![indexPaket]
      //                 .deadlinePengerjaan = deadlineBaru;

      //             if (kDebugMode) {
      //               logger.log('TOB_PROVIDER-KumpulkanJawabanTO: Paket '
      //                   'Gagal Kumpulkan >> ${_listPaketTO['$idJenisProduk']![indexPaket]}');
      //             }
      //           }
      //         }

      //         await gShowTopFlash(
      //           gNavigatorKey.currentState!.context,
      //           errorGagalMenyimpanJawaban,
      //           dialogType: DialogType.error,
      //           duration: const Duration(seconds: 6),
      //         );
      //         _isLoadingPaketTO = false;
      //         notifyListeners();
      //         return false;
      //       }

      //       _isLoadingPaketTO = false;
      //       notifyListeners();
      //       return isBerhasilSimpan;
      //     } else {
      //       final bool isBerhasilSimpan =
      //           await _soalServiceLocal.updateKumpulkanJawabanSiswa(
      //         isKumpulkan: true,
      //         onlyUpdateNull: false,
      //         kodePaket: kodePaket,
      //       );

      //       if (isBerhasilSimpan) {
      //         listSoal[cacheKey]
      //             ?.forEach((soal) => soal.sudahDikumpulkan = true);

      //         if (_listPaketTO.containsKey(kodeTOB)) {
      //           DateTime waktuMengumpulkan = await gGetServerTime();

      //           _listPaketTO.forEach((kodeTOB, daftarPaket) async {
      //             for (PaketTO paketTO in daftarPaket) {
      //               if (paketTO.kodePaket == kodePaket) {
      //                 int indexPaket = _listPaketTO[kodeTOB]!.indexWhere(
      //                     (paket) =>
      //                         paket.kodeTOB == kodeTOB &&
      //                         paket.kodePaket == kodePaket);

      //                 if (indexPaket >= 0) {
      //                   _listPaketTO[kodeTOB]![indexPaket].isSelesai = true;
      //                   _listPaketTO[kodeTOB]![indexPaket].tanggalSiswaSubmit =
      //                       waktuMengumpulkan;

      //                   if (kDebugMode) {
      //                     logger.log(
      //                         'TOB_PROVIDER-KumpulkanJawabanSiswa: Paket After Kumpulkan '
      //                         '>> ${_listPaketTO[kodeTOB]![indexPaket]}');
      //                   }
      //                 }
      //               }
      //             }
      //           });
      //         } else {
      //           int indexPaket = _listPaketTO['$idJenisProduk']!.indexWhere(
      //               (paket) =>
      //                   paket.kodeTOB == kodeTOB &&
      //                   paket.kodePaket == kodePaket);

      //           if (indexPaket >= 0) {
      //             _listPaketTO['$idJenisProduk']![indexPaket].isSelesai = true;
      //             _listPaketTO['$idJenisProduk']![indexPaket]
      //                 .tanggalSiswaSubmit = await gGetServerTime();

      //             if (kDebugMode) {
      //               logger.log(
      //                   'TOB_PROVIDER-KumpulkanJawabanSiswa: Paket After Kumpulkan '
      //                   '>> ${_listPaketTO['$idJenisProduk']![indexPaket]}');
      //             }
      //           }
      //         }

      //         await gShowTopFlash(gNavigatorKey.currentState!.context,
      //             'Yeey, Jawaban kamu berhasil dikumpulkan Sobat',
      //             dialogType: DialogType.success);
      //       } else {
      //         await gShowTopFlash(gNavigatorKey.currentState!.context,
      //             'Gagal menyimpan jawaban Sobat, coba lagi!',
      //             dialogType: DialogType.error);
      //       }
      //     }
      //   } catch (e) {}
      // }

      if (event is TOBKSetSisaWaktuFirebase) {
        // Get Peserta TO in Firebase
        // PesertaTO? pesertaFirebase = await _firebaseHelper.getPesertaTOByKodePaket(
        //   noRegistrasi: noRegistrasi,
        //   tipeUser: tipeUser,
        //   kodePaket: kodePaket,
        // );
        PesertaTO? pesertaFirebase;
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
          _sisaWaktu = Duration(minutes: event.totalWaktuSeharusnya);
        } else {
          // Jika Peserta TO Firebase Exist.
          // Hitung sisa wakti dari peserta TO firebase.
          bool belumBerakhir =
              now.isBefore(pesertaFirebase.deadlinePengerjaan!);

          if (belumBerakhir) {
            _sisaWaktu = pesertaFirebase.deadlinePengerjaan!.difference(now);
          } else {
            // Sekedar Formalitas, kondisi ini akan terpenuhi jika boleh melihat solusi.
            _sisaWaktu = Duration(minutes: event.totalWaktuSeharusnya);
          }
        }
      }

      if (event is TOBKSetMulaiTO) {
        emit(TOBIsLoading());
        try {
          bool resetGoa = true;
          if (event.isRemedialGOA) {
            resetGoa = await apiService.hitRemidialGOA(
                noRegistrasi: event.noRegister,
                tahunAjaran: event.tahunAjaran,
                kodePaket: event.kodePaket,
                tingkatKelas: event.tingkatKelas);
          }
          final res = await apiService.setMulaiTO(
            noRegistrasi: event.noRegister,
            tahunAjaran: event.tahunAjaran,
            kodePaket: event.kodePaket,
            totalWaktuPaket: event.totalWaktuPaket,
            merk: await gMerkHp(),
            versi: await gVersi(),
            versiOS: await gVersiOS(),
            idJenisProduk: event.idJenisProduk,
          );
          if (!res || !resetGoa) return;

          emit(TOBKSuccessMulaiTO(
            paketTO: event.paketTO,
            isRemedialGOA: event.isRemedialGOA,
          ));
        } on NoConnectionException catch (e) {
          emit(TOBKError(err: e.toString()));
        } on DataException catch (e) {
          emit(TOBKError(err: e.toString()));
        } catch (e) {
          emit(TOBKError(err: e.toString()));
        }
      }

      if (event is TOBKGetListTO) {
        List<PaketTO> listPaketTO = [];
        int page = 1;
        int jumlahHalaman = 1;

        String kodeProduk = '${event.idJenisProduk}-${event.kodeTOB}'
            '${event.idBundlingAktif}';

        if (_paketTryOut.containsKey(kodeProduk)) {
          listPaketTO = _paketTryOut[kodeProduk]!;
        }

        if (_listPage.containsKey(kodeProduk)) {
          page = _listPage[kodeProduk]!;
        }

        if (_listJumlahHalaman.containsKey(kodeProduk)) {
          jumlahHalaman = _listJumlahHalaman[kodeProduk]!;
        }

        if (!event.isRefresh && listPaketTO.isNotEmpty) {
          emit(LoadedListTO(
            paketTO: listPaketTO,
            page: page,
            isRefresh: event.isRefresh,
          ));
          return;
        }

        if (event.page == null || event.page == 1) {
          emit(TOBKLoading());
        } else {
          emit(TOBKPaginateLoading());
        }

        try {
          // kuis
          if (event.idJenisProduk == 16) {
            final res = await apiService.fetchDaftarKuis(
                idJenisProduk: event.idJenisProduk.toString(),
                listIdProduk: event.listIdProduk,
                page: event.page ?? 1,
                noRegistrasi: event.noRegistrasi);
            final List<dynamic> listBundelSoalResponse =
                res['list_paket'] ?? [];
            final List<dynamic> listNamaKelompokUjian =
                res['list_kelompok_ujian'] ?? [];
            final int jumlahHalaman = res['jumlah_halaman'];

            if (listBundelSoalResponse.isEmpty) {
              throw 'Paket Kuis tidak ditemukan';
            }

            if (!_paketTryOut.containsKey(kodeProduk)) {
              _paketTryOut[kodeProduk] = [];
            }

            List<PaketTO> mappedList = [];

            for (Map<String, dynamic> dataPaket in listBundelSoalResponse) {
              final int cIdKelompokUjian =
                  dataPaket['daftar_bundel_soal'][0]['c_id_kelompok_ujian'];

              // Cari nama kelompok ujian berdasarkan cIdKelompokUjian
              String? namaKelompokUjian;
              String? singkatan;
              String? icon;
              for (Map<String, dynamic> namaKelompok in listNamaKelompokUjian) {
                if (namaKelompok['c_id_kelompok_ujian'] == cIdKelompokUjian) {
                  namaKelompokUjian = namaKelompok['c_nama_kelompok_ujian'];
                  singkatan = namaKelompok['c_singkatan'];
                  icon = namaKelompok['c_icon_mapel_mobile'] ??
                      namaKelompok['c_icon_mapel_web'];
                  break;
                }
              }

              dataPaket['nama_kelompok_ujian'] = namaKelompokUjian;
              dataPaket['singkatan'] = singkatan;
              dataPaket['iconMapel'] = icon;

              // _paketTryOut[kodeProduk]!.add(QuizModel.fromJson(dataPaket));
              mappedList.add(QuizModel.fromJson(dataPaket));
            }

            if (event.page == 1) {
              _paketTryOut[kodeProduk] = mappedList;
            } else {
              _paketTryOut[kodeProduk]!.addAll(mappedList);
            }

            _listPage[kodeProduk] = (event.page == null) ? 1 : event.page!;
            _listJumlahHalaman[kodeProduk] = jumlahHalaman;

            // Tambahkan data ke dalam listBundelSoal
            emit(LoadedListTO(
              paketTO: _paketTryOut[kodeProduk]?.toSet().toList() ?? [],
              page: event.page,
              jumlahHalaman: jumlahHalaman,
              isRefresh: event.isRefresh,
            ));
          } else {
            // get list tobk, racing, goa
            final res = await apiService.getListTO(
              idJenisProduk: event.idJenisProduk,
              listIdProduct: event.listIdProduk,
              kodeTOB: event.kodeTOB,
              page: event.page ?? 1,
              noRegistrasi: event.noRegistrasi,
            );

            if (!_paketTryOut.containsKey(kodeProduk)) {
              _paketTryOut[kodeProduk] = [];
            }

            switch (event.idJenisProduk) {
              // racing, goa
              case 12:
              case 80:
                final mappedList = (res['data']['list_paket'] as List<dynamic>)
                    .map((x) => Data.fromJson(x).convertToPaketTO())
                    .toList();

                if (event.page == 1) {
                  _paketTryOut[kodeProduk] = mappedList;
                } else {
                  _paketTryOut[kodeProduk]!.addAll(mappedList);
                }

                final jumlahHalaman = res['data']['jumlah_halaman'];

                _listPage[kodeProduk] = (event.page == null) ? 1 : event.page!;
                _listJumlahHalaman[kodeProduk] = jumlahHalaman;

                emit(LoadedListTO(
                  paketTO: _paketTryOut[kodeProduk]?.toSet().toList() ?? [],
                  page: event.page,
                  jumlahHalaman: jumlahHalaman,
                  isRefresh: event.isRefresh,
                ));
                return;
              default:
                // tobk
                _paketTryOut[kodeProduk] = (res['data'] as List<dynamic>)
                    .map((x) => PaketTOModel.fromJson(x))
                    .toList();

                final paketTO =
                    _paketTryOut[kodeProduk]?.toSet().toList() ?? [];

                emit(LoadedListTO(
                  paketTO: paketTO,
                  page: event.page,
                  isRefresh: event.isRefresh,
                ));
            }
          }
        } on NoConnectionException catch (e) {
          emit(TOBKError(err: e.toString(), page: event.page));
        } on DataException catch (e) {
          if (e.toString().contains('Siswa belum memilih mapel pilihan!')) {
            emit(TOBKErrorMapel());
          } else {
            emit(TOBKError(
              err: e.toString(),
              page: event.page,
              shouldBeEmpty: event.page == 1,
            ));
          }
        } catch (e) {
          if (e is DioException) {
            emit(TOBKErrorResponse(e.toString()));
          } else {
            emit(TOBKError(err: e.toString(), page: event.page));
          }
        }
      }

      if (event is TOBKSetUrutanPaket) {
        emit(LoadedUrutanPaket(event.urutan));
      }

      if (event is TOBKSetBlockingTime) {
        Duration sisaWaktu = Duration(seconds: event.waktuPengerjaan);
        emit(LoadedSisaWaktu(sisaWaktu));
      }

      if (event is TOBKGetAllJawabanSiswa) {
        try {
          if (state is LoadedSoal) {
            List<Soal> listSoal = (state as LoadedSoal).listSoal;
            final res = await TOBServiceApi().getSortJawabanSiswa(
              noRegister: event.noRegistrasi ?? '',
              kodePaket: event.kodePaket,
              tahunAjaran: event.tahunAjaran ?? '',
              urutan: event.urutan,
              idJenisProduk: event.idJenisProduk,
            );

            List<JawabanSiswa> listJawabanSiswa =
                res.map((x) => JawabanSiswaModel.fromJson(x)).toList();

            int totalSoalRagu = 0;

            for (var value in listJawabanSiswa) {
              for (int i = 0; i < listSoal.length; i++) {
                Soal itemSoal = listSoal[i];
                if (value.idSoal == itemSoal.idSoal) {
                  itemSoal = itemSoal.copyWith(
                    isRagu: value.isRagu,
                    jawabanSiswa: value.jawabanSiswa,
                  );
                }
              }

              if (value.isRagu) {
                totalSoalRagu += 1;
              }
            }

            emit(LoadedSoal(
              listSoal: listSoal,
              totalSoalRagu: totalSoalRagu,
            ));
          }
        } on NoConnectionException catch (e) {
          emit(TOBKError(err: e.toString()));
        } on DataException catch (e) {
          emit(TOBKError(err: e.toString()));
        } catch (e) {
          emit(TOBKError(err: e.toString()));
        }
      }

      if (event is TOBKIntervalTimer) {
        emit(LoadedIntervalTimer(event.timer));
      }
    });
  }
}
