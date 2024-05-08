import 'package:flutter/material.dart';

import 'basic_empty.dart';

class UnderConstructionWidget extends BasicEmpty {
  final String namaFitur;

  const UnderConstructionWidget({
    Key? key,
    super.imageWidth,
    super.shrink,
    super.textColor,
    required this.namaFitur,
    required super.imageUrl,
  }) : super(
          key: key,
          title: 'Under Construction',
          subTitle: 'Fitur "$namaFitur" sedang dalam pengembangan',
          emptyMessage:
              'Hi Sobat! Mohon maaf atas ketidaknyamanannya karena fitur "$namaFitur" sedang dalam pengembangan oleh tim kami.',
        );
}
