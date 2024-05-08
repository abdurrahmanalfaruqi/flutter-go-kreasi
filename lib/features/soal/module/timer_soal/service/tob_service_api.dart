import 'dart:developer' as logger show log;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gokreasi_new/api/dummy_data.dart';
import 'package:gokreasi_new/core/config/constant.dart';
import 'package:gokreasi_new/core/config/global.dart';
import 'package:gokreasi_new/core/helper/dio_option_helper.dart';
import 'package:gokreasi_new/core/helper/kreasi_shared_pref.dart';
import 'package:gokreasi_new/core/shared/entity/dio_error_handler.dart';
import 'package:gokreasi_new/core/util/injector.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/profile/domain/entity/kelompok_ujian.dart';

import '../../../../ptn/module/ptnclopedia/entity/kampus_impian.dart';
import '../../../../../core/helper/api_helper.dart';
import '../../../../../core/helper/hive_helper.dart';

class TOBServiceApi {
  final ApiHelper _apiHelper = locator<ApiHelper>();

  static final TOBServiceApi _instance = TOBServiceApi._internal();

  factory TOBServiceApi() => _instance;

  TOBServiceApi._internal();

  Future<Map<String, dynamic>> fetchDaftarTOB({
    required Map<String, dynamic> params,
  }) async {
    final response = await _apiHelper.dio.post(
      '/tobk/v2/mobile/list-tob',
      data: params,
      options: DioOptionHelper().dioOption,
    );

    if (kDebugMode) {
      logger.log('TOB_SERVICE_API-FetchDaftarTOB: response >> $response');
    }

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }

