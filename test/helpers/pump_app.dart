import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' as rp;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/app/app.dart';
import 'package:sprint/app/router/router_provider.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Arabic strings for assertions, so tests never duplicate copy.
final ar = lookupAppLocalizations(const Locale('ar'));

/// Sets the test window size (logical pixels, ratio 1), text scale and hinge.
void setWindow(
  WidgetTester tester, {
  Size size = const Size(400, 800),
  double textScale = 1,
  List<ui.DisplayFeature> features = const [],
  bool reduceMotion = true,
}) {
  tester.view.devicePixelRatio = 1;
  // Skeletons pulse forever; tests settle only when motion is reduced.
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      FakeAccessibilityFeatures(disableAnimations: reduceMotion);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  tester.view.physicalSize = size;
  tester.view.displayFeatures = features;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

Future<void> pumpSprintApp(
  WidgetTester tester, {
  Size size = const Size(400, 800),
  double textScale = 1,
  List<ui.DisplayFeature> features = const [],
  List<rp.Override> overrides = const [],
  bool reduceMotion = true,
}) async {
  setWindow(
    tester,
    size: size,
    textScale: textScale,
    features: features,
    reduceMotion: reduceMotion,
  );
  await tester.pumpWidget(
    ProviderScope(overrides: overrides, child: const SprintApp()),
  );
  await tester.pumpAndSettle();
}

ProviderContainer containerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(SprintApp)));

GoRouter routerOf(WidgetTester tester) {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(SprintApp)),
  );
  return container.read(appRouterProvider);
}

String currentPath(WidgetTester tester) =>
    routerOf(tester).routerDelegate.currentConfiguration.uri.path;
