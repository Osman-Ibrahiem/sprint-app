import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/l10n/directional_icon.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';

enum SettingsRowType {
  /// A label and the current value ("اللغة · العربية").
  value,

  /// A label and a mirrored chevron.
  navigation,

  /// A danger label with the sign-out icon (mirrored in RTL).
  destructive,
}

/// One row of the account list (SettingsRow README, FR-MYB-03): 52 high, the
/// whole row is a 48+ target.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    required this.label,
    required this.onTap,
    this.type = SettingsRowType.navigation,
    this.value,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final SettingsRowType type;

  /// The current value of a [SettingsRowType.value] row.
  final String? value;

  /// A leading icon (navigation and value rows); destructive rows draw the
  /// sign-out icon themselves.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final destructive = type == SettingsRowType.destructive;
    final fg = destructive ? colors.danger : colors.ink;

    return AdaptivePressable(
      label: value == null ? label : '$label، $value',
      onTap: onTap,
      expand: true,
      borderRadius: SprintRadius.mdBorder,
      builder: (context, _) => ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: SprintExtras.settingsRowHeight,
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: SprintSpacing.space4,
            vertical: SprintSpacing.space2,
          ),
          child: Row(
            children: [
              if (destructive)
                DirectionalIcon(
                  PhosphorIconsRegular.signOut,
                  size: SprintSize.iconMd,
                  color: fg,
                )
              else if (icon != null)
                SprintIcon(
                  icon!,
                  size: SprintSize.iconMd,
                  color: colors.inkMuted,
                ),
              if (destructive || icon != null)
                const SizedBox(width: SprintSpacing.space3),
              Expanded(
                child: Text(label, style: text.body.copyWith(color: fg)),
              ),
              if (value != null) ...[
                Flexible(
                  child: Text(
                    value!,
                    style: text.body.copyWith(color: colors.inkMuted),
                  ),
                ),
                const SizedBox(width: SprintSpacing.space2),
              ],
              if (!destructive)
                DirectionalIcon(
                  PhosphorIconsRegular.caretRight,
                  size: SprintSize.iconMd,
                  color: colors.inkMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
