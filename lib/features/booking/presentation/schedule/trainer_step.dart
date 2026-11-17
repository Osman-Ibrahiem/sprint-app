import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/a11y/focusable_tap.dart';
import 'package:sprint/core/l10n/directional_icon.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/features/booking/domain/facility_schedule.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The first step of the trainer path: who gives the session (FR-017, BR-09).
/// Each trainer shows a name, a short bio and whether they have sessions in
/// the coming days, in words and with an icon.
class TrainerList extends StatelessWidget {
  const TrainerList({
    required this.trainers,
    required this.onSelected,
    super.key,
  });

  final List<ScheduleTrainer> trainers;
  final ValueChanged<ScheduleTrainer> onSelected;

  static ValueKey<String> rowKey(String trainerId) =>
      ValueKey('trainer-$trainerId');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(l10n.bookingTrainerStepTitle, style: context.text.title),
        ),
        const SizedBox(height: SprintSpacing.space1),
        Text(
          l10n.bookingTrainerStepBody,
          style: context.text.body.copyWith(color: colors.inkMuted),
        ),
        const SizedBox(height: SprintSpacing.space3),
        for (final t in trainers)
          Padding(
            padding: const EdgeInsetsDirectional.only(
              bottom: SprintSpacing.space2,
            ),
            child: _TrainerRow(trainer: t, onTap: () => onSelected(t)),
          ),
      ],
    );
  }
}

class _TrainerRow extends StatelessWidget {
  const _TrainerRow({required this.trainer, required this.onTap});

  final ScheduleTrainer trainer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final name = trainer.name ?? l10n.bookingTrainerNoName;
    final sessions = trainer.hasSessionsInWindow
        ? l10n.bookingTrainerHasSessions
        : l10n.bookingTrainerNoSessions;
    return FocusableTap(
      key: TrainerList.rowKey(trainer.id),
      label: '$name، ${trainer.bio}، $sessions',
      selected: false,
      onTap: onTap,
      builder: (context, hovered) => Container(
        padding: const EdgeInsetsDirectional.all(SprintSpacing.space3),
        decoration: BoxDecoration(
          color: hovered ? colors.surfaceSunken : colors.surface,
          borderRadius: SprintRadius.lgBorder,
          border: Border.all(color: colors.line),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: context.text.bodyStrong),
                  Text(
                    trainer.bio,
                    style: context.text.caption.copyWith(
                      color: colors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: SprintSpacing.space1),
                  Row(
                    children: [
                      SprintIcon(
                        trainer.hasSessionsInWindow
                            ? PhosphorIconsRegular.checkCircle
                            : PhosphorIconsRegular.prohibit,
                        size: SprintSize.iconSm,
                        color: trainer.hasSessionsInWindow
                            ? colors.success
                            : colors.inkDisabled,
                      ),
                      const SizedBox(width: SprintSpacing.space1),
                      Flexible(
                        child: Text(
                          sessions,
                          style: context.text.caption.copyWith(
                            color: trainer.hasSessionsInWindow
                                ? colors.ink
                                : colors.inkMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            DirectionalIcon(
              PhosphorIconsRegular.caretRight,
              size: SprintSize.iconMd,
              color: colors.inkMuted,
            ),
          ],
        ),
      ),
    );
  }
}

/// The chosen trainer, with the way to change them (FR-019).
class ChosenTrainerRow extends StatelessWidget {
  const ChosenTrainerRow({
    required this.trainer,
    required this.onChange,
    super.key,
  });

  final ScheduleTrainer trainer;
  final VoidCallback onChange;

  static const changeKey = ValueKey<String>('trainer-change');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = trainer.name ?? l10n.bookingTrainerNoName;
    // A Wrap, so a narrow pane puts the action under the name.
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: SprintSpacing.space2,
      children: [
        Text(l10n.bookingTrainerChosen(name), style: context.text.headline),
        SprintButton(
          key: changeKey,
          label: l10n.bookingTrainerChange,
          variant: SprintButtonVariant.ghost,
          size: SprintButtonSize.sm,
          onPressed: onChange,
        ),
      ],
    );
  }
}
