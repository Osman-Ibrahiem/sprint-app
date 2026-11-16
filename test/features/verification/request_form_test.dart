import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:sprint/core/adaptive/photo_capabilities.dart';
import 'package:sprint/core/l10n/locale_notifier.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/theme/theme_mode_notifier.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/features/verification/presentation/id_card_photo_picker.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/sign_up_steps.dart';
import '../../helpers/verification_steps.dart';

/// The request form: every field error next to its field, the photo step,
/// and the cross-cutting matrix (language, theme, window, text scale) as the
/// sign-in form (FR-024, FR-025, FR-047, NFR-10).
void main() {
  late FakeIdCardSource picker;

  Future<void> open(
    WidgetTester tester, {
    Size size = const Size(400, 800),
    double scale = 1,
    String userId = SeedIds.bookerExternal,
  }) async {
    picker = FakeIdCardSource();
    await pumpSprintApp(
      tester,
      size: size,
      textScale: scale,
      overrides: fakePhotoOverrides(picker),
    );
    await openVerificationAs(tester, userId);
  }

  final sizes = {
    'compact': const Size(400, 800),
    'expanded': const Size(1000, 800),
  };
  for (final lang in ['ar', 'en']) {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      for (final MapEntry(key: sizeName, value: size) in sizes.entries) {
        for (final scale in [1.0, 2.0]) {
          testWidgets('renders: $lang $mode $sizeName x$scale, no overflow', (
            tester,
          ) async {
            await open(tester, size: size, scale: scale);
            containerOf(tester)
              ..read(localeProvider.notifier).set(Locale(lang))
              ..read(themeModeProvider.notifier).set(mode);
            await tester.pumpAndSettle();
            final l10n = lookupAppLocalizations(Locale(lang));
            expect(find.text(l10n.verifNationalIdLabel), findsOneWidget);
            expect(find.text(l10n.verifCodeLabel), findsOneWidget);
            expect(find.text(l10n.verifPhotoLabel), findsOneWidget);
            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  }

  testWidgets('the owning units are listed and one can be chosen', (
    tester,
  ) async {
    await open(tester);
    for (final id in [SeedIds.ouPe, SeedIds.ouEng, SeedIds.ouCentral]) {
      expect(find.text(unitName(id)), findsOneWidget);
    }
    await tapText(tester, unitName(SeedIds.ouEng));
    expect(find.text(ar.verifErrUnitEmpty), findsNothing);
    // A chosen row says so with a word, not colour alone.
    expect(find.text(ar.optionSelected), findsWidgets);
  });

  group('each field error shows next to its field, in words', () {
    final cases = {
      'short': ('123', ar.verifErrNationalIdLength),
      'century': ('19901010100011', ar.verifErrNationalIdCentury),
      'birth date': ('29913010100011', ar.verifErrNationalIdBirthDate),
      'governorate': ('29901019900011', ar.verifErrNationalIdGovernorate),
    };
    for (final MapEntry(:key, :value) in cases.entries) {
      testWidgets('national ID, $key', (tester) async {
        await open(tester);
        await enterRequestFields(tester, nationalId: value.$1, code: 'A1');
        await tapText(tester, ar.verifSubmit);
        expect(find.text(value.$2), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsWidgets);
      });
    }

    testWidgets('code with a symbol', (tester) async {
      await open(tester);
      await enterRequestFields(
        tester,
        nationalId: '29902020200022',
        code: '12 !! 34',
      );
      await tapText(tester, ar.verifSubmit);
      expect(find.text(ar.verifErrCodeInvalid), findsOneWidget);
      expect(find.text(ar.verifErrNationalIdLength), findsNothing);
    });

    testWidgets('an error leaves when the field is edited', (tester) async {
      await open(tester);
      await tapText(tester, ar.verifSubmit);
      expect(find.text(ar.verifErrNationalIdEmpty), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, '2');
      await tester.pump();
      expect(find.text(ar.verifErrNationalIdEmpty), findsNothing);
    });
  });

  group('the photo step', () {
    testWidgets('required, and shown at the preview height once chosen', (
      tester,
    ) async {
      await open(tester);
      await tapText(tester, ar.verifSubmit);
      expect(find.text(ar.verifErrPhotoEmpty), findsOneWidget);

      await pickIdCardPhoto(tester, ar.verifPhotoGallery);
      expect(picker.lastSource, IdCardSource.gallery);
      expect(find.text(ar.verifErrPhotoEmpty), findsNothing);
      final preview = find.byKey(IdCardPhotoPicker.previewKey);
      expect(preview, findsOneWidget);
      expect(
        tester
            .getSize(
              find
                  .ancestor(of: preview, matching: find.byType(Container))
                  .first,
            )
            .height,
        SprintExtras.idCardPreviewHeight,
      );
      // It can be replaced before sending.
      expect(find.text(ar.verifPhotoReplace), findsOneWidget);
    });

    testWidgets('the camera is offered on a phone platform', (tester) async {
      await open(tester);
      final button = find.byKey(IdCardPhotoPicker.buttonKey);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.text(ar.verifPhotoCamera), findsOneWidget);
      await tapText(tester, ar.verifPhotoCamera);
      expect(picker.lastSource, IdCardSource.camera);
    });

    testWidgets('backing out changes nothing', (tester) async {
      await open(tester);
      picker.bytes = null;
      await pickIdCardPhoto(tester, ar.verifPhotoGallery);
      expect(find.byKey(IdCardPhotoPicker.previewKey), findsNothing);
      expect(find.text(ar.verifPhotoChoose), findsOneWidget);
    });

    testWidgets('a refusal from the platform is told in words', (tester) async {
      await open(tester);
      picker.failWith = StateError('denied');
      await pickIdCardPhoto(tester, ar.verifPhotoGallery);
      expect(find.text(ar.signInUnexpected), findsOneWidget);
      expect(find.byKey(IdCardPhotoPicker.previewKey), findsNothing);
    });

    testWidgets('a file that is not an image is refused', (tester) async {
      picker = FakeIdCardSource();
      await pumpSprintApp(
        tester,
        overrides: [
          idCardPhotoSourceProvider.overrideWithValue(picker),
          idCardEncoderProvider.overrideWithValue((b) async => null),
        ],
      );
      await openVerificationAs(tester, SeedIds.bookerExternal);
      await pickIdCardPhoto(tester, ar.verifPhotoGallery);
      expect(find.text(ar.verifPhotoNotImage), findsOneWidget);
      expect(find.byKey(IdCardPhotoPicker.previewKey), findsNothing);
    });
  });

  group('the camera exists on Android and iOS apps only', () {
    test('by platform', () {
      expect(cameraAvailableFor(TargetPlatform.android, isWeb: false), isTrue);
      expect(cameraAvailableFor(TargetPlatform.iOS, isWeb: false), isTrue);
      expect(cameraAvailableFor(TargetPlatform.android, isWeb: true), isFalse);
      expect(cameraAvailableFor(TargetPlatform.iOS, isWeb: true), isFalse);
      expect(cameraAvailableFor(TargetPlatform.macOS, isWeb: false), isFalse);
      expect(cameraAvailableFor(TargetPlatform.windows, isWeb: false), isFalse);
      expect(cameraAvailableFor(TargetPlatform.linux, isWeb: false), isFalse);
    });

    testWidgets('on desktop the gallery opens at once', (tester) async {
      picker = FakeIdCardSource();
      await pumpSprintApp(tester, overrides: fakePhotoOverrides(picker));
      await openVerificationAs(tester, SeedIds.bookerExternal);
      final button = find.byKey(IdCardPhotoPicker.buttonKey);
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(picker.lastSource, IdCardSource.gallery);
      expect(find.text(ar.verifPhotoCamera), findsNothing);
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));
  });

  group('encodeIdCardJpeg', () {
    Uint8List png(int w, int h) =>
        Uint8List.fromList(img.encodePng(img.Image(width: w, height: h)));

    test('shrinks a wide picture to 1280 on the long side as a JPEG', () {
      final out = encodeIdCardJpeg(png(3000, 2000))!;
      final decoded = img.decodeJpg(out)!;
      expect(decoded.width, idCardMaxSide);
      expect(decoded.height, closeTo(853, 1));
    });

    test('shrinks a tall picture by its height', () {
      final decoded = img.decodeJpg(encodeIdCardJpeg(png(1000, 4000))!)!;
      expect(decoded.height, idCardMaxSide);
      expect(decoded.width, 320);
    });

    test('keeps a small picture at its size', () {
      final decoded = img.decodeJpg(encodeIdCardJpeg(png(800, 600))!)!;
      expect((decoded.width, decoded.height), (800, 600));
    });

    test('bytes that are not an image give null', () {
      expect(encodeIdCardJpeg(Uint8List.fromList([1, 2, 3, 4])), isNull);
    });
  });
}
