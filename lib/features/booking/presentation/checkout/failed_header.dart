import 'package:flutter/material.dart';
import 'package:sprint/features/booking/presentation/checkout/moment_placeholder.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The failure state's header: the failure moment and, under it, the same
/// checkout (FR-011, US-10). The title is announced once.
class FailedHeader extends StatelessWidget {
  const FailedHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MomentPlaceholder(
      kind: MomentKind.failure,
      title: l10n.checkoutFailedTitle,
      body: l10n.checkoutFailedBody,
      announce: true,
    );
  }
}
