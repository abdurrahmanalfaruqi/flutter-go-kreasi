import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/menu/entity/menu.dart';
import 'package:gokreasi_new/features/menu/presentation/provider/menu_provider.dart';
import 'package:gokreasi_new/features/soal/entity/buku_soal.dart';
import 'package:gokreasi_new/features/soal/model/buku_soal_model.dart';
import 'package:gokreasi_new/features/soal/service/api/soal_service_api.dart';

part 'soal_event.dart';
part 'soal_state.dart';

class SoalBloc extends Bloc<SoalEvent, SoalState> {
  final Map<String, BukuSoal> _listBukuSoal = {};
  final _apiService = SoalServiceAPI();
  final _bukuSaktiMenu =
      const Menu(idJenis: 0, label: 'Buku Sakti', namaJenisProduk: 'sakti');

  SoalBloc() : super(const SoalState()) {
    on<LoadListBukuSoal>(_onLoadListBukuSoal);

    on<SetSelectedMenu>(_onSetSelectedMenu);
  }

  void _onSetSelectedMenu(SetSelectedMenu event, Emitter<SoalState> emit) {
    emit(state.copyWith(selectedMenu: event.selectedMenu));
  }

  void _onLoadListBukuSoal(
    LoadListBukuSoal event,
    Emitter<SoalState> emit,
  ) async {
    String bukuSoalKey =
        '${event.userData?.noRegistrasi}-${event.userData?.idBundlingAktif}';
    try {
      if (!event.isRefresh && _listBukuSoal.containsKey(bukuSoalKey)) {
        emit(state.copyWith(
          soalStatus: SoalStatus.success,
          bukuSoal: _listBukuSoal[bukuSoalKey],
        ));
        return;
      }

      emit(state.copyWith(soalStatus: SoalStatus.loading));

      final res = await _apiService
          .fetchListBukuSoal(event.userData?.listIdProduk ?? []);

      if (!_listBukuSoal.containsKey(bukuSoalKey)) {
        _listBukuSoal[bukuSoalKey] = const BukuSoal();
      }

      _listBukuSoal[bukuSoalKey] = BukuSoalModel.fromJson(res);

      _sortListBukuPaket(bukuSoalKey);

      _sortListBukuSakti(bukuSoalKey);

      _addBukuSaktiToBukuSoal(bukuSoalKey);

      if (_listBukuSoal[bukuSoalKey]?.listBukuPaket?.isEmpty == true) {
        _listBukuSoal[bukuSoalKey]
            ?.listBukuPaket
            ?.add(MenuProvider.emptyMenuBukuSoal);
      }

      emit(state.copyWith(
        soalStatus: SoalStatus.success,
        bukuSoal: _listBukuSoal[bukuSoalKey],
        selectedMenu: _listBukuSoal[bukuSoalKey]?.listBukuPaket?.first,
      ));
    } catch (e) {
      emit(state.copyWith(
        soalStatus: SoalStatus.error,
        bukuSoal: const BukuSoal(),
      ));
    }
  }

  /// [_sortListBukuSakti] digunakan untuk sorting buku sakti.
  void _sortListBukuSakti(String key) {
    _listBukuSoal[key]?.listBukuSakti?.sort((a, b) {
      if (a.idJenis == 76) {
        return -1;
      } else if (b.idJenis == 76) {
        return 1;
      } else if (a.idJenis == 72) {
        return 1;
      } else if (b.idJenis == 72) {
        return -1;
      } else {
        return 0;
      }
    });
  }

  /// [_sortListBukuPaket] digunakan untuk sorting buku paket.
  void _sortListBukuPaket(String key) {
    _listBukuSoal[key]?.listBukuPaket?.sort((a, b) {
      int orderA = _getOrder(a.idJenis);
      int orderB = _getOrder(b.idJenis);

      return orderA.compareTo(orderB);
    });
  }

  int _getOrder(int idJenis) {
    switch (idJenis) {
      case 77:
        return 1;
      case 78:
        return 2;
      case 79:
        return 3;
      case 82:
        return 4;
      case 80:
        return 5;
      case 16:
        return 6;
      default:
        return 0; // Default order, if idJenis is not recognized
    }
  }

  /// [_addBukuSaktiToBukuSoal] digunakan untuk menambah tab buku sakti ke
  /// dropdown ke index pertama.
  void _addBukuSaktiToBukuSoal(String key) {
    if (_listBukuSoal[key]?.listBukuPaket?.contains(_bukuSaktiMenu) == false &&
        _listBukuSoal[key]?.listBukuSakti?.isNotEmpty == true) {
      _listBukuSoal[key]?.listBukuPaket?.insert(0, _bukuSaktiMenu);
    }
  }
}
