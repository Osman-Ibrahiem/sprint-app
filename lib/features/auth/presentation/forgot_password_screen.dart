import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_text_field/sprint_text_field.dart';
import 'package:sprint/features/auth/presentation/widgets/auth_form_scaffold.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Asks for a password reset code by email or mobile number (US-04,
/// FR-020, FR-021). The answer is the same whether or not the account
/// exists: the next screen always opens.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({this.from, super.key});

  final String? from;

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _identifier = TextEditingController();
  bool _loading = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _identifier.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _identifier.dispose();
    super.dispose();
  }

  bool get _filled => _identifier.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (_loading || !_filled) return;
    setState(() {
      _loading = true;
      _failed = false;
    });
    final identifier = _identifier.text.trim();
    final result = await ref
        .read(authRepositoryProvider)
        .requestPasswordReset(identifier);
    if (!mounted) return;
    final now = ref.read(appClockProvider).now();
    final DateTime? resendAfter = switch (result) {
      Ok(:final value) => value.resendAfter,
      // A code is already out; the screen after this one shows the wait.
      Err(failure: ResendTooSoon(:final wait)) => now.add(wait),
      Err() => null,
    };
    if (resendAfter == null) {
      setState(() {
        _loading = false;
        _failed = true;
      });
      return;
    }
    TextInput.finishAutofillContext();
    setState(() => _loading = false);
    context.push(
      AppPaths.resetFor(identifier, widget.from),
      extra: resendAfter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    return AuthFormScaffold(
      title: l10n.forgotTitle,
      primaryLabel: l10n.forgotSendButton,
      loading: _loading,
      onSubmit: _filled ? _submit : null,
      children: [
        Text(
          l10n.forgotIntro,
          style: context.text.body.copyWith(color: colors.inkMuted),
        ),
        SprintTextField(
          label: l10n.signInIdentifierLabel,
          type: SprintTextFieldType.email,
          controller: _identifier,
          enabled: !_loading,
          autofillHints: const [AutofillHints.username, AutofillHints.email],
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
        ),
        if (_failed)
          Semantics(
            liveRegion: true,
            container: true,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                top: SprintSpacing.space1,
              ),
              child: Text(
                l10n.signInUnexpected,
                style: context.text.body.copyWith(color: colors.danger),
              ),
            ),
          ),
      ],
    );
  }
}
