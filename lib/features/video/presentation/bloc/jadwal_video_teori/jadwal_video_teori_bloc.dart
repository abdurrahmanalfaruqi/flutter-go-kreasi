import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/core/util/injector.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/buku/domain/entity/buku.dart';
import 'package:gokreasi_new/features/buku/data/model/buku_model.dart';
import 'package:gokreasi_new/features/jadwal/domain/usecase/jadwal_usecase.dart';
import 'package:gokreasi_new/features/video/domain/entity/video_ekstra.dart';
import 'package:gokreasi_new/features/video/data/model/video_jadwal.dart';
import 'package:gokreasi_new/features/video/domain/usecase/video_usecase.dart';

part 'jadwal_video_teori_event.dart';
part 'jadwal_video_teori_state.dart';

class JadwalVideoTeoriBloc
    extends Bloc<JadwalVideoTeoriEvent, JadwalVideoTeoriState> {
  List<Buku> listBukuVideo = [];
  List<BabUtamaVideoJadwal> listBabVideo = [];
  
  JadwalVideoTeoriBloc() : super(JadwalVideoTeoriInitial()) {
    on<LoadDaftarVideo>((event, emit) async {
      try {
        emit(JadwalVideoLoading());
        final params = {
          "list_id_produk": event.listIdProduk,
        };
        final responseData = await locator<GetVideoJadwalMapel>().call(
          params: params,
        );

        listBukuVideo = [];
        if (responseData.isNotEmpty) {
          for (var dataBuku in responseData) {
            listBukuVideo.add(
              BukuModel.fromJson(
                  json: dataBuku, imageUrl: dataBuku['iconMapel']),
            );
          }

          listBukuVideo.sort(
              (a, b) => a.namaKelompokUjian.compareTo(b.namaKelompokUjian));

          emit(JadwalVideoLoaded(
              listBukuVideo: listBukuVideo, listBabVideo: listBabVideo));
        }
      } catch (e) {
        emit(JadwalVideoError(e.toString()));
      }
    });

    on<LoadDaftarBabVideo>((event, emit) async {
      try {
        emit(JadwalVideoLoading());
        final params = {
          "id_buku": event.idBuku,
          "level": event.levelTeori,
          "kelengkapan": event.kelengkapan,
        };
        final responseData = await locator<GetVideoJadwalUseCase>().call(
          params: params,
        );

        listBabVideo.clear();

        if (responseData.isNotEmpty) {
          for (var data in responseData) {
            if (data['info'].length != 0) {
              if (data['info'][0]['video'] != null) {
                listBabVideo.add(BabUtamaVideoJadwal.fromJson(data));
              }
            }
          }
        }
        emit(JadwalVideoLoaded(
          listBukuVideo: listBukuVideo,
          listBabVideo: listBabVideo,
        ));
      } catch (e) {
        emit(const JadwalVideoBabError("Data Video Kosong"));
      }
    });

    on<LoadDaftarVideoEkstra>((event, emit) async {
      try {
        emit(JadwalVideoLoading());
        List<VideoExtra> listVideoEkstra = [];
        final params = {
          "id_produk_aktif": event.userData?.listIdProduk,
          "id_sekolah_kelas": int.parse(event.userData?.idSekolahKelas ?? '0'),
          "id_jenis_kelas": event.userData?.idJenisKelas,
        };

        final responseData = await locator<GetVideoExtra>().call(
          params: params,
        );

        if (responseData.isEmpty) {
          throw 'Video Ekstra tidak ditemukan';
        }

        listVideoEkstra = List.generate(
          responseData.length,
          (index) => VideoExtra.fromJson(responseData[index], index),
        );

        Map<String, List<VideoExtra>> result = {};

        for (VideoExtra video in listVideoEkstra) {
          String jenis = video.jenis ?? '-';
          if (!result.containsKey(jenis)) {
            result[jenis] = [];
          }

          result[jenis]!.add(video);
        }

        emit(LoadedVideoEkstra(result));
      } catch (e) {
        emit(const JadwalVideoBabError('Data Video Ekstra Tidak Ada'));
      }
    });
  }
}
