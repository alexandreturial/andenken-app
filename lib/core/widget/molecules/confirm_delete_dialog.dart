import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../atoms/app_text.dart';

/// Dialog de confirmação de exclusão (spec §9). Sem frame Stitch na v1.
Future<bool> showConfirmDeleteDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Apagar',
  String cancelLabel = 'Cancelar',
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: AppText(title, variant: AppTextVariant.headlineMd),
        content: AppText(
          message,
          variant: AppTextVariant.bodyMd,
          color: AppColors.onSurfaceVariant,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.hardRed,
              foregroundColor: AppColors.onPrimary,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}
