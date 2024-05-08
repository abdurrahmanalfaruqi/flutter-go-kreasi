import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/core/config/enum.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/laporan/module/tobk/model/laporan_list_tryout_model.dart';
import 'package:gokreasi_new/features/laporan/module/tobk/model/laporan_tryout_nilai_model.dart';
import 'package:gokreasi_new/features/laporan/module/tobk/model/laporan_tryout_pilihan_model.dart';
import 'package:gokreasi_new/features/laporan/module/tobk/model/laporan_tryout_tob_model.dart';
import 'package:gokreasi_new/features/laporan/module/tobk/service/api/laporan_tryout_service_api.dart';

part 'laporan_tobk_event.dart';
part 'laporan_tobk_state.dart';

class LaporanTobkBloc extends Bloc<LaporanTobkEvent, LaporanTobkState> {
  LaporanTryoutServiceAPI apiService = LaporanTryoutServiceAPI();

  List<LaporanTryoutPilihanModel> listPilihan = [];
  List<LaporanTryoutNilaiModel> listNilai = [];
  List<LaporanListTryoutModel> listTryOut = [];
  List<LaporanTryoutTobModel> listLaporanTryout = [];
  List<Map<String, String>> opsiTOBK = [
    {"c_NamaTO": "Pilih Jenis", "c_JenisTO": ""}
  ];
  double totalNilai = 0.0;

  LaporanTobkBloc() : super(LaporanTobkState()) {
    on<LoadLaporanTobk>((event, emit) async {
      try {
        emit(LaporanTobkLoading());
        // if (event.userData?.tingkatKelas == "13" ||
        //     event.userData?.tingkatKelas == "12" ||
        //     event.jenisTO == "UTBK") {
        // }

        listLaporanTryout.clear();

        List<dynamic>? responseData = await apiService.fetchLaporanTryout(
          noRegistrasi: event.userData?.noRegistrasi ?? '',
          listIdProduk: event.userData?.listIdProduk,
          jenisTO: event.jenisTO,
          idTingkatKelas: int.parse(event.userData?.tingkatKelas ?? '0'),
        );

        if (responseData != null) {
          for (int i = 0; i < responseData.length; i++) {
            listLaporanTryout
                .add(LaporanTryoutTobModel.fromJson(responseData[i]));
          }
        }

        if (listLaporanTryout.isNotEmpty) {
          listLaporanTryout.first.isSelected = true;
        }

        emit(LaporanTobkDataLoaded(
            listLaporanTryout: listLaporanTryout,
            listNilai: listNilai,
            listTryOut: listTryOut,
            listPilihan: listPilihan,
            opsiTOBK: opsiTOBK,
            totalNilai: totalNilai));
      } catch (e) {
        emit(LaporanTobkError(e.toString()));
      }
    });

    on<LoadFristLaporan>((event, emit) async {
      try {
        emit(LaporanTobkLoading());
        final responseData =
            await apiService.fetchJenisTO(noregister: event.noRegister);
        opsiTOBK = [
          {"c_NamaTO": "Pilih Jenis", "c_JenisTO": ""}
        ];

        List<Map<String, String>> convertedData = [];

        for (var data in responseData) {
          bool isNamaTOValid = data["c_NamaTO"] != null &&
              (data["c_NamaTO"] as String).isNotEmpty;
          bool isJenisTOValid = data["c_JenisTO"] != null &&
              (data["c_JenisTO"] as String).isNotEmpty;

          if (isNamaTOValid && isJenisTOValid) {
            Map<String, String> convertedItem = {
              "c_NamaTO": data["c_NamaTO"],
              "c_JenisTO": data["c_JenisTO"],
            };

            convertedData.add(convertedItem);
          }
        }

        opsiTOBK.addAll(convertedData);

        emit(LaporanTobkDataLoaded(
            listLaporanTryout: const [],
            listNilai: const [],
            listTryOut: const [],
            listPilihan: const [],
            opsiTOBK: opsiTOBK,
            totalNilai: 0.0));
      } catch (e) {
        emit(LaporanTobkError(e.toString()));
      }
    });

    on<UploadLaporanToFeed>((event, emit) async {
      try {
        await apiService.uploadFeed(
            userId: event.userId, content: event.content, file64: event.file64);
        emit(UploadSuccessEvent());
      } catch (e) {
        emit(UploadErrorEvent());
      }
    });
  }
}
