import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../../domain/usecases/sign_out.dart';

class AndenkenAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AndenkenAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerMargin,
          ),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
          ),
          child: Row(
            children: [
              PopupMenuButton<String>(
                tooltip: 'Menu',
                icon: const Icon(Icons.menu, color: AppColors.primary),
                onSelected: (value) async {
                  if (value == 'logout') {
                    await context.read<SignOut>()();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(value: 'logout', child: Text('Logout')),
                ],
              ),
              const SizedBox(width: AppSpacing.gutter),
              Text(
                'ANDENKEN',
                style: AppTypography.headlineMd.copyWith(
                  color: AppColors.secondaryContainer,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.surfaceContainerHighest,
                child: Icon(Icons.person, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
