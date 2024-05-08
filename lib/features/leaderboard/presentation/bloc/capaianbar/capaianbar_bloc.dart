import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/core/util/injector.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/home/domain/usecase/home_usecase.dart';
import 'package:gokreasi_new/features/leaderboard/model/pengerjaan_soal.dart';

part 'capaianbar_event.dart';
part 'capaianbar_state.dart';

enum Filternilai { harian, mingguan, bulanan }

class CapaianBarBloc extends Bloc<CapaianBarEvent, CapaianBarState> {
  final Map<String, List<PengerjaanSoal>> _listPengerjaanSoal = {};
  Filternilai filterNilai = Filternilai.harian;

  CapaianBarBloc() : super(CapaianBarState()) {
    on<LoadCapaianBar>((event, emit) async {
      try {
        emit(CapaianBarLoading());

        String capaianBarKey =
            '${event.userData?.noRegistrasi}-${event.userData?.idBundlingAktif}';
        if (!event.isRefresh &&
            _listPengerjaanSoal.containsKey(capaianBarKey)) {
          emit(CapaianBarDataLoaded(
            listPengerjaanSoal: _listPengerjaanSoal[capaianBarKey]!,
            filterNilai: filterNilai,
          ));
          return;
        }

        UserModel? userData = event.userData;
        final params = {
          "noreg": userData?.noRegistrasi,
          "idsekolahkelas": int.parse(userData?.idSekolahKelas ?? '0'),
          "tahun_ajaran": userData?.tahunAjaran,
          "idbundling": userData?.idBundlingAktif,
          "list_id_produk": userData?.listIdProduk,
        };
        final responseData = await locator<GetCapaianBar>().call(
          params: params,
        );

        if (responseData.isEmpty) {
          throw 'Data tidak ditemukan';
        }

        if (!_listPengerjaanSoal.containsKey(capaianBarKey)) {
          _listPengerjaanSoal[capaianBarKey] = [];
        }

        _listPengerjaanSoal[capaianBarKey] = responseData
            .map((capaian) => PengerjaanSoal.fromJson(capaian))
            .toSet()
            .toList();

        emit(CapaianBarDataLoaded(
          listPengerjaanSoal: _listPengerjaanSoal[capaianBarKey]!,
          filterNilai: filterNilai,
        ));
      } catch (e) {
        emit(CapaianBarError("Gagal Mengambil data"));
      }
    });

    on<SetFilternilai>((event, emit) {
      if (state is CapaianBarDataLoaded) {
        emit(
          CapaianBarDataLoaded(
            filterNilai: event.filternilai,
            listPengerjaanSoal:
                (state as CapaianBarDataLoaded).listPengerjaanSoal,
          ),
        );
      }
    });
  }
}
