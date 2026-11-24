import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/widgets/code_field/sprint_code_field.dart';
import 'package:sprint/core/widgets/sprint_text_field/sprint_text_field.dart';
import 'package:sprint/features/auth/domain/masking.dart';
import 'package:sprint/features/identity/domain/verification.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/features/verification/presentation/verification_request_detail.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/sign_up_steps.dart';
import '../../helpers/verification_steps.dart';

/// What the per-screen tests do not each repeat for every new screen of
/// feature 003 (T084): 200% text on a 400-wide window without overflow, every
/// interactive element at least 48 in both directions, and codes, phones,
/// emails and national IDs kept left-to-right in Arabic (FR-014, NFR-10,
/// NFR-12). The ARB parity and no-hard-coded-strings guards run unchanged.
void main() {
  const compact = Size(400, 800);
  // Tall, so nothing is scrolled out and clipped: clipped nodes look small.
  const tall = Size(400, 4000);

  /// Every new screen: how to reach it.
  final screens = <String, Future<void> Function(WidgetTester)>{
    'sign in': (t) async => routerOf(t).go('/sign-in'),
    'sign up': (t) async => routerOf(t).go('/sign-up'),
    'confirm email': (t) async =>
        routerOf(t).go('/confirm-email?email=nora.new%40example.test'),
    'forgot password': (t) async => routerOf(t).go('/forgot-password'),
    'reset password': (t) async =>
        routerOf(t).go('/reset-password?identifier=mona%40example.test'),
    'account card': (t) =>
        openVerificationAs(t, SeedIds.bookerInternal, path: '/profile'),
    'verification request': (t) =>
        openVerificationAs(t, SeedIds.bookerExternal),
    'verification queue': (t) =>
        openVerificationAs(t, SeedIds.superAdmin, path: '/verification'),
    'request detail': (t) => openVerificationAs(
      t,
      SeedIds.superAdmin,
      path: '/verification/${SeedIds.verEngPending}',
    ),
    'sheet upload': (t) =>
        openVerificationAs(t, SeedIds.superAdmin, path: '/verification/upload'),
    'demo mailbox': (t) async => routerOf(t).go('/demo/mailbox'),
  };

  group('every new screen at 200% on 400 wide', () {
    for (final MapEntry(key: name, value: open) in screens.entries) {
      for (final lang in ['ar', 'en']) {
        testWidgets('$name ($lang): no overflow, targets of 48', (
          tester,
        ) async {
          final handle = tester.ensureSemantics();
          await pumpSprintApp(tester, size: tall, textScale: 2);
          if (lang == 'en') {
            containerOf(tester)
                .read(localeProvider.notifier)
                .set(const Locale('en'));
            await tester.pumpAndSettle();
          }
          await open(tester);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);

          final small = _smallTargets(tester);
          expect(small, isEmpty, reason: 'under 48: ${small.join(', ')}');
          handle.dispose();
        });
      }
    }
  });

  group('left-to-right values inside Arabic', () {
    testWidgets('account card: phone and email', (tester) async {
      await pumpSprintApp(tester, size: compact);
      await openVerificationAs(
        tester,
        SeedIds.bookerInternal,
        path: '/profile',
      );
      final user = (await tester.runAsync(
        () =>
            containerOf(tester)
                .read(identityRepositoryProvider)
                .getUser(SeedIds.bookerInternal),
      ))!;
      _expectIsolated(tester, maskEmail(user.email));
      _expectIsolated(tester, maskPhone(user.phone));
    });

    testWidgets('confirm email: the address and the demo code', (tester) async {
      await pumpSprintApp(tester, size: const Size(400, 1100));
      await signUpNewAccount(tester);
      _expectIsolated(tester, newEmail);
      _expectIsolated(tester, mailboxCode(tester, newEmail)!);
    });

    testWidgets('reviewer detail: national ID and student code', (
      tester,
    ) async {
      await pumpSprintApp(tester, size: const Size(400, 1400));
      await openReviewerAs(
        tester,
        SeedIds.superAdmin,
        '/verification/${SeedIds.verEngPending}',
      );
      final queue = (await tester.runAsync(
        () =>
            containerOf(tester)
                .read(verificationRepositoryProvider)
                .queue(SeedIds.superAdmin),
      ))!;
      final request = (queue as Ok<List<Verification>>).value.firstWhere(
        (x) => x.id == SeedIds.verEngPending,
      );
      final id = find.byKey(VerificationRequestDetail.nationalIdKey);
      expect(id, findsOneWidget);
      expect(_isLtr(tester.element(id)), isTrue);
      _expectIsolated(tester, request.code);
    });

    testWidgets('demo mailbox: the recipient and the code', (tester) async {
      await pumpSprintApp(tester, size: const Size(400, 1100));
      await signUpNewAccount(tester);
      routerOf(tester).go('/demo/mailbox');
      await tester.pumpAndSettle();
      _expectIsolated(tester, newEmail);
      _expectIsolated(tester, mailboxCode(tester, newEmail)!);
    });

    testWidgets(
      'form fields: phone, email, ID and code are typed left to right',
      (tester) async {
        const leftToRight = {
          SprintTextFieldType.phone,
          SprintTextFieldType.email,
          SprintTextFieldType.nationalId,
          SprintTextFieldType.password,
        };
        var checked = 0;
        void check() {
          for (final f in tester.widgetList<SprintTextField>(
            find.byType(SprintTextField),
          )) {
            if (!leftToRight.contains(f.type)) continue;
            final editable = tester.widget<EditableText>(
              find.descendant(
                of: find.byWidget(f),
                matching: find.byType(EditableText),
              ),
            );
            expect(
              editable.textDirection,
              TextDirection.ltr,
              reason: '${f.type} field flips in Arabic',
            );
            checked++;
          }
          // The confirmation code boxes run left to right too (decision 2).
          for (final e in find.byType(SprintCodeField).evaluate()) {
            final boxes = find.descendant(
              of: find.byWidget(e.widget),
              matching: find.byKey(SprintCodeField.boxKey(0)),
            );
            expect(_isLtr(tester.element(boxes)), isTrue);
            expect(
              tester.getCenter(boxes).dx,
              lessThan(
                tester.getCenter(find.byKey(SprintCodeField.boxKey(5))).dx,
              ),
              reason: 'the first box sits on the left in Arabic too',
            );
            checked++;
          }
        }

        await pumpSprintApp(tester, size: tall);
        for (final path in [
          '/sign-in',
          '/sign-up',
          '/confirm-email?email=a%40b.c',
        ]) {
          routerOf(tester).go(path);
          await tester.pumpAndSettle();
          check();
        }
        await openVerificationAs(tester, SeedIds.bookerExternal);
        check();
        expect(checked, greaterThanOrEqualTo(7));
      },
    );
  });
}

