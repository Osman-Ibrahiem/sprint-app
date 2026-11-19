import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/catalogue/presentation/search/search_providers.dart';

/// add and clear update the live recents (and so the suggestions) at once.
void main() {
  test('add and clear notify listeners', () async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final seen = <List<String>>[];
    c.listen(recentSearchesProvider, (_, next) => seen.add(next));
    await c.read(recentSearchesProvider.notifier).add('سباحة');
    await c.read(recentSearchesProvider.notifier).add('تنس');
    expect(c.read(recentSearchesProvider), ['تنس', 'سباحة']);
    await c.read(recentSearchesProvider.notifier).clear();
    expect(c.read(recentSearchesProvider), isEmpty);
    expect(seen, isNotEmpty);
  });
}
