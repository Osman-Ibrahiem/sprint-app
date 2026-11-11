import 'package:flutter/material.dart';
import 'package:sprint/app/shell/placeholders/placeholder_page.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

class HomePlaceholder extends StatelessWidget {
  const HomePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PlaceholderPage(title: l10n.homeTitle, intro: l10n.homeIntro);
  }
}
