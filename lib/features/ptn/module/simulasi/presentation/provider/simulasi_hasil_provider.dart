import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import 'package:gokreasi_new/core/config/enum.dart';
import 'package:gokreasi_new/core/config/global.dart';
import 'package:gokreasi_new/core/helper/kreasi_shared_pref.dart';
import 'package:gokreasi_new/features/ptn/module/simulasi/model/pilihan_model.dart';

import '../../model/hasil_model.dart';
import '../../service/api/simulasi_service_api.dart';
import '../../../../../../core/util/app_exceptions.dart';

class SimulasiHasilProvider with ChangeNotifier {
  final _apiService = SimulasiServiceAPI();

  bool _isLoading = false;
  final List<HasilModel> _listSimulasi = [];
  String? _errorHasil;

  bool get isLoading => _isLoading;
  List<HasilModel> get listSimulasi => _listSimulasi;
  String? get errorHasil => _errorHasil;

  /// [_validateEmptyPrioritas] digunakan untuk cek apakah ada prioritas yang
  /// di check tapi kosong
  List<HasilModel>? _validateEmptyPrioritas(List<PilihanModel> listPTNPilihan) {
    int invalidPilihan = listPTNPilihan.indexWhere(
        (pilihan) => pilihan.isAktif && pilihan.namaJurusan?.idJurusan == null);

    if (invalidPilihan >= 0) {
      gShowTopFlash(
        gNavigatorKey.currentContext!,
        'Prioritas ke ${invalidPilihan + 1} kosong sobat',
        dialogType: DialogType.error,
        duration: const Duration(seconds: 4),
      );
      _errorHasil =
          'Terjadi kesalahan, silahkan kembali ke step sebelumnya ya sobat';
      return [];
    }

    return null;
  }

  /// [loadSimulasi] digunakan untuk kalkulasi SNBT.
  /// namun dicek dulu apakah ada data yang dichecklist namun id jurusannya null
  /// namun remove array ketika id jurusannya null
  Future<List<HasilModel>> loadSimulasi({
    required String noRegistrasi,
    required int nilaiAkhir,
    required List<PilihanModel> listPTNPilihan,
  }) async {
    try {
      _errorHasil = null;
      _listSimulasi.clear();
      _isLoading = true;
      notifyListeners();

      String noreg = KreasiSharedPref().getNomorReg() ?? '';

      final validate = _validateEmptyPrioritas(listPTNPilihan);

      if (validate != null) {
        return validate;
      }

      List<PilihanModel> reqBodyData = [];

      listPTNPilihan.asMap().forEach((index, pilihan) {
        final newData = pilihan.copyWith(prioritas: index + 1);
        reqBodyData.add(newData);
      });

      reqBodyData.removeWhere((ptn) => ptn.namaJurusan?.idJurusan == null);

      final response = await _apiService.savePTN(
        {
          "data": reqBodyData
              .map((item) => item.toJson(noRegistrasi: noreg))
              .toList(),
        },
      );

      if (!response) {
        _errorHasil =
            'Terjadi kesalahan, silahkan kembali ke step sebelumnya ya sobat';
        return [];
      }

      final responseData = await _apiService.fetchSimulasi(
        noRegistrasi: noRegistrasi,
        nilaiAkhir: nilaiAkhir,
      );

      final res = responseData.cast<Map<String, dynamic>>();

      /// Used to check if the responseData is not null, then it will loop through the responseData and
      /// add it to the _listSimulasi.
      if (res.isNotEmpty) {
        for (int i = 0; i < res.length; i++) {
          final item = res[i];

          item.addAll({
            'data_peminat': _findNewestYear(
              item['peminat'].cast<Map<String, dynamic>>(),
            ),
            'data_daya_tampung': _findNewestYear(
              item['daya_tampung'].cast<Map<String, dynamic>>(),
            ),
          });
          _listSimulasi.add(HasilModel.fromJson(item));
        }
      }

      if (kDebugMode) {
        logger.log(
            'SIMULASI_HASIL_PROVIDER-LoadSimulasi: List Simulasi >> $_listSimulasi');
      }
      _isLoading = false;
      notifyListeners();
      return [..._listSimulasi];
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-LoadSimulasi: $e');
      }
      return [];
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-LoadSimulasi: $e');
      }

      if (e.toString() == 'Tidak ada jurusan yg dipilih!' ||
          e.toString() == 'pilihan ptn prioritas 1 sudah memilih 4 kali') {
        _errorHasil = e.toString();
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-LoadSimulasi: $e');
      }
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// [_findNewestYear] digunakan untuk mencari tahun terbaru dari peminat dan
  /// daya tampung
  Map<String, dynamic> _findNewestYear(List<Map<String, dynamic>> data) {
    int newestYear = data[0]["tahun"]!;

    for (int i = 1; i < data.length; i++) {
      int currentYear = data[i]["tahun"]!;
      if (currentYear > newestYear) {
        newestYear = currentYear;
      }
    }

    final newestData =
        data.firstWhere((element) => element['tahun'] == newestYear);

    return newestData;
  }
}
