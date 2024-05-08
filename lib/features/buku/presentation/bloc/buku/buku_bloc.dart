import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/core/util/injector.dart';
import 'package:gokreasi_new/features/buku/domain/entity/bab_buku.dart';
import 'package:gokreasi_new/features/buku/domain/entity/buku.dart';
import 'package:gokreasi_new/features/buku/data/model/bab_buku_model.dart';
import 'package:gokreasi_new/features/buku/data/model/buku_model.dart';
import 'package:gokreasi_new/features/buku/domain/usecase/buku_usecase.dart';

part 'buku_event.dart';
part 'buku_state.dart';

class BukuBloc extends Bloc<BukuEvent, BukuState> {
  Map<String, List<Buku>> buku = {};
  Map<String, List<BabUtamaBuku>> babBuku = {};

  BukuBloc() : super(BukuInitial()) {
    on<LoadDaftarBuku>((event, emit) async {
      try {
        String bukuKey = '${event.idJenisProduk}' '${event.idBundlingAktif}';
        List<Buku> listBuku = [];

        if (buku.containsKey(bukuKey)) {
          listBuku = buku[bukuKey]!;
        }

        if (!event.isRefresh && listBuku.isNotEmpty) {
          emit(BukuLoaded(
            listBuku: listBuku,
            listBab: const [],
          ));
          return;
        }

        emit(BukuLoading());

        final params = {
          "no_registrasi": event.noRegistrasi,
          "list_id_produk": event.listIdProduk,
          "id_jenis_produk": event.idJenisProduk,
        };
        final responseData = await locator<FetchDaftarBuku>().call(
          params: params,
        );

        if (!buku.containsKey(bukuKey)) {
          buku[bukuKey] = [];
        }

        if (responseData.isNotEmpty) {
          buku[bukuKey] = responseData
              .map((x) => BukuModel.fromJson(json: x, imageUrl: x['iconMapel']))
              .toList();

          buku[bukuKey]!.sort(
              (a, b) => a.namaKelompokUjian.compareTo(b.namaKelompokUjian));
        }

        emit(BukuLoaded(
          listBuku: buku[bukuKey] ?? [],
          listBab: const [],
        ));
      } catch (e) {
        emit(BukuError(e.toString()));
      }
    });

    on<LoadDaftarBab>((event, emit) async {
      try {
        String bukuKey = '${event.idJenisProduk}' '${event.idBundlingAktif}';
        String babKey = '${event.kodeBuku}' '${event.idBundlingAktif}';

        List<Buku> listBuku = [];
        List<BabUtamaBuku> listBab = [];

        if (babBuku.containsKey(babKey)) {
          listBab = babBuku[babKey]!;
        }

        if (buku.containsKey(bukuKey)) {
          listBuku = buku[bukuKey]!;
        }

        if (!event.isRefresh && listBab.isNotEmpty) {
          emit(BukuLoaded(
            listBab: listBab,
            listBuku: listBuku,
          ));
          return;
        }

        emit(BukuLoading());

        final params = {
          "id_buku": int.parse(event.kodeBuku),
          "level": event.levelTeori,
          "kelengkapan": event.kelengkapan,
        };

        final responseData = await locator<FetchDaftarBab>().call(
          params: params,
        );

        if (!babBuku.containsKey(babKey)) {
          babBuku[babKey] = [];
        }

        if (responseData.isNotEmpty) {
          babBuku[babKey] =
              responseData.map((x) => BabUtamaBukuModel.fromJson(x)).toList();
        }

        emit(BukuLoaded(
          listBab: babBuku[babKey] ?? [],
          listBuku: listBuku,
        ));
      } catch (e) {
        emit(BukuError(e.toString()));
      }
    });
  }
}
