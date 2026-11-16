import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/theme/theme_mode_notifier.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/features/identity/domain/verification.dart';
import 'package:sprint/features/verification/domain/verification_state.dart';
import 'package:sprint/features/verification/presentation/verification_slot.dart';
import 'package:sprint/features/verification/presentation/verification_status_badge.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/verification_steps.dart';

/// The verification slot of the Profile account card: each state as a word
/// and an icon, what it means, and its next action (FR-029, FR-030), with the
/// national ID masked (FR-033, NFR-06).
void main() {
  late FakeIdCardSource picker;

  Future<void> profileAs(
    WidgetTester tester,
    String userId, {
    Size size = const Size(400, 800),
    double scale = 1,
  }) async {
    picker = FakeIdCardSource();
    await pumpSprintApp(
      tester,
      size: size,
      textScale: scale,
      overrides: fakePhotoOverrides(picker),
    );
    await openVerificationAs(tester, userId, path: '/profile');
  }

  Finder badgeWord(String word) => find.descendant(
    of: find.byType(VerificationStatusBadge),
    matching: find.text(word),
  );

  Finder badgeIcon(VerificationState s) => find.descendant(
    of: find.byType(VerificationStatusBadge),
    matching: find.byIcon(VerificationStatusBadge.iconOf(s)),
  );

  final states = <(String, String, VerificationState)>[
    ('none', SeedIds.bookerExternal, VerificationState.none),
    ('under review', SeedIds.userUnverified, VerificationState.underReview),
    ('approved', SeedIds.bookerInternal, VerificationState.approved),
    ('rejected', SeedIds.userRejected, VerificationState.rejected),
    ('expired', SeedIds.userExpired, VerificationState.expired),
  ];

  for (final (name, userId, state) in states) {
    testWidgets('$name: a word and an icon, never colour alone', (
      tester,
    ) async {
      await profileAs(tester, userId);
      final word = switch (state) {
        VerificationState.none => ar.verifStatusNone,
        VerificationState.underReview => ar.statusUnderReview,
        VerificationState.approved => ar.statusVerified,
        VerificationState.rejected => ar.statusRejected,
        VerificationState.expired => ar.verifStatusExpired,
      };
      expect(badgeWord(word), findsOneWidget);
      expect(badgeIcon(state), findsOneWidget);
    });
  }

  testWidgets('none: explains the price and offers to request', (tester) async {
    await profileAs(tester, SeedIds.bookerExternal);
    expect(find.text(ar.verifNoneBody), findsOneWidget);
    expect(find.text(ar.verifActionRequest), findsOneWidget);
    final action = find.byKey(VerificationSlot.actionKey);
    await tester.ensureVisible(action);
    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(find.text(ar.verifNationalIdLabel), findsOneWidget);
  });

  testWidgets('under review: waits, with no action', (tester) async {
    await profileAs(tester, SeedIds.userUnverified);
    expect(find.text(ar.verifPendingBody), findsOneWidget);
    expect(find.text(ar.verifActionWait), findsOneWidget);
    expect(find.byKey(VerificationSlot.actionKey), findsNothing);
  });

  testWidgets('approved: shows the expiry date and no action', (tester) async {
    await profileAs(tester, SeedIds.bookerInternal);
    final session = containerOf(tester).read(currentSessionProvider);
    final expires = session.verification!.expiresAt!;
    expect(session.verification!.status, VerificationStatus.approved);
    final body = tester
        .widget<Text>(find.byKey(VerificationSlot.bodyKey))
        .data!;
    expect(body, startsWith('متوثق لحد'));
    expect(body, contains('${expires.toLocal().year}'));
    expect(find.byKey(VerificationSlot.actionKey), findsNothing);
  });

  testWidgets('rejected: shows the reason and offers a new request', (
    tester,
  ) async {
    await profileAs(tester, SeedIds.userRejected);
    final reason = containerOf(tester)
        .read(currentSessionProvider)
        .verification!
        .reason!;
    expect(find.text(ar.verifReasonLabel(reason)), findsOneWidget);
    expect(find.text(ar.verifActionAgain), findsOneWidget);
  });

  testWidgets('expired: says since when and offers to renew', (tester) async {
    await profileAs(tester, SeedIds.userExpired);
    expect(
      tester.widget<Text>(find.byKey(VerificationSlot.bodyKey)).data,
      startsWith('التوثيق انتهى يوم'),
    );
    expect(find.text(ar.verifActionRenew), findsOneWidget);
    final action = find.byKey(VerificationSlot.actionKey);
    await tester.ensureVisible(action);
    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(find.text(ar.verifNationalIdLabel), findsOneWidget);
  });

  testWidgets('the national ID shows its last four digits only', (
    tester,
  ) async {
    await profileAs(tester, SeedIds.userRejected);
    final text = tester
        .widget<Text>(find.byKey(VerificationSlot.nationalIdKey))
        .data!;
    expect(text, contains('**********0066'));
    expect(find.textContaining('29705051400066'), findsNothing);
    expect(find.textContaining('2970505'), findsNothing);
  });

  testWidgets('approval while on Profile updates the slot at once', (
    tester,
  ) async {
    await profileAs(tester, SeedIds.userUnverified);
    expect(badgeWord(ar.statusUnderReview), findsOneWidget);
    final repo = containerOf(tester).read(verificationRepositoryProvider);
    await tester.runAsync(() async {
      await repo.approve(SeedIds.verifier, SeedIds.verUnverified);
    });
    await tester.pumpAndSettle();
    expect(badgeWord(ar.statusVerified), findsOneWidget);
    expect(find.byKey(VerificationSlot.actionKey), findsNothing);
  });

  testWidgets('screen readers hear the status as one phrase', (tester) async {
    final handle = tester.ensureSemantics();
    await profileAs(tester, SeedIds.userRejected);
    expect(
      find.bySemanticsLabel(RegExp(ar.verifCardSpoken(ar.statusRejected))),
      findsWidgets,
    );
    handle.dispose();
  });

  final sizes = {
    'compact': const Size(400, 800),
    'expanded': const Size(1000, 800),
  };
  for (final lang in ['ar', 'en']) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      for (final MapEntry(key: sizeName, value: size) in sizes.entries) {
        for (final scale in [1.0, 2.0]) {
          testWidgets('renders: $lang $mode $sizeName x$scale, no overflow', (
            tester,
          ) async {
            await profileAs(
              tester,
              SeedIds.userRejected,
              size: size,
              scale: scale,
            );
            containerOf(tester)
              ..read(localeProvider.notifier).set(Locale(lang))
              ..read(themeModeProvider.notifier).set(mode);
            await tester.pumpAndSettle();
            final l10n = lookupAppLocalizations(Locale(lang));
            expect(find.text(l10n.verifCardTitle), findsOneWidget);
            expect(find.byType(SprintButton), findsWidgets);
            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  }
}
