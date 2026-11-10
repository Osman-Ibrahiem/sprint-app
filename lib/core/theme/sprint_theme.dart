import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_text.g.dart';

/// Builds light and dark [ThemeData] from the colour tokens (FR-009, FR-011).
///
/// `pageTransitionsTheme` is deliberately not set: page, sheet and back
/// gesture timing stay the platform's (FR-018). `volt` appears only as a fill
/// with `on-volt` text (FR-012).
abstract final class SprintTheme {
  static ThemeData get light => _build(SprintColors.light, Brightness.light);
  static ThemeData get dark => _build(SprintColors.dark, Brightness.dark);

  static ThemeData _build(SprintColors c, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      primaryContainer: c.primarySoft,
      onPrimaryContainer: c.onPrimarySoft,
      secondary: c.volt,
      onSecondary: c.onVolt,
      error: c.danger,
      onError: c.onDanger,
      errorContainer: c.dangerSoft,
      onErrorContainer: c.danger,
      surface: c.surface,
      onSurface: c.ink,
      onSurfaceVariant: c.inkMuted,
      surfaceContainerLowest: c.bg,
      surfaceContainerLow: c.surface,
      surfaceContainer: c.surface,
      surfaceContainerHigh: c.surfaceRaised,
      surfaceContainerHighest: c.surfaceSunken,
      outline: c.controlBorder,
      outlineVariant: c.line,
      shadow: Colors.transparent,
      scrim: c.scrim,
      surfaceTint: Colors.transparent,
    );

    final text = _textTheme(c.ink);
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      extensions: <ThemeExtension<dynamic>>[c],
      scaffoldBackgroundColor: c.bg,
      canvasColor: c.bg,
      textTheme: text,
      primaryTextTheme: text,
      fontFamily: SprintText.body.fontFamily,
      dividerColor: c.line,
      focusColor: c.focusRing,
      // Dark lifts surfaces instead of using shadows (FR-011).
      shadowColor: isDark ? Colors.transparent : null,
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: SprintRadius.lgBorder),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape:
            const RoundedRectangleBorder(borderRadius: SprintRadius.xlBorder),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: c.scrim,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: SprintRadius.xlRadius),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.ink,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        titleTextStyle: SprintText.title.copyWith(color: c.ink),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.onPrimary : c.controlBorder,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) =>
              s.contains(WidgetState.selected) ? c.primary : c.surfaceSunken,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.primary),
      iconTheme: IconThemeData(color: c.ink, size: SprintSize.iconLg),
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      cupertinoOverrideTheme: NoDefaultCupertinoThemeData(
        brightness: brightness,
        primaryColor: c.primary,
        primaryContrastingColor: c.onPrimary,
        scaffoldBackgroundColor: c.bg,
        barBackgroundColor: c.surface,
        textTheme: CupertinoTextThemeData(
          primaryColor: c.primary,
          textStyle: SprintText.body.copyWith(color: c.ink),
          navTitleTextStyle: SprintText.headline.copyWith(color: c.ink),
          navLargeTitleTextStyle: SprintText.titleLg.copyWith(color: c.ink),
          actionTextStyle: SprintText.button.copyWith(color: c.primary),
        ),
      ),
    );
  }

  static TextTheme _textTheme(Color ink) {
    TextStyle s(TextStyle t) => t.copyWith(color: ink);
    return TextTheme(
      displayLarge: s(SprintText.display),
      displayMedium: s(SprintText.display),
      displaySmall: s(SprintText.titleLg),
      headlineLarge: s(SprintText.titleLg),
      headlineMedium: s(SprintText.title),
      headlineSmall: s(SprintText.headline),
      titleLarge: s(SprintText.title),
      titleMedium: s(SprintText.headline),
      titleSmall: s(SprintText.bodyStrong),
      bodyLarge: s(SprintText.body),
      bodyMedium: s(SprintText.body),
      bodySmall: s(SprintText.caption),
      labelLarge: s(SprintText.button),
      labelMedium: s(SprintText.label),
      labelSmall: s(SprintText.micro),
    );
  }
}
