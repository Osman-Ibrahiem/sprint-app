import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/shell/placeholders/no_access_screen.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/features/catalogue/domain/price.dart';
import 'package:sprint/features/identity/domain/verification.dart';
import 'package:sprint/features/notifications/domain/notification.dart' as app;
import 'package:sprint/features/verification/data/in_memory_verification_repository.dart';
import 'package:sprint/features/verification/presentation/sheet_upload_screen.dart';
import 'package:sprint/features/verification/presentation/sheet_upload_summary.dart';
import 'package:sprint/features/verification/presentation/verification_notice.dart';
import 'package:sprint/features/verification/presentation/verification_queue_screen.dart';
import 'package:sprint/features/verification/presentation/verification_request_detail.dart';
import 'package:sprint/features/verification/presentation/verification_slot.dart';

import '../helpers/pump_app.dart';
import '../helpers/sign_up_steps.dart';
import '../helpers/verification_steps.dart';

/// BRD US-05 (FR-VER-02, FR-VER-03, BR-23 – BR-26): a verifier reviews the
/// requests in their scope, approves or rejects with a reason, and uploads
/// the sheet.
void main() {
  late FakeSheetPicker sheets;

  Future<void> start(
    WidgetTester tester, {
    String as = SeedIds.verifier,
  }) async {
    sheets = FakeSheetPicker(text: sampleSheetText());
    await pumpSprintApp(tester, overrides: fakeSheetOverrides(sheets));
    await openReviewerAs(tester, as, '/verification');
  }

  Future<R> run<R extends Object?>(
    WidgetTester tester,
    Future<R> Function() body,
  ) async => (await tester.runAsync(body)) as R;

  InMemoryVerificationRepository repoOf(WidgetTester tester) =>
      containerOf(tester).read(verificationRepositoryProvider)
          as InMemoryVerificationRepository;

  Future<Verification> latest(WidgetTester tester, String userId) async {
    final v = await run(
      tester,
      () =>
          containerOf(tester)
              .read(verificationRepositoryProvider)
              .current(userId),
    );
    return v!;
  }

  Future<List<app.Notification>> notificationsOf(
    WidgetTester tester,
    String userId,
  ) => run(
    tester,
    () => containerOf(tester).read(notificationRepositoryProvider).list(userId),
  );

  Future<void> actAs(WidgetTester tester, String userId, String path) async {
    await openVerificationAs(tester, userId, path: path);
  }

  Future<void> openRequest(WidgetTester tester, String id) async {
    await tester.tap(find.byKey(VerificationQueueScreen.rowKey(id)));
    await tester.pumpAndSettle();
  }

  testWidgets('approve: the person becomes internal and gets a notification', (
    tester,
  ) async {
    await start(tester);
    expect(
      find.byKey(VerificationQueueScreen.rowKey(SeedIds.verUnverified)),
      findsOneWidget,
    );
    await openRequest(tester, SeedIds.verUnverified);
    // A pushed page: the request opens as its own screen on compact.
    expect(find.byKey(VerificationQueueScreen.listKey), findsNothing);
    // The reviewer sees the full national ID here, and only here (FR-033).
    expect(
      tester
          .widget<Text>(find.byKey(VerificationRequestDetail.nationalIdKey))
          .data,
      '30003030300033',
    );

    await tester.tap(find.byKey(VerificationRequestDetail.approveKey));
    await tester.pumpAndSettle();
    expect(find.byKey(VerificationRequestDetail.decidedKey), findsOneWidget);
    expect(find.byKey(VerificationRequestDetail.approveKey), findsNothing);

    final v = await latest(tester, SeedIds.userUnverified);
    expect(v.status, VerificationStatus.approved);
    expect(v.reviewerId, SeedIds.verifier);
    expect(v.expiresAt, isNotNull);
    final tier = await run(
      tester,
      () =>
          containerOf(tester)
              .read(verificationRepositoryProvider)
              .tierFor(SeedIds.userUnverified, DateTime.now()),
    );
    expect(tier, PriceTier.internal);
    expect(
      (await notificationsOf(
        tester,
        SeedIds.userUnverified,
      )).map((n) => n.type),
      contains('verification.approved'),
    );

    // The person sees it on the account card, but the card does not consume
    // it: the centre owns read state (research R5).
    await actAs(tester, SeedIds.userUnverified, '/profile');
    expect(find.byKey(VerificationNotice.noticeKey), findsOneWidget);
    expect(find.textContaining('تم قبول طلب التوثيق'), findsOneWidget);
    expect(find.byKey(VerificationSlot.bodyKey), findsOneWidget);
    final after = await notificationsOf(tester, SeedIds.userUnverified);
    expect(
      after.where((n) => n.type == 'verification.approved').single.readAt,
      isNull,
    );
  });

  testWidgets('reject: a reason is needed and the person sees it', (
    tester,
  ) async {
    await start(tester);
    await openRequest(tester, SeedIds.verUnverified);
    await tester.tap(find.byKey(VerificationRequestDetail.rejectKey));
    await tester.pumpAndSettle();

    TextButton confirm() => tester.widget<TextButton>(
      find.widgetWithText(TextButton, ar.verifRevReasonConfirm),
    );
    expect(confirm().onPressed, isNull);
    await tester.enterText(find.byType(TextField), 'قصير');
    await tester.pump();
    expect(confirm().onPressed, isNull);

    const reason = 'الكود مش مطابق للكشف';
    await tester.enterText(find.byType(TextField), reason);
    await tester.pump();
    expect(confirm().onPressed, isNotNull);
    await tester.tap(find.widgetWithText(TextButton, ar.verifRevReasonConfirm));
    await tester.pumpAndSettle();

    final v = await latest(tester, SeedIds.userUnverified);
    expect(v.status, VerificationStatus.rejected);
    expect(v.reason, reason);

    await actAs(tester, SeedIds.userUnverified, '/profile');
    expect(find.byKey(VerificationNotice.noticeKey), findsOneWidget);
    expect(find.text(ar.verifNoticeRejected(reason)), findsOneWidget);
    expect(find.text(ar.verifReasonLabel(reason)), findsOneWidget);
  });

  testWidgets('a new sheet verifies every matching pending request', (
    tester,
  ) async {
    await start(tester, as: SeedIds.verifier);
    await tester.tap(find.byKey(VerificationQueueScreen.uploadKey));
    await tester.pumpAndSettle();
    expect(find.byKey(SheetUploadScreen.pickKey), findsOneWidget);

    await tester.tap(find.byKey(SheetUploadScreen.pickKey));
    await tester.pumpAndSettle();
    expect(sheets.calls, 1);
    expect(find.byKey(SheetUploadSummary.summaryKey), findsOneWidget);

    final batch = repoOf(tester).allBatches.last;
    expect(batch.fileName, 'sheet.csv');
    expect(batch.approved, 1);
    expect(batch.rowsRead, 4);
    expect(
      (await latest(tester, SeedIds.userUnverified)).status,
      VerificationStatus.approved,
    );
    expect(
      (await latest(tester, SeedIds.userUnverified)).method,
      VerificationMethod.auto,
    );
    expect(
      (await notificationsOf(
        tester,
        SeedIds.userUnverified,
      )).map((n) => n.type),
      contains('verification.approved'),
    );
    // The request outside the verifier's unit is untouched.
    expect(
      (await latest(tester, SeedIds.userEngPending)).status,
      VerificationStatus.pending,
    );
  });

  testWidgets('a request out of scope is hidden and refused by direct link', (
    tester,
  ) async {
    await start(tester);
    expect(
      find.byKey(VerificationQueueScreen.rowKey(SeedIds.verEngPending)),
      findsNothing,
    );
    routerOf(tester).go('/verification/${SeedIds.verEngPending}');
    await tester.pumpAndSettle();
    expect(find.byType(NoAccessScreen), findsOneWidget);
    expect(find.text('30101011100055'), findsNothing);

    final r = await run(
      tester,
      () =>
          containerOf(tester)
              .read(verificationRepositoryProvider)
              .approve(SeedIds.verifier, SeedIds.verEngPending),
    );
    expect((r as Err).failure, isA<NoAccess>());
  });

  testWidgets('a person without the role gets NoAccess on every route', (
    tester,
  ) async {
    await start(tester, as: SeedIds.bookerInternal);
    for (final path in [
      '/verification',
      '/verification/upload',
      '/verification/${SeedIds.verUnverified}',
    ]) {
      routerOf(tester).go(path);
      await tester.pumpAndSettle();
      expect(find.byType(NoAccessScreen), findsOneWidget, reason: path);
      expect(currentPath(tester), path);
    }
  });

  testWidgets('your own request is not yours to decide', (tester) async {
    await start(tester);
    await tester.runAsync(
      () => repoOf(tester).put(
        Verification(
          id: 'ver-own',
          userId: SeedIds.verifier,
          type: VerificationType.staff,
          nationalId: '29001010100019',
          code: 'ST-1',
          owningUnitId: SeedIds.ouPe,
          status: VerificationStatus.pending,
          method: VerificationMethod.manual,
          submittedAt: DateTime.now().toUtc(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Not listed, and a direct link shows no approve or reject.
    expect(find.byKey(VerificationQueueScreen.rowKey('ver-own')), findsNothing);
    routerOf(tester).go('/verification/ver-own');
    await tester.pumpAndSettle();
    expect(find.text(ar.verifRevOwnRequest), findsOneWidget);
    expect(find.byKey(VerificationRequestDetail.approveKey), findsNothing);
    expect(find.byKey(VerificationRequestDetail.rejectKey), findsNothing);

    final r = await run(
      tester,
      () =>
          containerOf(tester)
              .read(verificationRepositoryProvider)
              .approve(SeedIds.verifier, 'ver-own'),
    );
    expect((r as Err).failure, isA<OwnRequest>());
  });

  testWidgets('a request already decided is refused with a message', (
    tester,
  ) async {
    await start(tester);
    routerOf(tester).go('/verification/${SeedIds.verRejected}');
    await tester.pumpAndSettle();
    expect(find.byKey(VerificationRequestDetail.decidedKey), findsOneWidget);
    expect(find.byKey(VerificationRequestDetail.approveKey), findsNothing);

    final r = await run(
      tester,
      () =>
          containerOf(tester)
              .read(verificationRepositoryProvider)
              .approve(SeedIds.verifier, SeedIds.verRejected),
    );
    expect((r as Err).failure, isA<AlreadyDecided>());
  });

  testWidgets(
    'bad columns add nothing and the expected columns are explained',
    (tester) async {
      await start(tester);
      routerOf(tester).go('/verification/upload');
      await tester.pumpAndSettle();
      sheets.text = 'اسم\nمنى';
      final rowsBefore = repoOf(tester).allSheetRows.length;
      final batchesBefore = repoOf(tester).allBatches.length;

      await tester.tap(find.byKey(SheetUploadScreen.pickKey));
      await tester.pumpAndSettle();

      expect(find.text(ar.sheetErrBadColumns), findsOneWidget);
      expect(find.byKey(SheetUploadSummary.summaryKey), findsNothing);
      expect(find.byKey(SheetUploadScreen.helpKey), findsOneWidget);
      expect(repoOf(tester).allSheetRows.length, rowsBefore);
      expect(repoOf(tester).allBatches.length, batchesBefore);
      expect(
        (await latest(tester, SeedIds.userUnverified)).status,
        VerificationStatus.pending,
      );
    },
  );

  testWidgets('a file with no valid rows adds nothing', (tester) async {
    await start(tester);
    routerOf(tester).go('/verification/upload');
    await tester.pumpAndSettle();
    sheets.text = 'national_id,code,type\n123,1,student\n';
    await tester.tap(find.byKey(SheetUploadScreen.pickKey));
    await tester.pumpAndSettle();
    expect(find.text(ar.sheetErrNoRows), findsOneWidget);
    expect(find.byKey(SheetUploadSummary.summaryKey), findsNothing);
  });

  testWidgets('a super admin sees every unit, oldest first', (tester) async {
    await start(tester, as: SeedIds.superAdmin);
    final eng = tester.getTopLeft(
      find.byKey(VerificationQueueScreen.rowKey(SeedIds.verEngPending)),
    );
    final pe = tester.getTopLeft(
      find.byKey(VerificationQueueScreen.rowKey(SeedIds.verUnverified)),
    );
    expect(eng.dy, lessThan(pe.dy));
    await tapText(tester, ar.verifRevUpload);
    expect(find.byKey(SheetUploadScreen.pickKey), findsOneWidget);
  });
}
