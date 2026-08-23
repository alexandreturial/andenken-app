import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'core/flavor/flavor.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router = createAppRouter();

  /// Preenchido nas fases 3–4 (T032+). MultiProvider não aceita lista vazia.
  List<SingleChildWidget> get _providers => [];

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp.router(
      title: FlavorConfig.current.displayName,
      locale: AppTheme.locale,
      supportedLocales: AppTheme.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: _router,
      builder: (context, child) {
        final page = child ?? const SizedBox.shrink();
        if (!FlavorConfig.current.showFlavorBanner) {
          return page;
        }
        return Banner(
          message: FlavorConfig.current.bannerLabel,
          location: BannerLocation.topStart,
          child: page,
        );
      },
    );

    if (_providers.isEmpty) {
      return app;
    }
    return MultiProvider(providers: _providers, child: app);
  }
}

