import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/adaptive/platform.dart';
import 'package:sprint/core/theme/sprint_theme.dart';
import 'package:sprint/features/demo/presentation/component_gallery/component_gallery_screen.dart';
import 'package:sprint/features/demo/presentation/component_gallery/gallery_section.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

import '../../helpers/pump_app.dart';

/// Scrolls the gallery down by jumping, so a nested control under the centre
/// of the screen cannot swallow the drag.
Future<void> scrollToHeading(WidgetTester tester, String heading) async {
  final target = find.byKey(GallerySection.titleKey(heading));
  final position = tester.state<ScrollableState>(find.byType(Scrollable).first).position;
  for (var i = 0; i < 200 && target.evaluate().isEmpty; i++) {
    position.jumpTo(
      (position.pixels + 400).clamp(0, position.maxScrollExtent).toDouble(),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(target, findsOneWidget, reason: heading);
}

void main() {
  Future<void> pumpGallery(
    WidgetTester tester, {
    Locale locale = const Locale('ar'),
    Size size = const Size(400, 800),
  }) async {
    setWindow(tester, size: size, reduceMotion: true);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: SprintTheme.light,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const ComponentGalleryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('lists ten section headings in Arabic', (tester) async {
    await pumpGallery(tester);
    final l10n = ar;
    final headings = [
      l10n.galleryButtonSection,
      l10n.galleryTextFieldSection,
      l10n.gallerySlotChipSection,
      l10n.galleryDayStripSection,
      l10n.galleryStatusBadgeSection,
      l10n.galleryLogoSection,
      l10n.galleryFacilityCardSection,
      l10n.galleryBookingTicketSection,
      l10n.galleryNavigationSection,
      l10n.galleryStatTileSection,
    ];
    for (final heading in headings) {
      await scrollToHeading(tester, heading);
      expect(find.byKey(GallerySection.titleKey(heading)), findsOneWidget, reason: heading);
    }
  });

  testWidgets('lists the headings in English too', (tester) async {
    await pumpGallery(tester, locale: const Locale('en'));
    final l10n = lookupAppLocalizations(const Locale('en'));
    for (final heading in [
      l10n.galleryButtonSection,
      l10n.galleryLogoSection,
      l10n.galleryStatTileSection,
    ]) {
      await scrollToHeading(tester, heading);
      expect(find.byKey(GallerySection.titleKey(heading)), findsOneWidget);
    }
  });

  testWidgets('the sample-content note is visible', (tester) async {
    await pumpGallery(tester);
    expect(find.text(ar.gallerySampleNote), findsWidgets);
  });

  testWidgets('the text size control scales the section subtree', (tester) async {
    await pumpGallery(tester);
    final context = tester.element(find.byKey(GallerySection.titleKey(ar.galleryButtonSection)));
    expect(MediaQuery.textScalerOf(context).scale(10), 10);

    await tester.ensureVisible(find.text('200%'));
    await tester.tap(find.text('200%'));
    await tester.pumpAndSettle();
    final scaled = tester.element(find.byKey(GallerySection.titleKey(ar.galleryButtonSection)));
    expect(MediaQuery.textScalerOf(scaled).scale(10), 20);
  });

  testWidgets('the reduced-motion control disables animations for the '
      'subtree', (tester) async {
    await pumpGallery(tester);
    final context = tester.element(find.byKey(
      GallerySection.titleKey(ar.galleryButtonSection),
    ));
    // The harness starts with reduced motion on, matching the system setting.
    expect(MediaQuery.disableAnimationsOf(context), isTrue);

    await tester.tap(find.byType(Switch));
    await tester.pump();
    final animated = tester.element(find.byKey(
      GallerySection.titleKey(ar.galleryButtonSection),
    ));
    expect(MediaQuery.disableAnimationsOf(animated), isFalse);
  });

  testWidgets('the platform look control wraps sections in '
      'AdaptivePlatformOverride', (tester) async {
    await pumpGallery(tester);
    await tester.tap(find.text(ar.galleryPlatformApple));
    await tester.pumpAndSettle();
    final context = tester.element(find.byKey(GallerySection.titleKey(ar.galleryButtonSection)));
    expect(adaptiveStyleOf(context), AdaptiveStyle.apple);

    await tester.tap(find.text(ar.galleryPlatformAndroid));
    await tester.pumpAndSettle();
    final android = tester.element(find.byKey(GallerySection.titleKey(ar.galleryButtonSection)));
    expect(adaptiveStyleOf(android), AdaptiveStyle.android);
  });

  testWidgets('sections are built lazily', (tester) async {
    await pumpGallery(tester);
    expect(find.byKey(GallerySection.titleKey(ar.galleryButtonSection)), findsOneWidget);
    expect(find.byKey(GallerySection.titleKey(ar.galleryStatTileSection)), findsNothing);
  });

  testWidgets('the demo link opens the gallery', (tester) async {
    await pumpSprintApp(tester, size: const Size(500, 900));
    routerOf(tester).push(AppPaths.demo);
    await tester.pumpAndSettle();

    final list = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text(ar.galleryOpenFromDemo),
      200,
      scrollable: list,
    );
    await tester.tap(find.text(ar.galleryOpenFromDemo));
    await tester.pumpAndSettle();
    expect(find.byType(ComponentGalleryScreen), findsOneWidget);
    expect(find.text(ar.galleryTitle), findsOneWidget);
  });
}
