import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/adaptive/adaptive_sheet.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// What the person chose in the gate prompt.
enum AccountGateChoice { signIn, signUp }

/// The one reusable account gate (FR-016 – FR-019, research R6).
///
/// For a signed-in person it returns `true` at once. For a guest it shows
/// [AccountGatePrompt] naming [reason] (an already localised phrase such as
/// "عشان تحجز"), then pushes `/sign-in` or `/sign-up` on top of the current
/// screen and waits. The screen underneath is never popped, so its state is
/// kept. Returns `true` when the person ended up signed in, `false` when the
/// prompt or the auth screens were dismissed.
///
/// The gate never runs the action itself: the caller shows it ready to
/// continue and waits for a new tap (FR-017).
Future<bool> requireAccount(
  BuildContext context,
  WidgetRef ref,
  String reason,
) async {
  if (!ref.read(currentSessionProvider).isGuest) return true;
  final choice = await showSprintSheet<AccountGateChoice>(
    context: context,
    builder: (ctx) => AccountGatePrompt(
      reason: reason,
      onChoose: (c) => Navigator.of(ctx).pop(c),
      onDismiss: () => Navigator.of(ctx).pop(),
    ),
  );
  if (choice == null || !context.mounted) return false;
  final router = GoRouter.of(context);
  // `from` is the place the gate was opened on, so any fallback in the auth
  // flow (for example a password reset) still lands back here.
  final here = router.routerDelegate.currentConfiguration.uri.toString();
  final path = switch (choice) {
    AccountGateChoice.signIn => AppPaths.signIn,
    AccountGateChoice.signUp => AppPaths.signUp,
  };
  final done = await router.push<bool>(
    AppPaths.keepingFrom(path, here),
    extra: const GateExtra(),
  );
  return done == true;
}

/// The gate's content: icon, title, what needs an account, the two choices and
/// a way out. Shown in a platform sheet or dialog by [requireAccount].
class AccountGatePrompt extends StatelessWidget {
  const AccountGatePrompt({
    required this.reason,
    required this.onChoose,
    required this.onDismiss,
    super.key,
  });

  final String reason;
  final ValueChanged<AccountGateChoice> onChoose;
  final VoidCallback onDismiss;

  static const signInKey = ValueKey<String>('gate-sign-in');
  static const signUpKey = ValueKey<String>('gate-sign-up');
  static const dismissKey = ValueKey<String>('gate-dismiss');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final content = SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(SprintSpacing.space5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.lock_outline,
              size: SprintSize.iconLg,
              color: colors.ink,
            ),
            const SizedBox(height: SprintSpacing.space3),
            Semantics(
              header: true,
              child: Text(
                l10n.gateTitle,
                textAlign: TextAlign.center,
                style: context.text.title,
              ),
            ),
            const SizedBox(height: SprintSpacing.space2),
            Text(
              l10n.gateBody(reason),
              textAlign: TextAlign.center,
              style: context.text.body.copyWith(color: colors.inkMuted),
            ),
            const SizedBox(height: SprintSpacing.space5),
            SprintButton(
              key: signInKey,
              label: l10n.gateSignIn,
              onPressed: () => onChoose(AccountGateChoice.signIn),
            ),
            const SizedBox(height: SprintSpacing.space2),
            SprintButton(
              key: signUpKey,
              label: l10n.gateSignUp,
              variant: SprintButtonVariant.secondary,
              onPressed: () => onChoose(AccountGateChoice.signUp),
            ),
            const SizedBox(height: SprintSpacing.space1),
            SprintButton(
              key: dismissKey,
              label: l10n.gateDismiss,
              variant: SprintButtonVariant.ghost,
              onPressed: onDismiss,
            ),
          ],
        ),
      ),
    );
    return SprintSheetSurface(child: content);
  }
}
