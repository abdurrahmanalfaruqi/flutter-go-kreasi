import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/core/helper/kreasi_shared_pref.dart';
import 'package:gokreasi_new/core/util/injector.dart';
import 'dart:developer' as logger;
import 'package:gokreasi_new/features/berita/domain/entity/berita.dart';
import 'package:gokreasi_new/features/berita/data/model/berita_model.dart';
import 'package:gokreasi_new/features/berita/domain/usecase/berita_usecase.dart';

part 'news_event.dart';
part 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  NewsBloc() : super(NewsInitial()) {
    on<LoadNews>((event, emit) async {
      try {
        emit(NewsLoading());
        final responseData = await locator<FetchBeritaUseCase>().call();

        List<Berita> listBerita = [];

        for (Map<String, dynamic> berita in responseData) {
          listBerita.add(BeritaModel.fromJson(berita));
        }

        List<Berita> headlinesNews = listBerita.take(10).toList();

        emit(NewsDataLoaded(
          headlineNews: headlinesNews,
          allNews: listBerita,
        ));
      } catch (e) {
        emit(NewsError(e.toString()));
      }
    });

    on<NewsAddViewer>((event, emit) async {
      try {
        await locator<SetBeritaViewerUseCase>().call(
          params: {
            'id_berita': event.idBerita,
          },
        );
      } catch (e) {
        if (kDebugMode) {
          logger.log('Exception-AddViewer: $e');
        }
      }
    });

    on<LoadBeritaPopUp>((event, emit) async {
      try {
        final res = await locator<FetchBeritaPopUpUseCase>().call();

        List<Berita> listBeritaPopUp = [];

        for (Map<String, dynamic> berita in res) {
          listBeritaPopUp.add(BeritaModel.fromJson(berita));
        }

        List<Berita>? headlineNews = [];
        List<Berita>? allNews = [];

        if (state is NewsDataLoaded) {
          headlineNews = (state as NewsDataLoaded).headlineNews;
          allNews = (state as NewsDataLoaded).allNews;
        }

        final idBeritaPopUp = int.parse(listBeritaPopUp.first.id);
        await KreasiSharedPref().setIdBeritaPopUp(idBeritaPopUp);

        Berita selectedBerita = listBeritaPopUp
            .firstWhere((news) => int.parse(news.id) == idBeritaPopUp);

        String editedDescription =
            selectedBerita.description.replaceAll('rn', '');
        String editedSummary = selectedBerita.summary.replaceAll('rn', '');

        Berita processedNews = selectedBerita.copyWith(
          description: editedDescription,
          summary: editedSummary,
        );

        emit(NewsDataLoaded(
          beritaPopUp: processedNews,
          allNews: allNews,
          headlineNews: headlineNews,
        ));
      } catch (e) {
        if (kDebugMode) {
          logger.log('Exception-LoadBeritaPopUp: $e');
        }
      }
    });
  }
}
