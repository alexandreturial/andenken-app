import 'package:flutter/material.dart';

import '../atoms/app_text.dart';
import '../templates/app_page_template.dart';

/// Placeholder until the real screen exists. Not a Stitch frame.
class RouteStubScreen extends StatelessWidget {
  const RouteStubScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppPageTemplate(
      title: title,
      body: Center(child: AppText(title, variant: AppTextVariant.headlineMd)),
    );
  }
}
