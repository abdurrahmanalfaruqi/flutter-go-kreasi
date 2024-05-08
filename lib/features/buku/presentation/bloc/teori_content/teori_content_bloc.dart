import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/core/util/injector.dart';
import 'package:gokreasi_new/features/buku/data/model/content_model.dart';
import 'package:gokreasi_new/features/buku/domain/usecase/buku_usecase.dart';

part 'teori_content_event.dart';
part 'teori_content_state.dart';

class TeoriContentBloc extends Bloc<TeoriContentEvent, TeoriContentState> {
  TeoriContentBloc() : super(TeoriContentInitial()) {
    on<TeoriContentEvent>((event, emit) async {
      if (event is LoadTeoriContent) {
        try {
          emit(TeoriContentLoading());
          final params = {
            "kode_bab": event.kodeBab,
            "kode_teori": int.parse(event.idTeoriBab),
            "level": event.level,
            "jenis": event.jenis,
          };

          final responseData = await locator<FetchContent>().call(
            params: params,
          );

          final content = ContentModel.fromJson(responseData);

          emit(TeoriContentLoaded(content));
        } catch (e) {
          emit(TeoriContentError(e.toString()));
        }
      }
    });
  }
}
