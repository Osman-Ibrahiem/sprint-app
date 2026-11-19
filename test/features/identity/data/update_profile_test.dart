import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/providers/session_provider.dart';
import 'package:sprint/core/result/failure.dart';
import 'package:sprint/core/result/result.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/features/identity/domain/user.dart';

import '../../../helpers/data_env.dart';

/// The one profile write (FR-044, data-model): a trimmed name of at least two
/// characters, an optional photo key, and nothing else touched.
void main() {
  late DataEnv env;

  setUp(() => env = DataEnv());

  T ok<T>(Result<T> r) => (r as Ok<T>).value;
  Failure fail<T>(Result<T> r) => (r as Err<T>).failure;

  test('the name is trimmed and the other fields never change', () async {
    final repo = env.layer.identity;
    final before = (await repo.getUser(Ids.bookerInternal))!;

    var events = 0;
    final sub = repo.changes.listen((_) => events++);

    final after = ok(await repo.updateProfile(
      Ids.bookerInternal,
      name: '  منى عبد الله  ',
    ));
    await pumpEventQueue();

    expect(after.name, 'منى عبد الله');
    expect(after.email, before.email);
    expect(after.phone, before.phone);
    expect(after.nationalId, before.nationalId);
    expect(events, greaterThanOrEqualTo(1));
    await sub.cancel();
  });

  test('fewer than two characters after trimming is InvalidName', () async {
    final repo = env.layer.identity;
    for (final name in ['', ' ', ' أ ', 'a']) {
      expect(
        fail(await repo.updateProfile(Ids.bookerInternal, name: name)),
        isA<InvalidName>(),
        reason: '"$name"',
      );
    }
    expect((await repo.getUser(Ids.bookerInternal))!.name, isNot(' '));
  });

  test('the avatar key is set and cleared without touching the name', () async {
    final repo = env.layer.identity;
    final before = (await repo.getUser(Ids.bookerInternal))!;

    final withPhoto = ok(await repo.updateProfile(
      Ids.bookerInternal,
      name: before.name,
      avatarId: 'avatar-usr-booker-int',
    ));
    expect(withPhoto.avatarId, 'avatar-usr-booker-int');
    expect(withPhoto.name, before.name);

    final cleared = ok(await repo.updateProfile(
      Ids.bookerInternal,
      name: before.name,
      clearAvatar: true,
    ));
    expect(cleared.avatarId, isNull);
  });

  test('the signed-in session refreshes with the new name', () async {
    final c = ProviderContainer(overrides: [
      dataLayerProvider.overrideWithValue(env.layer),
      appClockProvider.overrideWithValue(Clock(() => env.now)),
    ]);
    addTearDown(c.dispose);
    await c.read(sessionProvider.notifier).actAs(Ids.bookerInternal);

    ok(await env.layer.identity.updateProfile(
      Ids.bookerInternal,
      name: 'اسم جديد',
    ));
    await pumpEventQueue();

    expect(c.read(currentSessionProvider).user!.name, 'اسم جديد');
    expect(c.read(currentSessionProvider).user, isA<User>());
  });
}
