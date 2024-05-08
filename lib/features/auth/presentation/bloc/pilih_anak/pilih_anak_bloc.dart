import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/core/config/global.dart';
import 'package:gokreasi_new/core/util/app_exceptions.dart';
import 'package:gokreasi_new/core/util/data_formatter.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/service/api/auth_service_api.dart';

part 'pilih_anak_event.dart';
part 'pilih_anak_state.dart';

class PilihAnakBloc extends Bloc<PilihAnakEvent, PilihAnakState> {
  PilihAnakBloc() : super(PilihAnakInitial()) {
    on<PilihAnakEvent>((event, emit) async {
      final apiService = AuthServiceApi();
      if (event is GetAnakList) {
        try {
          emit(PilihAnakLoading());
          String nomorHpOrtuFormat =
              DataFormatter.formatPhoneNumber(phoneNumber: event.nomorHpOrtu);
          String? imei = (gAkunTesterOrtu.contains(nomorHpOrtuFormat))
              ? gTesterImeiOrtu
              : await gGetIdDevice();
              
          final res = await apiService.getAnakList({
            "nomor_hp": nomorHpOrtuFormat,
            "id_dev": imei,
          });

          if (res == null && res?.isEmpty == true) {
            throw 'List Anak tidak ditemukan';
          }

          List<Anak> listAnak = [];

          for (Map<String, dynamic> resAnak in res!) {
            Map<String, dynamic> bundlingParams = {
              "id_ortu": resAnak['c_id_ortu'].toString(),
              "noreg": resAnak['c_no_register'],
              "id_dev": imei,
              "daftar_anak": res.map((child) {
                return {
                  "c_no_register": child['c_no_register'],
                  "c_nama_lengkap": child['c_nama_lengkap'],
                  "c_email": child['c_email'],
                  "c_nomor_hp": child['c_nomor_hp'],
                };
              }).toList(),
            };

            final resBundling = await apiService.getBundlingAnak(
              bundlingParams,
            );

            resAnak['id_ortu'] = resAnak['c_id_ortu'].toString();

            listAnak.add(Anak.fromJson(
              json: resAnak,
              daftarAnak:
                  resBundling?['daftar_anak'].cast<Map<String, dynamic>>(),
              daftarBundling:
                  resBundling?['daftar_bundling'].cast<Map<String, dynamic>>(),
              daftarProduk:
                  resBundling?['daftar_produk'].cast<Map<String, dynamic>>(),
              listIdProduk: resBundling?['list_id_produk'].cast<int>(),
            ));
          }

          emit(LoadedListAnak(
            listAnak: listAnak,
          ));
        } on DataException catch (e) {
          String imei = await gGetIdDevice() ?? '';
          emit(PilihAnakErrResponse(err: e.toString(), deviceId: imei));
        } catch (e) {
          String imei = await gGetIdDevice() ?? '';
          emit(PilihAnakError(
            err: kDebugMode ? e.toString() : gPesanError,
            deviceId: imei,
          ));
        }
      }
    });
  }
}
