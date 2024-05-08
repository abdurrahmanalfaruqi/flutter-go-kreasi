import 'package:flutter/material.dart';

import 'basic_empty.dart';

class NoDataFoundWidget extends BasicEmpty {
  const NoDataFoundWidget({
    Key? key,
    super.shrink,
    super.imageWidth,
    super.textColor,
    super.isLandscape,
    required super.imageUrl,
    required super.subTitle,
    required super.emptyMessage,
  }) : super(key: key, title: 'Oops!!');
}
