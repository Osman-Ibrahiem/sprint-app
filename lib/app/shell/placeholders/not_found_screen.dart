import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Shown for any unknown route, with a way back to Home (FR-008).
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

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
                  Icons.explore_off_outlined,
                  size: SprintSize.iconLg,
                  color: context.colors.inkMuted,
                ),
                const SizedBox(height: SprintSpacing.space3),
                Text(
                  l10n.notFoundTitle,
                  style: context.text.title,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SprintSpacing.space2),
                Text(
                  l10n.notFoundBody,
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
