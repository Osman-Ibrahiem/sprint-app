import 'package:flutter/material.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';

enum SprintTextFieldType { text, password, search, phone, email, nationalId }

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

  static const fieldKey = ValueKey<String>('sprint-text-field');

  @override
  State<SprintTextField> createState() => _SprintTextFieldState();
}

class _SprintTextFieldState extends State<SprintTextField> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;
  bool _revealed = false;

  bool get _ltr => switch (widget.type) {
        SprintTextFieldType.password ||
        SprintTextFieldType.phone ||
        SprintTextFieldType.email ||
        SprintTextFieldType.nationalId =>
          true,
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
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  TextInputType get _keyboardType => switch (widget.type) {
        SprintTextFieldType.phone => TextInputType.phone,
        SprintTextFieldType.email => TextInputType.emailAddress,
        SprintTextFieldType.nationalId => TextInputType.number,
        _ => TextInputType.text,
      };

  Iterable<String>? get _autofillHints => switch (widget.type) {
        SprintTextFieldType.password => const [AutofillHints.password],
        SprintTextFieldType.phone => const [AutofillHints.telephoneNumber],
        SprintTextFieldType.email => const [AutofillHints.email],
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final hasError = widget.error != null;
    final search = widget.type == SprintTextFieldType.search;

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
      enableSuggestions: !_isPassword,
      autocorrect: !_isPassword,
      textDirection: _ltr ? TextDirection.ltr : null,
      textAlign: _ltr
          ? (rtl ? TextAlign.right : TextAlign.left)
          : TextAlign.start,
      style: context.text.body.copyWith(color: textColor),
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration.collapsed(
        hintText: widget.placeholder,
        hintStyle: context.text.body.copyWith(color: colors.inkMuted),
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
                            _revealed
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: SprintSize.iconMd,
                            color: colors.inkMuted,
                          ),
                        ),
                    ],
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
}
