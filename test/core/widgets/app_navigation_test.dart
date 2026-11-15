import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/adaptive/adaptive_pressable.dart';
import 'package:sprint/core/adaptive/platform.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/widgets/app_navigation/app_navigation.dart';
import 'package:sprint/core/widgets/app_navigation/nav_destination.dart';
import 'package:sprint/core/widgets/app_navigation/sprint_nav_rail.dart';
import 'package:sprint/core/widgets/app_navigation/sprint_tab_bar.dart';
import 'package:sprint/core/widgets/sprint_logo/sprint_logo.dart';

import '../../helpers/widget_harness.dart';

void main() {
  final colors = SprintColors.light;

  List<NavDestination> destinations({int? badgeAt, int? badgeCount}) => [
        const NavDestination(
          label: 'الرئيسية',
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
        ),
        NavDestination(
          label: 'المنشآت',
          icon: Icons.square_outlined,
          selectedIcon: Icons.square,
          badgeCount: badgeAt == 1 ? badgeCount : null,
        ),
        NavDestination(
          label: 'حجوزاتي',
          icon: Icons.confirmation_number_outlined,
          selectedIcon: Icons.confirmation_number,
          badgeCount: badgeAt == 2 ? badgeCount : null,
        ),
        const NavDestination(
          label: 'حسابي',
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
        ),
        const NavDestination(
          label: 'الإشعارات',
          icon: Icons.notifications_outlined,
          selectedIcon: Icons.notifications,
        ),
        const NavDestination(
          label: 'المساعدة',
          icon: Icons.help_outline,
          selectedIcon: Icons.help,
        ),
      ];

  Future<void> pumpNav(
    WidgetTester tester,
    List<NavDestination> items, {
    NavigationForm? form,
    int selected = 0,
    ValueChanged<int>? onSelected,
    AdaptiveStyle style = AdaptiveStyle.android,
    Locale locale = const Locale('ar'),
    double textScale = 1,
    Size size = const Size(400, 800),
  }) =>
      pumpWidgetUnderAndSettle(
        tester,
        SizedBox(
          width: size.width,
          height: 600,
          child: AppNavigation(
            destinations: items,
            selected: selected,
            onSelected: onSelected ?? (_) {},
            form: form,
          ),
        ),
        style: style,
        locale: locale,
        textScale: textScale,
        size: size,
      );

  Color? surfaceColor(WidgetTester tester, Finder label) {
    final box = find
        .ancestor(of: label, matching: find.byType(DecoratedBox))
        .evaluate()
        .map((e) => e.widget)
        .whereType<DecoratedBox>()
        .firstWhere(
          (w) =>
              w.key == AdaptivePressable.surfaceKey &&
              w.decoration is BoxDecoration,
        );
    return (box.decoration as BoxDecoration).color;
  }

  testWidgets('tab bar active styling: Fill icon and primary label',
      (tester) async {
    await pumpNav(tester, destinations(), form: NavigationForm.tabBar);
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsNothing);
    final label = tester.widget<Text>(find.text('الرئيسية'));
    expect(label.style!.color, colors.primary);
  });

  testWidgets('Apple tab bar is translucent and has no pill', (tester) async {
    await pumpNav(
      tester,
      destinations(),
      form: NavigationForm.tabBar,
      style: AdaptiveStyle.apple,
    );
    final root = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(SprintTabBar),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    expect(
      (root.decoration as BoxDecoration).color,
      colors.surface.withValues(alpha: 0.85),
    );
    expect(
      find.byWidgetPredicate(
        (w) => w is DecoratedBox &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).color == colors.primarySoft,
      ),
      findsNothing,
    );
  });

  testWidgets('Android tab bar is solid and shows the selected pill',
      (tester) async {
    await pumpNav(
      tester,
      destinations(),
      form: NavigationForm.tabBar,
      style: AdaptiveStyle.android,
    );
    expect(
      surfaceColor(tester, find.text('الرئيسية')),
      Colors.transparent,
    );
    expect(
      find.byWidgetPredicate(
        (w) => w is DecoratedBox &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).color == colors.primarySoft,
      ),
      findsWidgets,
    );
  });

  testWidgets('rail active styling: primary-soft pill with on-primary-soft',
      (tester) async {
    await pumpNav(tester, destinations(), form: NavigationForm.rail);
    expect(surfaceColor(tester, find.text('الرئيسية')), colors.primarySoft);
    expect(
      tester.widget<Text>(find.text('الرئيسية')).style!.color,
      colors.onPrimarySoft,
    );
  });

  testWidgets('sidebar active styling: primary-soft row with on-primary-soft',
      (tester) async {
    await pumpNav(tester, destinations(), form: NavigationForm.sidebar);
    expect(surfaceColor(tester, find.text('الرئيسية')), colors.primarySoft);
    expect(
      tester.widget<Text>(find.text('الرئيسية')).style!.color,
      colors.onPrimarySoft,
    );
  });

  testWidgets('badges: danger on-danger, hidden at 0, 99+ above 99, spoken',
      (tester) async {
    await pumpNav(
      tester,
      destinations(badgeAt: 2, badgeCount: 0),
      form: NavigationForm.sidebar,
    );
    expect(find.byType(NavigationBadge), findsNothing);

    await pumpNav(
      tester,
      destinations(badgeAt: 2, badgeCount: 3),
      form: NavigationForm.sidebar,
    );
    expect(find.text('3'), findsOneWidget);
    final badge = tester.widget<Text>(find.text('3'));
    expect(badge.style!.color, colors.onDanger);
    final badgeBox = tester.widget<DecoratedBox>(
      find
          .ancestor(of: find.text('3'), matching: find.byType(DecoratedBox))
          .first,
    );
    expect((badgeBox.decoration as BoxDecoration).color, colors.danger);

    final handle = tester.ensureSemantics();
    expect(find.bySemanticsLabel('حجوزاتي، 3 غير مقروء'), findsOneWidget);
    final item = tester.getSemantics(
      find.bySemanticsLabel('حجوزاتي، 3 غير مقروء'),
    );
    expect(item.flagsCollection.isLiveRegion, isTrue);
    handle.dispose();

    await pumpNav(
      tester,
      destinations(badgeAt: 2, badgeCount: 120),
      form: NavigationForm.sidebar,
    );
    expect(find.text('99+'), findsOneWidget);
  });

  testWidgets('six destinations in the tab bar give four plus More',
      (tester) async {
    var selected = -1;
    await pumpNav(
      tester,
      destinations(),
      form: NavigationForm.tabBar,
      onSelected: (index) => selected = index,
    );
    expect(find.text('الرئيسية'), findsOneWidget);
    expect(find.text('حسابي'), findsOneWidget);
    expect(find.text('الإشعارات'), findsNothing);
    expect(find.text('المساعدة'), findsNothing);
    expect(find.text('المزيد'), findsOneWidget);

    await tester.tap(find.text('المزيد'));
    await tester.pumpAndSettle();
    expect(find.text('الإشعارات'), findsOneWidget);
    expect(find.text('المساعدة'), findsOneWidget);
    await tester.tap(find.text('المساعدة'));
    await tester.pumpAndSettle();
    expect(selected, 5);
  });

  testWidgets('desktop hover shows surface-sunken and the focus ring',
      (tester) async {
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(
      () => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic,
    );
    await pumpNav(
      tester,
      destinations(),
      form: NavigationForm.sidebar,
      style: AdaptiveStyle.desktop,
    );

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await gesture.moveTo(tester.getCenter(find.text('المنشآت')));
    await tester.pumpAndSettle();
    expect(surfaceColor(tester, find.text('المنشآت')), colors.surfaceSunken);

    Focus.of(tester.element(find.text('المنشآت'))).requestFocus();
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('focus-ring-visible')),
      findsOneWidget,
    );
  });

  testWidgets('desktop number keys 1 to 5 select', (tester) async {
    final picked = <int>[];
    await pumpNav(
      tester,
      destinations(),
      form: NavigationForm.rail,
      style: AdaptiveStyle.desktop,
      onSelected: picked.add,
    );
    Focus.of(tester.element(find.text('الرئيسية'))).requestFocus();
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
    await tester.pumpAndSettle();
    expect(picked, [0, 2]);
  });

  testWidgets('rail and sidebar sit on the start edge in both languages',
      (tester) async {
    await pumpNav(tester, destinations(), form: NavigationForm.rail);
    expect(
      tester.getRect(find.byType(SprintNavRail)).right,
      greaterThan(300),
    );
    await pumpNav(
      tester,
      destinations(),
      form: NavigationForm.rail,
      locale: const Locale('en'),
    );
    expect(tester.getRect(find.byType(SprintNavRail)).left, 0);
  });

  testWidgets('the sidebar shows the Sprint lockup', (tester) async {
    await pumpNav(tester, destinations(), form: NavigationForm.sidebar);
    expect(find.byType(SprintLogo), findsOneWidget);
  });

  testWidgets('200% text drops tab labels but keeps the spoken label',
      (tester) async {
    final handle = tester.ensureSemantics();
    await pumpNav(
      tester,
      destinations(),
      form: NavigationForm.tabBar,
      textScale: 2,
    );
    expect(find.text('الرئيسية'), findsNothing);
    expect(find.bySemanticsLabel('الرئيسية'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('every item is at least 48', (tester) async {
    for (final form in NavigationForm.values) {
      await pumpNav(tester, destinations(), form: form);
      for (final item in find.byType(AdaptivePressable).evaluate()) {
        final size = item.size!;
        expect(size.width, greaterThanOrEqualTo(48), reason: form.name);
        expect(size.height, greaterThanOrEqualTo(48), reason: form.name);
      }
    }
  });

  testWidgets('selecting the selected item reports it', (tester) async {
    final picked = <int>[];
    await pumpNav(
      tester,
      destinations(),
      form: NavigationForm.rail,
      selected: 1,
      onSelected: picked.add,
    );
    await tester.tap(find.text('المنشآت'));
    await tester.pumpAndSettle();
    expect(picked, [1]);
  });
}
