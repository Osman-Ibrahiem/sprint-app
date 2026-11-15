import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_harness.dart';
import 'sample_screen.dart';

/// SC-011: a screen built from the widgets needs no raw values.
void main() {
  testWidgets('sample screen builds in both languages', (tester) async {
    for (final locale in [const Locale('ar'), const Locale('en')]) {
      await pumpWidgetUnderAndSettle(
        tester,
        const SizedBox(height: 700, child: SampleScreen()),
        locale: locale,
      );
      expect(tester.takeException(), isNull);
    }
  });

  test('sample screen source passes the token rules', () {
    final source = File('test/core/widgets/sample_screen.dart').readAsStringSync();
    final banned = <String, RegExp>{
      'raw colour': RegExp(r'Color\(\s*0x'),
      'Colors.*': RegExp(r'\bColors\.\w+'),
      'platform check': RegExp(r'Platform\.is|defaultTargetPlatform|kIsWeb'),
      'size literal': RegExp(r'\b(width|height|radius)\s*:\s*(?!0\b)\d'),
      'numeric fontSize': RegExp(r'fontSize\s*:\s*\d'),
    };
    for (final rule in banned.entries) {
      expect(rule.value.hasMatch(source), isFalse, reason: rule.key);
    }
  });
}
