import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_text_field/sprint_text_field.dart';
import 'package:sprint/features/auth/domain/auth_limits.dart';
import 'package:sprint/features/auth/domain/validators.dart';
import 'package:sprint/features/auth/presentation/widgets/auth_form_scaffold.dart';
import 'package:sprint/features/auth/presentation/widgets/code_entry.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The emailed code plus the new password (US-04, FR-022). On success the
/// person is signed in and sent to [from] or Home.
///
/// [resendAfter] comes from the request screen; opened without it (a deep
/// link) a new code can be asked for at once.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({
    required this.identifier,
    this.from,
    this.resendAfter,
    super.key,
  });

  final String identifier;
  final String? from;
  final DateTime? resendAfter;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();
  late DateTime _resendAfter =
      widget.resendAfter ?? ref.read(appClockProvider).now();
  bool _loading = false;
  String? _codeError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _code.addListener(_onEdit);
    _password.addListener(_onEdit);
  }

  @override
  void dispose() {
    _code.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _onEdit() => setState(() {});

  bool get _filled =>
      _code.text.length == AuthLimits.codeLength && _password.text.isNotEmpty;

  String _passwordMessage(String reason, AppLocalizations l10n) =>
      switch (reason) {
        'tooShort' => l10n.resetPasswordTooShort,
        'needsLetter' => l10n.resetPasswordNeedsLetter,
        'needsDigit' => l10n.resetPasswordNeedsDigit,
        _ => l10n.resetPasswordEmpty,
      };

  Future<void> _submit() async {
    if (_loading || !_filled) return;
    final l10n = AppLocalizations.of(context);
    final check = validatePassword(_password.text);
    if (check case Invalid(:final reason)) {
      setState(() {
        _codeError = null;
        _passwordError = _passwordMessage(reason.name, l10n);
      });
      return;
    }
    setState(() {
      _loading = true;
      _codeError = null;
      _passwordError = null;
    });
    final result = await ref
        .read(authRepositoryProvider)
        .resetPassword(
          identifier: widget.identifier,
          code: _code.text,
          newPassword: _password.text,
        );
    if (!mounted) return;
    switch (result) {
      case Ok():
        TextInput.finishAutofillContext();
        await ref.read(sessionProvider.notifier).refresh();
        if (!mounted) return;
        setState(() => _loading = false);
        // The router checks `from` and falls back to Home.
        context.go(AppPaths.keepingFrom(AppPaths.signIn, widget.from));
      case Err(:final failure):
        setState(() {
          _loading = false;
          switch (failure) {
            case CodeWrong(:final triesLeft):
              _codeError = l10n.resetCodeWrong(triesLeft);
            case CodeExpired():
              _codeError = l10n.resetCodeExpired;
            case CodeDead():
              _codeError = l10n.resetCodeDead;
            case InvalidField(:final reason):
              _passwordError = _passwordMessage(reason, l10n);
            default:
              _codeError = l10n.signInUnexpected;
          }
        });
    }
  }

  Future<void> _resend() async {
    final l10n = AppLocalizations.of(context);
    final result = await ref
        .read(authRepositoryProvider)
        .requestPasswordReset(widget.identifier);
    if (!mounted) return;
    final now = ref.read(appClockProvider).now();
    setState(() {
      switch (result) {
        case Ok(:final value):
          _resendAfter = value.resendAfter;
          _codeError = null;
        case Err(failure: ResendTooSoon(:final wait)):
          _resendAfter = now.add(wait);
          _codeError = l10n.resetResendTooSoon(
            (wait.inMilliseconds / 1000).ceil(),
          );
        case Err():
          _codeError = l10n.signInUnexpected;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return AuthFormScaffold(
      title: l10n.resetTitle,
      primaryLabel: l10n.resetSaveButton,
      loading: _loading,
      onSubmit: _filled ? _submit : null,
      children: [
        Text(
          l10n.resetSentNeutral,
          style: context.text.body.copyWith(color: colors.inkMuted),
        ),
        CodeEntry(
          address: widget.identifier,
          resendAfter: _resendAfter,
          onResend: _resend,
          controller: _code,
          error: _codeError,
          now: ref.read(appClockProvider).now,
          onSubmitted: (_) => _passwordFocus.requestFocus(),
        ),
        SprintTextField(
          label: l10n.resetNewPasswordLabel,
          helper: l10n.resetPasswordHint,
          error: _passwordError,
          type: SprintTextFieldType.password,
          controller: _password,
          focusNode: _passwordFocus,
          enabled: !_loading,
          autofillHints: const [AutofillHints.newPassword],
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: SprintSpacing.space1),
      ],
    );
  }
}
