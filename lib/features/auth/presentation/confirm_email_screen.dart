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
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/features/auth/domain/auth_limits.dart';
import 'package:sprint/features/auth/domain/email_code.dart';
import 'package:sprint/features/auth/presentation/widgets/auth_form_scaffold.dart';
import 'package:sprint/features/auth/presentation/widgets/code_entry.dart';
import 'package:sprint/features/auth/presentation/widgets/demo_code_notice.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The 6-digit code step of sign up (FR-001, FR-005, FR-006, BRD US-02), also
/// reached from sign in with an unconfirmed account. A right code creates the
/// session and goes to [from] or Home; every failure says what happened and
/// what is possible next.
class ConfirmEmailScreen extends ConsumerStatefulWidget {
  const ConfirmEmailScreen({required this.email, this.from, super.key});

  final String email;
  final String? from;

  static const statusKey = ValueKey<String>('confirm-email-status');

  @override
  ConsumerState<ConfirmEmailScreen> createState() => _ConfirmEmailScreenState();
}

class _ConfirmEmailScreenState extends ConsumerState<ConfirmEmailScreen> {
  final _code = TextEditingController();
  late DateTime _resendAfter = ref
      .read(appClockProvider)
      .now()
      .add(AuthLimits.resendWait);
  bool _loading = false;
  String? _error;
  String? _status;

  @override
  void initState() {
    super.initState();
    _code.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  bool get _complete => _code.text.length == AuthLimits.codeLength;

  String _messageFor(Failure failure, AppLocalizations l10n) =>
      switch (failure) {
        CodeWrong(:final triesLeft) => l10n.confirmCodeWrong(triesLeft),
        CodeExpired() => l10n.confirmCodeExpired,
        CodeDead() => l10n.confirmCodeDead,
        NoPendingConfirmation() => l10n.confirmNoPending,
        _ => l10n.signInUnexpected,
      };

  Future<void> _confirm() async {
    if (_loading) return;
    final l10n = AppLocalizations.of(context);
    if (!_complete) {
      setState(() {
        _status = null;
        _error = l10n.confirmCodeEmpty;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _status = null;
    });
    final result = await ref
        .read(authRepositoryProvider)
        .confirmEmail(email: widget.email, code: _code.text);
    if (!mounted) return;
    switch (result) {
      case Ok():
        await ref.read(sessionProvider.notifier).refresh();
        if (!mounted) return;
        TextInput.finishAutofillContext();
        setState(() => _loading = false);
        // The router sends a signed-in person from an auth route to `from`
        // (validated) or Home, and drops the confirmation page off the stack.
        context.go(AppPaths.keepingFrom(AppPaths.signIn, widget.from));
      case Err(:final failure):
        setState(() {
          _loading = false;
          _error = _messageFor(failure, l10n);
        });
    }
  }

  Future<void> _resend() async {
    final l10n = AppLocalizations.of(context);
    final result = await ref
        .read(authRepositoryProvider)
        .resendCode(email: widget.email, purpose: CodePurpose.confirmEmail);
    if (!mounted) return;
    setState(() {
      switch (result) {
        case Ok(:final value):
          _resendAfter = value.resendAfter;
          _code.clear();
          _error = null;
          _status = l10n.confirmResent;
        case Err(:final failure):
          if (failure is ResendTooSoon) {
            _resendAfter = ref.read(appClockProvider).now().add(failure.wait);
            _error = l10n.confirmResendTooSoon(failure.wait.inSeconds + 1);
          } else {
            _error = l10n.signInUnexpected;
          }
          _status = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final hasMailbox = ref.watch(simulatedMailboxProvider) != null;
    return AuthFormScaffold(
      title: l10n.confirmEmailTitle,
      primaryLabel: l10n.confirmEmailButton,
      loading: _loading,
      onSubmit: _confirm,
      children: [
        CodeEntry(
          address: widget.email,
          resendAfter: _resendAfter,
          now: ref.read(appClockProvider).now,
          onResend: _resend,
          controller: _code,
          error: _error,
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          onSubmitted: (_) => _confirm(),
          demoNotice: hasMailbox
              ? DemoCodeNotice(
                  email: widget.email,
                  purpose: CodePurpose.confirmEmail,
                )
              : null,
        ),
        if (_status != null)
          Semantics(
            liveRegion: true,
            container: true,
            child: Row(
              key: ConfirmEmailScreen.statusKey,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: SprintSize.iconMd,
                  color: colors.success,
                ),
                const SizedBox(width: SprintSpacing.space2),
                Expanded(
                  child: Text(
                    _status!,
                    style: context.text.body.copyWith(color: colors.ink),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
