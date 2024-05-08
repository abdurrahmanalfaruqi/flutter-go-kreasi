import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gokreasi_new/features/auth/data/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:gokreasi_new/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:gokreasi_new/features/home/presentation/bloc/ptn/ptn_bloc.dart';

import '../../../entity/kampus_impian.dart';
import '../../../../../../../core/config/constant.dart';
import '../../../../../../../core/config/extensions.dart';
import '../../../../../../../core/shared/widget/card/custom_card.dart';
import '../../../../../../../core/shared/widget/loading/shimmer_widget.dart';

class ImpianKuliahWidget extends StatefulWidget {
  const ImpianKuliahWidget({Key? key}) : super(key: key);

  @override
  State<ImpianKuliahWidget> createState() => _ImpianKuliahWidgetState();
}

class _ImpianKuliahWidgetState extends State<ImpianKuliahWidget> {
  UserModel? userdata;
  KampusImpian? kampusImpian;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is LoadedUser) {
          userdata = authState.user;
        }

        return BlocBuilder<PtnBloc, PtnState>(builder: (context, state) {
          if (state is PtnLoading) {
            return _buildLoadingWidget(context);
          }

          if (state is PtnDataLoaded && userdata.isLogin) {
            kampusImpian = (state.listKampusPilihan.isNotEmpty)
                ? state.listKampusPilihan.first
                : null;
          }

          return CustomCard(
            onTap: () => _onImpianClicked(context, userdata),
            padding: EdgeInsets.symmetric(
              vertical: (context.isMobile) ? context.dp(10) : context.dp(5),
              horizontal: (context.isMobile) ? context.dp(12) : context.dp(6),
            ),
            child: _buildKampusImpianDisplay(context, kampusImpian),
          );
        });
      },
    );
  }

  /// NOTE: Tempat menyimpan seluruh private function---------------------------
  void _onImpianClicked(BuildContext context, UserModel? userData) {
    if (userData.isLogin &&
        !userData.isTamu &&
        (userData?.isBolehPTN == true)) {
      Navigator.pushNamed(
        context,
        Constant.kRouteImpian,
      );
    } else {
      Navigator.pushNamed(
        context,
        Constant.kRouteStoryBoardScreen,
        arguments: Constant.kStoryBoard['Impian'],
      );
    }
  }

  Row _buildKampusImpianDisplay(
      BuildContext context, KampusImpian? kampusImpian) {
    return Row(
      children: [
        Image.asset(
          'assets/icon/ic_ptn.webp',
          width: (context.isMobile) ? context.dp(32) : context.dp(22),
          fit: BoxFit.fitWidth,
        ),
        SizedBox(width: context.dp(8)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (kampusImpian == null)
                    ? 'Atur target kamu yuk sobat!'
                    : 'Impian Kuliah Kamu',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    context.text.bodySmall?.copyWith(color: context.hintColor),
              ),
              (kampusImpian == null)
                  ? Text('Impian Kamu Kuliah Dimana?',
                      semanticsLabel: 'Impian Kamu Kuliah Dimana?',
                      style: context.text.titleSmall)
                  : Hero(
                      tag: 'impian-nama-ptn',
                      transitionOnUserGestures: true,
                      child: Text(
                          '${kampusImpian.aliasPTN} - ${kampusImpian.namaJurusan}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.titleSmall)),
              if (kampusImpian != null)
                Hero(
                  tag: 'impian-peminat-tampung',
                  transitionOnUserGestures: true,
                  child: Text(
                    '${kampusImpian.peminat} | ${kampusImpian.tampung}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall
                        ?.copyWith(color: context.hintColor),
                  ),
                ),
            ],
          ),
        ),
        Icon(Icons.chevron_right,
            color: context.primaryColor, semanticLabel: 'Chevron Right Icon')
      ],
    );
  }

  CustomCard _buildLoadingWidget(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.symmetric(
        vertical: (context.isMobile) ? context.dp(10) : context.dp(5),
        horizontal: (context.isMobile) ? context.dp(12) : context.dp(6),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/icon/ic_ptn.webp',
            width: context.dp(32),
            fit: BoxFit.fitWidth,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget.rounded(
                    width: context.dp(160),
                    height: context.dp(14),
                    borderRadius: BorderRadius.circular(46)),
                const SizedBox(height: 4),
                ShimmerWidget.rounded(
                    width: double.infinity,
                    height: context.dp(18),
                    borderRadius: BorderRadius.circular(46)),
                const SizedBox(height: 4),
                ShimmerWidget.rounded(
                    width: context.dp(190),
                    height: context.dp(14),
                    borderRadius: BorderRadius.circular(46))
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right,
              color: context.primaryColor, semanticLabel: 'Chevron Right Icon')
        ],
      ),
    );
  }
}
