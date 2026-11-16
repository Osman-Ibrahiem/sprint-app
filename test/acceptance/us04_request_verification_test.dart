import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/identity/domain/verification.dart';
import 'package:sprint/features/verification/presentation/id_card_photo_picker.dart';
import 'package:sprint/features/verification/presentation/verification_request_screen.dart';
import 'package:sprint/features/verification/presentation/verification_slot.dart';
import 'package:sprint/features/verification/presentation/verification_status_badge.dart';

import '../helpers/pump_app.dart';
import '../helpers/sign_up_steps.dart';
import '../helpers/verification_steps.dart';

/// BRD US-04 (FR-VER-01, FR-VER-04, BR-22 – BR-27): ask for the internal
/// price with a national ID, a code, a unit and a photo.
void main() {
  late FakeIdCardSource picker;

  Session sessionOf(WidgetTester tester) =>
      containerOf(tester).read(currentSessionProvider);

  Future<void> start(WidgetTester tester, String userId) async {
    picker = FakeIdCardSource();
    await pumpSprintApp(tester, overrides: fakePhotoOverrides(picker));
    await openVerificationAs(tester, userId);
  }

  Future<void> fillAndSend(
    WidgetTester tester, {
    required String nationalId,
    required String code,
    String? unitId = SeedIds.ouPe,
    bool photo = true,
  }) async {
    await enterRequestFields(tester, nationalId: nationalId, code: code);
    if (unitId != null) await tapText(tester, unitName(unitId));
    if (photo) await pickIdCardPhoto(tester, ar.verifPhotoGallery);
    await tapText(tester, ar.verifSubmit);
  }

  Future<Verification?> latest(WidgetTester tester, String userId) async {
    final repo = containerOf(tester).read(verificationRepositoryProvider);
    return tester.runAsync<Verification?>(() => repo.current(userId));
  }

  testWidgets('in the sheet: internal at once, with its expiry date', (
    tester,
  ) async {
    await start(tester, SeedIds.bookerExternal);
    expect(sessionOf(tester).tier, PriceTier.external);

    await fillAndSend(tester, nationalId: '29902020200022', code: '20230003');

    expect(find.byKey(VerificationRequestScreen.resultKey), findsOneWidget);
    expect(find.textContaining(ar.statusVerified), findsWidgets);
    expect(find.textContaining('تم التوثيق'), findsOneWidget);
    expect(picker.calls, 1);
    expect(sessionOf(tester).tier, PriceTier.internal);
    final v = (await latest(tester, SeedIds.bookerExternal))!;
    expect(v.status, VerificationStatus.approved);
    expect(v.method, VerificationMethod.auto);
    expect(v.expiresAt, isNotNull);
  });

  testWidgets('not in the sheet: under review and still the full price', (
    tester,
  ) async {
    await start(tester, SeedIds.bookerExternal);
    await fillAndSend(tester, nationalId: '29902020200022', code: '99999999');

    expect(find.text(ar.verifResultPending), findsOneWidget);
    expect(find.text(ar.statusUnderReview), findsWidgets);
    expect(sessionOf(tester).tier, PriceTier.external);
    expect(
      (await latest(tester, SeedIds.bookerExternal))!.status,
      VerificationStatus.pending,
    );
  });

  testWidgets('a national ID on another account: refused with the reason', (
    tester,
  ) async {
    await start(tester, SeedIds.bookerExternal);
    // منى عبد الله already holds this national ID.
    await fillAndSend(tester, nationalId: '29901010100011', code: '20230003');

    expect(find.byKey(VerificationRequestScreen.resultKey), findsOneWidget);
    expect(find.text(ar.statusRejected), findsWidgets);
    expect(
      find.text(ar.verifResultRejected(ar.verifReasonDuplicate)),
      findsOneWidget,
    );
    expect(sessionOf(tester).tier, PriceTier.external);

    // The card repeats the reason and offers a new request.
    await tester.tap(find.byKey(VerificationRequestScreen.doneKey));
    await tester.pumpAndSettle();
    routerOf(tester).go('/profile');
    await tester.pumpAndSettle();
    expect(
      find.text(ar.verifReasonLabel(ar.verifReasonDuplicate)),
      findsOneWidget,
    );
    expect(find.byKey(VerificationSlot.actionKey), findsOneWidget);
  });

  testWidgets('an incomplete form sends nothing and says what is missing', (
    tester,
  ) async {
    await start(tester, SeedIds.bookerExternal);
    await tapText(tester, ar.verifSubmit);

    expect(find.text(ar.verifErrNationalIdEmpty), findsOneWidget);
    expect(find.text(ar.verifErrCodeEmpty), findsOneWidget);
    expect(find.text(ar.verifErrUnitEmpty), findsOneWidget);
    expect(find.text(ar.verifErrPhotoEmpty), findsOneWidget);
    expect(find.byKey(VerificationRequestScreen.resultKey), findsNothing);
    expect(await latest(tester, SeedIds.bookerExternal), isNull);
  });

  testWidgets('rejected, then a new request starts from the old answers', (
    tester,
  ) async {
    await start(tester, SeedIds.userRejected);
    // The code is back; the national ID (FR-033) and the photo are not.
    final fields = find.byType(TextField);
    expect(tester.widget<TextField>(fields.at(0)).controller!.text, isEmpty);
    expect(tester.widget<TextField>(fields.at(1)).controller!.text, '20190066');
    expect(find.textContaining('29705051400066'), findsNothing);
    expect(find.byKey(IdCardPhotoPicker.previewKey), findsNothing);
    expect(find.text(ar.verifRenewTitle), findsNothing);

    await tapText(tester, ar.verifSubmit);
    expect(find.text(ar.verifErrNationalIdEmpty), findsOneWidget);
    expect(find.text(ar.verifErrPhotoEmpty), findsOneWidget);

    await enterRequestFields(tester, nationalId: '29705051400066');
    await pickIdCardPhoto(tester, ar.verifPhotoGallery);
    await tapText(tester, ar.verifSubmit);
    expect(find.text(ar.verifResultPending), findsOneWidget);
    expect(
      (await latest(tester, SeedIds.userRejected))!.status,
      VerificationStatus.pending,
    );
  });

  testWidgets('expired, then renewing goes through the rules again', (
    tester,
  ) async {
    await start(tester, SeedIds.userExpired);
    expect(sessionOf(tester).tier, PriceTier.external);
    // The title and the button both say "تجديد التوثيق".
    expect(find.text(ar.verifRenewTitle), findsNWidgets(2));
    expect(find.byKey(IdCardPhotoPicker.previewKey), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField).at(0)).controller!.text,
      isEmpty,
    );

    await enterRequestFields(tester, nationalId: '29804040400044');
    await pickIdCardPhoto(tester, ar.verifPhotoGallery);
    final send = find.byType(SprintButton).last;
    await tester.ensureVisible(send);
    await tester.tap(send);
    await tester.pumpAndSettle();
    expect(find.byKey(VerificationRequestScreen.resultKey), findsOneWidget);
    expect(
      (await latest(tester, SeedIds.userExpired))!.status,
      VerificationStatus.pending,
    );
  });

  testWidgets('no second request while one is under review', (tester) async {
    await start(tester, SeedIds.userUnverified);
    // The screen shows the waiting request instead of a form.
    expect(find.byType(TextField), findsNothing);
    expect(find.text(ar.verifAlreadyPending), findsOneWidget);
    expect(find.byType(VerificationStatusBadge), findsOneWidget);

    final result = await tester.runAsync(
      () => containerOf(tester)
          .read(verificationRepositoryProvider)
          .submit(
            userId: SeedIds.userUnverified,
            type: VerificationType.student,
            nationalId: '30003030300033',
            code: '20220002',
            owningUnitId: SeedIds.ouPe,
            photo: picker.bytes!,
          ),
    );
    expect(result, isA<Err<Verification>>());
    expect((result! as Err<Verification>).failure, isA<AlreadyPending>());

    routerOf(tester).go('/profile');
    await tester.pumpAndSettle();
    expect(find.byKey(VerificationSlot.actionKey), findsNothing);
    expect(find.text(ar.verifActionWait), findsOneWidget);
  });

  testWidgets('a guest opening the link is sent to sign in first', (
    tester,
  ) async {
    picker = FakeIdCardSource();
    await pumpSprintApp(tester, overrides: fakePhotoOverrides(picker));
    routerOf(tester).go('/profile/verification');
    await tester.pumpAndSettle();
    expect(currentPath(tester), '/sign-in');
    expect(find.byType(SprintButton), findsWidgets);
  });
}
