import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gokreasi_new/core/config/enum.dart';
import 'package:gokreasi_new/core/config/extensions.dart';
import 'package:gokreasi_new/core/config/global.dart';
import 'package:gokreasi_new/core/shared/widget/image/custom_image_network.dart';
import 'package:gokreasi_new/features/home/domain/entity/promotion.dart';
import 'package:gokreasi_new/features/home/presentation/bloc/home/home_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class PromotionWidget extends StatefulWidget {
  const PromotionWidget({super.key});

  @override
  State<PromotionWidget> createState() => _PromotionWidgetState();
}

class _PromotionWidgetState extends State<PromotionWidget> {
  Promotion? promotionData;

  String get _baseUrlPromotion {
    return '${dotenv.env['BASE_URL_IMAGE']!}/media';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is LoadedPromotion) {
          promotionData = state.promotionData;
          return Center(
            child: GestureDetector(
              onTap: () => _launchUrl(state.promotionData.linkPendaftaran),
              child: CustomImageNetwork(
                _baseUrlPromotion + state.promotionData.linkImage,
                width: (context.isMobile) ? context.dw * 0.8 : context.dw * 0.5,
                height:
                    (context.isMobile) ? context.dh * 0.4 : context.dh * 0.7,
              ),
            ),
          );
        }

        if (promotionData == null &&
            (state is LoadedPromotion || state is HomeError)) {
          Navigator.of(context).pop();
        }

        return const SizedBox.shrink();
      },
    );
  }

  Future<void> _launchUrl(String linkPendaftaran) async {
    Navigator.of(context).pop();

    final Uri url = Uri.parse(linkPendaftaran);
    if (!await launchUrl(url)) {
      if (!context.mounted) return;

      gShowTopFlash(
        context,
        'Could not launch $url',
        dialogType: DialogType.error,
      );
    }
  }
}
