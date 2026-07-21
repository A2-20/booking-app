import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/app_config.dart';

class CurrencyIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const CurrencyIcon({super.key, this.size = 16, this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppConfig.currencySvgPath,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}
