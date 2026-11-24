import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sprint/core/l10n/ltr_isolate.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/core/widgets/code_field/sprint_code_field.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Confirmation code entry (contracts/ui.md): the address the code went to in
/// an LTR isolate, the six code boxes ([SprintCodeField]), resend with a countdown to [resendAfter],
/// and a slot for the demo notice ([demoNotice], built by the caller only
/// when demo tools are on, FR-023).
class CodeEntry extends StatefulWidget {
  const CodeEntry({
    required this.address,
    required this.resendAfter,
    required this.onResend,
    this.controller,
    this.error,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.demoNotice,
    this.now = DateTime.now,
    super.key,
  });

  final String address;
  final DateTime resendAfter;
  final VoidCallback onResend;
  final TextEditingController? controller;
  final String? error;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final Widget? demoNotice;

  /// The clock the countdown reads; tests pass a fake one.
  final DateTime Function() now;

  static const resendKey = ValueKey<String>('code-entry-resend');

  @override
  State<CodeEntry> createState() => _CodeEntryState();
}

class _CodeEntryState extends State<CodeEntry> {
  Timer? _timer;
  late int _remaining = _secondsLeft();

  int _secondsLeft() {
    final ms = widget.resendAfter.difference(widget.now()).inMilliseconds;
    return ms <= 0 ? 0 : (ms / 1000).ceil();
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(CodeEntry old) {
    super.didUpdateWidget(old);
    if (old.resendAfter != widget.resendAfter) {
      _remaining = _secondsLeft();
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (_remaining == 0) return;
    _timer = Timer.periodic(SprintExtras.countdownTick, (_) {
      final left = _secondsLeft();
      if (!mounted) return;
      if (left != _remaining) setState(() => _remaining = left);
      if (left == 0) _timer?.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final waiting = _remaining > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.codeEntrySentTo,
          style: context.text.body.copyWith(color: colors.inkMuted),
        ),
        const SizedBox(height: SprintSpacing.space1),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: LtrIsolate(
            child: Text(
              widget.address,
              style: context.text.label.copyWith(color: colors.ink),
            ),
          ),
        ),
        if (widget.demoNotice != null) ...[
          const SizedBox(height: SprintSpacing.space3),
          widget.demoNotice!,
        ],
        const SizedBox(height: SprintSpacing.space4),
        SprintCodeField(
          label: l10n.codeEntryLabel,
          controller: widget.controller,
          focusNode: widget.focusNode,
          error: widget.error,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
        ),
        const SizedBox(height: SprintSpacing.space2),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: SprintButton(
            key: CodeEntry.resendKey,
            label: waiting
                ? l10n.codeEntryResendIn(_remaining)
                : l10n.codeEntryResend,
            variant: SprintButtonVariant.ghost,
            size: SprintButtonSize.sm,
            onPressed: waiting ? null : widget.onResend,
          ),
        ),
      ],
    );
  }
}
