import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/seed/seed_users.dart';
import 'package:sprint/core/seed/seed_verification.dart';
import 'package:sprint/features/verification/presentation/verification_request_detail.dart';

import '../helpers/pump_app.dart';
import '../helpers/verification_steps.dart';

/// SC-006, NFR-06, FR-033: no full seed national ID and no ID card image
/// appears anywhere except the request detail `/verification/:id`, for any
/// seed person on any screen they can reach.
void main() {
  /// Every screen with a fixed path. The request detail is the one place the
  /// full ID and the photo may show, so it is not in this list.
  const paths = [
    '/home',
    '/facilities',
    '/bookings',
    '/profile',
    '/profile/verification',
    '/verification',
    '/verification/upload',
    '/demo',
    '/demo/components',
    '/demo/mailbox',
  ];

  final secrets = <String>{
    for (final u in seedUsers)
      if (u.nationalId != null) u.nationalId!,
    for (final v in seedVerifications(DateTime.now())) v.nationalId,
  };

  /// Every piece of text a person (or a screen reader) can get from the
  /// screen: text, field contents and semantics labels.
  List<String> everythingShown(WidgetTester tester) {
    final out = <String>[];
    for (final w in tester.widgetList<Text>(find.byType(Text))) {
      out.add(w.data ?? w.textSpan?.toPlainText() ?? '');
    }
    for (final w in tester.widgetList<EditableText>(
      find.byType(EditableText),
    )) {
      out.add(w.controller.text);
    }
    void walk(SemanticsNode node) {
      final d = node.getSemanticsData();
      out
        ..add(d.label)
        ..add(d.value)
        ..add(d.hint);
      node.visitChildren((c) {
        walk(c);
        return true;
      });
    }

    final root =
        tester.binding.rootPipelineOwner.semanticsOwner?.rootSemanticsNode;
    if (root != null) walk(root);
    return out;
  }

  bool showsPhoto(WidgetTester tester) =>
      find.byKey(VerificationRequestDetail.photoKey).evaluate().isNotEmpty ||
      tester
          .widgetList<Image>(find.byType(Image))
          .any((i) => i.image is MemoryImage);

  test('the guard has IDs to look for', () {
    expect(secrets.length, greaterThanOrEqualTo(6));
    expect(secrets.every((s) => RegExp(r'^\d{14}$').hasMatch(s)), isTrue);
  });

  testWidgets('every seed person, on every screen, shows no full ID or photo', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpSprintApp(tester);
    final hits = <String>[];
    for (final u in seedUsers) {
      await tester.runAsync(
        () => containerOf(tester).read(sessionProvider.notifier).actAs(u.id),
      );
      await tester.pumpAndSettle();
      for (final path in paths) {
        routerOf(tester).go(path);
        await tester.pumpAndSettle();
        final shown = everythingShown(tester);
        for (final s in secrets) {
          if (shown.any((t) => t.contains(s))) hits.add('${u.id} $path: $s');
        }
        if (showsPhoto(tester)) hits.add('${u.id} $path: ID card photo');
      }
    }
    semantics.dispose();
    expect(hits, isEmpty, reason: hits.join('\n'));
  });

  testWidgets('the detail is where a reviewer in scope sees the full ID', (
    tester,
  ) async {
    // The control: the scan above can see an ID when one is on screen.
    final semantics = tester.ensureSemantics();
    await pumpSprintApp(tester);
    await openReviewerAs(
      tester,
      'usr-verifier',
      '/verification/ver-unverified',
    );
    expect(
      everythingShown(tester).any((t) => t.contains('30003030300033')),
      isTrue,
    );
    semantics.dispose();
  });

  testWidgets('a person without the role never gets the detail', (
    tester,
  ) async {
    await pumpSprintApp(tester);
    await openReviewerAs(
      tester,
      'usr-booker-int',
      '/verification/ver-unverified',
    );
    expect(
      everythingShown(tester).any((t) => t.contains('30003030300033')),
      isFalse,
    );
    expect(showsPhoto(tester), isFalse);
  });
}
