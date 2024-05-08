import 'package:flutter/material.dart';
import 'package:gokreasi_new/features/soal/module/timer_soal/presentation/provider/tob_provider.dart';
import 'package:provider/provider.dart';

import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';

import '../../../../core/config/extensions.dart';

class SoalCountdownTimer extends StatefulWidget {
  final bool isBlockingTime;
  final String kodePaket;
  final VoidCallback onEndTimer;
  final CountdownController? countdownController;
  final Function(double) onTick;

  const SoalCountdownTimer({
    Key? key,
    required this.isBlockingTime,
    required this.onEndTimer,
    this.countdownController,
    required this.kodePaket,
    required this.onTick,
  }) : super(key: key);

  @override
  State<SoalCountdownTimer> createState() => _SoalCountdownTimerState();
}

class _SoalCountdownTimerState extends State<SoalCountdownTimer> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: context.dp(6)),
      child: Selector<TOBProvider, Duration>(
        selector: (_, tob) => tob.waktuPengerjaan,
        shouldRebuild: (previous, next) => previous != next,
        builder: (context, sisaWaktuPengerjaan, child) {
          return Countdown(
            controller: widget.countdownController,
            seconds: sisaWaktuPengerjaan.inSeconds,
            interval: const Duration(seconds: 1),
            onFinished: widget.onEndTimer,
            build: (context, time) {
              widget.onTick(time);
              int hours = (time / 3600).floor();
              int minutes = ((time % 3600) / 60).floor();
              int seconds = (time % 60).floor();

              String displayTime =
                  '${(minutes < 10) ? '0$minutes' : minutes} : ${(seconds < 10) ? '0$seconds' : seconds}';
              Color textColor = context.onPrimary;
              if (sisaWaktuPengerjaan.inHours >= 1) {
                displayTime =
                    '$hours : ${(minutes < 10) ? '0$minutes' : minutes} : ${(seconds < 10) ? '0$seconds' : seconds}';
              }

              if (time < 11) {
                bool isOdd = time.round().isOdd;
                textColor = isOdd ? context.onPrimary : context.secondaryColor;
                displayTime += '  ';

                if (!context.isMobile) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayTime,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: textColor),
                      ),
                      Text(
                        'Waktu akan habis',
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                        style:
                            context.text.labelSmall?.copyWith(color: textColor),
                      ),
                    ],
                  );
                }

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayTime,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: textColor),
                    ),
                    Text(
                      'Waktu akan habis',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      style:
                          context.text.labelSmall?.copyWith(color: textColor),
                    ),
                  ],
                );
              }

              return Text(
                displayTime,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: textColor),
              );
            },
          );
        },
      ),
      // BlocBuilder<TOBKBloc, TOBKState>(
      //   builder: (context, state) {
      //     if (state is LoadedSisaWaktu) {
      //       Duration sisaWaktuPengerjaan = state.sisaWaktu;

      //     }
      //     return Container();
      //   },
      // ),
    );
  }
}
