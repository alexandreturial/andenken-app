import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tokens do Stitch *Andenken Flashcards* (`docs/stitch/DESIGN.md`).
/// Dark-mode-first. Não misturar export Flutter do Stitch em `lib/`.
abstract class AppTheme {
  static const Locale locale = Locale('pt', 'BR');
  static const List<Locale> supportedLocales = [locale];

  /// Gutter / espaçamento padrão (16px).
  static const double space = AppSpacing.gutter;

  /// Radius padrão de botão e input (8px).
  static const double radius = AppRadius.button;

  static ThemeData get dark {
    const colors = AppColors.scheme;
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.button),
    );
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.card),
      side: const BorderSide(color: AppColors.outlineVariant),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colors,
      scaffoldBackgroundColor: AppColors.background,
      visualDensity: VisualDensity.standard,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColors.onSurface,
        displayColor: AppColors.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.headlineMd.copyWith(
          color: AppColors.onSurface,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.gutter,
          vertical: AppSpacing.stackSm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.gold, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.hardRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.hardRed),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.onSecondary,
          shape: buttonShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          foregroundColor: AppColors.onSurface,
          side: const BorderSide(color: AppColors.outline),
          shape: buttonShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLow,
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: cardShape,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainer,
        labelStyle: AppTypography.labelSm.copyWith(color: AppColors.gold),
        side: BorderSide.none,
        shape: const StadiumBorder(),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.gold,
        linearTrackColor: AppColors.surfaceContainerHighest,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.onSecondary,
        shape: buttonShape,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
    );
  }
}

/// Cores nomeadas do DESIGN.md + acentos de marca (vermelho / ouro).
abstract class AppColors {
  static const Color surface = Color(0xFF131313);
  static const Color surfaceDim = Color(0xFF131313);
  static const Color surfaceBright = Color(0xFF393939);
  static const Color surfaceContainerLowest = Color(0xFF0E0E0E);
  static const Color surfaceContainerLow = Color(0xFF1B1B1B);
  static const Color surfaceContainer = Color(0xFF1F1F1F);
  static const Color surfaceContainerHigh = Color(0xFF2A2A2A);
  static const Color surfaceContainerHighest = Color(0xFF353535);
  static const Color onSurface = Color(0xFFE2E2E2);
  static const Color onSurfaceVariant = Color(0xFFEBBBB4);
  static const Color inverseSurface = Color(0xFFE2E2E2);
  static const Color inverseOnSurface = Color(0xFF303030);
  static const Color outline = Color(0xFFB18780);
  static const Color outlineVariant = Color(0xFF603E39);
  static const Color surfaceTint = Color(0xFFFFB4A8);
  static const Color primary = Color(0xFFFFB4A8);
  static const Color onPrimary = Color(0xFF690100);
  static const Color primaryContainer = Color(0xFFFF5540);
  static const Color onPrimaryContainer = Color(0xFF5C0000);
  static const Color inversePrimary = Color(0xFFC00100);
  static const Color secondary = Color(0xFFFFECC0);
  static const Color onSecondary = Color(0xFF3D2F00);
  static const Color secondaryContainer = Color(0xFFFECB00);
  static const Color onSecondaryContainer = Color(0xFF6E5700);
  static const Color tertiary = Color(0xFFC8C6C5);
  static const Color onTertiary = Color(0xFF313030);
  static const Color tertiaryContainer = Color(0xFF929090);
  static const Color onTertiaryContainer = Color(0xFF2A2A2A);
  static const Color error = Color(0xFFFFB4AB);
  static const Color onError = Color(0xFF690005);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onErrorContainer = Color(0xFFFFDAD6);
  static const Color background = Color(0xFF131313);
  static const Color onBackground = Color(0xFFE2E2E2);

  /// Acentos de marca do DESIGN.md (Hard / Easy).
  static const Color hardRed = Color(0xFFFF0000);
  static const Color gold = Color(0xFFFFCC00);
  static const Color cardSurface = Color(0xFF1A1A1A);

  static const ColorScheme scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    secondary: secondary,
    onSecondary: onSecondary,
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: onSecondaryContainer,
    tertiary: tertiary,
    onTertiary: onTertiary,
    tertiaryContainer: tertiaryContainer,
    onTertiaryContainer: onTertiaryContainer,
    error: error,
    onError: onError,
    errorContainer: errorContainer,
    onErrorContainer: onErrorContainer,
    surface: surface,
    onSurface: onSurface,
    onSurfaceVariant: onSurfaceVariant,
    outline: outline,
    outlineVariant: outlineVariant,
    inverseSurface: inverseSurface,
    onInverseSurface: inverseOnSurface,
    inversePrimary: inversePrimary,
    surfaceTint: surfaceTint,
    surfaceContainerLowest: surfaceContainerLowest,
    surfaceContainerLow: surfaceContainerLow,
    surfaceContainerHighest: surfaceContainerHighest,
    surfaceContainerHigh: surfaceContainerHigh,
    surfaceContainer: surfaceContainer,
    surfaceBright: surfaceBright,
    surfaceDim: surfaceDim,
  );
}

abstract class AppRadius {
  static const double sm = 4;
  static const double button = 8;
  static const double md = 12;
  static const double card = 16;
  static const double xl = 24;
  static const double full = 9999;
}

abstract class AppSpacing {
  static const double base = 8;
  static const double stackSm = 12;
  static const double gutter = 16;
  static const double containerMargin = 24;
  static const double stackMd = 24;
  static const double cardPadding = 32;
  static const double stackLg = 48;
}

abstract class AppTypography {
  static TextStyle get headlineLg => GoogleFonts.hankenGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 40 / 32,
        letterSpacing: -0.02 * 32,
      );

  static TextStyle get headlineLgMobile => GoogleFonts.hankenGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 34 / 28,
        letterSpacing: -0.01 * 28,
      );

  static TextStyle get headlineMd => GoogleFonts.hankenGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
      );

  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 28 / 18,
      );

  static TextStyle get bodyMd => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
      );

  static TextStyle get labelSm => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
        letterSpacing: 0.05 * 12,
      );

  static TextTheme get textTheme => TextTheme(
        headlineLarge: headlineLgMobile,
        headlineMedium: headlineMd,
        headlineSmall: headlineMd,
        bodyLarge: bodyLg,
        bodyMedium: bodyMd,
        bodySmall: bodyMd,
        labelSmall: labelSm,
        labelMedium: bodyMd.copyWith(fontWeight: FontWeight.w600),
        labelLarge: bodyMd.copyWith(fontWeight: FontWeight.w600),
        titleLarge: headlineMd,
        titleMedium: bodyLg.copyWith(fontWeight: FontWeight.w600),
        titleSmall: bodyMd.copyWith(fontWeight: FontWeight.w600),
      );
}
