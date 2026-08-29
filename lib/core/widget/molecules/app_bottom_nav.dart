import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../atoms/app_text.dart';

enum AppBottomNavTab { decks, study, create }

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.active,
    required this.onDecks,
    required this.onStudy,
    required this.onCreate,
  });

  final AppBottomNavTab active;
  final VoidCallback onDecks;
  final VoidCallback onStudy;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLow,
      elevation: 8,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.gutter,
            vertical: AppSpacing.base,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Item(
                label: 'Decks',
                icon: Icons.style,
                selected: active == AppBottomNavTab.decks,
                onTap: onDecks,
              ),
              _Item(
                label: 'Study',
                icon: Icons.psychology,
                selected: active == AppBottomNavTab.study,
                onTap: onStudy,
              ),
              _Item(
                label: 'Create',
                icon: Icons.add_circle,
                selected: active == AppBottomNavTab.create,
                onTap: onCreate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.secondaryContainer
        : AppColors.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: selected
            ? BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.md),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            AppText(label, variant: AppTextVariant.labelSm, color: color),
          ],
        ),
      ),
    );
  }
}
