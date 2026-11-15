import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/theme/sprint_theme.dart';
import 'package:sprint/features/demo/presentation/component_gallery/component_gallery_screen.dart';
import 'package:sprint/features/demo/presentation/component_gallery/gallery_section.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

import 'helpers/pump_app.dart';
import 'helpers/widget_harness.dart';

void main() {
  testWidgets('debug gallery', (tester) async {
    setWindow(tester, size: const Size(400, 800), reduceMotion: true);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: SprintTheme.light,
          locale: const Locale('ar'),
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
    final l10n = ar;
    final scrollables = find.byType(Scrollable).evaluate().toList();
    // ignore: avoid_print
    print('scrollables: ${scrollables.length}');
    for (final e in scrollables) {
      final w = e.widget as Scrollable;
      // ignore: avoid_print
      print('axis=${w.axisDirection}');
    }
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
    final scrollable = find.byType(Scrollable).first;
    for (final heading in headings) {
      final finder = find.byKey(GallerySection.titleKey(heading));
      var scrolls = 0;
      while (finder.evaluate().isEmpty && scrolls < 50) {
        await tester.dragFrom(const Offset(8, 400), const Offset(0, -300));
        await tester.pump(const Duration(milliseconds: 50));
        scrolls++;
      }
      final position = tester.state<ScrollableState>(scrollable).position;
      // ignore: avoid_print
      print('$heading scrolls=$scrolls found=${finder.evaluate().length} '
          'pixels=${position.pixels} max=${position.maxScrollExtent}');
    }
  });
}
