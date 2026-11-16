import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/data/in_memory_snapshot_store.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/core/theme/theme_mode_notifier.dart';
import 'package:sprint/features/demo/presentation/demo_screen.dart';
import 'package:flutter/material.dart';

import '../../helpers/pump_app.dart';

/// "إرجاع الداتا التجريبية" (FR-013b, T082) and the seed ID card photo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<Uint8List> assetBytes() async {
    final data = await rootBundle.load('assets/demo/id_card_placeholder.jpg');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  test(
    'the seed request photo resolves once the asset bytes are provided',
    () async {
      final bytes = await assetBytes();
      expect(bytes, isNotEmpty);

      final container = ProviderContainer(
        overrides: [
          seedPhotosProvider.overrideWithValue({
            SeedIds.placeholderPhotoId: bytes,
          }),
        ],
      );
      addTearDown(container.dispose);
      final repo = container.read(verificationRepositoryProvider);
      final result = await repo.photo(
        SeedIds.superAdmin,
        SeedIds.placeholderPhotoId,
      );
      expect(result, isA<Ok<Uint8List>>());
      expect((result as Ok<Uint8List>).value, bytes);

      // Without the bytes (the plain test default) it is the known not-found.
      final bare = ProviderContainer();
      addTearDown(bare.dispose);
      final none = await bare
          .read(verificationRepositoryProvider)
          .photo(SeedIds.superAdmin, SeedIds.placeholderPhotoId);
      expect(none, isA<Err<Uint8List>>());
    },
  );

  testWidgets('a saved photo wins over the seed photo', (tester) async {
    final store = InMemorySnapshotStore();
    final saved = Uint8List.fromList([9, 9, 9]);
    store.photos[SeedIds.placeholderPhotoId] = saved;
    final container = ProviderContainer(
      overrides: [
        snapshotStoreProvider.overrideWithValue(store),
        seedPhotosProvider.overrideWithValue({
          SeedIds.placeholderPhotoId: Uint8List.fromList([1]),
        }),
      ],
    );
    addTearDown(container.dispose);
    final result = await container
        .read(verificationRepositoryProvider)
        .photo(SeedIds.superAdmin, SeedIds.placeholderPhotoId);
    expect((result as Ok<Uint8List>).value, saved);
  });

  testWidgets('reset asks first, then clears data, signs out and keeps theme', (
    tester,
  ) async {
    final store = InMemorySnapshotStore();
    await pumpSprintApp(
      tester,
      size: const Size(500, 900),
      overrides: [snapshotStoreProvider.overrideWithValue(store)],
    );
    final container = containerOf(tester);
    await tester.runAsync(() async {
      container.read(themeModeProvider.notifier).set(ThemeMode.dark);
      await container
          .read(sessionProvider.notifier)
          .actAs(SeedIds.bookerInternal);
    });
    await tester.pumpAndSettle();
    expect(container.read(currentSessionProvider).isGuest, isFalse);

    // Something saved on the device.
    store.snapshot = {'schemaVersion': 1};
    store.photos['x'] = Uint8List.fromList([1]);

    routerOf(tester).push('/demo');
    await tester.pumpAndSettle();
    final button = find.byKey(DemoScreen.resetKey);
    await tester.scrollUntilVisible(
      button,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text(ar.demoResetTitle), findsOneWidget);

    // Backing out changes nothing.
    await tester.tap(find.text(ar.demoResetKeep));
    await tester.pumpAndSettle();
    expect(store.snapshot, isNotNull);
    expect(container.read(currentSessionProvider).isGuest, isFalse);

    await tester.tap(button);
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.text(ar.demoResetConfirm));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();

    expect(store.snapshot, isNull);
    expect(store.photos, isEmpty);
    expect(container.read(currentSessionProvider).isGuest, isTrue);
    expect(currentPath(tester), '/home');
    expect(container.read(themeModeProvider), ThemeMode.dark);
  });
}
