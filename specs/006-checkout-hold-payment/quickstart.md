# Quickstart: validating feature 006

## Prerequisites

- Flutter 3.47.9 stable, from the worktree root.
- `flutter pub get && dart run build_runner build --delete-conflicting-outputs`
- Demo tools on (default build). Sign in as the seeded verified booker (see `lib/core/seed/`).

## Automated

```bash
flutter analyze
```

```bash
flutter test
```

Key suites: `test/features/booking/domain/hold_policy_test.dart` (BR-46 extension and cap), `test/features/booking/data/checkout_flow_test.dart` (every outcome, leave, late refund, race), `test/features/payments/` (fake provider, receipt numbering), `test/features/booking/presentation/checkout/` (states × sizes × themes × directions, back handling, 200% text), `test/acceptance/us10_*`, `us12_*`, `us06_paid_*`, guards (no raw `Icon(`, no card data in storage).

## Manual walk (web and one mobile platform)

Run the app (`preview_start` on the web config, or `flutter run`). For each row set the outcome on `/demo` → "الدفع التجريبي" first.

| # | Setup | Steps | Expected |
| --- | --- | --- | --- |
| 1 | نجاح | Pool lane 3, paid slot → متابعة للدفع → الدفع → test card `4242 4242 4242 4242` → تأكيد الدفع | Processing, then "حجزك اتأكد", ticket with QR and code, "إيصال الدفع" opens receipt; PDF saves |
| 2 | فشل | Same → تأكيد الدفع | "الدفع ماتمّش. ممكن تحاول تاني", Hold unchanged; set نجاح, إعادة المحاولة → confirmed |
| 3 | any | On provider page → إلغاء | Back on payment with "الدفع اتلغى", same countdown |
| 4 | any | On payment → back (button, gesture, browser back) | "ترك الدفع؟"; "ترك الدفع" → summary, slot free for another account |
| 5 | `holdMinutes` = 1 (settings inspector) | Enter payment and wait | Last-minute banner in seconds, then "المهلة خلصت"; slot free |
| 6 | تأخير 30 s | Pay | Processing → after 20 s "لسه مستنيين" → confirmed |
| 7 | تأخير "بعد الحد الأقصى", `holdMinutes` = 1, `holdMaxMinutes` = 2 | Pay, wait | Countdown jumps to the maximum, then expired; when the delay ends a refund record and an in-app record exist, booking stays expired |
| 8 | free facility | Book a range | Same confirmation screen, "السعر · مجاني", no receipt |
| 9 | second account | While account A holds the last place, account B tries it | B is refused "الميعاد ده اتحجز" |
| 10 | — | Repeat 1 on medium, expanded, large; Arabic/English; light/dark; text 200% | Layout per `design-pack/adaptive.md`, nothing cut, QR on white |
| 11 | — | Refresh the browser on the payment, processing and confirmation screens | Same state and countdown |

Record evidence in `specs/006-checkout-hold-payment/evidence.md` as earlier features did.
