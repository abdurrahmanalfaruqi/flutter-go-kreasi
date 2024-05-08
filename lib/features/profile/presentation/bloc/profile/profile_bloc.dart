import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/core/helper/kreasi_shared_pref.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/home/service/home_service_api.dart';
import 'package:gokreasi_new/features/profile/domain/entity/mapel_pilihan.dart';
import 'package:gokreasi_new/features/profile/data/model/mapel_piliihan_model.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<ProfileEvent>((event, emit) async {
      final apiService = HomeServiceAPI();

      if (event is ProfileGetSekolahKelas) {
        emit(ProfileLoading());
        try {
          final idSekolahKelas =
              int.parse(event.userData?.idSekolahKelas ?? '0');
          final res = await apiService.getSekolahKelas();
          List<int> listIdSekolahKelas = res['data'].cast<int>() ?? [];

          bool validToChooseMapel =
              listIdSekolahKelas.any((ids) => ids == idSekolahKelas);

          if (!validToChooseMapel) {
            emit(ProfileNotValid());
            return;
          }

          UserModel? userData = await KreasiSharedPref().getUser();
          final resMapel = await apiService
                  .getCurrentMapelSiswa(userData?.noRegistrasi ?? '') ??
              [];
          List<MapelPilihan> listCurrentMapel =
              resMapel.map((curr) => MapelPilihanModel.fromJson(curr)).toList();

          emit(LoadedGetCurrentMapel(listCurrentMapel));
        } catch (e) {
          emit(ProfileError(e.toString()));
        }
      }

      if (event is ProfileGetOpsiMapel) {
        emit(ProfileLoading());
        try {
          final res =
              await apiService.getOpsiMapelPilihan(event.idSekolahKelas);
          List<dynamic> resOpsi = res['data']?['list_kelompok_ujian'] ?? [];
          List<MapelPilihan> listCurrentMapel =
              resOpsi.map((curr) => MapelPilihanModel.fromJson(curr)).toList();
          int minimalPilih = res['minimal_pilihan'] ?? 2;
          int maximalPilih = res['maksimal_pilihan'] ?? 4;

          emit(LoadedOpsiMapel(
            listOpsiMapel: listCurrentMapel,
            minimalPilih: minimalPilih,
            maximalPilih: maximalPilih,
          ));
        } catch (e) {
          emit(ProfileGetOpsiError(e.toString()));
        }
      }

      if (event is ProfileSaveMapel) {
        try {
          List<int?> listIdKelompokUjian = event.listSelectedMapel
              .map((mapel) => mapel.idKelompokKelas)
              .toList();
          Map<String, dynamic> params = {
            "no_register": event.noRegistrasi,
            "list_id_kelompok_ujian": listIdKelompokUjian,
          };
          final res = await apiService.saveMapelPilihan(params);

          if (!res) {
            emit(const ProfileFailedSaveMapel(
                'Terjadi kesalahan saat save mapel'));
            return;
          }

          emit(LoadedGetCurrentMapel(event.listSelectedMapel));
        } catch (e) {
          emit(ProfileFailedSaveMapel(e.toString()));
        }
      }
    });
  }
}
