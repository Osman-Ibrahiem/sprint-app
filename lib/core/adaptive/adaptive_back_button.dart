import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/adaptive/platform.dart';
import 'package:sprint/core/l10n/directional_icon.dart';

/// A back button for custom app bar leading slots. It points to the start of
/// the line (so it mirrors in RTL) and uses the chevron on Apple platforms and
/// the arrow elsewhere, like the adaptive app bar's own back (FR-019).
class AdaptiveBackButton extends StatelessWidget {
  const AdaptiveBackButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final apple = adaptiveStyleOf(context) == AdaptiveStyle.apple;
    return IconButton(
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      icon: DirectionalIcon(
        apple ? PhosphorIconsRegular.caretLeft : PhosphorIconsRegular.arrowLeft,
      ),
      onPressed: onPressed,
    );
  }
}
