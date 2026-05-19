import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color navy = Color(0xFF1A2755);
  static const Color navyDeep = Color(0xFF0E1838);
  static const Color orange = Color(0xFFEE9A2E);
  static const Color orangeWarm = Color(0xFFD97706);
  static const Color silver = Color(0xFF98A0B3);
  static const Color slate = Color(0xFF4A536B);
  static const Color surfaceLight = Color(0xFFF7F6FB);
  static const Color surfaceDark = Color(0xFF12172A);

  static const Color signalPrimary = navy;
  static const Color signalSecondary = orange;
  static const Color signalTertiary = orangeWarm;
  static const Color signalNeutral = silver;
}

enum MetricKind {
  thermalInfluence,
  buttonPressed,
  buttonIdle,
  polarity,
  ambientActive,
  ambientPaused,
  directedSlope,
  directedAccel,
  lunarAccel,
  pitch,
  volume,
  thermalContact,
}

Color metricColor(BuildContext context, MetricKind kind) {
  final cs = Theme.of(context).colorScheme;
  switch (kind) {
    case MetricKind.thermalInfluence:
      return AppColors.navy;
    case MetricKind.buttonPressed:
      return AppColors.orange;
    case MetricKind.buttonIdle:
      return AppColors.silver;
    case MetricKind.polarity:
      return AppColors.slate;
    case MetricKind.ambientActive:
      return AppColors.navy;
    case MetricKind.ambientPaused:
      return AppColors.silver;
    case MetricKind.directedSlope:
      return cs.tertiary;
    case MetricKind.directedAccel:
      return AppColors.orangeWarm;
    case MetricKind.lunarAccel:
      return cs.tertiary;
    case MetricKind.pitch:
      return AppColors.navyDeep;
    case MetricKind.volume:
      return AppColors.orange;
    case MetricKind.thermalContact:
      return AppColors.slate;
  }
}

ThemeData buildLightTheme() {
  final base = ColorScheme.fromSeed(
    seedColor: AppColors.navy,
    brightness: Brightness.light,
  );
  final scheme = base.copyWith(
    primary: AppColors.navy,
    onPrimary: Colors.white,
    secondary: AppColors.orange,
    onSecondary: Colors.white,
    tertiary: AppColors.orangeWarm,
    onTertiary: Colors.white,
    surface: AppColors.surfaceLight,
    onSurface: AppColors.navyDeep,
    onSurfaceVariant: AppColors.slate,
    outlineVariant: AppColors.silver.withValues(alpha: 0.45),
  );

  return _buildThemeFromScheme(scheme);
}

ThemeData buildDarkTheme() {
  final base = ColorScheme.fromSeed(
    seedColor: AppColors.navy,
    brightness: Brightness.dark,
  );
  final scheme = base.copyWith(
    primary: AppColors.orange,
    onPrimary: AppColors.navyDeep,
    secondary: AppColors.orange,
    onSecondary: AppColors.navyDeep,
    tertiary: AppColors.silver,
    onTertiary: AppColors.navyDeep,
    surface: AppColors.surfaceDark,
    onSurface: const Color(0xFFE6E8F0),
    onSurfaceVariant: AppColors.silver,
    outlineVariant: AppColors.slate.withValues(alpha: 0.6),
  );

  return _buildThemeFromScheme(scheme);
}

ThemeData _buildThemeFromScheme(ColorScheme scheme) {
  final isDark = scheme.brightness == Brightness.dark;
  final appBarBg = isDark ? AppColors.navyDeep : AppColors.navy;
  final appBarFg = Colors.white;

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: appBarBg,
      foregroundColor: appBarFg,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: isDark
          ? AppColors.navyDeep.withValues(alpha: 0.85)
          : Colors.white,
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        side: BorderSide(color: scheme.primary.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 0.7,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: scheme.primary, width: 1.6),
      ),
      isDense: true,
    ),
  );
}
