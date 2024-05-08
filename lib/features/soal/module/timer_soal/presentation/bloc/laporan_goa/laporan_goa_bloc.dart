import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/entity/hasil_goa.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/entity/paket_to.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/model/hasil_goa_model.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/service/tob_service_api.dart';

part 'laporan_goa_event.dart';
part 'laporan_goa_state.dart';

class LaporanGoaBloc extends Bloc<LaporanGoaEvent, LaporanGoaState> {
  TOBServiceApi tobServiceApi = TOBServiceApi();
  HasilGOA hasilGOA = HasilGOA(
      isRemedial: false,
      jumlahPercobaanRemedial: 0,
      detailHasilGOA: [],
      jumlahMaksimalPercobaanRemidial: 2);
  LaporanGoaBloc() : super(LaporanGoaInitial()) {
    on<LoadLaporanGoa>((event, emit) async {
      try {
        emit(LaporanGoaLoading());
        final respone = await tobServiceApi.fetchLaporanGOA(
            kodePaket: event.paketTO.kodePaket,
            noRegistrasi: event.noRegistrasi,
            ta: event.ta.replaceAll('/', '-'));

        if (respone != 0) {
          hasilGOA = HasilGOAModel.fromJson(respone);
        }

        emit(LaporanGoaLoaded(hasilGOA: hasilGOA));
      } catch (e) {
        emit(LaporanGoaError(e.toString()));
      }
    });
  }
}
