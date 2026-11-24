import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/reduced_motion.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_motion.g.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// How many digits a confirmation code has.
const int sprintCodeLength = 6;

/// Turns Arabic-Indic and Persian digits into 0-9 and drops everything that
/// is not a digit, as the user types or pastes ("١٢٣ ٤٥٦" becomes "123456").
class CodeDigitsFormatter extends TextInputFormatter {
  const CodeDigitsFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final out = StringBuffer();
    for (final unit in newValue.text.runes) {
      if (unit >= 0x0660 && unit <= 0x0669) {
        out.writeCharCode(0x30 + unit - 0x0660);
      } else if (unit >= 0x06F0 && unit <= 0x06F9) {
        out.writeCharCode(0x30 + unit - 0x06F0);
      } else if (unit >= 0x30 && unit <= 0x39) {
        out.writeCharCode(unit);
      }
    }
    var text = out.toString();
    if (text.length > sprintCodeLength) {
      text = text.substring(0, sprintCodeLength);
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// The confirmation code as six boxes side by side (decision 2 of refactor
/// 000, Figma `CodeEntry`: default, focused, error, ready).
///
/// Built on `pinput` (one hidden text input behind the boxes), so typing,
/// paste from the context menu and the `oneTimeCode` autofill (iOS fills a
/// code from Mail) all land in one place. The boxes are drawn here from
/// tokens only. Digits always run left to right, in Arabic too, like every
/// code in the app; each box has its own spoken label; the digit's entrance
/// is dropped under reduced motion.
class SprintCodeField extends StatelessWidget {
  const SprintCodeField({
    required this.label,
    this.controller,
    this.focusNode,
    this.error,
    this.enabled = true,
    this.onChanged,
    this.onCompleted,
    this.onSubmitted,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// Shown under the boxes with an icon; turns every box `danger`.
  final String? error;
  final bool enabled;
  final ValueChanged<String>? onChanged;

  /// Called once the sixth digit is in.
  final ValueChanged<String>? onCompleted;

  /// The keyboard's done action.
  final ValueChanged<String>? onSubmitted;

  static const boxesKey = ValueKey<String>('sprint-code-field-boxes');
  static ValueKey<String> boxKey(int index) =>
      ValueKey<String>('sprint-code-box-$index');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final hasError = error != null;

    return Semantics(
      container: true,
      label: hasError ? '$label، $error' : label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: Text(
              label,
              style: context.text.label.copyWith(
                color: enabled ? colors.ink : colors.inkDisabled,
              ),
            ),
          ),
          const SizedBox(height: SprintSpacing.space1),
          // Codes read left to right in both languages (README § الأرقام).
          Directionality(
            textDirection: TextDirection.ltr,
            child: Pinput.builder(
              key: boxesKey,
              length: sprintCodeLength,
              controller: controller,
              focusNode: focusNode,
              enabled: enabled,
              forceErrorState: hasError,
              showErrorWhenFocused: true,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: const [CodeDigitsFormatter()],
              textInputAction: TextInputAction.done,
              enableSuggestions: false,
              closeKeyboardWhenCompleted: false,
              mainAxisAlignment: MainAxisAlignment.start,
              separatorBuilder: (_) =>
                  const SizedBox(width: SprintSpacing.space2),
              onChanged: onChanged,
              onCompleted: onCompleted,
              onSubmitted: onSubmitted,
              builder: (context, item) => Expanded(
                child: _CodeBox(
                  key: boxKey(item.index),
                  item: item,
                  spoken: item.value.isEmpty
                      ? l10n.codeBoxEmpty(item.index + 1, sprintCodeLength)
                      : l10n.codeBoxFilled(
                          item.index + 1,
                          sprintCodeLength,
                          item.value,
                        ),
                ),
              ),
            ),
          ),
          if (hasError) ...[
            const SizedBox(height: SprintSpacing.space1),
            ExcludeSemantics(
              child: Row(
                children: [
                  SprintIcon(
                    Icons.error_outline,
                    size: SprintSize.iconSm,
                    color: colors.danger,
                  ),
                  const SizedBox(width: SprintSpacing.space1),
                  Expanded(
                    child: Text(
                      error!,
                      style: context.text.caption.copyWith(
                        color: colors.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// One box: 48 high at least, `radius-sm`, the same border rules as the text
/// field (control-border at rest, 2px primary on the next box to fill, 2px
/// danger on error).
class _CodeBox extends StatelessWidget {
  const _CodeBox({required this.item, required this.spoken, super.key});

  final PinItemState item;
  final String spoken;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (fill, border, width, ink) = switch (item.type) {
      PinItemStateType.disabled => (
        colors.surfaceSunken,
        colors.controlBorder,
        SprintExtras.hairlineWidth,
        colors.inkDisabled,
      ),
      PinItemStateType.error => (
        colors.dangerSoft,
        colors.danger,
        SprintExtras.focusRingWidth,
        colors.ink,
      ),
      PinItemStateType.focused => (
        colors.surface,
        colors.primary,
        SprintExtras.focusRingWidth,
        colors.ink,
      ),
      PinItemStateType.submitted ||
      PinItemStateType.following ||
      PinItemStateType.initial => (
        colors.surface,
        colors.controlBorder,
        SprintExtras.hairlineWidth,
        colors.ink,
      ),
    };

    return Semantics(
      container: true,
      label: spoken,
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: ReducedMotion.fade(context, SprintMotion.durationFast),
          curve: SprintMotion.easeStandard,
          constraints: const BoxConstraints(
            minHeight: SprintSize.controlHeight,
          ),
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: SprintSpacing.space2,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: SprintRadius.smBorder,
            border: Border.all(color: border, width: width),
          ),
          child: AnimatedSwitcher(
            duration: ReducedMotion.skip(context, SprintMotion.durationFast),
            switchInCurve: SprintMotion.easeEnter,
            switchOutCurve: SprintMotion.easeExit,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
            child: Text(
              item.value,
              key: ValueKey<String>('${item.index}-${item.value}'),
              style: context.text.number.copyWith(color: ink),
            ),
          ),
        ),
      ),
    );
  }
}
