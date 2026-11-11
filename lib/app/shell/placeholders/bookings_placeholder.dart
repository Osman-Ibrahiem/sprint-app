import 'package:flutter/material.dart';
import 'package:sprint/app/shell/placeholders/placeholder_page.dart';
import 'package:sprint/app/shell/placeholders/sign_in_prompt.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

class BookingsPlaceholder extends StatelessWidget {
  const BookingsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(
      title: AppLocalizations.of(context).navBookings,
      leading: const [SizedBox(height: SprintSpacing.space4), SignInPrompt()],
      showNote: false,
      blocks: 0,
    );
  }
}
