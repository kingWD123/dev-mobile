import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens. Keep the palette small on purpose: one brand color for
/// actions/emphasis, one reserved color for ratings, and a neutral ink/surface
/// scale for everything else. Screens should read colors from here rather
/// than inlining new ones.
class AppColors {
  static const primary = Color(0xFF0E8C6F);
  static const primaryDark = Color(0xFF45BFA0);
  static const rating = Color(0xFFDE9A2A);

  static const textLight = Color(0xFF16191C);
  static const mutedLight = Color(0xFF767C82);
  static const bgLight = Color(0xFFFFFFFF);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const chipLight = Color(0xFFF3F4F5);
  static const borderLight = Color(0xFFE7E8EA);

  static const textDark = Color(0xFFEDEFF1);
  static const mutedDark = Color(0xFF999FA5);
  static const bgDark = Color(0xFF121316);
  static const surfaceDark = Color(0xFF1B1D20);
  static const chipDark = Color(0xFF232629);
  static const borderDark = Color(0xFF2B2E32);

  /// Flat card: hairline border, no drop shadow.
  static BoxDecoration card(BuildContext context, {double radius = 16}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? surfaceDark : surfaceLight,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Theme.of(context).dividerColor),
    );
  }

  /// Neutral filled pill/badge — the default for icon badges and chips.
  static BoxDecoration flatField(BuildContext context, {double radius = 14}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? chipDark : chipLight,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static Color muted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? mutedDark : mutedLight;

  static Color ink(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textDark : textLight;
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        surface: AppColors.surfaceLight,
      ),
      textTheme: textTheme.apply(
        bodyColor: AppColors.textLight,
        displayColor: AppColors.textLight,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textLight,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textLight,
        ),
      ),
      dividerColor: AppColors.borderLight,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        surface: AppColors.surfaceDark,
      ),
      textTheme: textTheme.apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
      dividerColor: AppColors.borderDark,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: const Color(0xFF06231C),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
        ),
      ),
    );
  }
}
