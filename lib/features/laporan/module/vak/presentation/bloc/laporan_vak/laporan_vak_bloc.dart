import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/features/laporan/module/vak/entity/laporan_vak.dart';
import 'package:gokreasi_new/features/laporan/module/vak/model/laporan_vak_model.dart';
import 'package:gokreasi_new/features/laporan/module/vak/service/api/laporan_service_api.dart';

part 'laporan_vak_event.dart';
part 'laporan_vak_state.dart';

class LaporanVakBloc extends Bloc<LaporanVakEvent, LaporanVakState> {
  final _apiService = LaporanServiceAPI();
  LaporanVAK laporanVAK = const LaporanVAK(
      noRegistrasi: "",
      scoreVisual: "",
      scoreAuditory: "",
      scoreKinesthetic: "",
      kecenderungan: "",
      judul1: "",
      isi1: "");
  LaporanVakBloc() : super(LaporanVakInitial()) {
    on<LoadLaporanVak>((event, emit) async {
      try {
        emit(LaporanVakLoading());

        final responseData = await _apiService.fetchLaporanVak(
          noRegistrasi: event.noRegistrasi,
          userType: event.userType,
        );

        if (responseData != null) {
          laporanVAK = LaporanVAKModel.fromJson(responseData);
        }

        emit(LaporanVakDataLoaded(laporanVAK: laporanVAK));
      } catch (e) {
        emit(LaporanVakError(e.toString()));
      }
    });
  }
}
