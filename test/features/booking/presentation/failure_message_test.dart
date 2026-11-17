import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/features/booking/domain/schedule_notice.dart';
import 'package:sprint/features/booking/presentation/schedule/schedule_notice_view.dart';
import 'package:sprint/features/booking/presentation/widgets/failure_message.dart';
import 'package:sprint/core/theme/sprint_theme.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

import '../../../helpers/domain_builders.dart';

/// Every refusal has words (FR-032, SC-009).
void main() {
  final seven = cairo(2026, 11, 17, 19);

  Future<BuildContext> pumpContext(WidgetTester tester, String lang) async {
    late BuildContext captured;
    await tester.pumpWidget(
      MaterialApp(
        locale: Locale(lang),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: SprintTheme.light,
        home: Builder(
          builder: (c) {
            captured = c;
            return const SizedBox();
          },
        ),
      ),
    );
    return captured;
  }

  final cases = <String, Failure>{
    'taken': const SlotTaken(),
    'taken at': SlotTaken(at: seven),
    'full': const SlotFull(),
    'full at': SlotFull(at: seven),
    'past': const SlotPast(),
    'window': const OutsideWindow(),
    'closed': const ClosedSlot(),
    'closed at': ClosedSlot(at: seven),
    'range': const RangeTooLong(maxHours: 3),
    'range generic': const RangeTooLong(),
    'overlap': const OverlapsOwnBooking(),
    'cap': const TooManyActiveBookings(max: 2),
    'cap generic': const TooManyActiveBookings(),
    'not permitted': const NotPermitted(),
    'not found': const NotFound('unit'),
    'anything else': const HoldExpired(),
  };

  for (final lang in ['ar', 'en']) {
    for (final e in cases.entries) {
      testWidgets('$lang: ${e.key} has words, never a technical text', (
        tester,
      ) async {
        final context = await pumpContext(tester, lang);
        final text = bookingFailureMessage(context, e.value);
        expect(text.trim(), isNotEmpty);
        expect(text, isNot(contains('Instance of')));
        expect(text, isNot(contains('{')));
        expect(
          RegExp('[٠-٩]').hasMatch(text),
          isFalse,
          reason: 'Western digits',
        );
      });
    }
  }

  testWidgets('names the conflicting hour, the maximum and the cap', (
    tester,
  ) async {
    final c = await pumpContext(tester, 'ar');
    expect(bookingFailureMessage(c, SlotTaken(at: seven)), contains('7:00'));
    expect(
      bookingFailureMessage(c, const RangeTooLong(maxHours: 3)),
      contains('3'),
    );
    expect(
      bookingFailureMessage(c, const TooManyActiveBookings(max: 2)),
      contains('حجزين'),
    );
  });

  testWidgets('an overlap names the other booking\'s facility and time', (
    tester,
  ) async {
    final c = await pumpContext(tester, 'ar');
    final text = bookingFailureMessage(
      c,
      const OverlapsOwnBooking(bookingId: 'x'),
      overlap: OverlapInfo(
        facilityName: 'حمام السباحة',
        start: seven,
        end: seven.add(const Duration(hours: 1)),
      ),
    );
    expect(text, contains('حمام السباحة'));
    expect(text, contains('7:00'));
    expect(text, contains('8:00'));
  });

  testWidgets('the choice-gone notice has its own words', (tester) async {
    final c = await pumpContext(tester, 'en');
    expect(
      scheduleNoticeMessage(c, const ScheduleNotice.choiceNoLongerAvailable()),
      AppLocalizations.of(c).bookingChoiceGone,
    );
  });

  testWidgets('the notice is a live region with a dismiss target of 48dp', (
    tester,
  ) async {
    var dismissed = 0;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: SprintTheme.light,
        home: Scaffold(
          body: ScheduleNoticeView(
            notice: const ScheduleNotice.failure(SlotTaken()),
            onDismiss: () => dismissed++,
          ),
        ),
      ),
    );
    final handle = tester.ensureSemantics();
    // The sentence is the live region; the dismiss button is its own node, so
    // a screen reader can reach it.
    final sentence = tester.getSemantics(
      find.bySemanticsLabel(
        lookupAppLocalizations(const Locale('ar')).bookingFailSlotTaken,
      ),
    );
    expect(sentence.flagsCollection.isLiveRegion, isTrue);
    final dismiss = find.bySemanticsLabel(
      lookupAppLocalizations(const Locale('ar')).bookingNoticeDismiss,
    );
    expect(dismiss, findsOneWidget);
    expect(tester.getSemantics(dismiss).flagsCollection.isButton, isTrue);
    final size = tester.getSize(find.byType(IconButton));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
    await tester.tap(find.byType(IconButton));
    expect(dismissed, 1);
    handle.dispose();
  });
}
