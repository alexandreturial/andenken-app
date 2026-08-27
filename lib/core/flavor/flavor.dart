enum AppFlavor { develop, homolog, prod }

/// Ambiente da build. Na v1 os três flavors usam o mesmo Firebase (plan §1.3).
class FlavorConfig {
  FlavorConfig._(this.flavor);

  final AppFlavor flavor;

  static FlavorConfig? _instance;

  static FlavorConfig get current =>
      _instance ?? FlavorConfig._(AppFlavor.develop);

  static void ensureInitialized() {
    const raw = String.fromEnvironment('FLAVOR', defaultValue: 'develop');
    _instance = FlavorConfig._(AppFlavor.values.byName(raw));
  }

  bool get isProd => flavor == AppFlavor.prod;

  bool get showFlavorBanner => !isProd;

  String get bannerLabel => switch (flavor) {
    AppFlavor.develop => 'DEV',
    AppFlavor.homolog => 'HML',
    AppFlavor.prod => '',
  };

  String get displayName => switch (flavor) {
    AppFlavor.develop => 'Andenken Dev',
    AppFlavor.homolog => 'Andenken Homolog',
    AppFlavor.prod => 'Andenken',
  };
}
