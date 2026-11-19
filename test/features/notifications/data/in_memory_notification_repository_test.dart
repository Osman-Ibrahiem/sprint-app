import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/notifications/data/in_memory_notification_repository.dart';
import 'package:sprint/features/notifications/domain/notification.dart';

/// The notification centre's data rules (contracts/repositories.md): every
/// write signals `changes`, "mark all read" is per person, and a re-pushed id
/// is one record that keeps its first read state.
void main() {
  final sent = DateTime.utc(2026, 11, 18, 9);

  Notification note(
    String id, {
    String userId = 'u1',
    String type = 'booking.confirmed',
    DateTime? sentAt,
    DateTime? readAt,
  }) =>
      Notification(
        id: id,
        userId: userId,
        type: type,
        payload: const {'bookingId': 'b1', 'code': 'SP-1001'},
        sentAt: sentAt ?? sent,
        readAt: readAt,
      );

  test('push, markRead and markAllRead each signal changes', () async {
    final repo = InMemoryNotificationRepository();
    var events = 0;
    final sub = repo.changes.listen((_) => events++);

    await repo.push(note('n1'));
    await pumpEventQueue();
    expect(events, 1);

    await repo.markRead('n1', sent.add(const Duration(minutes: 1)));
    await pumpEventQueue();
    expect(events, 2);

    await repo.push(note('n2'));
    await pumpEventQueue();
    expect(events, 3);

    await repo.markAllRead('u1', sent.add(const Duration(minutes: 2)));
    await pumpEventQueue();
    expect(events, 4);

    await sub.cancel();
  });

  test('markAllRead only touches that person and only unread records', () async {
    final repo = InMemoryNotificationRepository([
      note('a', userId: 'u1'),
      note('b', userId: 'u1', readAt: sent),
      note('c', userId: 'u2'),
    ]);
    final at = sent.add(const Duration(hours: 1));

    await repo.markAllRead('u1', at);

    final u1 = await repo.list('u1');
    expect(u1.singleWhere((n) => n.id == 'a').readAt, at);
    expect(u1.singleWhere((n) => n.id == 'b').readAt, sent);
    expect((await repo.list('u2')).single.readAt, isNull);
  });

  test('pushing the same id twice is one record that keeps the first read '
      'state', () async {
    final repo = InMemoryNotificationRepository();
    await repo.push(note('rem-b1', type: 'booking.reminder'));
    await repo.push(
      note('rem-b1', type: 'booking.reminder', sentAt: sent.add(Duration.zero)),
    );

    final all = await repo.list('u1');
    expect(all, hasLength(1));
    expect(all.single.id, 'rem-b1');

    await repo.markRead('rem-b1', sent.add(const Duration(minutes: 5)));
    await repo.push(
      note('rem-b1', type: 'booking.reminder', sentAt: sent.add(const Duration(minutes: 6))),
    );
    expect((await repo.list('u1')).single.readAt,
        sent.add(const Duration(minutes: 5)));
  });

  test('newest first and a cancelled-by-me record is already read', () async {
    final repo = InMemoryNotificationRepository([
      note('old', sentAt: sent),
      note(
        'mine',
        type: 'booking.cancelled_by_owner',
        sentAt: sent.add(const Duration(minutes: 1)),
        readAt: sent.add(const Duration(minutes: 1)),
      ),
      note('new', sentAt: sent.add(const Duration(minutes: 2))),
    ]);

    final list = await repo.list('u1');
    expect(list.map((n) => n.id), ['new', 'mine', 'old']);
    expect(list.singleWhere((n) => n.id == 'mine').readAt,
        list.singleWhere((n) => n.id == 'mine').sentAt);
  });
}
