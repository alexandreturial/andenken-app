import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

enum AppTextVariant { headlineLg, headlineMd, bodyLg, bodyMd, labelSm }

class AppText extends StatelessWidget {
  const AppText(
    this.data, {
    super.key,
    this.variant = AppTextVariant.bodyMd,
    this.color,
    this.textAlign,
  });

  final String data;
  final AppTextVariant variant;
  final Color? color;
  final TextAlign? textAlign;

  TextStyle get _style {
    late final TextStyle base;
    switch (variant) {
      case AppTextVariant.headlineLg:
        base = AppTypography.headlineLgMobile;
        break;
      case AppTextVariant.headlineMd:
        base = AppTypography.headlineMd;
        break;
      case AppTextVariant.bodyLg:
        base = AppTypography.bodyLg;
        break;
      case AppTextVariant.bodyMd:
        base = AppTypography.bodyMd;
        break;
      case AppTextVariant.labelSm:
        base = AppTypography.labelSm;
        break;
    }
    return base.copyWith(color: color ?? AppColors.onSurface);
  }

  @override
  Widget build(BuildContext context) {
    return Text(data, style: _style, textAlign: textAlign);
  }
}
