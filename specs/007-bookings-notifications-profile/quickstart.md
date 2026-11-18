# Quickstart: validating feature 007

## Prerequisites

- Flutter 3.47.9 (as CI). `flutter pub get`, then `dart run build_runner build --delete-conflicting-outputs` (freezed and riverpod outputs are committed).
- Run the web build: `flutter run -d chrome`. Demo data resets from `/demo`.

## Static checks and tests

```bash
dart analyze
flutter test
flutter build web --release
```

## Walk (compact 390 and desktop 1440; Arabic then English; light then dark)

1. **Guest**: open the app, tap "حجوزاتي" (account gate), "حسابي" (guest card with language and appearance), search a word from Home (results, no results, recents). No bell, no notifications destination.
2. **Booker** (`/demo` user switcher): Home shows upcoming bookings; tap one: details with ticket and cancel; tap "كل حجوزاتي": list with "الجاية / السابقة" and the empty states.
3. **Cancel**: cancel a paid booking at the default settings (full), change `refundPercent` to 50 then 0 in the settings inspector and cancel others, cancel a free booking, open one inside the cutoff (no button, line with the time).
4. **Pending payment**: start a paid booking, open it from "حجوزاتي", cancel while holding; then in `/demo` set the provider to delay and confirm cancel is not offered while processing.
5. **Facility cancel and reminder**: `/demo` "إلغاء من الإدارة" on a booking (full refund, notification, red-free neutral wording) and "إظهار تذكير حجزي الجاي" (reminder with cancel, then after the cutoff without).
6. **Notifications**: bell badge, mark all read, tap each kind to its destination, permission dialog once, Account "الإشعارات" row changes the stored answer.
7. **Account**: every verification state, edit name and photo (locked email and phone), sign out.
8. **Resize** across 600, 840 and 1200 and fold: selection, search text, unread state and scroll are kept.
9. **Accessibility**: text scale 200%, keyboard only on web, screen reader labels in Arabic, 48 targets.

## Expected outcomes

Map to SC-001 to SC-009 in [spec.md](spec.md); every branch above is reachable without a code change. Evidence goes to `evidence.md` (screenshots per window class, test output, analyzer, web build).
