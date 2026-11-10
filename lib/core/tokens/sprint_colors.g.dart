// GENERATED CODE - DO NOT EDIT.
// Source: docs/design-system/tokens.json (run `dart run tool/gen_tokens.dart`).
// dart format off
import 'package:flutter/material.dart';

@immutable
class SprintColors extends ThemeExtension<SprintColors> {
  const SprintColors({
    required this.bg,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.line,
    required this.controlBorder,
    required this.ink,
    required this.inkMuted,
    required this.inkDisabled,
    required this.primary,
    required this.primaryHover,
    required this.primaryPressed,
    required this.onPrimary,
    required this.primarySoft,
    required this.onPrimarySoft,
    required this.volt,
    required this.onVolt,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.danger,
    required this.dangerSoft,
    required this.onDanger,
    required this.focusRing,
    required this.scrim,
    required this.qrInk,
    required this.qrGround,
    required this.shadowCard,
    required this.shadowSheet,
    required this.shadowPopover,
  });

  final Color bg;
  final Color surface;
  final Color surfaceRaised;
  final Color surfaceSunken;
  final Color line;
  final Color controlBorder;
  final Color ink;
  final Color inkMuted;
  final Color inkDisabled;
  final Color primary;
  final Color primaryHover;
  final Color primaryPressed;
  final Color onPrimary;
  final Color primarySoft;
  final Color onPrimarySoft;
  final Color volt;
  final Color onVolt;
  final Color success;
  final Color successSoft;
  final Color warning;
  final Color warningSoft;
  final Color danger;
  final Color dangerSoft;
  final Color onDanger;
  final Color focusRing;
  final Color scrim;
  final Color qrInk;
  final Color qrGround;
  final List<BoxShadow> shadowCard;
  final List<BoxShadow> shadowSheet;
  final List<BoxShadow> shadowPopover;

