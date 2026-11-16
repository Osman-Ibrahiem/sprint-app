import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/core/widgets/sprint_text_field/sprint_text_field.dart';
import 'package:sprint/features/auth/domain/validators.dart';
import 'package:sprint/features/auth/presentation/widgets/auth_form_scaffold.dart';
import 'package:sprint/features/auth/presentation/widgets/validation_messages.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Create an account with name, mobile number, email and password (FR-001 –
/// FR-003, BRD US-02). Each field is checked when the person leaves it and
/// again on submit; every problem shows next to its field in words. A good
/// submit sends the code and opens `/confirm-email`, keeping [from].
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({this.from, super.key});

  final String? from;

  static const takenKey = ValueKey<String>('sign-up-taken');
  static const takenSignInKey = ValueKey<String>('sign-up-taken-sign-in');
  static const takenResetKey = ValueKey<String>('sign-up-taken-reset');

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

enum _Field { name, phone, email, password }

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _controllers = {
    for (final f in _Field.values) f: TextEditingController(),
  };
  final _focus = {for (final f in _Field.values) f: FocusNode()};
  final _errors = <_Field, String>{};
  bool _loading = false;
  bool _taken = false;
  String? _unexpected;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final n in _focus.values) {
      n.dispose();
    }
    super.dispose();
  }

  String _text(_Field f) => _controllers[f]!.text;

  /// The message for [f], or null when it is valid.
  String? _check(_Field f, AppLocalizations l10n) => switch (f) {
    _Field.name => switch (validateName(_text(f))) {
      Invalid(:final reason) => nameMessage(l10n, reason),
      _ => null,
    },
    _Field.phone => switch (normalizePhone(_text(f))) {
      Invalid(:final reason) => phoneMessage(l10n, reason),
      _ => null,
    },
    _Field.email => switch (normalizeEmail(_text(f))) {
      Invalid(:final reason) => emailMessage(l10n, reason),
      _ => null,
    },
    _Field.password => switch (validatePassword(_text(f))) {
      Invalid(:final reason) => passwordMessage(l10n, reason),
      _ => null,
    },
  };

  void _leave(_Field f) {
    // Leaving an untouched field is not a mistake yet.
    if (_text(f).isEmpty && !_errors.containsKey(f)) return;
    final message = _check(f, AppLocalizations.of(context));
    setState(() {
      if (message == null) {
        _errors.remove(f);
      } else {
        _errors[f] = message;
      }
    });
  }

  void _edited(_Field f) {
    if (_errors.containsKey(f) || _taken || _unexpected != null) {
      setState(() {
        _errors.remove(f);
        if (f == _Field.email || f == _Field.phone) _taken = false;
        _unexpected = null;
      });
    }
  }

  Future<void> _submit() async {
    if (_loading) return;
    final l10n = AppLocalizations.of(context);
    final found = <_Field, String>{};
    for (final f in _Field.values) {
      final m = _check(f, l10n);
      if (m != null) found[f] = m;
    }
    if (found.isNotEmpty) {
      setState(() {
        _errors
          ..clear()
          ..addAll(found);
        _taken = false;
      });
      _focus[found.keys.first]!.requestFocus();
      return;
    }
    setState(() {
      _loading = true;
      _errors.clear();
      _taken = false;
      _unexpected = null;
    });
    final result = await ref
        .read(authRepositoryProvider)
        .signUp(
          name: _text(_Field.name),
          phone: _text(_Field.phone),
          email: _text(_Field.email),
          password: _text(_Field.password),
        );
    if (!mounted) return;
    switch (result) {
      case Ok(:final value):
        TextInput.finishAutofillContext();
        setState(() => _loading = false);
        context.push(
          AppPaths.keepingFrom(
            AppPaths.confirmEmail,
            widget.from,
            email: value.email,
          ),
        );
      case Err(:final failure):
        setState(() {
          _loading = false;
          switch (failure) {
            case EmailTaken():
              _errors[_Field.email] = l10n.signUpEmailTaken;
              _taken = true;
            case PhoneTaken():
              _errors[_Field.phone] = l10n.signUpPhoneTaken;
              _taken = true;
            case InvalidField(:final field, :final reason):
              final f = _Field.values.where((e) => e.name == field).firstOrNull;
              final m = invalidFieldMessage(l10n, field, reason);
              if (f != null && m != null) {
                _errors[f] = m;
              } else {
                _unexpected = l10n.signInUnexpected;
              }
            default:
              _unexpected = l10n.signInUnexpected;
          }
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;

    Widget field(
      _Field f, {
      required String label,
      required String helper,
      required SprintTextFieldType type,
      required Iterable<String> hints,
      bool last = false,
    }) => SprintTextField(
      label: label,
      helper: helper,
      error: _errors[f],
      type: type,
      controller: _controllers[f],
      focusNode: _focus[f],
      enabled: !_loading,
      autofillHints: hints,
      textInputAction: last ? TextInputAction.done : TextInputAction.next,
      onChanged: (_) => _edited(f),
      onLeave: () => _leave(f),
      onSubmitted: (_) =>
          last ? _submit() : _focus[_Field.values[f.index + 1]]!.requestFocus(),
    );

    return AuthFormScaffold(
      title: l10n.signUpTitle,
      primaryLabel: l10n.signUpButton,
      loading: _loading,
      onSubmit: _submit,
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_unexpected != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(
                bottom: SprintSpacing.space3,
              ),
              child: Semantics(
                liveRegion: true,
                container: true,
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: SprintSize.iconMd,
                      color: colors.danger,
                    ),
                    const SizedBox(width: SprintSpacing.space2),
                    Expanded(
                      child: Text(
                        _unexpected!,
                        style: context.text.body.copyWith(color: colors.ink),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_taken)
            Container(
              key: SignUpScreen.takenKey,
              margin: const EdgeInsetsDirectional.only(
                bottom: SprintSpacing.space3,
              ),
              padding: const EdgeInsetsDirectional.all(SprintSpacing.space3),
              decoration: BoxDecoration(
                color: colors.warningSoft,
                borderRadius: SprintRadius.mdBorder,
              ),
              child: Semantics(
                liveRegion: true,
                container: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.signUpTakenActions,
                      style: context.text.body.copyWith(color: colors.ink),
                    ),
                    SprintButton(
                      key: SignUpScreen.takenSignInKey,
                      label: l10n.signInButton,
                      variant: SprintButtonVariant.ghost,
                      onPressed: () => context.pushReplacement(
                        AppPaths.keepingFrom(AppPaths.signIn, widget.from),
                      ),
                    ),
                    SprintButton(
                      key: SignUpScreen.takenResetKey,
                      label: l10n.signInForgot,
                      variant: SprintButtonVariant.ghost,
                      onPressed: () => context.push(
                        AppPaths.keepingFrom(
                          AppPaths.forgotPassword,
                          widget.from,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Text(
            l10n.signUpAlreadyHave,
            textAlign: TextAlign.center,
            style: context.text.body.copyWith(color: colors.inkMuted),
          ),
          SprintButton(
            label: l10n.signInButton,
            variant: SprintButtonVariant.ghost,
            onPressed: _loading
                ? null
                : () => context.pushReplacement(
                    AppPaths.keepingFrom(AppPaths.signIn, widget.from),
                  ),
          ),
        ],
      ),
      children: [
        field(
          _Field.name,
          label: l10n.signUpNameLabel,
          helper: l10n.signUpNameHelper,
          type: SprintTextFieldType.text,
          hints: const [AutofillHints.name],
        ),
        field(
          _Field.phone,
          label: l10n.signUpPhoneLabel,
          helper: l10n.signUpPhoneHelper,
          type: SprintTextFieldType.phone,
          hints: const [AutofillHints.telephoneNumber],
        ),
        field(
          _Field.email,
          label: l10n.signUpEmailLabel,
          helper: l10n.signUpEmailHelper,
          type: SprintTextFieldType.email,
          hints: const [AutofillHints.email],
        ),
        field(
          _Field.password,
          label: l10n.signUpPasswordLabel,
          helper: l10n.signUpPasswordHelper,
          type: SprintTextFieldType.password,
          hints: const [AutofillHints.newPassword],
          last: true,
        ),
      ],
    );
  }
}
