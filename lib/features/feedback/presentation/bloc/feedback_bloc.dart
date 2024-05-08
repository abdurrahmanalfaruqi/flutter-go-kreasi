import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/core/config/global.dart';
import 'package:gokreasi_new/core/util/app_exceptions.dart';
import 'package:gokreasi_new/core/util/injector.dart';
import 'package:gokreasi_new/features/feedback/data/model/feedback_question.dart';
import 'package:gokreasi_new/features/feedback/domain/usecase/feedback_usecase.dart';

part 'feedback_event.dart';
part 'feedback_state.dart';

class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  List<FeedbackQuestion> listPertanyaan = [];
  FeedbackBloc() : super(FeedbackInitial()) {
    on<LoadFeedback>((event, emit) async {
      try {
        emit(FeedbackLoading());
        final responseData = await locator<GetFeedbackQuestionUseCase>().call();
        listPertanyaan.clear();

        for (var i = 0; i < responseData.length; i++) {
          listPertanyaan.add(FeedbackQuestion.fromJson(responseData[i]));
        }

        if (listPertanyaan.isEmpty) {
          throw 'Data tidak ditemukan';
        }

        emit(FeedbackLoaded(listPertanyaan: listPertanyaan));
      } on NoConnectionException {
        emit(const FeedbackError("Silahkan Cek Koneksi Internet anda"));
      } catch (e) {
        emit(const FeedbackError(
            'Terjadi kesalahan saat mengambil data. \nMohon coba kembali nanti.'));
      }
    });

    on<AnswerFeedback>((event, emit) async {
      listPertanyaan[event.no].answer = event.answer;
      emit(FeedbackLoaded(listPertanyaan: listPertanyaan));
    });

    on<SaveFeedback>((event, emit) async {
      try {
        emit(FeedbackLoading());
        Map<String, dynamic> bodyParams = {
          "id_rencana": int.parse(event.rencanaId),
          "no_register": event.userId,
        };

        for (var i = 0; i < listPertanyaan.length; i++) {
          if (i == listPertanyaan.length - 1) {
            bodyParams['nomor_$i'] = (listPertanyaan[i].answer == null ||
                    listPertanyaan[i].answer == '')
                ? '-'
                : listPertanyaan[i].answer;
          } else {
            bodyParams['nomor_$i'] = listPertanyaan[i].answer?.trim() == 'y';
          }
        }

        await locator<SetFeedback>().call(params: bodyParams);
        emit(SaveFeedbackSucces());
      } on NoConnectionException {
        emit(const SaveFeedbackError("Silahkan Cek Koneksi Internet anda"));
      } on DataException catch (e) {
        emit(SaveFeedbackError(e.toString()));
      } catch (e) {
        emit(SaveFeedbackError((kDebugMode) ? e.toString() : gPesanError));
      }
    });
  }
}