  static const SprintColors light = SprintColors(
    bg: Color(0xFFF6F7FB),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFEEF0F6),
    line: Color(0xFFE2E5EE),
    controlBorder: Color(0xFF8A93A8),
    ink: Color(0xFF0F1729),
    inkMuted: Color(0xFF5B6478),
    inkDisabled: Color(0xFFA6ADBD),
    primary: Color(0xFF2445E0),
    primaryHover: Color(0xFF1C38C2),
    primaryPressed: Color(0xFF172E9E),
    onPrimary: Color(0xFFFFFFFF),
    primarySoft: Color(0xFFE8ECFD),
    onPrimarySoft: Color(0xFF1A33A8),
    volt: Color(0xFFD4F536),
    onVolt: Color(0xFF1A2005),
    success: Color(0xFF15803D),
    successSoft: Color(0xFFE7F6EC),
    warning: Color(0xFFA15C07),
    warningSoft: Color(0xFFFDF3E1),
    danger: Color(0xFFB91C1C),
    dangerSoft: Color(0xFFFDECEC),
    onDanger: Color(0xFFFFFFFF),
    focusRing: Color(0xFF2445E0),
    scrim: Color(0x7A0B0F1A),
    qrInk: Color(0xFF0F1729),
    qrGround: Color(0xFFFFFFFF),
    shadowCard: <BoxShadow>[
    BoxShadow(offset: Offset(0.0, 1.0), blurRadius: 2.0, color: Color(0x0F0F1729)),
    BoxShadow(offset: Offset(0.0, 4.0), blurRadius: 12.0, color: Color(0x0F0F1729)),
  ],
    shadowSheet: <BoxShadow>[
    BoxShadow(offset: Offset(0.0, -8.0), blurRadius: 24.0, color: Color(0x1F0F1729)),
  ],
    shadowPopover: <BoxShadow>[
    BoxShadow(offset: Offset(0.0, 8.0), blurRadius: 24.0, color: Color(0x240F1729)),
  ],
  );

  static const SprintColors dark = SprintColors(
    bg: Color(0xFF0B0F1A),
    surface: Color(0xFF151B2B),
    surfaceRaised: Color(0xFF1C2336),
    surfaceSunken: Color(0xFF080B14),
    line: Color(0xFF262E42),
    controlBorder: Color(0xFF5F6B88),
    ink: Color(0xFFEEF1F8),
    inkMuted: Color(0xFF9AA3B8),
    inkDisabled: Color(0xFF4A5368),
    primary: Color(0xFF8EA2FF),
    primaryHover: Color(0xFFA6B6FF),
    primaryPressed: Color(0xFFBCC8FF),
    onPrimary: Color(0xFF0B1233),
    primarySoft: Color(0xFF1B2552),
    onPrimarySoft: Color(0xFFC9D3FF),
    volt: Color(0xFFD4F536),
    onVolt: Color(0xFF1A2005),
    success: Color(0xFF4ADE80),
    successSoft: Color(0xFF0F2A1B),
    warning: Color(0xFFFBBF24),
    warningSoft: Color(0xFF2E2108),
    danger: Color(0xFFF87171),
    dangerSoft: Color(0xFF2F1214),
    onDanger: Color(0xFF2A0606),
    focusRing: Color(0xFFD4F536),
    scrim: Color(0xA3000000),
    qrInk: Color(0xFF0F1729),
    qrGround: Color(0xFFFFFFFF),
    shadowCard: <BoxShadow>[],
    shadowSheet: <BoxShadow>[
    BoxShadow(offset: Offset(0.0, -8.0), blurRadius: 24.0, color: Color(0x80000000)),
  ],
    shadowPopover: <BoxShadow>[
    BoxShadow(offset: Offset(0.0, 8.0), blurRadius: 24.0, color: Color(0x99000000)),
  ],
  );

  @override
  SprintColors copyWith({
    Color? bg,
    Color? surface,
    Color? surfaceRaised,
    Color? surfaceSunken,
    Color? line,
    Color? controlBorder,
    Color? ink,
    Color? inkMuted,
    Color? inkDisabled,
    Color? primary,
    Color? primaryHover,
    Color? primaryPressed,
    Color? onPrimary,
    Color? primarySoft,
    Color? onPrimarySoft,
    Color? volt,
    Color? onVolt,
    Color? success,
    Color? successSoft,
    Color? warning,
    Color? warningSoft,
    Color? danger,
    Color? dangerSoft,
    Color? onDanger,
    Color? focusRing,
    Color? scrim,
    Color? qrInk,
    Color? qrGround,
    List<BoxShadow>? shadowCard,
    List<BoxShadow>? shadowSheet,
    List<BoxShadow>? shadowPopover,
  }) {
    return SprintColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      line: line ?? this.line,
      controlBorder: controlBorder ?? this.controlBorder,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      inkDisabled: inkDisabled ?? this.inkDisabled,
      primary: primary ?? this.primary,
      primaryHover: primaryHover ?? this.primaryHover,
      primaryPressed: primaryPressed ?? this.primaryPressed,
      onPrimary: onPrimary ?? this.onPrimary,
      primarySoft: primarySoft ?? this.primarySoft,
      onPrimarySoft: onPrimarySoft ?? this.onPrimarySoft,
      volt: volt ?? this.volt,
      onVolt: onVolt ?? this.onVolt,
      success: success ?? this.success,
      successSoft: successSoft ?? this.successSoft,
      warning: warning ?? this.warning,
      warningSoft: warningSoft ?? this.warningSoft,
      danger: danger ?? this.danger,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      onDanger: onDanger ?? this.onDanger,
      focusRing: focusRing ?? this.focusRing,
      scrim: scrim ?? this.scrim,
      qrInk: qrInk ?? this.qrInk,
      qrGround: qrGround ?? this.qrGround,
      shadowCard: shadowCard ?? this.shadowCard,
      shadowSheet: shadowSheet ?? this.shadowSheet,
      shadowPopover: shadowPopover ?? this.shadowPopover,
    );
  }

  @override
  SprintColors lerp(ThemeExtension<SprintColors>? other, double t) {
    if (other is! SprintColors) return this;
    return SprintColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceSunken: Color.lerp(surfaceSunken, other.surfaceSunken, t)!,
      line: Color.lerp(line, other.line, t)!,
      controlBorder: Color.lerp(controlBorder, other.controlBorder, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      inkDisabled: Color.lerp(inkDisabled, other.inkDisabled, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryHover: Color.lerp(primaryHover, other.primaryHover, t)!,
      primaryPressed: Color.lerp(primaryPressed, other.primaryPressed, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      onPrimarySoft: Color.lerp(onPrimarySoft, other.onPrimarySoft, t)!,
      volt: Color.lerp(volt, other.volt, t)!,
      onVolt: Color.lerp(onVolt, other.onVolt, t)!,
      success: Color.lerp(success, other.success, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      onDanger: Color.lerp(onDanger, other.onDanger, t)!,
      focusRing: Color.lerp(focusRing, other.focusRing, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      qrInk: Color.lerp(qrInk, other.qrInk, t)!,
      qrGround: Color.lerp(qrGround, other.qrGround, t)!,
      shadowCard: BoxShadow.lerpList(shadowCard, other.shadowCard, t)!,
      shadowSheet: BoxShadow.lerpList(shadowSheet, other.shadowSheet, t)!,
      shadowPopover: BoxShadow.lerpList(shadowPopover, other.shadowPopover, t)!,
    );
  }
}
