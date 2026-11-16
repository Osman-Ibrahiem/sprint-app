import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/seed/seed_ids.dart';
import 'package:sprint/features/catalogue/presentation/facilities/facilities_screen.dart';
import 'package:sprint/features/catalogue/presentation/facilities/facility_not_found.dart';
import 'package:sprint/features/catalogue/presentation/providers/share_provider.dart';

import '../../../helpers/pump_app.dart';

class _Recorder implements ShareAction {
  final shared = <({String text, String url})>[];
  final copied = <String>[];

  @override
  Future<void> share({required String text, required String url}) async =>
      shared.add((text: text, url: url));

  @override
  Future<void> copy(String url) async => copied.add(url);
}

void main() {
  testWidgets('share and copy-link use the seam with the id-based URL',
      (tester) async {
    final rec = _Recorder();
    await pumpSprintApp(tester, overrides: [
      shareActionProvider.overrideWithValue(rec),
    ]);
    routerOf(tester).go('/facilities/${SeedIds.poolFacility}');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(FacilitiesScreen.shareKey));
    await tester.pumpAndSettle();
    expect(rec.shared, hasLength(1));
    expect(rec.shared.single.url, endsWith('/facilities/${SeedIds.poolFacility}'));
    expect(rec.shared.single.text, contains('حمام السباحة الأولمبي'));

    await tester.tap(find.byKey(FacilitiesScreen.copyKey));
    await tester.pumpAndSettle();
    expect(rec.copied.single, rec.shared.single.url);
    expect(find.text(ar.catalogueShareCopied), findsOneWidget);
  });

  test('the URL is built from the id, with the base before the hash', () {
    expect(shareUrlFor('f-x', configuredBase: ''), '/facilities/f-x');
    expect(
      shareUrlFor('f-x', configuredBase: 'https://h.test/sprint-app/'),
      'https://h.test/sprint-app/#/facilities/f-x',
    );
    expect(
      shareUrlFor('f-x', webBase: 'https://h.test/sprint-app'),
      'https://h.test/sprint-app/#/facilities/f-x',
    );
  });

  testWidgets('a deep link opens signed out; an unknown id shows not found',
      (tester) async {
    await pumpSprintApp(tester);
    routerOf(tester).go('/facilities/${SeedIds.hallFacility}');
    await tester.pumpAndSettle();
    expect(currentPath(tester), '/facilities/${SeedIds.hallFacility}');
    expect(find.byType(FacilityNotFound), findsNothing);

    routerOf(tester).go('/facilities/nope');
    await tester.pumpAndSettle();
    expect(find.byType(FacilityNotFound), findsOneWidget);
  });
}
