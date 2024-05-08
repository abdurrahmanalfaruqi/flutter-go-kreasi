import 'package:flutter/material.dart';
import 'package:gokreasi_new/core/config/extensions.dart';

class CustomButton extends StatelessWidget {
  final double height;
  final double width;
  final String title;
  final double paddingLeft;
  final Function() onTap;

  const CustomButton({
    super.key,
    required this.height,
    required this.width,
    required this.title,
    this.paddingLeft = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: EdgeInsets.only(left: paddingLeft),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          textStyle: context.text.labelSmall?.copyWith(
            color: context.onPrimaryContainer,
            fontSize: (context.isMobile) ? 10 : 8.5
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(title),
      ),
    );
  }
}
