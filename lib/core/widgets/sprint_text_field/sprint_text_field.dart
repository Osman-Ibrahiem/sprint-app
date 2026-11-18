import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';

enum SprintTextFieldType {
  text,
  password,
  search,
  phone,
  email,
  nationalId,
  code,
}

/// Longest confirmation code the `code` type accepts.
const int sprintCodeLength = 6;

/// Turns Arabic-Indic and Persian digits into 0-9 and drops everything that
/// is not a digit, as the user types or pastes.
class _CodeDigitsFormatter extends TextInputFormatter {
  const _CodeDigitsFormatter();

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

/// The design system's input field (TextField README, FR-018 – FR-022).
///
/// The label is always above the field; validation belongs to the caller and
/// runs on [onLeave], never on every character.
class SprintTextField extends StatefulWidget {
  const SprintTextField({
    required this.label,
    this.placeholder,
    this.helper,
    this.error,
    this.type = SprintTextFieldType.text,
    this.controller,
    this.enabled = true,
    this.onChanged,
    this.onLeave,
    this.onSubmitted,
    this.autofillHints,
    this.textInputAction,
    this.focusNode,
    this.locked = false,
    this.lockedValue,
    this.onClear,
    this.cancelLabel,
    this.onCancel,
    super.key,
  });

  final String label;
  final String? placeholder;
  final String? helper;
  final String? error;
  final SprintTextFieldType type;
  final TextEditingController? controller;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onLeave;
  final ValueChanged<String>? onSubmitted;

  /// Overrides the type's default autofill hints (for example
  /// `AutofillHints.newPassword` on sign up and reset).
  final Iterable<String>? autofillHints;

  /// `next` moves focus to the next field, `done` submits (FR-047).
  final TextInputAction? textInputAction;

  /// An external node for form order; the field does not dispose it.
  final FocusNode? focusNode;

  /// Read-only value that is still readable (FR-MYB-03): `ink-muted` on
  /// `surface-sunken` with a lock icon; [helper] says why. Not "disabled",
  /// which means "not available right now". Shows [lockedValue].
  final bool locked;
  final String? lockedValue;

  /// Search type, filled state: a 48 clear button that runs this callback
  /// after emptying the field. Hidden when the field is empty.
  final VoidCallback? onClear;

  /// Search type: an optional text action after the field ("إلغاء").
  final String? cancelLabel;
  final VoidCallback? onCancel;

  static const fieldKey = ValueKey<String>('sprint-text-field');
  static const lockIconKey = ValueKey<String>('sprint-text-field-lock');
  static const clearKey = ValueKey<String>('sprint-text-field-clear');
  static const cancelKey = ValueKey<String>('sprint-text-field-cancel');

  @override
  State<SprintTextField> createState() => _SprintTextFieldState();
}

class _SprintTextFieldState extends State<SprintTextField> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();
  bool _focused = false;
  bool _revealed = false;

  bool get _ltr => switch (widget.type) {
    SprintTextFieldType.password ||
    SprintTextFieldType.phone ||
    SprintTextFieldType.email ||
    SprintTextFieldType.nationalId ||
    SprintTextFieldType.code => true,
    SprintTextFieldType.text || SprintTextFieldType.search => false,
  };

  bool get _isPassword => widget.type == SprintTextFieldType.password;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    final focused = _focusNode.hasFocus;
    if (focused != _focused) setState(() => _focused = focused);
    if (!focused) widget.onLeave?.call();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    if (widget.focusNode == null) _focusNode.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  TextInputType get _keyboardType => switch (widget.type) {
    SprintTextFieldType.phone => TextInputType.phone,
    SprintTextFieldType.email => TextInputType.emailAddress,
    SprintTextFieldType.nationalId ||
    SprintTextFieldType.code => TextInputType.number,
    _ => TextInputType.text,
  };

  Iterable<String>? get _autofillHints =>
      widget.autofillHints ??
      switch (widget.type) {
        SprintTextFieldType.password => const [AutofillHints.password],
        SprintTextFieldType.phone => const [AutofillHints.telephoneNumber],
        SprintTextFieldType.email => const [AutofillHints.email],
        SprintTextFieldType.code => const [AutofillHints.oneTimeCode],
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final hasError = widget.error != null;
    final search = widget.type == SprintTextFieldType.search;

    if (widget.locked) return _buildLocked(context, l10n, colors);

    final Color fill;
    final Color borderColor;
    final double borderWidth;
    if (!widget.enabled) {
      fill = colors.surfaceSunken;
      borderColor = colors.controlBorder;
      borderWidth = SprintExtras.hairlineWidth;
    } else if (hasError) {
      fill = colors.dangerSoft;
      borderColor = colors.danger;
      borderWidth = SprintExtras.focusRingWidth;
    } else if (_focused) {
      fill = colors.surface;
      borderColor = colors.primary;
      borderWidth = SprintExtras.focusRingWidth;
    } else {
      fill = search ? colors.surfaceSunken : colors.surface;
      borderColor = search ? Colors.transparent : colors.controlBorder;
      borderWidth = SprintExtras.hairlineWidth;
    }

    final labelColor = widget.enabled ? colors.ink : colors.inkDisabled;
    final textColor = widget.enabled ? colors.ink : colors.inkDisabled;

    final field = TextField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      obscureText: _isPassword && !_revealed,
      keyboardType: _keyboardType,
      autofillHints: _autofillHints,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.type == SprintTextFieldType.code
          ? const [_CodeDigitsFormatter()]
          : null,
      enableSuggestions: !_isPassword,
      autocorrect: !_isPassword,
      textDirection: _ltr ? TextDirection.ltr : null,
      textAlign: _ltr
          ? (rtl ? TextAlign.right : TextAlign.left)
          : TextAlign.start,
      style: context.text.body.copyWith(color: textColor),
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      // The container above draws the one border and focus ring. Every border
      // is cleared here, because `InputDecoration.collapsed` clears only
      // `border` and the theme's enabled and focused borders would otherwise
      // draw a second outline inside the field.
      decoration:
          InputDecoration.collapsed(
            hintText: widget.placeholder,
            hintStyle: context.text.body.copyWith(color: colors.inkMuted),
          ).copyWith(
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
          ),
    );

