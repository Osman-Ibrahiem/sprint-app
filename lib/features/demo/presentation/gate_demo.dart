import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/slot_chip/slot_chip.dart';
import 'package:sprint/core/widgets/slot_chip/slot_state.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/features/auth/presentation/account_gate.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// A stand-in for "book this slot" (FR-016, FR-017) so the account gate can be
/// shown before the booking flow exists. It keeps a selected [SlotChip], calls
/// [requireAccount] and says what came back; it never books anything.
class GateDemo extends ConsumerStatefulWidget {
  const GateDemo({super.key});

  static const bookKey = ValueKey<String>('gate-demo-book');
  static const statusKey = ValueKey<String>('gate-demo-status');
  static const slotHours = [17, 18, 19];

  @override
  ConsumerState<GateDemo> createState() => _GateDemoState();
}

class _GateDemoState extends ConsumerState<GateDemo> {
  late final Future<int> _threshold = ref
      .read(settingsRepositoryProvider)
      .resolve(SettingKeys.fewLeftThreshold);
  int? _selected;
  bool? _result;

  Future<void> _book() async {
    final l10n = AppLocalizations.of(context);
    final ok = await requireAccount(context, ref, l10n.gateReasonBook);
    if (!mounted) return;
    setState(() => _result = ok);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final day = DateTime(2026, 11, 20);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.gateDemoTitle, style: context.text.title),
        const SizedBox(height: SprintSpacing.space2),
        Text(l10n.gateDemoIntro, style: context.text.body),
        const SizedBox(height: SprintSpacing.space3),
        FutureBuilder<int>(
          future: _threshold,
          builder: (context, snapshot) => Wrap(
            spacing: SprintSpacing.space2,
            runSpacing: SprintSpacing.space2,
            children: [
              for (final h in GateDemo.slotHours)
                SlotChip(
                  key: ValueKey<String>('gate-demo-slot-$h'),
                  start: day.add(Duration(hours: h)),
                  state: _selected == h
                      ? SlotState.selected
                      : SlotState.available,
                  fewLeftThreshold: snapshot.data ?? 2,
                  onSelected: () => setState(() {
                    _selected = h;
                    _result = null;
                  }),
                ),
            ],
          ),
        ),
        const SizedBox(height: SprintSpacing.space3),
        SprintButton(
          key: GateDemo.bookKey,
          label: l10n.gateDemoBookSlot,
          onPressed: _selected == null ? null : _book,
        ),
        if (_result != null) ...[
          const SizedBox(height: SprintSpacing.space2),
          Semantics(
            liveRegion: true,
            container: true,
            child: Text(
              _result! ? l10n.gateDemoReady : l10n.gateDemoDismissed,
              key: GateDemo.statusKey,
              style: context.text.body,
            ),
          ),
        ],
      ],
    );
  }
}
