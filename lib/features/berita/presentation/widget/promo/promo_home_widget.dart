import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../../core/config/extensions.dart';
import '../../../../../core/shared/widget/image/custom_image_network.dart';

class PromoHomeWidget extends StatelessWidget {
  const PromoHomeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String promoImageUrl = dotenv.env['URL_PROMO_IMAGE']!;
    return AspectRatio(
      aspectRatio: 342 / 176,
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(
            (context.isMobile) ? max(12, context.dp(18)) : context.dp(12)),
        child: CustomImageNetwork(
          promoImageUrl,
          width: double.infinity,
          borderRadius: BorderRadius.circular(
              (context.isMobile) ? max(12, context.dp(18)) : context.dp(12)),
        ),
      ),
    );
  }
}
