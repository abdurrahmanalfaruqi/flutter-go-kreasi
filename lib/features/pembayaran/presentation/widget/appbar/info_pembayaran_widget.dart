import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/features/home/presentation/bloc/pembayaran/pembayaran_bloc.dart';

import '../detail_pembayaran.dart';
import '../../../../auth/data/model/user_model.dart';
import '../../../../../core/config/global.dart';
import '../../../../../core/config/extensions.dart';
import '../../../../../core/util/data_formatter.dart';
import '../../../../../core/shared/widget/card/custom_card.dart';
import '../../../../../core/shared/widget/loading/shimmer_widget.dart';

class InfoPembayaranWidget extends StatefulWidget {
  final UserModel userData;

  const InfoPembayaranWidget({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  State<InfoPembayaranWidget> createState() => _InfoPembayaranWidgetState();
}

class _InfoPembayaranWidgetState extends State<InfoPembayaranWidget> {

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PembayaranBloc, PembayaranState>(
      builder: (context, state) {
        int currentBayar = 0;
        String pesan = '';
        if (state is PembayaranLoading) {
          return ShimmerWidget.rounded(
            width: min(114, context.dp(114)),
            height: min(28, context.dp(28)),
            borderRadius: gDefaultShimmerBorderRadius,
          );
        }
        if (state is PembayaranDataLoaded) {
          currentBayar = int.parse(state.pembayaranModel.current);
          pesan = state.pesan;
        }
        if (context.isMobile) {
          return Expanded(
            child: _buildCustomCard(context, currentBayar, pesan),
          );
        }
        return _buildCustomCard(context, currentBayar, pesan);
      },
    );
  }

  CustomCard _buildCustomCard(
      BuildContext context, int currentBayar, String pesan) {
    return CustomCard(
      onTap: () => _showDetailPembayaran(context),
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.only(right: context.dp(12)),
      borderRadius: BorderRadius.circular(32),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/icon/ic_payment.webp',
            width: min(40, context.dp(26)),
            height: min(40, context.dp(26)),
          ),
          SizedBox(width: min(20, context.dp(4))),
          Expanded(
            child: Column(
              mainAxisSize:
                  (context.isMobile) ? MainAxisSize.max : MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Tooltip(
                  triggerMode: TooltipTriggerMode.tap,
                  textStyle: context.text.bodySmall
                      ?.copyWith(color: context.onPrimary),
                  message: pesan,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FittedBox(
                        child: Text('Info Pembayaran\t',
                            maxLines: 1,
                            style: context.text.bodySmall?.copyWith(
                                color: context.onBackground, fontSize: 10)),
                      ),
                      Icon(Icons.info_outline_rounded,
                          size: (context.isMobile) ? 12 : 20)
                    ],
                  ),
                ),
                Text(
                  currentBayar == -1 || currentBayar == 0
                      ? "-"
                      : DataFormatter.formatIDR(currentBayar),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall
                      ?.copyWith(color: context.onBackground, fontSize: 12),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailPembayaran(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        minHeight: 10,
        maxHeight: context.dh * 0.86,
        maxWidth: min(650, context.dw),
      ),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          right: min(22, context.dp(18)),
          left: min(22, context.dp(18)),
          top: min(28, context.dp(24)),
        ),
        child: const DetailPembayaran(),
      ),
    );
  }
}
