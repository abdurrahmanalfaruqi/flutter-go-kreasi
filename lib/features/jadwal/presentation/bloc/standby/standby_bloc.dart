import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/core/config/enum.dart';
import 'package:gokreasi_new/core/config/global.dart';
import 'package:gokreasi_new/core/util/app_exceptions.dart';
import 'package:gokreasi_new/core/util/injector.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/jadwal/domain/usecase/jadwal_usecase.dart';
import 'package:gokreasi_new/features/standby/model/standby_model.dart';

part 'standby_event.dart';
part 'standby_state.dart';

class StandbyBloc extends Bloc<StandbyEvent, StandbyState> {
  final List<StandbyModel> _listStandby = [];

  StandbyBloc() : super(StandbyInitial()) {
    on<LoadStandby>((event, emit) async {
      try {
        emit(StandbyLoading());
        _listStandby.clear();
        Map<String, dynamic> params = {
          "no_register": event.userData?.noRegistrasi,
          "id_gedung": int.parse(event.userData?.idGedung ?? '0'),
          "tahun_ajaran": event.userData?.tahunAjaran,
          "tingkat_kelas": int.tryParse(event.userData?.tingkatKelas ?? '0'),
        };
        final responseData =
            await locator<GetStandByUseCase>().call(params: params);

        if (responseData.isEmpty) {
          throw 'Gagal mengambil data';
        }

        for (Map<String, dynamic> element in responseData) {
          _listStandby.add(StandbyModel.fromJson(element));
        }
        emit(StandbyDataLoaded(listStandby: _listStandby));
      } catch (e) {
        emit(const StandbyError("Gagal Mengambil Data"));
      }
    });

    on<RequestTST>((event, emit) async {
      try {
        emit(RequestTSTLoading(event.planId));
        final resposeData = await locator<PostRequestTSTUseCase>().call(
          params: event.params,
        );

        if (!resposeData) {
          throw 'Gagal request TST';
        }

        gShowTopFlash(
          gNavigatorKey.currentContext!,
          'Yeey, kamu berhasil mengajukan TST Sobat',
          dialogType: DialogType.success,
        );

        add(LoadStandby(userData: event.userData));
      } on DataException catch (e) {
        await gShowTopFlash(
          gNavigatorKey.currentContext!,
          e.toString(),
          dialogType: DialogType.error,
        );
        emit(StandbyDataLoaded(listStandby: _listStandby));
      } catch (e) {
        await gShowTopFlash(
          gNavigatorKey.currentContext!,
          (kDebugMode) ? e.toString() : gPesanError,
          dialogType: DialogType.error,
        );
        emit(StandbyDataLoaded(listStandby: _listStandby));
      }
    });
  }
}
