import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/core/config/extensions.dart';
import 'package:gokreasi_new/core/util/data_formatter.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/jadwal/data/model/jadwal_siswa_model.dart';
import 'package:gokreasi_new/features/jadwal/domain/entity/jadwal_siswa.dart';
import 'package:gokreasi_new/features/jadwal/service/api/jadwal_service_api.dart';

part 'jadwal_kbm_event.dart';
part 'jadwal_kbm_state.dart';

class JadwalKBMBloc extends Bloc<JadwalKBMEvent, JadwalKBMState> {
  final _apiService = JadwalServiceApi();

  final Map<String, List<InfoJadwal>> _listTanggalKBM = {};
  final Map<String, List<JadwalSiswa>> _listJadwalKBM = {};
  String _tanggalKey = '';
  String _jadwalKey = '';

  JadwalKBMBloc() : super(const JadwalKBMState()) {
    on<SetSelectedDate>(_onSetSelectedDate);
    on<GetTanggalKBM>(_onGetTanggalKBM);
    on<GetJadwalByTanggal>(_onGetJadwalByTanggal);
  }

  /// [_onSetSelectedDate] digunakan untuk mengubah selected date time
  void _onSetSelectedDate(SetSelectedDate event, Emitter<JadwalKBMState> emit) {
    if (state.selectedDate != event.selectedDateTime) {
      emit(
        state.copyWith(
            status: JadwalKBMStatus.success,
            selectedDate: event.selectedDateTime,
            isReverseTransition:
                state.selectedDate?.isAfter(event.selectedDateTime)),
      );
    }
  }

  /// [_onGetTanggalKBM] digunakan untuk get tanggal yang ada jadwal KBM
  void _onGetTanggalKBM(
    GetTanggalKBM event,
    Emitter<JadwalKBMState> emit,
  ) async {
    try {
      _tanggalKey =
          '${event.userData?.noRegistrasi}-${event.userData?.idBundlingAktif}';

      if (!event.isRefresh && _listTanggalKBM.containsKey(_tanggalKey)) {
        emit(state.copyWith(
          status: JadwalKBMStatus.success,
          listTanggalKBM: _listTanggalKBM[_tanggalKey],
        ));
        return;
      }

      emit(state.copyWith(
        status: JadwalKBMStatus.loadingTanggal,
        selectedDate: DateTime.now().serverTimeFromOffset,
      ));

      final responseData = await _apiService.fetchTanggalJadwal(
        idKelas: event.userData?.idKelas ?? 0,
        tahunAjaran: event.userData?.tahunAjaran ?? '',
      );

      if (responseData.isEmpty) throw 'Data tidak ditemukan';

      if (!_listTanggalKBM.containsKey(_tanggalKey)) {
        _listTanggalKBM[_tanggalKey] = [];
      }

      _listTanggalKBM[_tanggalKey]?.clear();

      Map<String, dynamic> jsonJadwal = {};

      List<String> listTanggalKerja = responseData.cast<String>();

      for (var tanggal in listTanggalKerja) {
        jsonJadwal['tanggal'] = tanggal;
        _listTanggalKBM[_tanggalKey]!.add(InfoJadwalModel.fromJson(jsonJadwal));
      }

      final now = DateTime.now().serverTimeFromOffset;

      for (var jadwal in _listTanggalKBM[_tanggalKey]!) {
        if (jadwal.tanggal.day == now.day &&
            jadwal.tanggal.month == now.month &&
            jadwal.tanggal.year == now.year) {
          add(GetJadwalByTanggal(
            isRefresh: false,
            userData: event.userData,
          ));
        }
      }

      emit(state.copyWith(
        status: JadwalKBMStatus.success,
        listTanggalKBM: _listTanggalKBM[_tanggalKey],
      ));
    } catch (e) {
      emit(state.copyWith(status: JadwalKBMStatus.error));
    }
  }

  /// [_onGetJadwalByTanggal] digunakan untuk get jadwal by tanggal yang dipilih siswa.
  void _onGetJadwalByTanggal(
    GetJadwalByTanggal event,
    Emitter<JadwalKBMState> emit,
  ) async {
    try {
      _jadwalKey =
          '${DataFormatter.dateTimeToString(state.selectedDate ?? DateTime.now().serverTimeFromOffset, 'yyyy-MM-dd')}'
          '-${event.userData?.noRegistrasi}';

      if (!event.isRefresh && _listJadwalKBM.containsKey(_jadwalKey)) {
        emit(state.copyWith(
          status: JadwalKBMStatus.success,
          listTanggalKBM: _listTanggalKBM[_tanggalKey],
          listJadwalKBM: _listJadwalKBM[_jadwalKey],
        ));
        return;
      }

      emit(state.copyWith(status: JadwalKBMStatus.loadingJadwal));

      final responseData = await _apiService.fetchJadwalByTanggal(
        idKelas: event.userData?.idKelas ?? 0,
        tanggal: DataFormatter.dateTimeToString(
            state.selectedDate ?? DateTime.now().serverTimeFromOffset,
            'yyyy-MM-dd'),
        tahunAjaran: event.userData?.tahunAjaran ?? '',
      );

      if (responseData.isEmpty) throw 'Data tidak ditemukan';

      if (!_listJadwalKBM.containsKey(_jadwalKey)) {
        _listJadwalKBM[_jadwalKey] = [];
      }

      _listJadwalKBM[_jadwalKey] = responseData
          .map((jadwal) => JadwalSiswaModel.fromJson(jadwal))
          .toList();

      for (int i = 0; i < _listTanggalKBM[_tanggalKey]!.length; i++) {
        InfoJadwal selectedInfoJadwal = _listTanggalKBM[_tanggalKey]![i];
        if (state.selectedDate?.day == selectedInfoJadwal.tanggal.day &&
            state.selectedDate?.month == selectedInfoJadwal.tanggal.month &&
            state.selectedDate?.year == selectedInfoJadwal.tanggal.year) {
          _listTanggalKBM[_tanggalKey]![i] = selectedInfoJadwal.copyWith(
            daftarJadwalSiswa: _listJadwalKBM[_jadwalKey],
          );
        }
      }

      emit(state.copyWith(
        status: JadwalKBMStatus.success,
        listJadwalKBM: _listJadwalKBM[_jadwalKey],
        listTanggalKBM: _listTanggalKBM[_tanggalKey],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: JadwalKBMStatus.error,
        listJadwalKBM: _listJadwalKBM[_jadwalKey] = [],
      ));
    }
  }
}
