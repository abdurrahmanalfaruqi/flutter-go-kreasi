import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/core/config/global.dart';
import 'package:gokreasi_new/features/laporan/module/presensi/model/laporan_presensi.dart';
import 'package:gokreasi_new/features/laporan/module/presensi/service/api/laporan_presensi_service_api.dart';

part 'presensi_event.dart';
part 'presensi_state.dart';

class PresensiBloc extends Bloc<PresensiEvent, PresensiState> {
  final _apiService = LaporanPresensiServiceAPI();
  final Map<String, List<LaporanPresensiInfo>> _dataPresensi = {};

  PresensiBloc() : super(const PresensiState()) {
    on<LoadPresensiByTanggal>(_onLoadPresensiByTanggal);
  }

  void _onLoadPresensiByTanggal(
    LoadPresensiByTanggal event,
    Emitter<PresensiState> emit,
  ) async {
    String presensiKey = '${event.noRegistrasi}-${event.idBundlingAktif}'
        '-${event.tanggal}';

    try {
      if (!event.isRefresh &&
          _dataPresensi.containsKey(presensiKey) &&
          _dataPresensi[presensiKey]?.isNotEmpty == true) {
        emit(state.copyWith(
          status: PresensiStatus.success,
          listJadwalPresence: _dataPresensi[presensiKey],
        ));
        return;
      }

      emit(state.copyWith(status: PresensiStatus.loading));

      final resPresensi = await _apiService.fetchPresensiByTanggal(
        noRegistrasi: event.noRegistrasi,
        tanggal: event.tanggal,
      );

      if (resPresensi.isEmpty) {
        throw 'Data Kosong';
      }

      if (!_dataPresensi.containsKey(presensiKey)) {
        _dataPresensi[presensiKey] = [];
      }

      _dataPresensi[presensiKey] = resPresensi
          .map((presensi) => LaporanPresensiInfo.fromJson(presensi))
          .toList();

      emit(state.copyWith(
        status: PresensiStatus.success,
        listJadwalPresence: _dataPresensi[presensiKey],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PresensiStatus.error,
        listJadwalPresence: [],
        errorMessage: (kDebugMode) ? e.toString() : gPesanError,
      ));
    }
  }
}
