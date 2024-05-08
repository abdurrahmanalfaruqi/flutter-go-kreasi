import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/core/config/global.dart';
import 'package:gokreasi_new/core/util/app_exceptions.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/ptn/module/simulasi/model/nilai_model.dart';
import 'package:gokreasi_new/features/ptn/module/simulasi/service/api/simulasi_service_api.dart';

part 'simulasi_event.dart';
part 'simulasi_state.dart';

class SimulasiBloc extends Bloc<SimulasiEvent, SimulasiState> {
  final _apiService = SimulasiServiceAPI();
  int _selectedIndex = 0;
  bool _isFix = false;
  List<NilaiModel> listNilai = [];
  SimulasiBloc() : super(SimulasiInitial()) {
    on<LoadSimulasiNilai>((event, emit) async {
      try {
        emit(SimulasiLoading());
        listNilai.clear();
        final responseData = await _apiService.fetchNilai(
          noRegistrasi: event.userData?.noRegistrasi ?? '',
          idTingkatKelas: int.parse(event.userData?.tingkatKelas ?? '0'),
          listIdProduk: event.userData?.listIdProduk,
        );

        if (responseData.isNotEmpty) {
          for (int i = 0; i < responseData.length; i++) {
            final snbtNilaiModel = NilaiModel.fromJson(responseData[i]);
            _selectedIndex = snbtNilaiModel.isSelected ? i : _selectedIndex;
            _isFix = snbtNilaiModel.isSelected ? snbtNilaiModel.isFix : _isFix;
            listNilai.add(snbtNilaiModel);
          }
        }
        emit(SimulasiDataLoaded(listNilai: listNilai));
      } on NoConnectionException catch (_) {
        emit(const SimulasiError("mohon Cek Koneksi Internet anda"));
        rethrow;
      } on DataException catch (e) {
        emit(SimulasiError(e.toString()));
        rethrow;
      } catch (e) {
        throw 'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.';
      }
    });

    on<SaveNilaiEvent>((event, emit) async {
      try {
        final res = await _apiService.saveNilai(
          noRegister: event.noRegistrasi,
          kodeTOB: event.kodeTOB,
          nilaiAkhir: event.nilaiAkhir,
          detailNilai: event.detailNilai,
        );

        if (!res) throw 'Gagal save nilai';
      } catch (e) {
        emit(SimulasiError(
          kDebugMode ? e.toString() : gPesanError,
        ));
      }
    });
  }
}
