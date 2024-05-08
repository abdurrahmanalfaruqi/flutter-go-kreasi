import 'dart:async';
import 'dart:io';

import 'dart:developer' as logger show log;
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/core/config/extensions.dart';
import 'package:gokreasi_new/core/config/global.dart';
import 'package:gokreasi_new/core/shared/service/api/log_service_api.dart';
import 'package:gokreasi_new/core/shared/service/local/log_service_local.dart';
import 'package:gokreasi_new/core/util/app_exceptions.dart';

part 'log_event.dart';

part 'log_state.dart';

class LogBloc extends Bloc<LogEvent, LogState> {
  final _apiService = LogServiceAPI();
  final _localService = LogServiceLocal();

  int? _lastid;

  LogBloc() : super(LogInitial()) {
    on<SendLogActivity>(_onSendLogActivity);
    on<SaveLog>(_onSaveLog);
  }

  void _onSendLogActivity(SendLogActivity event, Emitter<LogState> emit) async {
    try {
      if (gUser == null || (gUser?.isOrtu ?? false) || event.userType == null) {
        return;
      }
      String platform = "Android";
      if (Platform.isIOS) {
        platform = "IOS";
      }
      final listLog = await _localService.fetchLog();

      if (listLog.isNotEmpty) {
        _lastid = await _apiService.setLog(
            userType: event.userType ?? '',
            listLog: listLog.toList(),
            platform: platform,
            lastid: _lastid);
        if (kDebugMode) {
          logger.log("cek log ${listLog.toList()}");
        }
        await _localService.deleteLog();
      }
    } on TimeoutException catch (e) {
      // throw 'TimeoutException-SendLogActivity: $e';
      if (kDebugMode) {
        logger.log('TimeoutException-SendLogActivity: $e');
      }
    } on DataException catch (e) {
      // throw 'Exception-SendLogActivity: $e';
      if (kDebugMode) {
        logger.log('Exception-SendLogActivity: $e');
      }
    } catch (e) {
      // throw 'FatalException-SendLogActivity: $e';
      if (kDebugMode) {
        logger.log('FatalException-SendLogActivity: $e');
      }
    }
  }

  void _onSaveLog(SaveLog event, Emitter<LogState> emit) async {
    try {
      if (gUser == null || gUser.isOrtu) {
        return;
      }
      await _localService.insertLog(
        userId: event.userId!,
        userType: event.userType!,
        menu: event.menu!,
        info: event.info!,
        accessType: event.accessType!,
      );
      if (kDebugMode) {
        logger.log("Berhasil menyimpan log aktivitas");
      }
    } catch (e) {
      if (kDebugMode) {
        logger.log('FatalException-SaveLog: $e');
      }
    }
  }
}
