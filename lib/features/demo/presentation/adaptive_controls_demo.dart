import 'package:flutter/material.dart';
import 'package:sprint/core/adaptive/adaptive_app_bar.dart';
import 'package:sprint/core/adaptive/adaptive_dialog.dart';
import 'package:sprint/core/adaptive/adaptive_loader.dart';
import 'package:sprint/core/adaptive/adaptive_sheet.dart';
import 'package:sprint/core/adaptive/adaptive_switch.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// A trigger for each of the five adaptive controls (FR-019, FR-020).
class AdaptiveControlsDemo extends StatefulWidget {
  const AdaptiveControlsDemo({super.key});

  @override
  State<AdaptiveControlsDemo> createState() => _AdaptiveControlsDemoState();
}

class _AdaptiveControlsDemoState extends State<AdaptiveControlsDemo> {
  bool _reminders = true;
  String? _last;

  Future<void> _dialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final result = await showSprintDialog<String>(
      context: context,
      title: l10n.demoDialogTitle,
      message: l10n.demoDialogMessage,
      actions: [
        SprintDialogAction(
          label: l10n.demoDialogKeep,
          value: l10n.demoDialogKeep,
          isDefault: true,
        ),
        SprintDialogAction(
          label: l10n.demoDialogConfirm,
          value: l10n.demoDialogConfirm,
          isDestructive: true,
        ),
      ],
    );
    if (mounted && result != null) setState(() => _last = result);
  }

  Future<void> _sheet(BuildContext triggerContext) async {
    final l10n = AppLocalizations.of(triggerContext);
    final result = await showSprintSheet<String>(
      context: triggerContext,
      anchor: triggerContext,
      title: l10n.demoSheetTitle,
      cancelLabel: l10n.demoSheetClose,
      actions: [
        SprintSheetAction(
          label: l10n.demoSheetShare,
          value: l10n.demoSheetShare,
        ),
        SprintSheetAction(
          label: l10n.demoSheetCalendar,
          value: l10n.demoSheetCalendar,
        ),
      ],
    );
    if (mounted && result != null) setState(() => _last = result);
  }

  void _largeTitle(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const _LargeTitlePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const gap = SizedBox(height: SprintSpacing.space3);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton(
          onPressed: () => _largeTitle(context),
          child: Text(l10n.demoAppBarTrigger),
        ),
        gap,
        OutlinedButton(
          onPressed: () => _dialog(context),
          child: Text(l10n.demoDialogTrigger),
        ),
        gap,
        // The builder gives the sheet the button's own context to anchor to.
        Builder(
          builder: (buttonContext) => OutlinedButton(
            onPressed: () => _sheet(buttonContext),
            child: Text(l10n.demoSheetTrigger),
          ),
        ),
        gap,
        Row(
          children: [
            Expanded(
              child: Text(l10n.demoSwitchLabel, style: context.text.body),
            ),
            AdaptiveSwitch(
              value: _reminders,
              onChanged: (v) => setState(() => _reminders = v),
              semanticLabel: l10n.demoSwitchLabel,
            ),
          ],
        ),
        gap,
        Row(
          children: [
            AdaptiveLoader(semanticLabel: l10n.demoLoaderLabel),
            const SizedBox(width: SprintSpacing.space3),
            Expanded(
              child: Text(l10n.demoLoaderLabel, style: context.text.body),
            ),
          ],
        ),
        gap,
        Text(
          _last == null ? l10n.demoResultNone : l10n.demoResult(_last!),
          style: context.text.caption.copyWith(color: context.colors.inkMuted),
        ),
      ],
    );
  }
}

class _LargeTitlePage extends StatelessWidget {
  const _LargeTitlePage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          AdaptiveSliverAppBar(title: l10n.demoLargeTitle, largeTitle: true),
          SliverList.builder(
            itemCount: 30,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
              child: Text(l10n.demoTypeSample, style: context.text.body),
            ),
          ),
        ],
      ),
    );
  }
}