    return Semantics(
      container: true,
      textField: true,
      label: hasError ? '${widget.label}، ${widget.error}' : widget.label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.label,
            style: context.text.label.copyWith(color: labelColor),
          ),
          const SizedBox(height: SprintSpacing.space1),
          _withCancel(
            context,
            DecoratedBox(
              key: SprintTextField.fieldKey,
              decoration: BoxDecoration(
                color: fill,
                borderRadius: search
                    ? SprintRadius.fullBorder
                    : SprintRadius.smBorder,
                border: Border.all(color: borderColor, width: borderWidth),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: SprintSize.controlHeight,
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: SprintSpacing.space3,
                    vertical: SprintSpacing.space2,
                  ),
                  child: Row(
                    children: [
                      if (search) ...[
                        SprintIcon(
                          Icons.search,
                          size: SprintSize.iconMd,
                          color: colors.inkMuted,
                        ),
                        const SizedBox(width: SprintSpacing.space2),
                      ],
                      Expanded(child: field),
                      if (search && widget.onClear != null)
                        ListenableBuilder(
                          listenable: _controller,
                          builder: (context, _) => _controller.text.isEmpty
                              ? const SizedBox.shrink()
                              : IconButton(
                                  key: SprintTextField.clearKey,
                                  tooltip: l10n.searchClear,
                                  constraints: const BoxConstraints(
                                    minWidth: SprintExtras.searchClearTarget,
                                    minHeight: SprintExtras.searchClearTarget,
                                  ),
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    _controller.clear();
                                    widget.onChanged?.call('');
                                    widget.onClear!();
                                  },
                                  icon: SprintIcon(
                                    Icons.close,
                                    size: SprintSize.iconMd,
                                    color: colors.inkMuted,
                                  ),
                                ),
                        ),
                      if (_isPassword)
                        IconButton(
                          tooltip: _revealed
                              ? l10n.fieldHidePassword
                              : l10n.fieldShowPassword,
                          constraints: const BoxConstraints(
                            minWidth: SprintSize.controlHeight,
                            minHeight: SprintSize.controlHeight,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: () =>
                              setState(() => _revealed = !_revealed),
                          icon: SprintIcon(
                            _revealed ? Icons.visibility_off : Icons.visibility,
                            size: SprintSize.iconMd,
                            color: colors.inkMuted,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (hasError || widget.helper != null) ...[
            const SizedBox(height: SprintSpacing.space1),
            Row(
              children: [
                if (hasError) ...[
                  SprintIcon(
                    Icons.error_outline,
                    size: SprintSize.iconSm,
                    color: colors.danger,
                  ),
                  const SizedBox(width: SprintSpacing.space1),
                ],
                Expanded(
                  child: Text(
                    hasError ? widget.error! : widget.helper!,
                    style: context.text.caption.copyWith(
                      color: hasError ? colors.danger : colors.inkMuted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _withCancel(BuildContext context, Widget field) {
    if (widget.cancelLabel == null) return field;
    return Row(
      children: [
        Expanded(child: field),
        TextButton(
          key: SprintTextField.cancelKey,
          style: TextButton.styleFrom(
            minimumSize: const Size(
              SprintSize.controlHeight,
              SprintSize.controlHeight,
            ),
          ),
          onPressed: widget.onCancel,
          child: Text(
            widget.cancelLabel!,
            style: context.text.label.copyWith(color: context.colors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildLocked(
    BuildContext context,
    AppLocalizations l10n,
    SprintColors colors,
  ) {
    final ltr = _ltr;
    final value = widget.lockedValue ?? '';
    return Semantics(
      container: true,
      readOnly: true,
      label: widget.label,
      value: value,
      hint: widget.helper == null
          ? null
          : l10n.lockedFieldReadOnly(widget.helper!),
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.label,
              style: context.text.label.copyWith(color: colors.inkMuted),
            ),
            const SizedBox(height: SprintSpacing.space1),
            Container(
              key: SprintTextField.fieldKey,
              constraints: const BoxConstraints(
                minHeight: SprintSize.controlHeight,
              ),
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: SprintSpacing.space4,
                vertical: SprintSpacing.space2,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceSunken,
                borderRadius: SprintRadius.smBorder,
                border: Border.all(
                  color: colors.line,
                  width: SprintExtras.hairlineWidth,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      value,
                      textDirection: ltr ? TextDirection.ltr : null,
                      textAlign: ltr ? TextAlign.left : TextAlign.start,
                      style: context.text.body.copyWith(color: colors.inkMuted),
                    ),
                  ),
                  const SizedBox(width: SprintSpacing.space2),
                  SprintIcon(
                    PhosphorIconsRegular.lock,
                    key: SprintTextField.lockIconKey,
                    size: SprintSize.iconMd,
                    color: colors.inkMuted,
                  ),
                ],
              ),
            ),
            if (widget.helper != null) ...[
              const SizedBox(height: SprintSpacing.space1),
              Text(
                widget.helper!,
                style: context.text.caption.copyWith(color: colors.inkMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
