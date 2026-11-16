import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/theme/theme_mode_notifier.dart';
import 'package:sprint/features/verification/presentation/sheet_upload_screen.dart';
import 'package:sprint/features/verification/presentation/sheet_upload_summary.dart';
import 'package:sprint/features/verification/presentation/verification_queue_screen.dart';
import 'package:sprint/features/verification/presentation/verification_request_detail.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/sign_up_steps.dart';
import '../../helpers/verification_steps.dart';

/// The reviewer screens: queue order and content, list then detail on compact
/// and side by side from expanded (FR-039), the reject dialog, the upload
/// summary, and the cross-cutting matrix (language, theme, window, text
/// scale) as the sign-in form (FR-031 – FR-039, FR-047, NFR-10).
void main() {
  late FakeSheetPicker sheets;

  Future<void> open(
    WidgetTester tester,
    String path, {
    String userId = SeedIds.superAdmin,
    Size size = const Size(400, 800),
    double scale = 1,
    String? sheet,
  }) async {
    sheets = FakeSheetPicker(text: sheet ?? sampleSheetText());
    await pumpSprintApp(
      tester,
      size: size,
      textScale: scale,
      overrides: fakeSheetOverrides(sheets),
    );
    await openReviewerAs(tester, userId, path);
  }

  testWidgets('the queue lists oldest first with type, unit and waiting time', (
    tester,
  ) async {
    await open(tester, '/verification');
    final eng = find.byKey(
      VerificationQueueScreen.rowKey(SeedIds.verEngPending),
    );
    final pe = find.byKey(
      VerificationQueueScreen.rowKey(SeedIds.verUnverified),
    );
    expect(tester.getTopLeft(eng).dy, lessThan(tester.getTopLeft(pe).dy));

    // Type · unit, how long it waited (2 days and 1 day), how it is priced.
    expect(
      find.descendant(of: eng, matching: find.text('ليلى حسن')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: eng,
        matching: find.text(
          '${ar.verifTypeStudent} · ${unitName(SeedIds.ouEng)}',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: eng, matching: find.text(ar.verifRevWaitDays(2))),
      findsOneWidget,
    );
    expect(
      find.descendant(of: pe, matching: find.text(ar.verifRevWaitDays(1))),
      findsOneWidget,
    );
    expect(
      find.descendant(of: pe, matching: find.text(ar.verifRevPricing)),
      findsOneWidget,
    );
    // The full national ID never shows in the list (FR-033).
    expect(find.textContaining('30003030300033'), findsNothing);
  });

  testWidgets('an empty queue says so', (tester) async {
    await open(tester, '/verification', userId: SeedIds.verifier);
    // The verifier's scope holds one request; decide it from the repository.
    expect(find.byKey(VerificationQueueScreen.listKey), findsOneWidget);
    await tester.tap(
      find.byKey(VerificationQueueScreen.rowKey(SeedIds.verUnverified)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(VerificationRequestDetail.approveKey));
    await tester.pumpAndSettle();
    routerOf(tester).go('/verification');
    await tester.pumpAndSettle();
    expect(find.byKey(VerificationQueueScreen.emptyKey), findsOneWidget);
    expect(find.text(ar.verifRevQueueEmpty), findsOneWidget);
  });

  group('list then detail on compact, side by side from expanded', () {
    testWidgets('compact: a request opens as its own page', (tester) async {
      await open(tester, '/verification');
      await tester.tap(
        find.byKey(VerificationQueueScreen.rowKey(SeedIds.verUnverified)),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(VerificationQueueScreen.detailPaneKey), findsNothing);
      expect(find.byKey(VerificationQueueScreen.listKey), findsNothing);
      expect(
        find.byKey(VerificationRequestDetail.nationalIdKey),
        findsOneWidget,
      );
      // The platform's back returns to the list.
      routerOf(tester).pop();
      await tester.pumpAndSettle();
      expect(find.byKey(VerificationQueueScreen.listKey), findsOneWidget);
    });

    testWidgets('medium stays a list, detail on its own page', (tester) async {
      await open(tester, '/verification', size: const Size(700, 900));
      expect(find.byKey(VerificationQueueScreen.detailPaneKey), findsNothing);
      expect(find.text(ar.verifRevPickPrompt), findsNothing);
    });

    testWidgets('expanded: the list and the request side by side', (
      tester,
    ) async {
      await open(tester, '/verification', size: const Size(1000, 800));
      expect(find.text(ar.verifRevPickPrompt), findsOneWidget);
      await tester.tap(
        find.byKey(VerificationQueueScreen.rowKey(SeedIds.verEngPending)),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(VerificationQueueScreen.listKey), findsOneWidget);
      expect(
        tester
            .widget<Text>(find.byKey(VerificationRequestDetail.nationalIdKey))
            .data,
        '30101011100055',
      );
      // Choosing another request replaces the pane; the list stays.
      await tester.tap(
        find.byKey(VerificationQueueScreen.rowKey(SeedIds.verUnverified)),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Text>(find.byKey(VerificationRequestDetail.nationalIdKey))
            .data,
        '30003030300033',
      );
      expect(find.byKey(VerificationQueueScreen.listKey), findsOneWidget);
    });

    testWidgets('expanded: a deep link opens the list with the request', (
      tester,
    ) async {
      await open(
        tester,
        '/verification/${SeedIds.verUnverified}',
        size: const Size(1000, 800),
      );
      expect(find.byKey(VerificationQueueScreen.listKey), findsOneWidget);
      expect(
        find.byKey(VerificationRequestDetail.nationalIdKey),
        findsOneWidget,
      );
    });

    testWidgets('folding keeps the open request', (tester) async {
      await open(
        tester,
        '/verification/${SeedIds.verUnverified}',
        size: const Size(1000, 800),
      );
      tester.view.physicalSize = const Size(400, 800);
      await tester.pumpAndSettle();
      expect(
        find.byKey(VerificationRequestDetail.nationalIdKey),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('the reject dialog', () {
    testWidgets('keeps confirm off until the reason has 10 characters', (
      tester,
    ) async {
      await open(tester, '/verification/${SeedIds.verUnverified}');
      await tester.tap(find.byKey(VerificationRequestDetail.rejectKey));
      await tester.pumpAndSettle();
      Finder confirm() =>
          find.widgetWithText(TextButton, ar.verifRevReasonConfirm);
      expect(tester.widget<TextButton>(confirm()).onPressed, isNull);
      await tester.enterText(find.byType(TextField), '123456789');
      await tester.pump();
      expect(tester.widget<TextButton>(confirm()).onPressed, isNull);
      await tester.enterText(find.byType(TextField), '1234567890');
      await tester.pump();
      expect(tester.widget<TextButton>(confirm()).onPressed, isNotNull);
      expect(find.text(ar.verifRevReasonHelper), findsOneWidget);
    });

    testWidgets('backing out rejects nothing', (tester) async {
      await open(tester, '/verification/${SeedIds.verUnverified}');
      await tester.tap(find.byKey(VerificationRequestDetail.rejectKey));
      await tester.pumpAndSettle();
      await tapText(tester, ar.verifRevReasonCancel);
      expect(find.byKey(VerificationRequestDetail.rejectKey), findsOneWidget);
      expect(find.byKey(VerificationRequestDetail.decidedKey), findsNothing);
    });
  });

  group('the upload summary', () {
    testWidgets('counts, and the problem rows with their reasons', (
      tester,
    ) async {
      await open(
        tester,
        '/verification/upload',
        sheet:
            'national_id,code,type\n'
            '30003030300033,20220002,student\n'
            '123,20220003,student\n'
            '29311111500099,BAD CODE!,student\n'
            '29902020200022,20230003,teacher\n',
      );
      await tester.tap(find.byKey(SheetUploadScreen.pickKey));
      await tester.pumpAndSettle();
      expect(find.text(ar.sheetSummaryTitle), findsOneWidget);
      for (final label in [
        ar.sheetSummaryRead,
        ar.sheetSummaryAdded,
        ar.sheetSummaryDuplicates,
        ar.sheetSummaryInvalid,
        ar.sheetSummaryApproved,
      ]) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.byKey(SheetUploadSummary.problemsKey), findsOneWidget);
      expect(
        find.text(ar.sheetProblemRow('3', ar.verifErrNationalIdLength)),
        findsOneWidget,
      );
      expect(
        find.text(ar.sheetProblemRow('4', ar.sheetReasonCode)),
        findsOneWidget,
      );
      expect(
        find.text(ar.sheetProblemRow('5', ar.sheetReasonType)),
        findsOneWidget,
      );
      // No national ID from the file is repeated back.
      expect(find.textContaining('29311111500099'), findsNothing);
      // The upload is listed among the earlier ones.
      expect(find.byKey(SheetUploadScreen.batchesKey), findsOneWidget);
      expect(find.text('sheet.csv'), findsOneWidget);
    });

    testWidgets('backing out of the file chooser does nothing', (tester) async {
      await open(tester, '/verification/upload');
      sheets.text = null;
      await tester.tap(find.byKey(SheetUploadScreen.pickKey));
      await tester.pumpAndSettle();
      expect(sheets.calls, 1);
      expect(find.byKey(SheetUploadSummary.summaryKey), findsNothing);
      expect(find.byKey(SheetUploadScreen.errorKey), findsNothing);
    });

    testWidgets('a file that cannot be read says so', (tester) async {
      await open(tester, '/verification/upload');
      sheets.failWith = const FormatException('bad bytes');
      await tester.tap(find.byKey(SheetUploadScreen.pickKey));
      await tester.pumpAndSettle();
      expect(find.text(ar.sheetErrRead), findsOneWidget);
    });

    testWidgets('earlier uploads in scope are listed', (tester) async {
      await open(tester, '/verification/upload', userId: SeedIds.verifier);
      expect(find.byKey(SheetUploadScreen.batchesKey), findsOneWidget);
      expect(find.text('students_pe_seed.csv'), findsOneWidget);
    });
  });

  // The cross-cutting matrix as the sign-in form (T039).
  final sizes = {
    'compact': const Size(400, 800),
    'expanded': const Size(1000, 800),
  };
  final screens = {
    'queue': '/verification',
    'request': '/verification/${SeedIds.verUnverified}',
    'upload': '/verification/upload',
  };
  for (final MapEntry(key: screen, value: path) in screens.entries) {
    for (final lang in ['ar', 'en']) {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        for (final MapEntry(key: sizeName, value: size) in sizes.entries) {
          for (final scale in [1.0, 2.0]) {
            testWidgets('$screen: $lang $mode $sizeName x$scale, no overflow', (
              tester,
            ) async {
              await open(tester, path, size: size, scale: scale);
              containerOf(tester)
                ..read(localeProvider.notifier).set(Locale(lang))
                ..read(themeModeProvider.notifier).set(mode);
              await tester.pumpAndSettle();
              final l10n = lookupAppLocalizations(Locale(lang));
              final marker = switch (screen) {
                'queue' => l10n.verifRevQueueTitle,
                'request' => l10n.verifRevApprove,
                _ => l10n.sheetPick,
              };
              expect(find.text(marker), findsWidgets);
              expect(tester.takeException(), isNull);
            });
          }
        }
      }
    }
  }
}
