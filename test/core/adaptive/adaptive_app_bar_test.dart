import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/adaptive/adaptive_app_bar.dart';

import '../../helpers/adaptive_harness.dart';

void main() {
  Future<void> pushPage(WidgetTester tester, Widget page) async {
    await pumpHarness(tester, (_) => const SizedBox.shrink());
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .push(MaterialPageRoute<void>(builder: (_) => page));
    await tester.pumpAndSettle();
  }

  testWidgets('box app bar follows the platform', (tester) async {
    final platform = debugDefaultTargetPlatformOverride!;
    await pushPage(
      tester,
      const Scaffold(appBar: AdaptiveAppBar(title: 'عنوان')),
    );

    if (isApple(platform)) {
      expect(find.byType(CupertinoNavigationBar), findsOneWidget);
      expect(find.byType(AppBar), findsNothing);
      // Chevron back button.
      expect(find.byType(CupertinoNavigationBarBackButton), findsOneWidget);
    } else {
      final bar = tester.widget<AppBar>(find.byType(AppBar));
      expect(bar.centerTitle, isFalse, reason: 'title sits at the start');
      expect(find.byType(CupertinoNavigationBar), findsNothing);
      expect(find.byType(BackButton), findsOneWidget);
    }
    expect(find.text('عنوان'), findsOneWidget);
  }, variant: allPlatforms);

  testWidgets('large title is used on Apple when requested', (tester) async {
    final platform = debugDefaultTargetPlatformOverride!;
    await pushPage(
      tester,
      const Scaffold(
        body: CustomScrollView(
          slivers: [AdaptiveSliverAppBar(title: 'عنوان', largeTitle: true)],
        ),
      ),
    );
    if (isApple(platform)) {
      expect(find.byType(CupertinoSliverNavigationBar), findsOneWidget);
    } else {
      expect(find.byType(SliverAppBar), findsOneWidget);
      expect(find.byType(CupertinoSliverNavigationBar), findsNothing);
    }
    expect(find.text('عنوان'), findsWidgets);
  }, variant: allPlatforms);

  testWidgets('no back button on the first route, actions are shown',
      (tester) async {
    await pumpHarness(
      tester,
      (_) => const SizedBox(
        height: 100,
        width: 400,
        child: Scaffold(
          appBar: AdaptiveAppBar(
            title: 'عنوان',
            actions: [Icon(Icons.share)],
          ),
        ),
      ),
    );
    expect(find.byType(BackButton), findsNothing);
    expect(find.byType(CupertinoNavigationBarBackButton), findsNothing);
    expect(find.byIcon(Icons.share), findsOneWidget);
  }, variant: allPlatforms);
}
