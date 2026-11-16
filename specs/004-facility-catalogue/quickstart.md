# Quickstart: Facility Catalogue and Details

How to run and check the feature once it is built. For what each screen must do, see
[spec.md](spec.md); for data shapes, [data-model.md](data-model.md); for routes and providers,
[contracts/](contracts/).

## Prerequisites

- Flutter 3.47.9 stable (the version CI uses). From the repo root:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

- Work in the `Sprint-App-004` working copy on branch `004-facility-catalogue`. Another session may be
  working on feature 003 in the main folder; use a different port for each web run.

## Run

```bash
flutter run -d chrome --web-port 8084
```

The app opens as a guest. The reviewer switcher on `/demo` signs in as a seeded user (the verified
booker for the internal tier, the unverified booker for the external tier).

## Scenarios to check by hand

1. **Guest discovery (US1)**: open the app signed out. Home shows facility types and featured
   facilities with prices for both tiers and no sign-in prompt. Tap a type: the list opens filtered.
   Tap a card: details open.
2. **List and filters (US2)**: on `/facilities` apply type, owning unit and free / paid alone and
   together. Check the chips, the result count, the clear actions and the empty state (type tennis
   plus free). Open a facility, go back: filters and scroll are kept.
3. **Details of each kind (US3)**: open the pool (shared lanes, "للمكان الواحد"), the futsal pitch
   (exclusive, "للحجز كله"), the free hall (no price, closed Fridays), the academy (trainers, session
   facts) and the pool's lane 6 (its own evening hours line). Tap "عرض المواعيد": the "قريبًا" screen
   opens and back returns.
4. **Signed-in home (US4)**: switch to a user with a confirmed upcoming booking: bookings first, then
   suggestions with a reason. Switch to a user with none: discovery plus the short note. Sign out:
   back to guest content.
5. **Share (US5)**: use the share action; open the produced link in a new tab; reload on a facility
   URL; open `/#/facilities/does-not-exist` and confirm the not-found screen.
6. **Every size, language, theme (US6)**: resize the window across 600, 840 and 1200; flip Arabic and
   English; flip light and dark; set text to 200% (the component gallery at `/demo/components` has a text-size control); turn on
   reduce-motion; tab through with the keyboard.

## Automated checks

```bash
flutter analyze
flutter test
flutter build web --release --base-href /sprint-app/
```

All three must pass before the pull request (constitution, Development Workflow). New tests live in
`test/features/catalogue/`; the guards in `test/guards/` run over the new files unchanged.

## Expected outcome

- `flutter test` shows the new catalogue tests passing and the Foundation and 002 suites unchanged.
- Every acceptance scenario in the spec can be shown from a cold start in under 3 minutes (SC-010).
