import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/features/laporan/module/quiz/model/laporan_kuis_model.dart';
import 'package:gokreasi_new/features/laporan/module/quiz/service/api/laporan_quiz_service_api.dart';
import 'package:gokreasi_new/features/soal/entity/detail_jawaban.dart';

part 'laporan_kuis_event.dart';
part 'laporan_kuis_state.dart';

class LaporanKuisBloc extends Bloc<LaporanKuisEvent, LaporanKuisState> {
  final _apiHelper = LaporanKuisServiceAPI();
  List<LaporanKuisModel> listLaporanKuis = [];
  LaporanKuisBloc() : super(LaporanKuisInitial()) {
    on<LoadListLaporanKuis>((event, emit) async {
      try {
        emit(LaporanKuisLoading());
        final response = await _apiHelper.fetchLaporanKuis(
          noRegistrasi: event.noRegistrasi,
          idSekolahKelas: event.idSekolahKelas,
          tahunAjaran: event.tahunAjaran,
        );
        if (response['meta']['code'] == 200) {
          /// [body] untuk mendapatkan data dari respons.
          List<dynamic> body = response["data"];
          if (body.isNotEmpty) {
            LaporanKuisModel a =
                LaporanKuisModel(cnamamapel: "Pilih Mata Pelajaran", info: []);

            /// Proses untuk mengonversi List dynamic menjadi list LaporanKuisModel.
            listLaporanKuis = body
                .map((dynamic item) => LaporanKuisModel.fromJson(item))
                .toList();

            listLaporanKuis.insert(0, a);
          }
        }
        emit(LaporanKuisDataLoaded(
            listLaporanKuis: listLaporanKuis, listHasilKuis: const []));
      } catch (e) {
        emit(LaporanKuisError(e.toString()));
      }
    });
    on<ClearlistHasilKuis>((event, emt) async {
      // ignore: invalid_use_of_visible_for_testing_member
      emit(LaporanKuisDataLoaded(
          listLaporanKuis: listLaporanKuis, listHasilKuis: const []));
    });
    on<LoadListHasilKuis>((event, emit) async {
      try {
        emit(LaporanHasilKuisLoading());
        final response = await _apiHelper.fetchLaporanJawabanKuis(
            noRegistrasi: event.noRegistrasi,
            idSekolahKelas: event.idSekolahKelas,
            tahunAjaran: event.tahunAjaran,
            kodequiz: event.kodeQuiz);
        List<dynamic> jawabanList = response["data"];

        List<DetailJawaban> hasil = [];

        for (Map<String, dynamic> jawaban in jawabanList) {
          hasil.add(DetailJawaban.fromJson(jawaban));
        }
        emit(LaporanKuisDataLoaded(
            listLaporanKuis: listLaporanKuis, listHasilKuis: hasil));
      } catch (e) {
        emit(LaporanKuisError(e.toString()));
      }
    });
  }
}
