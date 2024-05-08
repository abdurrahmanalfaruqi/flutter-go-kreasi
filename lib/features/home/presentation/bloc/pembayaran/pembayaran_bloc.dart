import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/core/util/injector.dart';
import 'package:gokreasi_new/features/home/domain/usecase/home_usecase.dart';
import 'package:gokreasi_new/features/pembayaran/entity/pembayaran.dart';
import 'package:gokreasi_new/features/pembayaran/model/pembayaran_model.dart';

part 'pembayaran_event.dart';
part 'pembayaran_state.dart';

class PembayaranBloc extends Bloc<PembayaranEvent, PembayaranState> {
  final Map<String, String?> _pesanPembayaran = {};
  final Map<String, List<Pembayaran>> _listDetailPembayaran = {};
  final Map<String, PembayaranModel> _infoPembayaran = {};
  PembayaranBloc() : super(PembayaranInitial()) {
    on<LoadPembayaran>((event, emit) async {
      try {
        emit(PembayaranLoading());
        String pembayaranKey = '${event.noRegistrasi}-${event.idbundling}';
        if (!event.isRefresh &&
            _pesanPembayaran.containsKey(pembayaranKey) &&
            _infoPembayaran.containsKey(pembayaranKey)) {
          emit(PembayaranDataLoaded(
              listDetailPembayaran: _listDetailPembayaran[pembayaranKey]!,
              pembayaranModel: _infoPembayaran[pembayaranKey]!,
              pesan: _pesanPembayaran[pembayaranKey]!));
          return;
        }

        if (!_pesanPembayaran.containsKey(pembayaranKey)) {
          _pesanPembayaran[pembayaranKey] = '';
        }

        if (!_listDetailPembayaran.containsKey(pembayaranKey)) {
          _listDetailPembayaran[pembayaranKey] = [];
        }

        if (!_infoPembayaran.containsKey(pembayaranKey)) {
          _infoPembayaran[pembayaranKey] = const PembayaranModel(
            id: "",
            total: "",
            current: "-1",
            remaining: "",
            status: "",
          );
        }

        if (_pesanPembayaran[pembayaranKey] == null ||
            _pesanPembayaran[pembayaranKey]?.isEmpty == true) {
          final params = {
            "no_register": event.noRegistrasi,
            "id_bundling": event.idbundling,
          };

          final response = await locator<GetPembayaran>().call(params: params);

          if (response['data'] != null) {
            _infoPembayaran[pembayaranKey] =
                PembayaranModel.fromJson(response['data']);
            _pesanPembayaran[pembayaranKey] = response['data']['message'] ??
                "Jika tidak sesuai silahkan hubungi 0853 5199 1159 (WA)";
          }
        }

        emit(PembayaranDataLoaded(
          pembayaranModel: _infoPembayaran[pembayaranKey]!,
          pesan: _pesanPembayaran[pembayaranKey]!,
          listDetailPembayaran: _listDetailPembayaran[pembayaranKey]!,
        ));
      } catch (e) {
        emit(PembayaranError(e.toString()));
      }
    });

    on<LoadPembayaranDetail>((event, emit) async {
      try {
        emit(PembayaranDetailLoading());
        String pembayaranKey = '${event.noRegistrasi}-${event.idbundling}';
        if (!event.isRefresh &&
            _listDetailPembayaran[pembayaranKey]?.isEmpty == true) {
          emit(PembayaranDataLoaded(
            pembayaranModel: _infoPembayaran[pembayaranKey]!,
            pesan: _pesanPembayaran[pembayaranKey]!,
            listDetailPembayaran: _listDetailPembayaran[pembayaranKey]!,
          ));
          return;
        }

        final params = {
          "no_register": event.noRegistrasi,
          "id_bundling": event.idbundling,
        };

        final responseData = await locator<GetDetailPembayaran>().call(
          params: params,
        );

        if (!_listDetailPembayaran.containsKey(pembayaranKey)) {
          _listDetailPembayaran[pembayaranKey] = [];
        }

        if (responseData.isNotEmpty) {
          _listDetailPembayaran[pembayaranKey] = responseData
              .map((bayar) => PembayaranModel.fromJson(bayar))
              .toList();
        }

        emit(PembayaranDataLoaded(
          pembayaranModel: _infoPembayaran[pembayaranKey]!,
          pesan: _pesanPembayaran[pembayaranKey]!,
          listDetailPembayaran: _listDetailPembayaran[pembayaranKey]!,
        ));
      } catch (e) {
        emit(PembayaranDetailError(e.toString()));
      }
    });
  }
}
