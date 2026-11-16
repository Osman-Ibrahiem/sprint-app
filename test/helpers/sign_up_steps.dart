import 'package:flutter/material.dart';
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/features/auth/domain/email_code.dart';

import 'pump_app.dart';

/// A clock the test can move; pass `clock.value` to `appClockProvider`.
class MovableClock {
  MovableClock([DateTime? start]) : now = start ?? DateTime.now().toUtc();

  DateTime now;

  Clock get value => Clock(() => now);
  void advance(Duration d) => now = now.add(d);
}

/// Opens `/sign-up` (optionally with `from`).
Future<void> openSignUp(WidgetTester tester, {String? from}) async {
  final path = from == null
      ? '/sign-up'
      : Uri(path: '/sign-up', queryParameters: {'from': from}).toString();
  routerOf(tester).go(path);
  await tester.pumpAndSettle();
}

const newName = 'نورا أحمد حسن';
const newPhone = '01099887766';
const newEmail = 'nora.new@example.test';
const newPassword = 'Sprint2026';

/// Types the four sign-up fields (name, phone, email, password).
Future<void> fillSignUp(
  WidgetTester tester, {
  String name = newName,
  String phone = newPhone,
  String email = newEmail,
  String password = newPassword,
}) async {
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), name);
  await tester.enterText(fields.at(1), phone);
  await tester.enterText(fields.at(2), email);
  await tester.enterText(fields.at(3), password);
  await tester.pump();
}

/// Taps the text, scrolling it into view first, then settles.
Future<void> tapText(WidgetTester tester, String text) async {
  final finder = find.text(text).hitTestable().evaluate().isEmpty
      ? find.text(text).last
      : find.text(text).hitTestable().first;
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// The newest code in the simulated mailbox for [email].
String? mailboxCode(
  WidgetTester tester,
  String email, [
  CodePurpose purpose = CodePurpose.confirmEmail,
]) =>
    containerOf(tester)
        .read(simulatedMailboxProvider)
        ?.latestCodeFor(email, purpose);

/// Types [code] into the confirmation field.
Future<void> enterCode(WidgetTester tester, String code) async {
  await tester.enterText(find.byType(TextField).first, code);
  await tester.pump();
}

/// A six-digit code that is not [real].
String wrongCodeFor(String real) => real == '000000' ? '111111' : '000000';

/// Fills the form, submits, and lands on the confirmation step.
Future<void> signUpNewAccount(WidgetTester tester, {String? from}) async {
  await openSignUp(tester, from: from);
  await fillSignUp(tester);
  await tapText(tester, ar.signUpButton);
}
