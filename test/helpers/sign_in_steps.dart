import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/core/widgets/sprint_text_field/sprint_text_field.dart';

import 'pump_app.dart';

/// Opens `/sign-in` (optionally with `from`) in the running app.
Future<void> openSignIn(WidgetTester tester, {String? from}) async {
  final path = from == null
      ? '/sign-in'
      : Uri(path: '/sign-in', queryParameters: {'from': from}).toString();
  routerOf(tester).go(path);
  await tester.pumpAndSettle();
}

/// Types the identifier and password into the two sign-in fields.
Future<void> fillSignIn(
  WidgetTester tester, {
  required String identifier,
  required String password,
}) async {
  final fields = find.byType(TextField);
  await tester.enterText(fields.at(0), identifier);
  await tester.enterText(fields.at(1), password);
  await tester.pump();
}

/// Presses the primary sign-in button and lets everything settle.
Future<void> submitSignIn(WidgetTester tester) async {
  await tester.tap(find.byType(SprintButton).first);
  await tester.pumpAndSettle();
}

Future<void> signInWith(
  WidgetTester tester, {
  required String identifier,
  required String password,
}) async {
  await fillSignIn(tester, identifier: identifier, password: password);
  await submitSignIn(tester);
}

/// Text field widgets, for the field-level checks.
Finder get signInFields => find.byType(SprintTextField);

/// The location of the page on top, including one pushed on the base route.
Uri topUri(WidgetTester tester) => Uri.parse(
  routerOf(tester)
      .routerDelegate
      .currentConfiguration
      .matches
      .last
      .matchedLocation,
);
