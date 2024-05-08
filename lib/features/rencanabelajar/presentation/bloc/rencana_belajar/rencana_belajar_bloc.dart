import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/core/util/app_exceptions.dart';
import 'package:gokreasi_new/features/rencanabelajar/model/rencana_belajar.dart';
import 'package:gokreasi_new/features/rencanabelajar/model/rencana_menu.dart';
import 'package:gokreasi_new/features/rencanabelajar/service/api/rencana_service_api.dart';

part 'rencana_belajar_event.dart';
part 'rencana_belajar_state.dart';

class RencanaBelajarBloc
    extends Bloc<RencanaBelajarEvent, RencanaBelajarState> {
  final _apiService = RencanaBelajarServiceAPI();

  final List<RencanaMenu> _listMenuRencana = [];
  final List<RencanaBelajar> _listRencanaBelajar = [];
  RencanaBelajarBloc() : super(RencanaBelajarInitial()) {
    on<LoadRencanaBelajar>((event, emit) async {
      try {
        emit(RencanaBelajarLoading());
        final responseMenu = await _apiService.fetchListMenu();

        if (responseMenu['data'] != null) {
          List<dynamic> responseData = responseMenu['data'];

          if (event.isRefresh) _listMenuRencana.clear();

          if (_listMenuRencana.isEmpty) {
            for (var data in responseData) {
              _listMenuRencana.add(RencanaMenu.fromJson(data));
            }
          }
        }

        final response = await _apiService.fetchDataRencanaBelajar(
          noRegistrasi: event.noregister,
        );

        List<dynamic>? responseList = response['data'];

        if (responseList?.isNotEmpty ?? false) {
          List<dynamic> data = response['data'];

          if (event.isRefresh) _listRencanaBelajar.clear();

          if (_listRencanaBelajar.isEmpty) {
            for (var rencana in data) {
              _listRencanaBelajar
                  .add(RencanaBelajar.fromJson(rencana, _listMenuRencana));
            }
          }
        }
        emit(RencanaBelajarDataLoaded(
          listRencanaBelajar: _listRencanaBelajar,
          listMenuRencana: _listMenuRencana,
        ));
      } on DataException catch (e) {
        emit(RencanaBelajarError(e.toString()));
      } catch (e) {
        emit(const RencanaBelajarError("gagal Mengambil data"));
      }
    });
  }
}
