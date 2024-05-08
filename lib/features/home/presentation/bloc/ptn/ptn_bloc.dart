import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/core/config/enum.dart';
import 'package:gokreasi_new/core/util/app_exceptions.dart';
import 'package:gokreasi_new/core/util/injector.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/home/domain/usecase/home_usecase.dart';
import 'package:gokreasi_new/features/ptn/module/ptnclopedia/entity/jurusan.dart';
import 'package:gokreasi_new/features/ptn/module/ptnclopedia/entity/kampus_impian.dart';
import 'package:gokreasi_new/features/ptn/module/ptnclopedia/entity/ptn.dart';
import 'package:gokreasi_new/features/ptn/module/ptnclopedia/model/jurusan_model.dart';
import 'package:gokreasi_new/features/ptn/module/ptnclopedia/model/ptn_model.dart';
import 'package:gokreasi_new/features/ptn/module/ptnclopedia/service/api/ptn_service_api.dart';

part 'ptn_event.dart';
part 'ptn_state.dart';

class PtnBloc extends Bloc<PtnEvent, PtnState> {
  final PtnServiceApi _apiService;
  bool isBoleh = false;
  final List<PTN> listPTN = [];
  List<Jurusan> listJurusan = [];
  List<KampusImpian> listKampusPilihan = [];
  List<KampusImpian> riwayatKampusPilihan = [];
  PTN? selectedPTn;
  Jurusan? selectedJurusan;
  int? pgPilihan2;
  String? resKodeTOB;
  PtnBloc(this._apiService) : super(PtnState()) {
    on<LoadListPtn>((event, emit) async {
      try {
        emit(PtnLoading(event: EventPTNType.selectPTN));
        final responseData = await locator<GetUniversitas>().call();
        if (responseData.isNotEmpty && listPTN.isEmpty) {
          for (var dataPTN in responseData) {
            listPTN.add(PTNModel.fromJson(dataPTN));
          }
        }
        emit(PtnDataLoaded(
          listPTN: listPTN,
          listJurusan: listJurusan,
          stateType: event.statePTNType,
          eventType: event.from,
          isBoleh: isBoleh,
          kodeTOB: resKodeTOB,
          listKampusPilihan: listKampusPilihan,
          riwayatKampusPilihan: riwayatKampusPilihan,
          index: event.index,
        ));
      } on NoConnectionException {
        emit(PtnError('Tidak ada koneksi internet.'));
      } catch (e) {
        emit(PtnError(
            'Terjadi kesalahan saat mengambil data.\nMohon coba kembali nanti.'));
      }
    });

    on<SetSelectedPTN>((event, emit) async {
      emit(PtnLoading(event: EventPTNType.selectJurusan));
      try {
        selectedPTn = event.selectedPtn!;
        final params = {'idPtn': event.selectedPtn!.idPTN ?? 0};

        final responseData = await locator<GetJurusan>().call(params: params);

        if (responseData.isNotEmpty) {
          listJurusan = [];
          for (var dataJurusan in responseData) {
            listJurusan.add(JurusanModel.fromJson(dataJurusan));
          }
        }
        selectedPTn = event.selectedPtn;
        selectedJurusan = null;

        emit(PtnDataLoaded(
          listPTN: listPTN,
          listJurusan: listJurusan,
          selectedPTN: event.selectedPtn,
          selectedJurusan: null,
          detailJurusan: null,
          stateType: event.statePTNType,
          eventType: event.from,
          isBoleh: isBoleh,
          kodeTOB: resKodeTOB,
          listKampusPilihan: listKampusPilihan,
          riwayatKampusPilihan: riwayatKampusPilihan,
          index: event.index,
        ));
      } on NoConnectionException catch (e) {
        emit(PTNErrorPopUp(e.toString()));
      } on DataException catch (e) {
        emit(PTNErrorPopUp(e.toString()));
      } catch (e) {
        emit(PTNErrorPopUp(e.toString()));
      }
    });

    on<GetKampusImpian>((event, emit) async {
      try {
        emit(PtnLoading());
        KampusImpian? kampusImpian1;
        KampusImpian? kampusImpian2;
        List<KampusImpian> riwayatPilihanKampus = [];

        List<int> listIdProduk = event.userData?.listIdProduk == null
            ? []
            : (event.userData?.listIdProduk ?? []);

        /// variable [listTOB] digunakan untuk mengecek apakah ada tob H-1
        /// jika ada maka fetch kampus impian by kode tob
        /// jika kosong maka fetch kampus impian latest
        final cekTOBParams = {
          "list_id_produk": listIdProduk,
        };
        List<dynamic>? listTOB = await locator<CekTOB>().call(
          params: cekTOBParams,
        );

        resKodeTOB =
            (listTOB.isNotEmpty == true) ? listTOB.first['kode_tob'] : null;
        isBoleh = listTOB.isNotEmpty == true;

        Map<String, dynamic> res = {};

        if (listTOB.isEmpty == true) {
          final params = {'noRegistrasi': event.userData?.noRegistrasi};
          res = await locator<FetchKampusImpian>().call(params: params);
        } else {
          final params = {
            "kode_tob": resKodeTOB ?? '',
            'noRegistrasi': event.userData?.noRegistrasi
          };
          res = await locator<FetchKampusImpianByTOB>().call(params: params);
        }

        if (res.isEmpty) {
          // clear data
          listKampusPilihan.clear();
          riwayatKampusPilihan.clear();
          // await HiveHelper.clearKampusImpianBox();
          // await HiveHelper.clearRiwayatKampusImpian();
          emit(PtnDataLoaded(
            isBoleh: isBoleh,
            kodeTOB: resKodeTOB,
            listKampusPilihan: listKampusPilihan,
            riwayatKampusPilihan: riwayatKampusPilihan,
          ));
          return;
        }

        String? kodeTOB = res['tob']['kode_tob'] == null
            ? '0'
            : res['tob']['kode_tob'].toString();
        String? namaTOB =
            res['tob']['nama_tob'] == null || res['tob']['nama_tob'] is! String
                ? null
                : res['tob']['nama_tob'];

        if (res['pilihan'].isNotEmpty &&
            res['pilihan'][0] != null &&
            res['pilihan'][0]['id_jurusan'] != null) {
          kampusImpian1 = KampusImpian.fromJson(
            json: res['pilihan'][0],
            kodeTOB: kodeTOB,
            namaTOB: namaTOB,
          );
        }

        if (res['pilihan'].length > 1 &&
            res['pilihan'][1] != null &&
            res['pilihan'][1]['id_jurusan'] != null) {
          kampusImpian2 = KampusImpian.fromJson(
            json: res['pilihan'][1],
            kodeTOB: kodeTOB,
            namaTOB: namaTOB,
          );
        }

        if (res['historyPilihan'] != null) {
          riwayatPilihanKampus = (res['historyPilihan'] as List<dynamic>)
              .map((kampus) => KampusImpian.fromJson(
                    json: kampus,
                    kodeTOB: kodeTOB,
                    namaTOB: namaTOB,
                  ))
              .toList();
        }

        listKampusPilihan.clear();
        riwayatKampusPilihan.clear();

        if (kampusImpian1 != null) {
          listKampusPilihan.add(kampusImpian1);
        }

        if (kampusImpian2 != null) {
          listKampusPilihan.add(kampusImpian2);
        }

        if (riwayatPilihanKampus.isNotEmpty) {
          riwayatKampusPilihan.addAll(riwayatPilihanKampus);
        }

        emit(PtnDataLoaded(
          listPTN: listPTN,
          listJurusan: listJurusan,
          selectedPTN: selectedPTn,
          selectedJurusan: selectedJurusan,
          pilihan2: pgPilihan2,
          isBoleh: isBoleh,
          kodeTOB: resKodeTOB,
          listKampusPilihan: listKampusPilihan,
          riwayatKampusPilihan: riwayatKampusPilihan,
        ));
      } on NoConnectionException catch (_) {
        emit(PtnError('Pastikan koneksi internet anda Baik Dan Terhubung'));
      } catch (e) {
        emit(PtnError(e.toString()));
      }
    });

    on<LoadJurusanList>((event, emit) async {
      emit(PtnLoading());
      try {
        final params = {'idPtn': event.idPtn};
        final responseData = await locator<GetJurusan>().call(params: params);

        if (responseData.isNotEmpty) {
          listJurusan = [];
          for (var dataJurusan in responseData) {
            listJurusan.add(JurusanModel.fromJson(dataJurusan));
          }
        }
        emit(PtnDataLoaded(
          listPTN: listPTN,
          listJurusan: listJurusan,
          isBoleh: isBoleh,
          kodeTOB: resKodeTOB,
          listKampusPilihan: listKampusPilihan,
          riwayatKampusPilihan: riwayatKampusPilihan,
        ));
      } on NoConnectionException catch (e) {
        emit(PtnError(e.toString()));
      } on DataException catch (e) {
        emit(PtnError(e.toString()));
      } catch (e) {
        emit(PtnError(e.toString()));
      }
    });

    on<SetSelectedJurusan>((event, emit) async {
      emit(PtnLoading());
      try {
        final params = {'idJurusan': event.selectedJurusan!.idJurusan ?? 0};
        final responseData = await locator<FetchDetailJurusan>().call(
          params: params,
        );

        DetailJurusan detailJurusan = DetailJurusan.fromJson(responseData);
        selectedPTn = event.selectedPTN;
        selectedJurusan = event.selectedJurusan!;
        emit(PtnDataLoaded(
          listPTN: listPTN,
          listJurusan: listJurusan,
          selectedJurusan: event.selectedJurusan,
          selectedPTN: event.selectedPTN,
          detailJurusan: detailJurusan,
          isBoleh: isBoleh,
          kodeTOB: resKodeTOB,
          listKampusPilihan: listKampusPilihan,
          riwayatKampusPilihan: riwayatKampusPilihan,
        ));
      } on NoConnectionException catch (e) {
        emit(PTNErrorPopUp(e.toString()));
      } on DataException catch (e) {
        emit(PTNErrorPopUp(e.toString()));
      } catch (e) {
        emit(PTNErrorPopUp(e.toString()));
      }
    });

    on<UpdateKampusImpian>((event, emit) async {
      try {
        emit(PtnLoading());
        final respone = await _apiService.putKampusImpian(
          noRegistrasi: event.noRegistrasi,
          pilihanKe: event.pilihanKe,
          idJurusan: event.idJurusan,
          kodeTOB: event.kodeTOB,
        );
        if (respone['meta']['code'] == 200) {
          emit(PtnUpdateSuccess());
        } else {
          emit(PtnUpdateError("Gagal menyimpan data"));
        }
      } on NoConnectionException {
        emit(
            PtnUpdateError("Gagal Menyimpan data Karena Koneksi Tidak Stabil"));
      } catch (e) {
        emit(PtnUpdateError("Gagal menyimpan data"));
      }
    });

    on<GetDetailJurusan>((event, emit) async {
      try {
        final detailJurusanParams = {'idJurusan': event.kampusImpian.idJurusan};
        final responeData = await locator<FetchDetailJurusan>().call(
          params: detailJurusanParams,
        );
        DetailJurusan detailJurusan = DetailJurusan(
            idPTN: 0,
            namaPTN: '',
            alias: '',
            idJurusan: 0,
            namaJurusan: '',
            kelompok: '',
            rumpun: '',
            lintas: false,
            peminat: const [],
            tampung: const []);
        if (responeData.isNotEmpty) {
          detailJurusan = DetailJurusan.fromJson(responeData);
        }

        for (PTN ptn in listPTN) {
          if (ptn.idPTN == detailJurusan.idPTN) {
            selectedPTn = ptn;
            break;
          }
        }

        final params = {'idPtn': selectedPTn?.idPTN ?? 0};
        final responseJurusan =
            await locator<GetJurusan>().call(params: params);

        if (responseJurusan.isNotEmpty) {
          for (var dataJurusan in responseJurusan) {
            listJurusan.add(JurusanModel.fromJson(dataJurusan));
          }
        }

        for (Jurusan jurusan in listJurusan) {
          if (jurusan.idJurusan == detailJurusan.idJurusan) {
            selectedJurusan = jurusan;
            break;
          }
        }
        emit(PtnDataLoaded(
          listPTN: listPTN,
          listJurusan: listJurusan,
          detailJurusan: detailJurusan,
          selectedPTN: selectedPTn,
          selectedJurusan: selectedJurusan,
          isBoleh: isBoleh,
          kodeTOB: resKodeTOB,
          listKampusPilihan: listKampusPilihan,
          riwayatKampusPilihan: riwayatKampusPilihan,
        ));
      } on NoConnectionException {
        emit(PtnError('Tidak ada koneksi internet.'));
      } catch (e) {
        emit(PtnError(
            'Terjadi kesalahan saat mengambil data.\nMohon coba kembali nanti.'));
      }
    });

    on<SaveKampusPilihan>((event, emit) async {
      // if (!HiveHelper.isBoxOpen<KampusImpian>(
      //     boxName: HiveHelper.kKampusImpianBox)) {
      //   await HiveHelper.openBox<KampusImpian>(
      //       boxName: HiveHelper.kKampusImpianBox);
      // }
      // if (!HiveHelper.isBoxOpen<KampusImpian>(
      //     boxName: HiveHelper.kRiwayatKampusImpianBox)) {
      //   await HiveHelper.openBox<KampusImpian>(
      //       boxName: HiveHelper.kRiwayatKampusImpianBox);
      // }

      // await HiveHelper.saveKampusImpianPilihan(
      //   pilihanKe: event.pilihanKe,
      //   kampusPilihan: event.kampusImpian,
      // );

      emit(PtnUpdateSuccess());
    });

    on<PTNResetSelectedPTN>((event, emit) async {
      emit(PtnDataLoaded(
        selectedPTN: null,
        selectedJurusan: null,
        isBoleh: isBoleh,
        kodeTOB: resKodeTOB,
        listKampusPilihan: listKampusPilihan,
        riwayatKampusPilihan: riwayatKampusPilihan,
      ));
    });
  }
}
