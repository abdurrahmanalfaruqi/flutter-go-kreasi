import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gokreasi_new/core/config/global.dart';
import 'package:gokreasi_new/core/helper/kreasi_shared_pref.dart';
import 'package:gokreasi_new/core/util/app_exceptions.dart';
import 'package:gokreasi_new/core/util/injector.dart';
import 'package:gokreasi_new/features/home/data/model/promotion_model.dart';
import 'package:gokreasi_new/features/home/domain/entity/promotion.dart';
import 'package:gokreasi_new/features/home/domain/usecase/home_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<HomeEvent>((event, emit) async {
      if (event is GetPromotionEvent) {
        try {
          emit(HomeLoading());
          final dateNow = DateTime.now().toUtc();
          // final dateNow = DateTime.parse("2024-03-09T00:00:00+00:00").toUtc();

          final savedPromoEvent = KreasiSharedPref().getPromoEvent();

          final res = await locator<GetPromotionEventUseCase>().call();
          final promotionData = PromotionModel.fromJson(res['data']);

          if (res.isEmpty) {
            throw 'Data tidak ditemukan';
          }

          if (promotionData.tanggalKedaluarsa.toUtc().isBefore(dateNow)) {
            throw 'Promo sudah habis';
          }

          // masuk block ini jika promo sudah tampil hari ini
          if (savedPromoEvent != null &&
              _isSameDate(savedPromoEvent.updatedAt, dateNow)) {
            throw 'Promo sudah tampil hari ini';
          }

          await KreasiSharedPref().setPromoEvent(promotionData);

          emit(LoadedPromotion(promotionData));
        } on DataException catch (e) {
          emit(HomeError(err: e.toString()));
        } catch (e) {
          emit(HomeError(err: (kDebugMode) ? e.toString() : gPesanError));
        }
      }
    });
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
