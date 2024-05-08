import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/core/util/app_exceptions.dart';
import 'package:gokreasi_new/core/util/data_formatter.dart';
import 'package:gokreasi_new/core/util/injector.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/jadwal/domain/entity/jadwal_siswa.dart';
import 'package:gokreasi_new/features/jadwal/data/model/jadwal_siswa_model.dart';
import 'package:gokreasi_new/features/jadwal/domain/usecase/jadwal_usecase.dart';

part 'jadwal_event.dart';
part 'jadwal_state.dart';

class JadwalBloc extends Bloc<JadwalEvent, JadwalState> {
  String deviceTime = DataFormatter.formatLastUpdate();
  List<InfoJadwal> listInfoJadwalKBM = [];
  JadwalBloc() : super(JadwalInitial()) {
    on<LoadJadwal>((event, emit) async {
      try {
        emit(JadwalLoading());
        final params = {
          "no_register": event.userData?.noRegistrasi,
          "tahun_ajaran": event.userData?.tahunAjaran
        };
        final responseData = await locator<GetJadwalUseCase>().call(params: params);
        if (event.isRefresh) listInfoJadwalKBM.clear();

        if (responseData != null && listInfoJadwalKBM.isEmpty) {
          Map<String, dynamic> jsonJadwal = {};

          responseData.forEach((tanggal, listJadwal) {
            jsonJadwal['tanggal'] = tanggal;
            jsonJadwal['listJadwal'] = listJadwal ?? [];

            listInfoJadwalKBM.add(InfoJadwalModel.fromJson(jsonJadwal));
          });
        }
        emit(JadwalLoaded(listInfoJadwalKBM: listInfoJadwalKBM));
      } on NoConnectionException catch (_) {
        emit(const JadwalError("Silahkan Cek Koneksi Internet"));
      } catch (e) {
        emit(const JadwalError("Gagal Mengambil Data"));
      }
    });
  }
}
