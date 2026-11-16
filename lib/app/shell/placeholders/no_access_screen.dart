import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Shown, at the same location, to a signed-in person who lacks the section
/// a route needs: a word and an icon, never a redirect (FR-018,
/// contracts/routes.md rule 2).
class NoAccessScreen extends StatelessWidget {
  const NoAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(SprintSpacing.space6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: SprintSize.iconLg,
                  color: context.colors.inkMuted,
                ),
                const SizedBox(height: SprintSpacing.space3),
                Text(
                  l10n.noAccessTitle,
                  style: context.text.title,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SprintSpacing.space2),
                Text(
                  l10n.noAccessBody,
                  style: context.text.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SprintSpacing.space6),
                FilledButton(
                  onPressed: () => context.go(AppPaths.home),
                  child: Text(l10n.backToHome),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
