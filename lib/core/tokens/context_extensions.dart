import 'package:flutter/material.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/tokens/sprint_text.g.dart';

extension SprintContext on BuildContext {
  /// Colour tokens for the current theme.
  SprintColors get colors => Theme.of(this).extension<SprintColors>()!;

  /// Type tokens, already coloured with `ink`.
  SprintTextStyles get text => SprintTextStyles(colors.ink);
}

/// [SprintText] styles bound to a colour (default `ink`).
class SprintTextStyles {
  const SprintTextStyles(this._color);
  final Color _color;

  TextStyle _c(TextStyle s) => s.copyWith(color: _color);

  TextStyle get display => _c(SprintText.display);
  TextStyle get titleLg => _c(SprintText.titleLg);
  TextStyle get title => _c(SprintText.title);
  TextStyle get headline => _c(SprintText.headline);
  TextStyle get button => _c(SprintText.button);
  TextStyle get numberLg => _c(SprintText.numberLg);
  TextStyle get number => _c(SprintText.number);
  TextStyle get body => _c(SprintText.body);
  TextStyle get bodyStrong => _c(SprintText.bodyStrong);
  TextStyle get label => _c(SprintText.label);
  TextStyle get caption => _c(SprintText.caption);
  TextStyle get micro => _c(SprintText.micro);
  TextStyle get code => _c(SprintText.code);
}
