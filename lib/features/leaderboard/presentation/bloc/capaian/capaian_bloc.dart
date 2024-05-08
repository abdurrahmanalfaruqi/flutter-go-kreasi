import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/core/helper/kreasi_shared_pref.dart';
import 'package:gokreasi_new/core/util/injector.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/home/domain/usecase/home_usecase.dart';
import 'package:gokreasi_new/features/leaderboard/model/capaian_detail_score.dart';
import 'package:gokreasi_new/features/leaderboard/model/capaian_score.dart';

part 'capaian_event.dart';
part 'capaian_state.dart';

class CapaianBloc extends Bloc<CapaianEvent, CapaianState> {
  final Map<String, List<CapaianDetailScore>> _capaianNilaiDetail = {};
  final Map<String, CapaianScore> _capaianScore = {};

  CapaianBloc() : super(CapaianState()) {
    on<LoadCapaian>((event, emit) async {
      try {
        emit(CapaianLoading());

        String capaianKey =
            '${event.userData?.noRegistrasi}-${event.userData?.idBundlingAktif}';
        final savedCapaianSkor = KreasiSharedPref().getCapaianSkor();
        final savedCapaianNilaiDetail =
            KreasiSharedPref().getCapaianNilaiDetail();

        bool isCapaianSaved =
            savedCapaianSkor != null && savedCapaianNilaiDetail != null;

        if (isCapaianSaved && !event.isRefresh) {
          emit(CapaianDataLoaded(
            capaianScore: savedCapaianSkor[capaianKey]!,
            capaianNilaiDetail: savedCapaianNilaiDetail[capaianKey]!,
          ));
          return;
        }

        if (!event.isRefresh &&
            _capaianNilaiDetail.containsKey(capaianKey) &&
            _capaianScore.containsKey(capaianKey)) {
          emit(CapaianDataLoaded(
            capaianScore: _capaianScore[capaianKey]!,
            capaianNilaiDetail: _capaianNilaiDetail[capaianKey]!,
          ));
          return;
        }

        UserModel? userData = event.userData;
        final params = {
          "noreg": userData?.noRegistrasi,
          "idsekolahkelas": int.parse(userData?.idSekolahKelas ?? '0'),
          "idgedung": int.parse(userData?.idGedung ?? '0'),
          "idkota": int.parse(userData?.idKota ?? '0'),
          "tahun_ajaran": userData?.tahunAjaran,
          "idbundling": userData?.idBundlingAktif
        };

        final responseData = await locator<GetCapaianScore>().call(
          params: params,
        );

        if (!_capaianNilaiDetail.containsKey(capaianKey)) {
          _capaianNilaiDetail[capaianKey] = [];
        }

        if (!_capaianScore.containsKey(capaianKey)) {
          _capaianScore[capaianKey] = const CapaianScore(
              totalScore: 0,
              totalSoal: 0,
              targetJumlahSoal: 0,
              totalSoalBenar: 0,
              totalSoalSalah: 0,
              rankingGedung: 0,
              rankingKota: 0,
              rankingNasional: 0);
        }

        _capaianScore[capaianKey] = CapaianScore.fromJson(responseData);
        final Map<String, dynamic>? detail =
            responseData.containsKey('detil') ? responseData['detil'] : null;
        // total merupakan totalScore siswa
        final int total = responseData.containsKey('totalscore')
            ? responseData['totalscore']
            : 0;

        if (detail != null &&
            _capaianNilaiDetail[capaianKey]?.isEmpty == true) {
          int totalBenar = 0;
          int totalSalah = 0;

          for (int i = 1; i <= 5; i++) {
            totalBenar += detail['benarlevel$i'] as int;
            totalSalah += detail['salahlevel$i'] as int;

            _capaianNilaiDetail[capaianKey]!.add(
              CapaianDetailScore(
                label: 'Bintang $i',
                benar: detail['benarlevel$i'],
                salah: detail['salahlevel$i'],
                score: detail['benarlevel$i'] * i,
              ),
            );
          }

          _capaianNilaiDetail[capaianKey]!.add(
            CapaianDetailScore(
              label: 'Total',
              benar: totalBenar,
              salah: totalSalah,
              score: total,
            ),
          );
        }

        await KreasiSharedPref().setCapaianSkor(_capaianScore);
        await KreasiSharedPref().setCapaianNilaiDetail(_capaianNilaiDetail);

        emit(CapaianDataLoaded(
          capaianScore: _capaianScore[capaianKey]!,
          capaianNilaiDetail: _capaianNilaiDetail[capaianKey]!,
        ));
      } catch (e) {
        if (!event.isRefresh) {
          emit(CapaianError(e.toString()));
        }
      }
    });
  }
}
