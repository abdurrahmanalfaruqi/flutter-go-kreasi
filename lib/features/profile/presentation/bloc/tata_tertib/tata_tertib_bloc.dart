import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/features/profile/service/api/data_service_api.dart';

part 'tata_tertib_event.dart';
part 'tata_tertib_state.dart';

class TataTertibBlocBloc
    extends Bloc<TataTertibBlocEvent, TataTertibBlocState> {
  String aturan = '';
  int idtataTertib = 0;
  DataServiceAPI dataServiceAPI = DataServiceAPI();
  TataTertibBlocBloc() : super(TataTertibBlocInitial()) {
    on<LoadTataTertib>((event, emit) async {
      try {
        emit(TataTertibBlocLoading());
        final responeData = await dataServiceAPI.fetchAturan(
          noRegistrasi: event.noregister,
          tahunAjaran: event.tahunAjaran,
        );
        aturan = responeData['deskripsi'];
        idtataTertib = responeData['id_tata_tertib'];

        emit(
          TataTertibBlocDataLoaded(
              aturanHtml: responeData['deskripsi'],
              isMenyetujui: responeData['is_setuju']),
        );
      } catch (e) {
        emit(const TataTertibBlocError("Gagal Mengambil Aturan"));
      }
    });

    on<StujuiTataTertib>((event, emit) async {
      try {
        emit(TataTertibBlocLoading());
        final responseData = await dataServiceAPI.setAturanSiswa(
          noRegistrasi: event.noregister,
          idTataTertib: idtataTertib,
        );

        if (responseData) {
          emit(TataTertibBlocDataLoaded(
            aturanHtml: aturan,
            isMenyetujui: true,
          ));
        } else {
          emit(TataTertibBlocDataLoaded(
            aturanHtml: aturan,
            isMenyetujui: false,
            hasError: true,
          ));
        }
      } catch (e) {
        emit(TataTertibBlocDataLoaded(
          aturanHtml: aturan,
          isMenyetujui: false,
          hasError: true,
        ));
      }
    });
  }
}
