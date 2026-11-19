import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/features/verification/domain/national_id.dart';
import 'package:sprint/features/verification/presentation/verification_slot.dart';

import '../../../helpers/pump_app.dart';

/// FR-023, SC-008, NFR-06: "حسابي" never shows the national ID.
void main() {
  testWidgets('no national ID, masked or not, on the account screen',
      (t) async {
    await pumpSprintApp(t, size: const Size(400, 1600));
    final c = containerOf(t);
    await c.read(sessionProvider.notifier).actAs(SeedIds.bookerInternal);
    routerOf(t).go(AppPaths.profile);
    await t.pumpAndSettle();
    final id = c.read(currentSessionProvider).user!.nationalId;
    expect(find.byKey(VerificationSlot.nationalIdKey), findsNothing);
    if (id != null && id.isNotEmpty) {
      expect(find.textContaining(id), findsNothing);
      expect(find.textContaining(maskNationalId(id)), findsNothing);
    }
  });
}
