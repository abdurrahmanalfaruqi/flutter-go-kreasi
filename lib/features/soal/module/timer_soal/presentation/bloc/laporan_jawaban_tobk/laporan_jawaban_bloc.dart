import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/features/laporan/module/tobk/model/laporan_jawaban_model.dart';
import 'package:gokreasi_new/features/laporan/module/tobk/service/api/laporan_tryout_service_api.dart';

part 'laporan_jawaban_event.dart';
part 'laporan_jawaban_state.dart';

class LaporanJawabanBloc
    extends Bloc<LaporanJawabanEvent, LaporanJawabanState> {
  LaporanTryoutServiceAPI apiServices = LaporanTryoutServiceAPI();
  List<LaporanTryoutJawabanModel> laporanTryoutList = [];
  LaporanJawabanBloc() : super(LaporanJawabanInitial()) {
    on<LoadLaporanJawaban>((event, emit) async {
      try {
        emit(LaporanJawabanLoading());
        final response = await apiServices.fetchLaporanJawaban(
          kodeTOB: event.kodeTob,
          noRegister: event.noRegistrasi,
          jenisTOB: event.jenisTOB,
          tingkatKelas: event.tingkatKelas,
        );

        if (response != null) {
          laporanTryoutList = [];
          for (var data in response) {
            laporanTryoutList.add(LaporanTryoutJawabanModel.fromJson(data));
          }
          emit(LaporanJawabanLoaded(listLaporanJawaban: laporanTryoutList));
        } else {
          emit(const LaporanJawabanError(""));
        }
      } catch (e) {
        emit(LaporanJawabanError(e.toString()));
      }
    });
  }
}
