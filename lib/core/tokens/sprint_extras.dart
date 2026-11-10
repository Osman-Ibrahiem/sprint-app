/// Constants that the design docs state in prose but that `tokens.json` does
/// not carry. They are NOT tokens: if one is promoted to a token, move it to
/// `tokens.json` and the generator instead.
abstract final class SprintExtras {
  /// Focus ring: 2px solid line, 2px away from the element
  /// (README § الوصولية).
  static const double focusRingWidth = 2;
  static const double focusRingOffset = 2;

  /// iOS press feedback: the fill fades to 70% (adaptive.md).
  static const double applePressedOpacity = 0.7;

  /// Apple tab bar: translucent with a blur over the content (adaptive.md).
  /// The strength is a design judgement, not a documented value.
  static const double tabBarBlurSigma = 24;
  static const double tabBarTranslucentAlpha = 0.85;

  /// Above this text scale, narrow navigation drops visible labels and keeps
  /// the icon plus its spoken label, so nothing is clipped at 200% (FR-017).
  static const double navLabelMaxTextScale = 1.3;
}
