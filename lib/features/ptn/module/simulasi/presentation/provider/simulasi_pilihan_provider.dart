import 'dart:developer' as logger show log;

import 'package:flutter/foundation.dart';
import 'package:gokreasi_new/core/config/global.dart';
import 'package:gokreasi_new/features/ptn/module/ptnclopedia/entity/jurusan.dart';
import 'package:gokreasi_new/features/ptn/module/ptnclopedia/entity/ptn.dart';

import '../../model/pilihan_model.dart';
import '../../service/api/simulasi_service_api.dart';
import '../../../../../../core/util/app_exceptions.dart';

class SimulasiPilihanProvider with ChangeNotifier {
  final _apiService = SimulasiServiceAPI();

  // List<UniversitasModel> _listUniversitas = [];
  bool _isLoading = false;
  List<PilihanModel> _listPilihan = [];
  int _index = -1;
  String? _errorPilihan;

  set index(int selectedIndex) {
    _index = selectedIndex;
    notifyListeners();
  }

  String? _selectedPrioritas;
  bool get isLoading => _isLoading;
  List<PilihanModel> get listPilihan => _listPilihan;
  PilihanModel get pilihan => _listPilihan[_index];
  String? get errorPilihan => _errorPilihan;

  String get selectedPrioritas => _selectedPrioritas!;

  void updatePilihanPTNByIndex(int index, PTN? selectedPTN) {
    pilihan.namaPTN = selectedPTN;
    pilihan.namaJurusan = null;
    notifyListeners();
  }

  void updatePilihanJurusanByIndex(int index, Jurusan? selectedJurusan) {
    pilihan.namaJurusan = selectedJurusan;
    pilihan.pg = (selectedJurusan?.passGrade != null)
        ? double.parse(selectedJurusan!.passGrade!)
        : 0.0;
    notifyListeners();
  }

  void updateListPilihanJurusan(List<PilihanModel> listPilihanPTN) {
    _listPilihan = listPilihanPTN;
  }

  void toggleSelectPTN() {
    pilihan.isAktif = !pilihan.isAktif;
    notifyListeners();
  }

  /// [loadPilihan] digunakan untuk mengambil list PTN SNBT Pilihan siswa.
  ///
  /// jika datanya kosong maka isi dengan 4 array kosong.
  /// jika ada datanya maka diisi sesuai nomor prioritas
  /// ex: prioritas 4 maka diisi sesuai urutan list ke 4
  Future<List<PilihanModel>> loadPilihan({
    required String noRegistrasi,
  }) async {
    if (kDebugMode) {
      logger.log(
          'SIMULASI_PILIHAN_PROVIDER-LoadPilihan: START with params($noRegistrasi)');
    }
    try {
      _errorPilihan = null;
      _isLoading = true;
      _listPilihan.clear();
      notifyListeners();
      final responseData = await _apiService.fetchPilihan(
        noRegistrasi: noRegistrasi,
      );

      if (responseData.isEmpty) {
        for (int i = 0; i < 4; i++) {
          if (_listPilihan.length < 4) {
            _listPilihan.add(PilihanModel.fromJson({'prioritas': i + 1}));
          }
        }
        notifyListeners();
        return _listPilihan;
      }

      for (int i = 1; i < 5; i++) {
        for (int j = 0; j < responseData.length; j++) {
          if (responseData[j]['prioritas'] == i) {
            _listPilihan.insert(responseData[j]['prioritas'] - 1,
                PilihanModel.fromJson(responseData[j]));
          } else {
            _listPilihan.add(PilihanModel.fromJson({'prioritas': i + 1}));
          }
        }
      }

      if (_listPilihan.length > 4) {
        _listPilihan.removeRange(4, _listPilihan.length);
      }

      _isLoading = false;

      notifyListeners();
      return [..._listPilihan];
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        logger.log('NoConnectionException-LoadPilihan: $e');
      }
      return [];
    } on DataException catch (e) {
      if (kDebugMode) {
        logger.log('Exception-LoadPilihan: $e');
      }

      _errorPilihan = e.toString();
      return [];
    } catch (e) {
      if (kDebugMode) {
        logger.log('Exception-LoadPilihan: $e');
      }
      _errorPilihan = gPesanError;
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
