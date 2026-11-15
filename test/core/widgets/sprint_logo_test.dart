import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_text.g.dart';
import 'package:sprint/core/widgets/sprint_logo/sprint_logo.dart';

import '../../helpers/widget_harness.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    LogoVariant variant, {
    double? size,
    Color? background,
    Locale locale = const Locale('ar'),
    bool dark = false,
  }) =>
      pumpWidgetUnderAndSettle(
        tester,
        ColoredBox(
          color: background ?? (dark ? SprintColors.dark.bg : SprintColors.light.bg),
          child: SprintLogo(
            variant: variant,
            size: size,
            backgroundColor: background,
          ),
        ),
        locale: locale,
        dark: dark,
      );

  String asset(WidgetTester tester) {
    final image = tester.widget<SvgPicture>(find.byType(SvgPicture));
    return (image.bytesLoader as SvgAssetLoader).assetName;
  }

  testWidgets('each variant renders its SVG', (tester) async {
    await pump(tester, LogoVariant.tilePrimary);
    expect(asset(tester), SprintLogo.tilePrimaryAsset);

    await pump(tester, LogoVariant.tileInk);
    expect(asset(tester), SprintLogo.tileInkAsset);

    for (final variant in [
      LogoVariant.mark,
      LogoVariant.lockupAr,
      LogoVariant.lockupEn,
    ]) {
      await pump(tester, variant);
      expect(asset(tester), isNotEmpty, reason: variant.name);
    }
  });

  testWidgets('the bare mark uses the primary tile when volt has under 3:1 '
      'contrast, and the mark on a dark background', (tester) async {
    await pump(tester, LogoVariant.mark, background: SprintColors.light.bg);
    expect(asset(tester), SprintLogo.tilePrimaryAsset);

    await pump(tester, LogoVariant.mark, background: SprintColors.dark.bg);
    expect(asset(tester), SprintLogo.markAsset);

    expect(
      SprintLogo.assetFor(
        LogoVariant.mark,
        backgroundLuminance: SprintColors.light.bg.computeLuminance(),
      ),
      SprintLogo.tilePrimaryAsset,
    );
    expect(
      SprintLogo.assetFor(
        LogoVariant.mark,
        backgroundLuminance: SprintColors.dark.bg.computeLuminance(),
      ),
      SprintLogo.markAsset,
    );
  });

  testWidgets('tile colours are identical in Light and Dark', (tester) async {
    await pump(tester, LogoVariant.tilePrimary);
    final lightAsset = asset(tester);
    final lightImage = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(lightImage.colorFilter, isNull);

    await pump(tester, LogoVariant.tilePrimary, dark: true);
    expect(asset(tester), lightAsset);

    await pump(tester, LogoVariant.tileInk, dark: true);
    expect(asset(tester), SprintLogo.tileInkAsset);
  });

  testWidgets('the lockup puts the tile on the start side, names the brand in '
      'title style and leaves one space-3 gap', (tester) async {
    await pump(tester, LogoVariant.lockupAr);
    expect(find.text('سبرنت'), findsOneWidget);
    final text = tester.widget<Text>(find.text('سبرنت'));
    expect(text.style!.fontSize, SprintText.title.fontSize);
    expect(text.style!.fontWeight, SprintText.title.fontWeight);
    expect(text.style!.color, SprintColors.light.ink);

    final tileRect = tester.getRect(find.byKey(SprintLogo.markKey));
    final wordRect = tester.getRect(find.text('سبرنت'));
    expect(tileRect.center.dx, greaterThan(wordRect.center.dx));
    expect(tileRect.left - wordRect.right, greaterThanOrEqualTo(12));

    await pump(tester, LogoVariant.lockupEn, locale: const Locale('en'));
    expect(find.text('Sprint'), findsOneWidget);
    final tileEn = tester.getRect(find.byKey(SprintLogo.markKey));
    final wordEn = tester.getRect(find.text('Sprint'));
    expect(tileEn.center.dx, lessThan(wordEn.center.dx));
    expect(wordEn.left - tileEn.right, greaterThanOrEqualTo(12));
  });

  testWidgets('the mark is never mirrored in RTL', (tester) async {
    await pump(tester, LogoVariant.mark);
    expect(
      find.descendant(
        of: find.byType(SprintLogo),
        matching: find.byWidgetPredicate(
          (w) => w is Transform && w.transform.storage[0] < 0,
        ),
      ),
      findsNothing,
    );
  });

  testWidgets('a size below 16 is raised to 16', (tester) async {
    await pump(tester, LogoVariant.mark, size: 8);
    final size = tester.getSize(find.byKey(SprintLogo.markKey));
    expect(size.width, SprintExtras.logoMinSize);
    expect(size.height, SprintExtras.logoMinSize);
  });

  testWidgets('no shadow, border or recolour is applied', (tester) async {
    await pump(tester, LogoVariant.tilePrimary);
    final image = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(image.colorFilter, isNull);
    expect(
      find.descendant(
        of: find.byType(SprintLogo),
        matching: find.byType(DecoratedBox),
      ),
      findsNothing,
    );
  });

  testWidgets('spoken as the brand name', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, LogoVariant.tilePrimary);
    expect(
      tester.getSemantics(find.byType(SprintLogo)).label,
      'سبرنت',
    );
    handle.dispose();
  });
}
