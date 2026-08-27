import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppPageTemplate extends StatelessWidget {
  const AppPageTemplate({
    super.key,
    this.title,
    this.leading,
    required this.body,
    this.floatingActionButton,
    this.actions,
  });

  final String? title;
  final Widget? leading;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null && leading == null && actions == null
          ? null
          : AppBar(
              title: title == null ? null : Text(title!),
              leading: leading,
              actions: actions,
            ),
      floatingActionButton: floatingActionButton,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.containerMargin,
        ),
        child: body,
      ),
    );
  }
}
