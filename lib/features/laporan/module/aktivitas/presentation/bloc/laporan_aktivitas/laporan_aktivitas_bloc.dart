import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/core/config/global.dart';
import 'package:gokreasi_new/core/util/app_exceptions.dart';
import 'package:gokreasi_new/core/util/injector.dart';
import 'package:gokreasi_new/features/laporan/module/aktivitas/data/model/laporan_aktivitas_model.dart';
import 'package:gokreasi_new/features/laporan/module/aktivitas/domain/usecase/aktivitas_usecase.dart';

part 'laporan_aktivitas_event.dart';
part 'laporan_aktivitas_state.dart';

class LaporanAktivitasBloc
    extends Bloc<LaporanAktivitasEvent, LaporanAktivitasState> {
  final Map<String, List<LaporanAktivitasModel>> _listAktivitas = {};
  LaporanAktivitasBloc() : super(LaporanAktivitasInitial()) {
    /// [LoadLaporanAktivitas] fungsi yang digunakan untuk memuat data log aktivitas.
    ///
    /// Args:
    ///   userId (String): Nomor registrasi siswa
    ///   type (String): Jenis Log Aktivitas (Hari Ini / Minggu Ini)
    ///
    /// Returns:
    ///   List<LaporanAktivitasModel>
    on<LoadLaporanAktivitas>((event, emit) async {
      try {
        emit(LaporanAktivitasLoading());

        String aktivitasKey = '${event.noRegistrasi}-${event.type}';
        if (!event.isRefresh && _listAktivitas.containsKey(aktivitasKey)) {
          emit(LaporanAktivitasLoaded(
              listLaporanAktivitas: _listAktivitas[aktivitasKey]!));
          return;
        }

        final responseData = await locator<GetAktivitasUseCase>().call(params: {
          "type": event.type,
          "user_id": event.noRegistrasi,
        });

        if (!_listAktivitas.containsKey(aktivitasKey)) {
          _listAktivitas[aktivitasKey] = [];
        }

        _listAktivitas[aktivitasKey] = responseData
            .map((aktivitas) => LaporanAktivitasModel.fromJson(aktivitas))
            .toList();

        _listAktivitas[aktivitasKey]!.sort(
          (a, b) => b.masukDateTime.compareTo(a.masukDateTime),
        );

        emit(
          LaporanAktivitasLoaded(
              listLaporanAktivitas: _listAktivitas[aktivitasKey]!),
        );
      } on NoConnectionException {
        emit(const LaporanAktivitasError("Tidak Ada Koneksi Internet"));
      } on DataException catch (e) {
        emit(LaporanAktivitasError((kDebugMode) ? e.toString() : gPesanError));
      } catch (e) {
        emit(const LaporanAktivitasError(
            "Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti."));
      }
    });
  }
}
