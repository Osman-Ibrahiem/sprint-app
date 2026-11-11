import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint/core/adaptive/adaptive_sheet.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// A chosen unit and its facility.
typedef _UnitChoice = ({String unitId, String facilityId, String label});

/// Read-only: for a chosen unit, each setting's value and the level it came
/// from (unit, facility, university or default) (FR-020).
class SettingsInspector extends ConsumerStatefulWidget {
  const SettingsInspector({super.key});

  @override
  ConsumerState<SettingsInspector> createState() => _SettingsInspectorState();
}

class _SettingsInspectorState extends ConsumerState<SettingsInspector> {
  _UnitChoice? _unit;

  Future<List<_UnitChoice>> _choices() async {
    final catalogue = ref.read(catalogueRepositoryProvider);
    final out = <_UnitChoice>[];
    for (final f in await catalogue.listFacilities()) {
      for (final u in await catalogue.listUnits(f.id)) {
        out.add((unitId: u.id, facilityId: f.id, label: '${f.name} · ${u.name}'));
      }
    }
    return out;
  }

  Future<void> _pick(BuildContext triggerContext) async {
    final choices = await _choices();
    if (!mounted || !triggerContext.mounted) return;
    final picked = await showSprintSheet<_UnitChoice>(
      context: triggerContext,
      anchor: triggerContext,
      title: AppLocalizations.of(context).demoSettingsPick,
      cancelLabel: AppLocalizations.of(context).demoSheetClose,
      actions: [
        for (final c in choices) SprintSheetAction(label: c.label, value: c),
      ],
    );
    if (picked != null && mounted) setState(() => _unit = picked);
  }

  Future<List<(String, String, SettingLevel)>> _rows(_UnitChoice unit) async {
    final repo = ref.read(settingsRepositoryProvider);
    final l10n = AppLocalizations.of(context);
    final out = <(String, String, SettingLevel)>[];
    for (final def in settingRegistry.values) {
      final r = await _resolve(repo, def.key, unit);
      out.add((def.key.name, _show(l10n, r.value), r.level));
    }
    return out;
  }

  Future<ResolvedSetting<Object?>> _resolve(
    dynamic repo,
    SettingKey<dynamic> key,
    _UnitChoice unit,
  ) async {
    final r = await repo.resolveWithSource(
      key,
      unitId: unit.unitId,
      facilityId: unit.facilityId,
    ) as ResolvedSetting<dynamic>;
    return ResolvedSetting<Object?>(r.value as Object?, r.level);
  }

  String _show(AppLocalizations l10n, Object? v) => switch (v) {
        null => l10n.demoNoLimit,
        Enum() => v.name,
        _ => v.toString(),
      };

  String _level(AppLocalizations l10n, SettingLevel level) => switch (level) {
        SettingLevel.unit => l10n.levelUnit,
        SettingLevel.facility => l10n.levelFacility,
        SettingLevel.university => l10n.levelUniversity,
        SettingLevel.registryDefault => l10n.levelDefault,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final unit = _unit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.demoSettingsTitle, style: context.text.title),
        const SizedBox(height: SprintSpacing.space3),
        Builder(
          builder: (buttonContext) => OutlinedButton(
            onPressed: () => _pick(buttonContext),
            child: Text(
              unit == null ? l10n.demoSettingsPick : l10n.demoSettingsUnit(unit.label),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        if (unit != null) ...[
          const SizedBox(height: SprintSpacing.space3),
          FutureBuilder<List<(String, String, SettingLevel)>>(
            key: ValueKey(unit.unitId),
            future: _rows(unit),
            builder: (context, snap) {
              final rows = snap.data;
              if (rows == null) return const SizedBox.shrink();
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: SprintRadius.lgBorder,
                  border: Border.all(color: colors.line),
                ),
                child: Column(
                  children: [
                    for (final (name, value, level) in rows)
                      Padding(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: SprintSpacing.space4,
                          vertical: SprintSpacing.space2,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Setting names are code identifiers.
                                  Text(name, style: context.text.label),
                                  Text(
                                    l10n.demoSettingsLevel(_level(l10n, level)),
                                    style: context.text.caption
                                        .copyWith(color: colors.inkMuted),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: SprintSpacing.space3),
                            Text(value, style: context.text.number),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
