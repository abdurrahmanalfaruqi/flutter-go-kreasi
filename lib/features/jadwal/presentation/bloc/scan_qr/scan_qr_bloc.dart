import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/core/config/global.dart';
import 'package:gokreasi_new/core/util/app_exceptions.dart';
import 'package:gokreasi_new/features/jadwal/service/api/jadwal_service_api.dart';

part 'scan_qr_event.dart';
part 'scan_qr_state.dart';

class ScanQrBloc extends Bloc<ScanQrEvent, ScanQrState> {
  ScanQrBloc() : super(ScanQrInitial()) {
    on<ScanQrEvent>((event, emit) async {
      final apiService = JadwalServiceApi();
      if (event is ScanQRKBM) {
        emit(ScanQRLoading());
        try {
          final res = await apiService.setPresensiSiswa(event.params);
          emit(ScanQRSuccess(res));
        } on DataException catch (e) {
          emit(ScanQRError(e.toString()));
        } catch (e) {
          emit(ScanQRError(kDebugMode ? e.toString() : gPesanError));
        }
      }

      if (event is ScanQRTST) {
        emit(ScanQRLoading());
        try {
          final res = await apiService.setPresensiSiswaTst(event.params);
          emit(ScanQRSuccess(res));
        } on DataException catch (e) {
          emit(ScanQRError(e.toString()));
        } catch (e) {
          emit(ScanQRError(kDebugMode ? e.toString() : gPesanError));
        }
      }
    });
  }
}
