import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/status_badge/sprint_status.dart';
import 'package:sprint/features/verification/domain/verification_state.dart';
import 'package:sprint/features/verification/presentation/verification_texts.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The verification status as a word and an icon in `StatusBadge`'s look
/// (FR-029): never colour alone. The five states reuse the design system's
/// colour pairs: under review (warning), verified (success), rejected
/// (danger), expired and none (muted).
class VerificationStatusBadge extends StatelessWidget {
  const VerificationStatusBadge({required this.state, super.key});

  final VerificationState state;

  static const wordKey = ValueKey<String>('verification-badge-word');
  static const containerKey = ValueKey<String>('verification-badge');

  static IconData iconOf(VerificationState s) => switch (s) {
    VerificationState.none => PhosphorIconsRegular.circleDashed,
    VerificationState.underReview => SprintStatus.underReview.icon,
    VerificationState.approved => SprintStatus.verified.icon,
    VerificationState.rejected => SprintStatus.rejected.icon,
    VerificationState.expired => SprintStatus.expired.icon,
  };

  static (Color, Color) _colors(VerificationState s, SprintColors c) =>
      switch (s) {
        VerificationState.none => (c.inkMuted, c.surfaceSunken),
        VerificationState.underReview => SprintStatus.underReview.colors(c),
        VerificationState.approved => SprintStatus.verified.colors(c),
        VerificationState.rejected => SprintStatus.rejected.colors(c),
        VerificationState.expired => SprintStatus.expired.colors(c),
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (foreground, background) = _colors(state, context.colors);
    final word = verificationStateWord(l10n, state);
    return Semantics(
      liveRegion: true,
      label: l10n.statusSpoken(word),
      child: ExcludeSemantics(
        child: Container(
          key: containerKey,
          constraints: const BoxConstraints(
            minHeight: SprintExtras.statusBadgeHeight,
          ),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: SprintSpacing.space3,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: SprintRadius.fullBorder,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(iconOf(state), size: SprintSize.iconSm, color: foreground),
              const SizedBox(width: SprintSpacing.space1),
              Flexible(
                child: Text(
                  word,
                  key: wordKey,
                  style: context.text.micro.copyWith(color: foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
