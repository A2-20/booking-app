import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Widget that displays the new official Saudi Riyal symbol inline with a price.
/// Usage: SarPriceText(price: '500')
class SarPriceText extends StatelessWidget {
  final String price;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;

  const SarPriceText({
    super.key,
    required this.price,
    this.fontSize = 14,
    this.fontWeight = FontWeight.bold,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? Theme.of(context).colorScheme.primary;
    final iconSize = fontSize * 1.1;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      textDirection: TextDirection.rtl,
      children: [
        Text(
          price,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: textColor,
          ),
        ),
        const SizedBox(width: 3),
        SvgPicture.asset(
          'assets/images/sar_symbol.svg',
          height: iconSize,
          width: iconSize,
          colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
        ),
      ],
    );
  }
}

/// Standalone SAR symbol icon
class SarSymbol extends StatelessWidget {
  final double size;
  final Color? color;

  const SarSymbol({super.key, this.size = 14, this.color});

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).colorScheme.primary;
    return SvgPicture.asset(
      'assets/images/sar_symbol.svg',
      height: size,
      width: size,
      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
    );
  }
}
