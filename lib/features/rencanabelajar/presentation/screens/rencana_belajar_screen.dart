import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/rencanabelajar/presentation/bloc/rencana_belajar/rencana_belajar_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../widgets/event_calendar_widget.dart';
import '../provider/rencana_belajar_provider.dart';
import '../../model/rencana_belajar.dart';
import '../../service/notifikasi/local_notification_service.dart';
import '../../../../core/shared/screen/basic_screen.dart';

class RencanaBelajarScreen extends StatefulWidget {
  const RencanaBelajarScreen({Key? key}) : super(key: key);

  @override
  State<RencanaBelajarScreen> createState() => _RencanaBelajarScreenState();
}

class _RencanaBelajarScreenState extends State<RencanaBelajarScreen> {
  final CalendarController _calendarController = CalendarController();
  late final _rencanaProvider = context.read<RencanaBelajarProvider>();
  UserModel? userData;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is LoadedUser) {
      userData = authState.user;
    }
    LocalNotificationService().requestPermissions();
    context.read<RencanaBelajarBloc>().add(LoadRencanaBelajar(
        noregister: userData?.noRegistrasi ?? '', isRefresh: true));
  }

  @override
  Widget build(BuildContext context) {
    return BasicScreen(
        title: 'Rencana Belajar',
        onWillPop: _onWillPop,
        body: BlocBuilder<RencanaBelajarBloc, RencanaBelajarState>(
          builder: (context, state) {
            
            if (state is RencanaBelajarDataLoaded) {
             List<RencanaBelajar> listRencanaBelajar = state.listRencanaBelajar;
              return EventCalendarWidget(
                controller: _calendarController,
                onWillPopCalendar: _onWillPopCalendar,
                listRencanabelajar: listRencanaBelajar,
                rencanaMenu: state.listMenuRencana,
              );
            }

            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text(
                    'Sedang menyiapkan data\nrencana belajar...',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ));
  }

  void _onWillPop() {
    if (_onWillPopCalendar()) {
      Navigator.of(context).pop();
    }
  }

  bool _onWillPopCalendar() {
    switch (_calendarController.view) {
      case CalendarView.week:
        _calendarController.view = CalendarView.schedule;
        _rencanaProvider.calendarView = CalendarView.schedule;
        return false;
      default:
        return true;
    }
  }
}
