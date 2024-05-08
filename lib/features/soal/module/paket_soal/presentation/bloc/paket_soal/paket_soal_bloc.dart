import 'dart:async';

import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/core/config/global.dart';
import 'package:gokreasi_new/core/util/app_exceptions.dart';
import 'package:gokreasi_new/core/util/injector.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/soal/module/paket_soal/domain/entity/paket_soal.dart';
import 'package:gokreasi_new/features/soal/module/paket_soal/data/model/paket_soal_model.dart';
import 'package:gokreasi_new/features/soal/module/paket_soal/domain/usecase/paket_soal_usecase.dart';
import 'package:gokreasi_new/features/soal/module/paket_soal/service/paket_soal_service_api.dart';

part 'paket_soal_event.dart';
part 'paket_soal_state.dart';

class PaketSoalBloc extends Bloc<PaketSoalEvent, PaketSoalState> {
  PaketSoalServiceApi apiService = PaketSoalServiceApi();

  final Map<String, List<PaketSoal>> _paketSoal = {};
  Map<String, int> listPage = {};
  Map<String, int> listJumlahHalaman = {};

  PaketSoalBloc() : super(PaketSoalInitial()) {
    on<GetPaketSoalList>((event, emit) async {
      try {
        String paketKey = '${event.idJenisProduk}' '${event.idBundlingAktif}';

        List<PaketSoal> listPaketSoal = [];
        int page = 1;
        int jumlahHalaman = 1;

        if (_paketSoal.containsKey(paketKey)) {
          listPaketSoal = _paketSoal[paketKey]!;
        }

        if (listPage.containsKey(paketKey)) {
          page = listPage[paketKey]!;
        }

        if (listJumlahHalaman.containsKey(paketKey)) {
          jumlahHalaman = listJumlahHalaman[paketKey]!;
        }

        if (!event.isRefresh && listPaketSoal.isNotEmpty) {
          emit(PaketSoalLoaded(
            page: page,
            jumlahHalaman: jumlahHalaman,
            listPaketSoal: listPaketSoal,
          ));
          return;
        }

        if (event.page == 1) {
          emit(PaketSoalLoading());
        } else {
          emit(PaketSoalPaginateLoading());
        }

        var responseData = await locator<GetDaftarPaketSoalUseCase>().call(
          params: {
            "idJenisProduk": event.idJenisProduk.toString(),
            "list_id_produk": event.listIdProduk,
            "halaman": event.page,
            "konten_per_halaman": 10,
            "no_register": event.noRegistrasi,
            "tingkat_kelas": event.tingkatKelas,
          },
        );

        final List<dynamic> responseList = responseData['list_paket'];
        jumlahHalaman = responseData['jumlah_halaman'];

        if (!_paketSoal.containsKey(paketKey)) {
          _paketSoal[paketKey] = [];
        }
        // Cek apakah response data memiliki data atau tidak
        if (responseData.isNotEmpty) {
          final mappedList =
              responseList.map((to) => PaketSoalModel.fromJson(to)).toList();

          if (event.page == 1) {
            _paketSoal[paketKey] = mappedList;
          } else {
            _paketSoal[paketKey]!.addAll(mappedList);
          }
        }

        listPage[paketKey] = event.page;
        listJumlahHalaman[paketKey] = jumlahHalaman;

        emit(PaketSoalLoaded(
          listPaketSoal: _paketSoal[paketKey]?.toSet().toList() ?? [],
          page: event.page,
          jumlahHalaman: jumlahHalaman,
        ));
      } on NoConnectionException catch (e) {
        emit(PaketSoalError(err: e.toString(), page: event.page));
      } on DataException catch (e) {
        emit(PaketSoalError(
          err: e.toString(),
          page: event.page,
          shouldBeEmpty: event.page == 1,
        ));
      } catch (e) {
        emit(PaketSoalError(err: e.toString(), page: event.page));
      }
    });

    on<PaketMulaiTO>((event, emit) async {
      try {
        var completer = Completer();
        BuildContext ctx = gNavigatorKey.currentContext!;

        ctx.showBlockDialog(dismissCompleter: completer);

        final res = await apiService.setMulaiTO(
          idJenisProduk: event.idJenisProduk,
          noRegister: event.noRegister,
          tahunAjaran: event.tahunAjaran,
          kodePaket: event.kodePaket,
          totalWaktuPaket: event.totalWaktuPaket,
          merk: await gMerkHp(),
          versi: await gVersi(),
          versiOS: await gVersiOS(),
        );

        if (!completer.isCompleted) {
          completer.complete();
        }

        emit(PaketSuccessMulaiTO(
          isSuccess: res,
          kodePaket: event.kodePaket,
          kodeTOB: event.kodeTOB,
          isSelesai: event.isSelesai,
          tanggalKadaluarsa: event.tanggalKadaluarsa,
          listIdBundel: event.listIdBundel,
          jumlahSoalPaket: event.jumlahSoalPaket,
          isKedaluarsa: event.isKedaluarsa,
        ));
      } on NoConnectionException catch (e) {
        emit(PaketSoalError(err: e.toString()));
      } on DataException catch (e) {
        emit(PaketSoalError(err: e.toString()));
      } catch (e) {
        emit(PaketSoalError(err: e.toString()));
      }
    });

    on<PaketSelesaiTO>((event, emit) async {
      try {
        final res = await apiService.setSelesaiTO(
          idJenisProduk: event.idJenisProduk,
          kodePaket: event.kodePaket,
          tingkatKelas: event.tingkatKelas,
          userData: event.userData,
        );

        emit(PaketSuccessSelesaiTO(res));
      } on NoConnectionException catch (e) {
        emit(PaketSoalError(err: e.toString()));
      } on DataException catch (e) {
        emit(PaketSoalError(err: e.toString()));
      } catch (e) {
        emit(PaketSoalError(err: e.toString()));
      }
    });
  }
}