    return response.data;
  }

  Future<Map<String, dynamic>> cekBolehTO({
    String? noRegistrasi,
    required String kodeTOB,
    required String namaTOB,
  }) async {
    final response = await _apiHelper.dio
        .get('tryout/mobile/tryout/syarat/$kodeTOB/$noRegistrasi',
            options: Options(
              headers: {
                "X-API-KEY": kDebugMode
                    ? dotenv.env['X-API-KEY_DEV']
                    : dotenv.env['X_API_KEY_PROD'],
              },
            ));

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }
    return response.data;
  }

  Future<Map<String, dynamic>> fetchDaftarKuis({
    required String idJenisProduk,
    required List<int> listIdProduk,
    required int page,
    required String? noRegistrasi,
    int offset = 10,
  }) async {
    try {
      final response = await _apiHelper.dio.post(
        '/buku-sakti/mobile/v1/buku-sakti-mobile/kuis/listpaket',
        data: {
          "no_register": noRegistrasi,
          "list_id_produk": listIdProduk,
          "halaman": page,
          "konten_per_halaman": offset,
        },
        options: DioOptionHelper().dioOption,
      );

      if (response.data['meta']['code'] != 200) {
        throw DioErrorHandler.errorFromResponse(response);
      }

      List<dynamic> listPaket = response.data['data']['list_paket'];
      List<dynamic> listNamaKelompokUjian =
          response.data['data']['list_kelompok_ujian'];
      int jumlahHalaman = response.data['data']['jumlah_halaman'];

      return {
        "list_paket": listPaket,
        "list_kelompok_ujian": listNamaKelompokUjian,
        "jumlah_halaman": jumlahHalaman,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getListTO({
    required int idJenisProduk,
    required List<int> listIdProduct,
    required int page,
    required String? noRegistrasi,
    String? kodeTOB,
    int offset = 10,
  }) async {
    bool isAppStore =
        gAkunTesterSiswa.contains(KreasiSharedPref().getNomorReg()) &&
            Platform.isIOS;
    try {
      String url = '';
      Response res;
      if (idJenisProduk != 25) {
        switch (idJenisProduk) {
          case 80:
            url = Constant.listRacing;
            break;
          case 12:
            url = Constant.listGOA;
            break;
          default:
        }

        res = await _apiHelper.dio.post(
          url,
          data: {
            "no_register": noRegistrasi,
            "list_id_produk": listIdProduct,
            "halaman": page,
            "konten_per_halaman": offset,
          },
          options: DioOptionHelper().dioOption,
        );
      } else {
        // get list paket tobk
        res = await _apiHelper.dio.post(
          data: {
            "kode_tob": int.parse(kodeTOB ?? '0'),
            "no_register": noRegistrasi
          },
          options: DioOptionHelper().dioOption,
          Constant.listTOBK,
        );
      }

      if (res.data['meta']['code'] != 200) {
        if (isAppStore) {
          switch (idJenisProduk) {
            case 80:
              return gDummyRacing;
            default:
          }
        } else {
          throw DioErrorHandler.errorFromResponse(res);
        }
      }

      return res.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Jika User belum login, maka [noRegistrasi] diisi dengan imei device.
  Future<List<dynamic>> fetchDaftarPaketTO({
    required String kodeTOB,
  }) async {
    final response = await _apiHelper.dio.get(
      '/tobk/mobile/v1/tobk/listpaket/$kodeTOB',
      options: DioOptionHelper().dioOption,
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }

    return response.data['data'] ?? [];
  }

  Future<List<dynamic>> fetchKisiKisi({
    required String kodePaket,
    required int idJenisProduk,
  }) async {
    String url = '';
    switch (idJenisProduk) {
      case 25:
        url = Constant.kisiTOBK;
        break;
      case 12:
        url = Constant.kisiGOA;
        break;
      case 16:
        url = Constant.kisiKuis;
        break;
      case 80:
        url = Constant.kisiRacing;
        break;
      default:
    }
    final response = await _apiHelper.dio.get(
      url + kodePaket,
      options: DioOptionHelper().dioOption,
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }

    return response.data['data'] ?? [];
  }

  /// [fetchDetailWaktu] digunakan untuk mendapatkan list subtest
  /// khusus GOA wajib mengirim params untuk mendapatkan isLulus dari setiap subtest
  Future<List<dynamic>> fetchDetailWaktu({
    required String kodePaket,
    required int idJenisProduk,
    UserModel? userData,
  }) async {
    String url = '';
    switch (idJenisProduk) {
      case 25:
        url = Constant.waktuTOBK;
        break;
      case 12:
        url = Constant.waktuGOA;
        break;
      case 16:
        url = Constant.waktuKuis;
        break;
      case 80:
        url = Constant.waktuRacing;
        break;
      default:
    }
    final response = await _apiHelper.dio.get(
      url + kodePaket,
      options: DioOptionHelper().dioOption,
      queryParameters: (idJenisProduk == 12)
          ? {
              "no_register": userData?.noRegistrasi,
              "tahun_ajaran": userData?.tahunAjaran,
              "tingkat_kelas": userData?.tingkatKelas,
            }
          : null,
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }

    return response.data['data'] ?? [];
  }

  /// [isRemedialGOA] menandakan GOA ini remedial atau tidak, untuk selain GOA isi dengan false.<br>
  /// [jenisStart] (awal / lanjutan). Menandakan apakah Siswa mengerjakan
  /// dari awal atau melanjutkan.<br>
  /// [waktu] pengerjaan soal didapat dari totalWaktu paket.<br>
  /// [tanggalSelesai] merupakan tanggal seharusnya siswa selesai mengerjakan,
  /// didapat dari response saat get paket. (format: 2022-07-14 13:00:00 | yyyy-MM-dd HH:mm:ss)<br>
  /// [tanggalKedaluwarsaTOB] didapat dari Object TOB. (format: 2022-07-14 13:00:00 | yyyy-MM-dd HH:mm:ss)
  Future<Map<String, dynamic>> fetchDaftarSoalTO({
    required String kodeTOB,
    required bool isRemedialGOA,
    String? noRegistrasi,
    required String kodePaket,
    required String jenisStart,
    required String waktu,
    String? tanggalSelesai,
    String? tanggalSiswaSubmit,
    required String tanggalKedaluwarsaTOB,
    required int urutan,
    required int idJenisProduk,
    List<int>? listIdBundleSoal,
  }) async {
    Map<String, dynamic> params = {
      'kode_paket': kodePaket,
      'urutan': urutan,
      'no_register': noRegistrasi,
    };
    // params.putIfAbsent('merk', () => merekHp);
    // params.putIfAbsent('versi_os', () => versiOS);

    // Belum ada di update 1.1.2
    if (kodePaket.contains('TO')) {
      // List<KampusImpian> pilihanJurusanHive =
      // await HiveHelper.getDaftarKampusImpian();
      // List<Map<String, dynamic>> pilihanJurusan = pilihanJurusanHive
      //     .map<Map<String, dynamic>>((jurusan) => {
      //           'kodejurusan': jurusan.idJurusan,
      //           'namajurusan': jurusan.namaJurusan
      //         })
      //     .toList();

      // List<KelompokUjian> pilihanKelompokUjianHive =
      //     await HiveHelper.getKonfirmasiTOMerdeka(kodeTOB: kodeTOB);
      // List<Map<String, dynamic>> pilihanKelompokUjian = pilihanKelompokUjianHive
      //     .map<Map<String, dynamic>>((mataUji) => {
      //           'id': mataUji.idKelompokUjian,
      //           'namaKelompokUjian': mataUji.namaKelompokUjian
      //         })
      //     .toList();

      // params.putIfAbsent(
      //     'keterangan',
      //     () => {
      //           'jurusanPilihan': {
      //             "pilihan1":
      //                 (pilihanJurusan.isNotEmpty) ? pilihanJurusan[0] : null,
      //             "pilihan2":
      //                 (pilihanJurusan.length > 1) ? pilihanJurusan[1] : null,
      //           },
      //           'mapelPilihan': pilihanKelompokUjian
      //         });
    }

    String url = '';
    switch (idJenisProduk) {
      case 16:
        // kuis
        url = Constant.soalKuis;
        break;
      case 12:
        // goa
        url = Constant.soalGOA;
        break;
      case 80:
        // racing
        url = Constant.soalRacing;
        break;
      default:
        // tobk
        url = Constant.soalTOBK;
    }

    final response = await _apiHelper.dio.post(
      url,
      data: params,
      options: DioOptionHelper().dioOption,
    );

    if (response.data['meta']['code'] != 200) {
      throw DioErrorHandler.errorFromResponse(response);
    }

    return {
      'sisaWaktu': response.data['waktu_pengerjaan'],
      'data': response.data['data']['detail_soal'] ?? [],
      'waktuPengerjaan': response.data['data']['sisa_waktu'],
    };
  }

  Future<bool> updatePesertaTO({
    String? noRegistrasi,
    required String kodePaket,
    required String tahunAjaran,
    required int idJenisProduk,
    required String kodeTOB,
    required List<KampusImpian> listKampusImpian,
  }) async {
    try {
      Map<String, dynamic> params = {
        'noRegistrasi': noRegistrasi,
        'kodePaket': kodePaket,
        'tahunAjaran': tahunAjaran,
      };

      if (idJenisProduk == 25) {
        List<Map<String, dynamic>> pilihanJurusan = listKampusImpian
            .map<Map<String, dynamic>>((jurusan) => {
                  'kodejurusan': jurusan.idJurusan,
                  'namajurusan': jurusan.namaJurusan
                })
            .toList();

        List<KelompokUjian> pilihanKelompokUjianHive =
            await HiveHelper.getKonfirmasiTOMerdeka(kodeTOB: kodeTOB);
        List<Map<String, dynamic>> pilihanKelompokUjian =
            pilihanKelompokUjianHive
                .map<Map<String, dynamic>>((mataUji) => {
                      'id': mataUji.idKelompokUjian,
                      'namaKelompokUjian': mataUji.namaKelompokUjian
                    })
                .toList();

        params.putIfAbsent(
            'keterangan',
            () => {
                  'jurusanPilihan': {
                    "pilihan1":
                        (pilihanJurusan.isNotEmpty) ? pilihanJurusan[0] : null,
                    "pilihan2":
                        (pilihanJurusan.length > 1) ? pilihanJurusan[1] : null,
                  },
                  'mapelPilihan': pilihanKelompokUjian
                });
      }

      final response = await _apiHelper.dio.post(
        '/tryout/peserta/update',
        data: params,
      );

      return response.data['meta']['code'] == 200;
    } catch (e) {
      if (kDebugMode) {
        logger.log('TOB_SERVICE_API-UpdatePesertaTO: $e');
      }
      return false;
    }
  }

  // Untuk sementara API ini hanya di gunakan untuk GOA saja.
  // Untuk timer selain GOA di pindahkan ke updatePesertaTO
  Future<bool> simpanJawabanTO({
    String? noRegistrasi,
    String? tipeUser,
    required String tingkatKelas,
    required String idSekolahKelas,
    required String idKota,
    required String idGedung,
    required String kodeTOB,
    required String kodePaket,
    required String tahunAjaran,
    required int idJenisProduk,
    required List<Map<String, dynamic>> detailJawaban,
    required List<KampusImpian> listKampusImpian,
  }) async {
    Map<String, dynamic> params = {
      'nis': noRegistrasi,
      'role': tipeUser,
      'idpenanda': idKota,
      'idgedung': idGedung,
      'idsekolahkelas': idSekolahKelas,
      'idtingkatkelas': tingkatKelas,
      'tahunajaran': tahunAjaran,
      'jenisproduk': idJenisProduk,
      'kodetob': kodeTOB,
      'kodepaket': kodePaket,
      'detailJawaban': detailJawaban
    };

    if (idJenisProduk == 25) {
      List<Map<String, dynamic>> pilihanJurusan = listKampusImpian
          .map<Map<String, dynamic>>((jurusan) => {
                'kodejurusan': jurusan.idJurusan,
                'namajurusan': jurusan.namaJurusan
              })
          .toList();

      // params.putIfAbsent(
      //     'jurusanpilihan',
      //     () => {
      //           "pilihan1": pilihanJurusan[0],
      //           "pilihan2": pilihanJurusan[1],
      //         });

      List<KelompokUjian> pilihanKelompokUjianHive =
          await HiveHelper.getKonfirmasiTOMerdeka(kodeTOB: kodeTOB);
      List<Map<String, dynamic>> pilihanKelompokUjian = pilihanKelompokUjianHive
          .map<Map<String, dynamic>>((mataUji) => {
                'id': mataUji.idKelompokUjian,
                'namaKelompokUjian': mataUji.namaKelompokUjian
              })
          .toList();

      // params.putIfAbsent('mapelpilihan', () => pilihanKelompokUjian);
      params.putIfAbsent(
          'keterangan',
          () => {
                'jurusanPilihan': {
                  "pilihan1":
                      (pilihanJurusan.isNotEmpty) ? pilihanJurusan[0] : null,
                  "pilihan2":
                      (pilihanJurusan.length > 1) ? pilihanJurusan[1] : null,
                },
                'mapelPilihan': pilihanKelompokUjian
              });
    }

    // idJenisProduk 12 adalah e-GOA
    final response = await _apiHelper.dio.post(
        '/${(idJenisProduk == 12) ? 'profiling' : 'tryout'}'
        '/simpanjawaban',
        data: params);

    if (kDebugMode) {
      logger.log('Kumpulkan Jawaban TO-GOA response >> $response');
    }

    return response.data['meta']['code'] == 200;
  }

  Future<dynamic> fetchLaporanGOA({
    required String noRegistrasi,
    required String kodePaket,
    required String ta,
  }) async {
    // idJenisProduk 12 adalah e-GOA
    final response = await _apiHelper.dio.get(
      '/laporan/mobile/v1/laporan/laporan-hasil-goa/$noRegistrasi/$ta/$kodePaket',
    );

    return response.data['data'];
  }

  Future<bool> storeJawabanSiswa({
    required Map<String, dynamic> jawabanSiswa,
    required int idJenisProduk,
  }) async {
    try {
      String url = '';
      switch (idJenisProduk) {
        case 25:
          url = Constant.storeTOBK;
          break;
        case 16:
          url = Constant.storeKuis;
          break;
        case 12:
          url = Constant.storeGOA;
          break;
        case 80:
          url = Constant.storeRacing;
          break;
        default:
      }
      final res = await _apiHelper.dio.post(
        url,
        data: jawabanSiswa,
        options: DioOptionHelper().dioOption,
      );

      if (res.data['meta']['code'] != 200) {
        throw DioErrorHandler.errorFromResponse(res);
      }

      return res.data['meta']['code'] == 200;
    } catch (e) {
      if (e is DioException) {
        throw DioErrorHandler.errorFromDio(e);
      }
      rethrow;
    }
  }

  Future<bool> setMulaiTO({
    required String noRegistrasi,
    required String tahunAjaran,
    required String kodePaket,
    required int totalWaktuPaket,
    required String merk,
    required String versi,
    required String versiOS,
    required int idJenisProduk,
  }) async {
    try {
      String url = '';
      switch (idJenisProduk) {
        case 25:
          url = Constant.startTOBK;
          break;
        case 16:
          url = Constant.startKuis;
          break;
        case 12:
          url = Constant.startGOA;
          break;
        case 80:
          url = Constant.startRacing;
          break;
        default:
      }
      final res = await _apiHelper.dio.post(
        url,
        data: {
          "no_register": noRegistrasi,
          "tahun_ajaran": tahunAjaran,
          "kode_paket": kodePaket,
          "total_waktu_paket": totalWaktuPaket,
          "merk": merk,
          "versi": versi,
          "versi_os": versiOS,
        },
        options: DioOptionHelper().dioOption,
      );

      if (res.data['meta']['code'] != 200) {
        throw DioErrorHandler.errorFromResponse(res);
      }

      return res.data['meta']['code'] == 200;
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }

  Future<List<dynamic>> getSortJawabanSiswa({
    required String noRegister,
    required String kodePaket,
    required String tahunAjaran,
    required int urutan,
    required int idJenisProduk,
  }) async {
    try {
      Response res;
      String url = '';
      switch (idJenisProduk) {
        case 16:
          url = Constant.getJawabanSortKuis;
          break;
        case 12:
          url = Constant.getJawabanSortGOA;
          break;
        case 80:
          url = Constant.getJawabanSortRacing;
          break;
        case 71:
          url = Constant.getJawabanSortEMMA;
          break;
        case 72:
          url = Constant.getJawabanSortEMWA;
          break;
        default:
          url = Constant.getJawabanSortTOBK;
      }

      if (idJenisProduk == 71 || idJenisProduk == 72) {
        res = await _apiHelper.dio.get(
          url,
          options: DioOptionHelper().dioOption,
          data: {
            "no_register": noRegister,
            "kode_paket": kodePaket,
            "tahun_ajaran": tahunAjaran,
            "urutan": urutan,
          },
        );
      } else {
        res = await _apiHelper.dio.post(
          url,
          options: DioOptionHelper().dioOption,
          data: {
            "no_register": noRegister,
            "kode_paket": kodePaket,
            "tahun_ajaran": tahunAjaran,
            "urutan": urutan,
          },
        );
      }

      return res.data['data']['list_jawaban_siswa'] ?? [];
    } catch (e) {
      if (e is DioException) {
        throw DioErrorHandler.errorFromDio(e);
      }
      rethrow;
    }
  }

  Future<List<dynamic>> getAllJawabanSiswa({
    required int idJenisProduk,
    required String noRegister,
    required String kodePaket,
    required String tahunAjaran,
  }) async {
    try {
      String url = '';
      switch (idJenisProduk) {
        case 16:
          url = Constant.getJawabanAllKuis;
          break;
        case 12:
          url = Constant.getJawabanAllGOA;
          break;
        case 80:
          url = Constant.getJawabanAllRacing;
          break;
        default:
          url = Constant.getJawabanAllTOBK;
      }
      final res = await _apiHelper.dio.post(
        url,
        options: DioOptionHelper().dioOption,
        data: {
          "no_register": noRegister,
          "kode_paket": kodePaket,
          "tahun_ajaran": tahunAjaran,
        },
      );

      return res.data['data']['list_jawaban_siswa'] ?? [];
    } catch (e) {
      if (e is DioException) {
        throw DioErrorHandler.errorFromDio(e);
      }
      rethrow;
    }
  }

  Future<List<dynamic>> getJawabanPaketTimer({
    required int idJenisProduk,
    required int idTingkatKelas,
    required String noRegistrasi,
    required String tahunAjaran,
    required String kodePaket,
  }) async {
    try {
      String url = '';
      switch (idJenisProduk) {
        case 12:
          url = Constant.kGetJawabanGOA;
          break;
        case 16:
          url = Constant.kGetJawabanKuis;
          break;
        default:
          url = Constant.kGetJawabanRacing;
      }

      final res = await _apiHelper.dio.post(
        url,
        data: {
          "no_register": noRegistrasi,
          "id_tingkat_kelas": idTingkatKelas,
          "tahun_ajaran": tahunAjaran,
          "kode_paket": kodePaket,
        },
        options: DioOptionHelper().dioOption,
      );

      return res.data['data'];
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> submitTOBK({
    required String noRegistrasi,
    required String tahunAjaran,
    required String kodePaket,
    required int tingkatKelas,
    required int idJenisProduk,
    required UserModel? userData,
    String? kodeTOB,
  }) async {
    try {
      String url = '';
      Map<String, dynamic> param = {
        "no_register": noRegistrasi,
        "tahun_ajaran": tahunAjaran,
        "kode_paket": kodePaket,
        "tingkat_kelas": tingkatKelas,
      };

      switch (idJenisProduk) {
        case 25:
          url = Constant.endTOBK;
          param.addAll({
            "nama_lengkap": userData?.namaLengkap,
            "id_kota": int.parse(userData?.idKota ?? '0'),
            "id_gedung": int.parse(userData?.idGedung ?? '0'),
            "id_sekolah_kelas": int.parse(userData?.idSekolahKelas ?? '0'),
            "id_bundling": userData?.idBundlingAktif,
          });
          break;
        case 12:
          url = Constant.endGOA;
          break;
        case 16:
          url = Constant.endKuis;
          param.addAll({
            "nama_lengkap": userData?.namaLengkap,
            "id_kota": int.parse(userData?.idKota ?? '0'),
            "id_gedung": int.parse(userData?.idGedung ?? '0'),
            "id_sekolah_kelas": int.parse(userData?.idSekolahKelas ?? '0'),
            "id_bundling": userData?.idBundlingAktif,
          });
          break;
        case 80:
          url = Constant.endRacing;
          param.addAll({
            "id_bundling": userData?.idBundlingAktif,
            "nama_lengkap": userData?.namaLengkap,
            "id_kota": int.parse(userData?.idKota ?? '0'),
            "id_gedung": int.parse(userData?.idGedung ?? '0'),
            "kode_tob": kodeTOB,
            "id_sekolah_kelas": int.parse(userData?.idSekolahKelas ?? '0'),
          });
          break;
        default:
      }
      final res = await _apiHelper.dio.post(
        url,
        data: param,
        options: DioOptionHelper().dioOption,
      );
      if (res.data['meta']['code'] != 200) {
        throw DioErrorHandler.errorFromResponse(res);
      }

      return res.data['meta']['code'] == 200;
    } on DioException catch (e) {
      throw DioErrorHandler.errorFromDio(e);
    }
  }

  Future<bool> olahDataJawaban({
    required String noRegistrasi,
    required String tahunAjaran,
    required String kodePaket,
    required int tingkatKelas,
    required int idJenisProduk,
    required String namaJenisProduk,
    required UserModel? userData,
    String? kodeBab,
    List<int>? listIdSoal,
    int? idBundle,
  }) async {
    try {
      Map<String, dynamic> params = {
        "no_register": noRegistrasi,
        "tahun_ajaran": tahunAjaran,
        "nama_jenis_produk": namaJenisProduk,
        "kode_paket": kodePaket,
        "tingkat_kelas": int.parse(userData?.tingkatKelas ?? '0')
      };

      String url = '';
      switch (idJenisProduk) {
        case 25:
          url = Constant.olahTOBK;
          break;
        case 12:
          url = Constant.olahGOA;
          break;
        case 16:
          url = Constant.olahKuis;
          break;
        case 71:
          url = Constant.olahEMMA;
          params.addAll({
            'list_id_soal': listIdSoal,
            "nama_lengkap": userData?.namaLengkap,
            "id_kota": int.parse(userData?.idKota ?? '0'),
            "id_gedung": int.parse(userData?.idGedung ?? '0'),
            "id_sekolah_kelas": int.parse(userData?.idSekolahKelas ?? '0'),
            "id_bundling": userData?.idBundlingAktif,
          });
          break;
        case 72:
          url = Constant.olahEMWA;
          params.addAll({
            'list_id_soal': listIdSoal,
            "nama_lengkap": userData?.namaLengkap,
            "id_kota": int.parse(userData?.idKota ?? '0'),
            "id_gedung": int.parse(userData?.idGedung ?? '0'),
            "id_sekolah_kelas": int.parse(userData?.idSekolahKelas ?? '0'),
            "id_bundling": userData?.idBundlingAktif,
          });
          break;
        case 76:
          url = Constant.olahLateks;
          params.addAll({
            'list_id_soal': listIdSoal,
            "nama_lengkap": userData?.namaLengkap,
            "id_kota": int.parse(userData?.idKota ?? '0'),
            "id_gedung": int.parse(userData?.idGedung ?? '0'),
            "id_sekolah_kelas": int.parse(userData?.idSekolahKelas ?? '0'),
            "id_bundling": userData?.idBundlingAktif,
            "kode_bab": kodeBab,
            "id_bundel": idBundle,
          });
          break;
        case 77:
          url = Constant.olahPakins;
          params.addAll({
            'list_id_soal': listIdSoal,
            "nama_lengkap": userData?.namaLengkap,
            "id_kota": int.parse(userData?.idKota ?? '0'),
            "id_gedung": int.parse(userData?.idGedung ?? '0'),
            "id_sekolah_kelas": int.parse(userData?.idSekolahKelas ?? '0'),
            "id_bundling": userData?.idBundlingAktif,
            "kode_bab": kodeBab,
            "id_bundel": idBundle,
          });
          break;
        case 78:
          url = Constant.olahSokod;
          params.addAll({
            'list_id_soal': listIdSoal,
            "nama_lengkap": userData?.namaLengkap,
            "id_kota": int.parse(userData?.idKota ?? '0'),
            "id_gedung": int.parse(userData?.idGedung ?? '0'),
            "id_sekolah_kelas": int.parse(userData?.idSekolahKelas ?? '0'),
            "id_bundling": userData?.idBundlingAktif,
            "kode_bab": kodeBab,
            "id_bundel": idBundle,
          });
          break;
        case 79:
          url = Constant.olahPenmat;
          params.addAll({
            'list_id_soal': listIdSoal,
            "nama_lengkap": userData?.namaLengkap,
            "id_kota": int.parse(userData?.idKota ?? '0'),
            "id_gedung": int.parse(userData?.idGedung ?? '0'),
            "id_sekolah_kelas": int.parse(userData?.idSekolahKelas ?? '0'),
            "id_bundling": userData?.idBundlingAktif,
            "kode_bab": kodeBab,
            "id_bundel": idBundle,
          });
          break;
        case 82:
          url = Constant.olahSoref;
          params.addAll({
            'list_id_soal': listIdSoal,
            "nama_lengkap": userData?.namaLengkap,
            "id_kota": int.parse(userData?.idKota ?? '0'),
            "id_gedung": int.parse(userData?.idGedung ?? '0'),
            "id_sekolah_kelas": int.parse(userData?.idSekolahKelas ?? '0'),
            "id_bundling": userData?.idBundlingAktif,
            "kode_bab": kodeBab,
            "id_bundel": idBundle,
          });
          break;
        case 80:
          url = Constant.olahRacing;
          break;
        default:
      }
      final res = await _apiHelper.dio.post(
        url,
        data: params,
        options: DioOptionHelper().dioOption,
      );

      if (res.data['meta']['code'] != 200) {
        throw DioErrorHandler.errorFromResponse(res);
      }

      return res.data['meta']['code'] == 200;
    } catch (e) {
      if (e is DioException) {
        throw DioErrorHandler.errorFromDio(e);
      }
      rethrow;
    }
  }

  Future<bool> hitRemidialGOA({
    required String noRegistrasi,
    required String tahunAjaran,
    required String kodePaket,
    required int tingkatKelas,
  }) async {
    try {
      final res = await _apiHelper.dio.post(
        '/goa-vak/mobile/v1/goa-mobile/remedial-goa',
        data: {
          "no_register": noRegistrasi,
          "tahun_ajaran": tahunAjaran,
          "kode_paket": kodePaket,
          "tingkat_kelas": tingkatKelas,
        },
        options: DioOptionHelper().dioOption,
      );
      if (res.data['meta']['code'] != 200) {
        return false;
      }
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<int?> fetchUrutanAktif({
    required int idJenisProduk,
    required String noRegistrasi,
    required String kodePaket,
  }) async {
    try {
      String url = '';
      switch (idJenisProduk) {
        case 12:
          url = Constant.bUrutanAktifGOA;
          break;
        case 16:
          url = Constant.bUrutanAktifKuis;
          break;
        case 80:
          url = Constant.bUrutanAktifRacing;
          break;
        default:
          url = Constant.bUrutanAktifTOBK;
      }

      final res = await _apiHelper.dio.get(
        url,
        options: DioOptionHelper().dioOption,
        queryParameters: {
          'no_register': noRegistrasi,
          'kode_paket': kodePaket,
        },
      );

      if (res.data['meta']['code'] != 200) {
        return null;
      }

      return res.data['data']['urutan_aktif'];
    } catch (_) {
      return null;
    }
  }
}
