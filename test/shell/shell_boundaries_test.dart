import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/shell/nav/sprint_nav_rail.dart';
import 'package:sprint/app/shell/nav/sprint_sidebar.dart';
import 'package:sprint/app/shell/nav/sprint_tab_bar.dart';
import 'package:sprint/app/shell/shell_keys.dart';
import 'package:sprint/core/tokens/sprint_size.g.dart';

import '../helpers/pump_app.dart';

void main() {
  // width -> which single navigation form is expected.
  final cases = <double, Type>{
    320: SprintTabBar,
    599: SprintTabBar,
    600: SprintNavRail,
    839: SprintNavRail,
    840: SprintSidebar,
    1199: SprintSidebar,
    1200: SprintSidebar,
    1920: SprintSidebar,
  };

  cases.forEach((width, expected) {
    testWidgets('width $width shows exactly one navigation: $expected',
        (tester) async {
      await pumpSprintApp(tester, size: Size(width, 800));
      final forms = <Type, Finder>{
        SprintTabBar: find.byType(SprintTabBar),
        SprintNavRail: find.byType(SprintNavRail),
        SprintSidebar: find.byType(SprintSidebar),
      };
      for (final entry in forms.entries) {
        expect(
          entry.value,
          entry.key == expected ? findsOneWidget : findsNothing,
          reason: '${entry.key} at width $width',
        );
      }
    });
  });

  testWidgets('large content is centred and capped at content-max',
      (tester) async {
    await pumpSprintApp(tester, size: const Size(1920, 900));
    final content = tester.getRect(find.byKey(shellContentKey));
    expect(content.width, SprintSize.contentMax);
    // Centred in the area beside the sidebar.
    final area = 1920 - SprintSize.sidebarWidth;
    expect(
      (content.center.dx - (SprintSize.sidebarWidth + area / 2)).abs() < 1 ||
          (content.center.dx - area / 2).abs() < 1,
      isTrue,
    );
  });

  testWidgets('content is not capped below the large class', (tester) async {
    await pumpSprintApp(tester, size: const Size(1100, 800));
    final content = tester.getRect(find.byKey(shellContentKey));
    expect(content.width, 1100 - SprintSize.sidebarWidth);
  });
}