bool _isLtr(BuildContext context) =>
    Directionality.of(context) == TextDirection.ltr;

/// Every Text showing [value] is either wrapped in an LTR directionality or
/// carries the Unicode LRI/PDI isolate around it.
void _expectIsolated(WidgetTester tester, String value) {
  final texts = find.byWidgetPredicate(
    (w) =>
        w is Text &&
        (w.data ?? w.textSpan?.toPlainText() ?? '').contains(value),
  );
  expect(texts, findsWidgets, reason: '"$value" is not on screen');
  for (final e in texts.evaluate()) {
    final w = e.widget as Text;
    final data = w.data ?? w.textSpan!.toPlainText();
    final marked = data.contains('\u2066$value\u2069');
    expect(
      marked || _isLtr(e),
      isTrue,
      reason: '"$value" can flip in Arabic: wrap it in an LTR isolate',
    );
  }
}

/// Interactive semantics nodes smaller than 48 in either direction.
List<String> _smallTargets(WidgetTester tester) {
  final out = <String>[];
  final root =
      tester.binding.rootPipelineOwner.semanticsOwner?.rootSemanticsNode;
  if (root == null) return out;

  void visit(SemanticsNode node, Matrix4 parent) {
    final data = node.getSemanticsData();
    final transform = node.transform == null
        ? parent
        : parent.multiplied(node.transform!);
    final hidden = data.flagsCollection.isHidden;
    final interactive =
        data.hasAction(SemanticsAction.tap) || data.flagsCollection.isTextField;
    if (!hidden && interactive) {
      final r = MatrixUtils.transformRect(transform, node.rect);
      final screen = Offset.zero & tester.view.physicalSize;
      final onScreen = r.overlaps(screen);
      if (onScreen && (r.width < 47.5 || r.height < 47.5)) {
        out.add(
          '"${data.label.isEmpty ? data.identifier : data.label}" '
          '${r.width.toStringAsFixed(0)}x${r.height.toStringAsFixed(0)} '
          'at ${r.left.toStringAsFixed(0)},${r.top.toStringAsFixed(0)} '
          'value="${data.value}" hint="${data.hint}" id=${node.id}',
        );
      }
    }
    node.visitChildren((c) {
      visit(c, transform);
      return true;
    });
  }

  visit(root, Matrix4.identity());
  return out;
}
