# Quickstart: Availability and Booking

How to run and check the feature once it is built. What each screen must do is in
[spec.md](spec.md); shapes are in [data-model.md](data-model.md); routes and providers are in
[contracts/](contracts/).

## Prerequisites

- Flutter 3.47.9 stable (the version CI uses). From the repo root, on branch
  `005-availability-booking`:

```bash
flutter pub get
```

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Automated checks

```bash
flutter analyze
```

```bash
flutter test
```

Both must pass, including the guard tests and the new acceptance tests
(`test/acceptance/us01_slots_guest_return_test.dart`, `us06_…`, `us07_…`, `us08_…`, `us09_…`,
`us11_…`).

## Run

```bash
flutter run -d chrome
```

The app opens as a guest. `/demo` has the account switch for seeded users (password in
`SeedIds.demoPassword`). If the device has demo data saved from before this feature, use
"إرجاع الداتا التجريبية" once so the new seed cases appear.

## Scenarios to check by hand

Seed days are relative to today; "day +3" is three days from now.

1. **Schedule as a guest (US1)**: open "حمام السباحة الأولمبي" → "عرض المواعيد". Seven days show, the
   first with places is selected, the unit picker lists six lanes. Lane 2 on day +3 shows 10:00 ص as
   "مكتمل"; lane 2 on day +2 shows one slot as "فاضل 1". Today's earlier slots show "فات". Both tier
   prices show. Nothing asks for sign-in.
2. **Closed day (US1)**: "ملعب كرة القدم الخماسي", ملعب أ, day +3: no slots for that unit (closure);
   ملعب ب still has slots. "الصالة المغطاة" on a Friday: the day is closed and cannot be selected.
3. **Guest returns to the slot (US3)**: as a guest pick a pool slot → "متابعة" → the gate shows →
   sign in as the external booker → the same slot is still selected and the price is now "السعر
   الكامل" only → "متابعة" opens the summary. Repeat with sign-up. Reload the page with a slot
   selected: it is still selected.
4. **Paid slot to the summary (US2)**: as the internal booker book ملعب ب. The summary shows the
   facility, unit, date, time, "الملعب كله" with 22 participants, "سعر الطلاب والعاملين", 140 ج.م
   "للحجز كله", and the cancellation policy. On the pool the policy says 4 hours (facility override).
   "متابعة للدفع" opens "قريبًا"; back returns to the summary; back again to the schedule with the slot
   still selected. No booking appears on home.
5. **Own overlap (US2)**: as the internal booker (who has lane 1 on day +3 at 6:00 م), tap ملعب التنس
   on day +3 at 6:00 م: it is not selected and the notice names the pool booking.
6. **Slot taken meanwhile (US2, clarify Q1)**: paid bookings are not created in this feature, so use
   the free hall. As user A select قاعة 2 for an hour and copy the address. Switch to user B and
   confirm the same hour. Switch back to A, open the copied address and tap "متابعة": the notice says
   the hour was just booked and the slot shows "مكتمل".
7. **Free range (US4)**: "الصالة المغطاة", قاعة 2: tap 4:00 م then 6:00 م (ends 7:00 م): three chips
   in a range, the length shows in words. Try to extend to a fourth hour: refused with the maximum.
   On قاعة 1, day +4, try 9:00 ص to 11:00 ص: refused, naming 10:00 ص. Confirm a valid range: the
   success screen shows the code and details with no QR; home shows the booking under upcoming; back
   from success lands on the schedule, where the hours are now taken.
8. **Trainer (US5)**: "أكاديمية التدريب" → the trainer step shows three trainers. Choose the first:
   one grid of sessions, no unit picker. On day +4 the 10:00 ص session shows "مكتمل" although the room
   has places. "تغيير المدرب" clears the selection. The summary names the trainer and the room.
9. **Tier (US6)**: compare one pool slot as internal (20 ج.م), external (40 ج.م, with the
   verification pointer) and the pending user (40 ج.م, "under review").
10. **Settings (SC-008)**: in the demo settings inspector change the booking window to 3 days, the
    few-left threshold to 5, the maximum range to 2 hours and the pool's capacity; reopen the schedule
    and see each take effect.
11. **Adaptive (US7)**: resize through compact, medium, expanded and large; switch Arabic / English
    and light / dark; set text to 200%; tab through with a keyboard; turn on reduced motion. The
    selection survives every change.

## Done when

- `flutter analyze` and `flutter test` pass, and CI's web build passes.
- Every scenario above behaves as described on web, and scenarios 1, 4, 7 and 8 also on one iOS and
  one Android target.
- The evidence file (`evidence.md`) records the runs, as in earlier features.
