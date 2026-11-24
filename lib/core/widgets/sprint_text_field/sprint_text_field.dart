import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';

/// The three shapes of the field (decision 2 of refactor 000): `text`,
/// `password` and `search`. `phone`, `email` and `nationalId` are the `text`
/// shape with their own keyboard, autofill and direction. The confirmation
/// code is not a text field: it is `SprintCodeField` (six boxes).
enum SprintTextFieldType { text, password, search, phone, email, nationalId }

/// The six states every shape shows, the same names as Figma and the
/// TextField README (decision 2 of refactor 000).
enum SprintTextFieldState {
  /// Empty, not focused: the placeholder in `ink-muted`.
  resting,

  /// Has the keyboard: a 2px `primary` border.
  focused,

  /// Not focused and holds a value: the value in `ink` on the resting
  /// container (search adds its clear button).
  filled,

  /// A wrong input: `danger-soft`, a 2px `danger` border and the message.
  /// Never on `search` (decision U2: "no results" is not an input error).
  error,

  /// A value that is shown and readable but cannot change (FR-MYB-03).
  locked,

  /// Not available right now: greyed out.
  disabled,
}

/// The one rule that picks the state; precedence locked > disabled > error >
/// focused > filled > resting.
SprintTextFieldState resolveTextFieldState({
  required SprintTextFieldType type,
  bool locked = false,
  bool enabled = true,
  bool hasError = false,
  bool focused = false,
  bool hasText = false,
}) {
  if (locked) return SprintTextFieldState.locked;
  if (!enabled) return SprintTextFieldState.disabled;
  if (hasError && type != SprintTextFieldType.search) {
    return SprintTextFieldState.error;
  }
  if (focused) return SprintTextFieldState.focused;
  if (hasText) return SprintTextFieldState.filled;
  return SprintTextFieldState.resting;
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
    this.showLabel = true,
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

  /// False draws no label above the field (a search field with only a
  /// placeholder); the label still names it for screen readers.
  final bool showLabel;

  /// Read-only value that is still readable (FR-MYB-03): `ink-muted` on
  /// `surface-sunken` with a lock icon; [helper] says why. Not "disabled",
  /// which means "not available right now". Shows [lockedValue] (masked on
  /// the password shape).
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
  static const revealKey = ValueKey<String>('sprint-text-field-reveal');

  @override
  State<SprintTextField> createState() => _SprintTextFieldState();
}

const String _passwordMask = '•';

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
    SprintTextFieldType.nationalId => true,
    SprintTextFieldType.text || SprintTextFieldType.search => false,
  };

  bool get _isPassword => widget.type == SprintTextFieldType.password;

  late bool _hasText = _controller.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  /// The state this field shows now.
  SprintTextFieldState get _state => resolveTextFieldState(
    type: widget.type,
    locked: widget.locked,
    enabled: widget.enabled,
    hasError: widget.error != null,
    focused: _focused,
    hasText: _hasText,
  );

  void _onFocusChanged() {
    final focused = _focusNode.hasFocus;
    if (focused != _focused) setState(() => _focused = focused);
    if (!focused) widget.onLeave?.call();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _controller.removeListener(_onTextChanged);
    if (widget.focusNode == null) _focusNode.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  TextInputType get _keyboardType => switch (widget.type) {
    SprintTextFieldType.phone => TextInputType.phone,
    SprintTextFieldType.email => TextInputType.emailAddress,
    SprintTextFieldType.nationalId => TextInputType.number,
    _ => TextInputType.text,
  };

  Iterable<String>? get _autofillHints =>
      widget.autofillHints ??
      switch (widget.type) {
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
    final search = widget.type == SprintTextFieldType.search;
    final state = _state;
    final hasError = state == SprintTextFieldState.error;

    if (state == SprintTextFieldState.locked) {
      return _buildLocked(context, l10n, colors);
    }

    final (fill, borderColor, borderWidth) = switch (state) {
      SprintTextFieldState.disabled => (
        colors.surfaceSunken,
        colors.controlBorder,
        SprintExtras.hairlineWidth,
      ),
      SprintTextFieldState.error => (
        colors.dangerSoft,
        colors.danger,
        SprintExtras.focusRingWidth,
      ),
      SprintTextFieldState.focused => (
        colors.surface,
        colors.primary,
        SprintExtras.focusRingWidth,
      ),
      // Resting and filled share the container; filled differs by its value
      // in `ink` (and the clear button on search).
      _ => (
        search ? colors.surfaceSunken : colors.surface,
        search ? Colors.transparent : colors.controlBorder,
        SprintExtras.hairlineWidth,
      ),
    };

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
            // A long placeholder takes a second line at large text instead
            // of an ellipsis (decision T1).
            hintMaxLines: 2,
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
          if (widget.showLabel) ...[
            Text(
              widget.label,
              style: context.text.label.copyWith(color: labelColor),
            ),
            const SizedBox(height: SprintSpacing.space1),
          ],
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
                      if (_isPassword) _revealToggle(context, l10n, colors),
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

  /// The eye icon and its word, "إظهار" or "إخفاء" (decision V3): the word
  /// is also the spoken label, and the whole control is a 48 target.
  Widget _revealToggle(
    BuildContext context,
    AppLocalizations l10n,
    SprintColors colors,
  ) {
    final word = _revealed ? l10n.fieldHidePassword : l10n.fieldShowPassword;
    return AdaptivePressable(
      key: SprintTextField.revealKey,
      label: word,
      onTap: widget.enabled
          ? () => setState(() => _revealed = !_revealed)
          : null,
      hoverColor: colors.surfaceSunken,
      pressedColor: colors.surfaceSunken,
      builder: (context, _) => Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: SprintSpacing.space2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SprintIcon(
              _revealed
                  ? PhosphorIconsRegular.eyeSlash
                  : PhosphorIconsRegular.eye,
              size: SprintSize.iconMd,
              color: colors.inkMuted,
            ),
            const SizedBox(width: SprintSpacing.space1),
            Text(
              word,
              style: context.text.label.copyWith(color: colors.inkMuted),
            ),
          ],
        ),
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
    final raw = widget.lockedValue ?? '';
    // A locked password never shows its characters.
    final value = _isPassword ? _passwordMask * raw.length : raw;
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
