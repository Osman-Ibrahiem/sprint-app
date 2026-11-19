import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// "إيصال الدفع" for any booking with a succeeded payment (R10, FR-PAY-04),
/// whatever its status now.
class ReceiptLink extends StatelessWidget {
  const ReceiptLink({required this.bookingId, super.key});

  final String bookingId;

  static const key0 = ValueKey<String>('details-receipt');

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: SprintButton(
      key: key0,
      label: AppLocalizations.of(context).bookingDetailsReceipt,
      variant: SprintButtonVariant.secondary,
      icon: const SprintButtonIcon(PhosphorIconsRegular.receipt),
      onPressed: () => context.go(AppPaths.bookingReceipt(bookingId)),
    ),
  );
}
