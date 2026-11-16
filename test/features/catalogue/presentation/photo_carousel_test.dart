import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/catalogue/presentation/details/photo_carousel.dart';

import 'package:sprint/core/theme/sprint_theme.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

import '../../../helpers/pump_app.dart';

final _png = Uint8List.fromList(const [
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0xF8,
  0xCF,
  0xC0,
  0xF0,
  0x1F,
  0x00,
  0x05,
  0x00,
  0x01,
  0xFF,
  0x89,
  0x99,
  0x3D,
  0x1D,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

Future<void> pump(WidgetTester tester, int n) async {
  setWindow(tester);
  await tester.pumpWidget(
    MaterialApp(
      theme: SprintTheme.light,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: PhotoCarousel(
          photos: [for (var i = 0; i < n; i++) MemoryImage(_png)],
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('no images shows the placeholder', (tester) async {
    await pump(tester, 0);
    expect(find.byKey(PhotoCarousel.placeholderKey), findsOneWidget);
    expect(find.text(ar.cataloguePhotoPlaceholder), findsOneWidget);
  });

  testWidgets('one image has no controls', (tester) async {
    await pump(tester, 1);
    expect(find.byKey(PhotoCarousel.indicatorKey), findsNothing);
  });

  testWidgets('three images swipe with a position indicator', (tester) async {
    await pump(tester, 3);
    expect(find.text(ar.cataloguePhotoPosition(1, 3)), findsOneWidget);
    await tester.drag(find.byType(PageView), const Offset(400, 0));
    await tester.pumpAndSettle();
    expect(find.text(ar.cataloguePhotoPosition(2, 3)), findsWidgets);
  });
}
