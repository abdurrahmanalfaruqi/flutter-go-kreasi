import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/core/util/app_exceptions.dart';
import 'package:gokreasi_new/core/util/injector.dart';
import 'package:gokreasi_new/features/soal/module/bundel_soal/domain/entity/bab_soal.dart';
import 'package:gokreasi_new/features/soal/module/bundel_soal/domain/entity/bundel_soal.dart';
import 'package:gokreasi_new/features/soal/module/bundel_soal/data/model/bab_soal_model.dart';
import 'package:gokreasi_new/features/soal/module/bundel_soal/data/model/bundle_soal_model.dart';
import 'package:gokreasi_new/features/soal/module/bundel_soal/domain/usecase/bundel_soal_usecase.dart';

part 'bundel_soal_event.dart';
part 'bundel_soal_state.dart';

class BundelSoalBloc extends Bloc<BundelSoalEvent, BundelSoalState> {
  final Map<String, List<List<BundelSoal>>> _bundleSoal = {};
  final Map<String, List<String>> _kelompokUjian = {};
  final Map<String, List<BabUtamaSoal>> _listUtamaSoal = {};

  set clearBundleSoalState(bool isLogout) {
    if (isLogout) {
      _bundleSoal.clear();
      _kelompokUjian.clear();
      _listUtamaSoal.clear();
    }
  }

  BundelSoalBloc() : super(BundelSoalInitial()) {
    on<GetBundelSoalList>((event, emit) async {
      try {
        String bundleKey = '${event.idJenisProduk}' '${event.idBundlingAktif}';

        List<List<BundelSoal>> listBundleSoal = [];
        List<String> listKelompokUjian = [];

        if (_bundleSoal.containsKey(bundleKey)) {
          listBundleSoal = _bundleSoal[bundleKey]!;
        }

        if (_kelompokUjian.containsKey(bundleKey)) {
          listKelompokUjian = _kelompokUjian[bundleKey]!;
        }

        if (!event.isRefresh &&
            listBundleSoal.isNotEmpty &&
            listKelompokUjian.isNotEmpty) {
          emit(BundelSoalLoaded(
            listBundelSoal: listBundleSoal,
            listKelompokUjian: listKelompokUjian,
          ));
          return;
        }

        emit(BundelSoalLoading());

        var responseData = await locator<GetDaftarBundelUseCase>().call(
          params: {
            'idJenisProduk': event.idJenisProduk.toString(),
            'list_id_produk': event.listIdProduk,
            'no_register': event.noRegistrasi,
          },
        );

        if (!_bundleSoal.containsKey(bundleKey)) {
          _bundleSoal[bundleKey] = [];
        }

        if (!_kelompokUjian.containsKey(bundleKey)) {
          _kelompokUjian[bundleKey] = [];
        }

        if (responseData.isNotEmpty) {
          var data = responseData.values.toList();
          _bundleSoal[bundleKey] = data
              .map((bundle) => (bundle as List)
                  .map((bun) => BundleSoalModel.fromJson(bun))
                  .toList())
              .toList();

          _kelompokUjian[bundleKey] =
              responseData.keys.toList().map((kel) => kel).toList();
        }

        // final List<dynamic> listBundelSoalResponse =
        //     responseData['list_paket'] ?? [];
        // final List<dynamic> listNamaKelompokUjian =
        //     responseData['list_kelompok_ujian'] ?? [];
        // final int jumlahHalaman = responseData['jumlah_halaman'];

        // Map<String, List<BundelSoal>> listBundelSoal = {};
        // String? namaKelompokUjian;
        // String? singkatan;
        // String? icon;
        //
        // if (listBundelSoalResponse.isNotEmpty) {
        //   for (Map<String, dynamic> dataPaket in listBundelSoalResponse) {
        //     final int cIdKelompokUjian =
        //         dataPaket['daftar_bundel_soal'][0]['c_id_kelompok_ujian'];
        //
        //     // Cari nama kelompok ujian berdasarkan cIdKelompokUjian
        //
        //     for (Map<String, dynamic> namaKelompok in listNamaKelompokUjian) {
        //       if (namaKelompok['c_id_kelompok_ujian'] == cIdKelompokUjian) {
        //         namaKelompokUjian = namaKelompok['c_nama_kelompok_ujian'];
        //         singkatan = namaKelompok['c_singkatan'];
        //         icon = namaKelompok['c_icon_mapel_mobile'];
        //         break;
        //       }
        //     }
        //
        //     dataPaket['nama_kelompok_ujian'] = namaKelompokUjian;
        //     dataPaket['singkatan'] = singkatan;
        //     dataPaket['iconMapel'] = icon;
        //     // Tambahkan data ke dalam listBundelSoal
        //     if (namaKelompokUjian != null) {
        //       if (!listBundelSoal.containsKey(namaKelompokUjian)) {
        //         listBundelSoal[namaKelompokUjian] = [];
        //       }
        //       listBundelSoal[namaKelompokUjian]
        //           ?.add(BundleSoalModel.fromJson(dataPaket));
        //     }
        //   }
        // }

        emit(BundelSoalLoaded(
          listBundelSoal: _bundleSoal[bundleKey] ?? [],
          listKelompokUjian: _kelompokUjian[bundleKey] ?? [],
        ));
      } on NoConnectionException catch (_) {
        emit(const BundelSoalError(err: "Silahkan Cek Koneksi Internet anda"));
      } on DataException catch (e) {
        emit(BundelSoalError(err: e.toString()));
      } catch (e) {
        emit(const BundelSoalError(err: "Data List Paket Tidak di temukan"));
      }
    });

    on<GetBundleBabList>((event, emit) async {
      try {
        String babKey = '${event.idBundle}' '${event.idBundlingAktif}';
        List<BabUtamaSoal> listBab = [];

        if (_listUtamaSoal.containsKey(babKey)) {
          listBab = _listUtamaSoal[babKey]!;
        }

        if (!event.isRefresh && listBab.isNotEmpty) {
          emit(LoadedBundleBab(listBab));
          return;
        }

        emit(BundelSoalLoading());

        final res = await locator<GetDaftarBabSubBabUseCase>().call(params: {
          'id_bundel': event.idBundle,
        });

        if (res.isEmpty) throw "Bab soal tidak ditemukan";

        if (!_listUtamaSoal.containsKey(babKey)) {
          _listUtamaSoal[babKey] = [];
        }

        _listUtamaSoal[babKey] =
            res.map((x) => BabUtamaSoalModel.fromJson(x)).toList();

        emit(LoadedBundleBab(_listUtamaSoal[babKey] ?? []));
      } catch (e) {
        emit(BundelSoalError(err: e.toString()));
      }
    });
  }
}
