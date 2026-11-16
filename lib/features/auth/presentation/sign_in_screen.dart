import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/core/widgets/sprint_text_field/sprint_text_field.dart';
import 'package:sprint/features/auth/presentation/widgets/auth_form_scaffold.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';
import 'package:sprint/core/l10n/sprint_icon.dart';

/// One sign-in form for an email or a mobile number (FR-007 – FR-011,
/// BRD US-03). [from] is the in-app path to return to; the router validates
/// it (contracts/routes.md rule 3) and redirects a signed-in person there as
/// soon as the session changes, so this screen never navigates on success by
/// itself except as a fallback.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({this.from, this.gate = false, super.key});

  final String? from;

  /// Pushed on top of a screen by the account gate: on success it pops with
  /// `true` instead of going to [from] (research R6).
  final bool gate;

  static const errorKey = ValueKey<String>('sign-in-error');

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _identifier.addListener(_onEdit);
    _password.addListener(_onEdit);
  }

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _onEdit() => setState(() {});

  bool get _filled =>
      _identifier.text.trim().isNotEmpty && _password.text.isNotEmpty;

  String _messageFor(Failure failure, AppLocalizations l10n) {
    switch (failure) {
      case BadCredentials():
        return l10n.signInBadCredentials;
      case LockedOut(:final until):
        final left = until.difference(ref.read(appClockProvider).now());
        final minutes = (left.inSeconds / 60).ceil().clamp(1, 1 << 20);
        return l10n.signInLocked(minutes);
      case Suspended():
        return l10n.signInSuspended;
      default:
        return l10n.signInUnexpected;
    }
  }

  Future<void> _submit() async {
    if (_loading || !_filled) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ref
        .read(sessionProvider.notifier)
        .signIn(identifier: _identifier.text.trim(), password: _password.text);
    if (!mounted) return;
    switch (result) {
      case Ok():
        TextInput.finishAutofillContext();
        setState(() => _loading = false);
        if (widget.gate) {
          context.pop(true);
          return;
        }
        // The session change normally redirected already (and unmounted us);
        // going to /sign-in again makes the router pick `from` or Home.
        context.go(AppPaths.keepingFrom(AppPaths.signIn, widget.from));
      case Err(:final failure):
        if (failure is NeedsConfirmation) {
          setState(() => _loading = false);
          final confirmed = await context.push<bool>(
            AppPaths.keepingFrom(
              AppPaths.confirmEmail,
              widget.from,
              email: failure.email,
            ),
            extra: widget.gate ? const GateExtra() : null,
          );
          if (mounted && widget.gate && confirmed == true) context.pop(true);
          return;
        }
        setState(() {
          _loading = false;
          _error = _messageFor(failure, l10n);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return AuthFormScaffold(
      title: l10n.signInTitle,
      primaryLabel: l10n.signInButton,
      loading: _loading,
      onSubmit: _filled ? _submit : null,
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SprintButton(
            label: l10n.signInForgot,
            variant: SprintButtonVariant.ghost,
            onPressed: _loading
                ? null
                : () => context.push(
                    AppPaths.keepingFrom(AppPaths.forgotPassword, widget.from),
                  ),
          ),
          SprintButton(
            label: l10n.signInCreateAccount,
            variant: SprintButtonVariant.secondary,
            onPressed: _loading
                ? null
                : () async {
                    final done = await context.push<bool>(
                      AppPaths.keepingFrom(AppPaths.signUp, widget.from),
                      extra: widget.gate ? const GateExtra() : null,
                    );
                    if (context.mounted && widget.gate && done == true) {
                      context.pop(true);
                    }
                  },
          ),
        ],
      ),
      children: [
        SprintTextField(
          label: l10n.signInIdentifierLabel,
          type: SprintTextFieldType.email,
          controller: _identifier,
          enabled: !_loading,
          autofillHints: const [AutofillHints.username, AutofillHints.email],
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _passwordFocus.requestFocus(),
        ),
        SprintTextField(
          label: l10n.signInPasswordLabel,
          type: SprintTextFieldType.password,
          controller: _password,
          focusNode: _passwordFocus,
          enabled: !_loading,
          autofillHints: const [AutofillHints.password],
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
        ),
        if (_error != null)
          Semantics(
            liveRegion: true,
            container: true,
            child: Container(
              key: SignInScreen.errorKey,
              padding: const EdgeInsetsDirectional.all(SprintSpacing.space3),
              decoration: BoxDecoration(
                color: colors.dangerSoft,
                borderRadius: SprintRadius.mdBorder,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SprintIcon(
                    Icons.error_outline,
                    size: SprintSize.iconMd,
                    color: colors.danger,
                  ),
                  const SizedBox(width: SprintSpacing.space2),
                  Expanded(
                    child: Text(
                      _error!,
                      style: context.text.body.copyWith(color: colors.ink),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
