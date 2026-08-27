import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'app_text.dart';

enum AppButtonVariant { primary, outlined, destructive }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.trailingIcon,
    this.leading,
    this.isLoading = false,
    this.uppercase = false,
    this.prominent = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? trailingIcon;
  final Widget? leading;
  final bool isLoading;
  final bool uppercase;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final Color labelColor;
    switch (variant) {
      case AppButtonVariant.primary:
        labelColor = AppColors.onSecondaryContainer;
        break;
      case AppButtonVariant.outlined:
        labelColor = AppColors.onSurface;
        break;
      case AppButtonVariant.destructive:
        labelColor = AppColors.onPrimary;
        break;
    }

    final labelStyle = uppercase
        ? AppTypography.labelSm.copyWith(color: labelColor, letterSpacing: 1.2)
        : null;

    final Widget labelChild;
    if (uppercase) {
      labelChild = Text(label, style: labelStyle);
    } else if (prominent) {
      labelChild = Text(
        label,
        style: AppTypography.headlineMd.copyWith(color: labelColor),
      );
    } else {
      labelChild = AppText(
        label,
        variant: AppTextVariant.bodyMd,
        color: labelColor,
      );
    }

    final Widget child;
    if (isLoading) {
      child = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: labelColor),
      );
    } else if (trailingIcon != null || leading != null) {
      child = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Flexible(child: labelChild),
          if (trailingIcon != null) ...[
            const SizedBox(width: 8),
            Icon(trailingIcon, size: 18, color: labelColor),
          ],
        ],
      );
    } else {
      child = labelChild;
    }

    final pressed = isLoading ? null : onPressed;

    final Widget button;
    switch (variant) {
      case AppButtonVariant.primary:
        button = FilledButton(
          onPressed: pressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.secondaryContainer,
            foregroundColor: AppColors.onSecondaryContainer,
          ),
          child: child,
        );
      case AppButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: pressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.surfaceContainerHigh,
            foregroundColor: AppColors.onSurface,
            side: const BorderSide(color: AppColors.surfaceContainerHighest),
          ),
          child: child,
        );
      case AppButtonVariant.destructive:
        button = FilledButton(
          onPressed: pressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.hardRed,
            foregroundColor: AppColors.onPrimary,
          ),
          child: child,
        );
    }

    return SizedBox(width: double.infinity, child: button);
  }
}
