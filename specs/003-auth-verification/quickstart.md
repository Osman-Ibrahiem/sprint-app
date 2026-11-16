# Quickstart: Auth and Verification

How to run the feature and check each story. Commands run from the repository root.

## Prerequisites

Flutter 3.47.9 stable (as CI), features 001 and 002 merged into `develop`, this branch checked out.

```bash
flutter pub get
```

```bash
dart run build_runner build --delete-conflicting-outputs
```

```bash
flutter gen-l10n
```

## Automated checks (all must pass)

```bash
flutter analyze --fatal-infos
```

```bash
flutter test
```

What these cover: validators and national ID rules (R5), password hashing (R3), codes, resend wait and lockout on a fake clock (R4), the repository contract suites for auth and verification ([contracts/repositories.md](contracts/repositories.md)), sheet parsing (R8), scope filtering (FR-032), tier and expiry (R9), booking freeze (SC-007), snapshot round trip and fallback (R1), the gate and redirects ([contracts/routes.md](contracts/routes.md)), the privacy guard (SC-006), one acceptance test per BRD scenario of US-02 to US-05 (SC-005), and the Foundation and 002 guards.

## Demo accounts

Every seed person signs in with the demo password in `lib/core/seed/seed_credentials.dart`. Emails are `<name>@example.test` (see `lib/core/seed/seed_users.dart`). Useful ones:

| Who | Use it for |
| --- | --- |
| كريم السيد (external booker) | request verification that the sample sheet matches |
| دينا محمود (pending, Faculty of Physical Education) | approve by hand as the seed verifier |
| the new pending person in Engineering | proves the PE verifier cannot see it; the super admin can |
| the unconfirmed account | sign in goes to the code step |
| the suspended account | sign in is refused with the suspended message |
| the seed verifier (PE) | review queue, approve, reject, upload |
| د. هالة إبراهيم (super admin) | sees every request |

Sample sheet for the live upload: `assets/demo/verification_sheet_sample.csv`.

## Run the app

```bash
flutter run -d chrome
```

Demo tools (mailbox, code notice, user switcher, reset) are on by default. To check a build without them:

```bash
flutter run -d chrome --dart-define=HIDE_DEMO_TOOLS=true
```

## Check each story

1. **Sign up and confirm (US 1, SC-001)**: as a guest open Profile → "إنشاء حساب", fill valid details, submit. Read the code in the demo notice, or in Demo → "صندوق البريد التجريبي". Enter it: signed in, tier external. Try a seed email or phone: "مسجل قبل كده" with sign in and reset offered.
2. **Sign in (US 2, SC-002, SC-009)**: sign in by email as a booker and by phone as the verifier; compare sections. Enter a wrong password, an unknown email and an unknown phone: the same message. Five wrong passwords: the wait shows. Reload the page: still signed in. Sign out from Profile.
3. **Gate (US 3, SC-003)**: as a guest open My Bookings → "تسجيل الدخول", sign in: back on My Bookings. Open `/#/verification` as a guest: sign in as the verifier lands on it; as a booker it shows no access.
4. **Reset (US 4)**: sign in → "نسيت الباسورد", enter a seed email, read the code, set a new password; the old one fails.
5. **Request (US 5)**: as كريم, Profile → "طلب التوثيق" with the national ID and code from the sample sheet's matching row: internal at once with the expiry date. As another external person, a request with no match: under review, still external. A national ID of another seed person: refused with the reason.
6. **Review (US 6, SC-004)**: as the PE verifier, approve دينا and reject another request with a reason; the Engineering request is not listed. Upload the sample sheet: summary with read, added, duplicate, invalid and approved counts. Switch to each person: tier, reason, notification.
7. **Freeze (US 7, SC-007)**: as كريم, note an existing booking's price, get verified, check the booking is unchanged.
8. **Persistence and reset (FR-013a, FR-013b)**: create an account, reload: it is there. Demo → "إرجاع الداتا التجريبية": back to the seed, signed out, theme and language kept. Note: seeded dates stop moving while a snapshot exists; reset before each rehearsal.

## Cross-cutting checks (SC-008)

For each new screen: Light and Dark; Arabic and English; compact (phone) and expanded (desktop or tablet) widths; text at 200%; keyboard only on web or macOS (Tab order, Enter submits, focus ring); VoiceOver or TalkBack reads labels, errors and the code field as one field. Codes, phones, emails and national IDs stay left to right inside Arabic text.

## Web load check (Foundation SC-011)

Measure the published build as in `specs/001-foundation/evidence.md` and record it in `evidence.md`: the splash within 1 second and interactive within 5 seconds on Fast 4G must still hold with the new packages.
