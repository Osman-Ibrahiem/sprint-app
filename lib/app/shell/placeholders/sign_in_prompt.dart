import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/features/auth/presentation/account_gate.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// What a guest sees on My Bookings and Profile: a word and an icon, with
/// "تسجيل الدخول" and "إنشاء حساب" that open the account gate. No redirect, so
/// deep links stay stable (contracts/routes.md rule 3, FR-019). [reason] is
/// the localised phrase the gate shows; it defaults to the bookings one.
class SignInPrompt extends ConsumerWidget {
  const SignInPrompt({this.reason, super.key});

  final String? reason;

  static const signInKey = ValueKey<String>('prompt-sign-in');
  static const signUpKey = ValueKey<String>('prompt-sign-up');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final why = reason ?? l10n.gateReasonBookings;
    return Container(
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: SprintRadius.lgBorder,
        border: Border.all(color: colors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lock_outline,
                size: SprintSize.iconLg,
                color: colors.ink,
              ),
              const SizedBox(width: SprintSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.signInPromptTitle, style: context.text.headline),
                    const SizedBox(height: SprintSpacing.space1),
                    Text(l10n.signInPromptBody, style: context.text.body),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SprintSpacing.space4),
          SprintButton(
            key: signInKey,
            label: l10n.gateSignIn,
            onPressed: () => requireAccount(context, ref, why),
          ),
          const SizedBox(height: SprintSpacing.space2),
          SprintButton(
            key: signUpKey,
            label: l10n.gateSignUp,
            variant: SprintButtonVariant.secondary,
            onPressed: () => requireAccount(context, ref, why),
          ),
        ],
      ),
    );
  }
}
