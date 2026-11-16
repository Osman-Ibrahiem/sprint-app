# Research: Facility Catalogue and Details

Decisions taken in the plan so tasks do not have to guess. Each has the choice, the reason and what was
rejected. Facts about the existing code were read on 2026-11-16 from the `develop` branch tip.

## R1. Where the screens plug in

- **Decision**: Replace the builders of the `home` and `facilities` entries of `baseDestinations`
  (`lib/app/router/routes.dart`) with the new screens. Add an optional `subRoutes` list to
  `ShellDestination` (default empty) and have `buildAppRouter` pass it to the branch's `GoRoute`. The
  facilities destination gets two sub-routes: `:id` (details) and `:id/schedule` (coming soon).
- **Why**: the router is built from destination data (the Foundation's route contract, rule 4), so the
  catalogue needs no special case in the router and role-driven destinations keep working. Sub-routes
  inside the facilities branch keep the navigation bar and the branch's own back stack.
- **Rejected**: top-level routes outside the shell (lose the navigation bar and the per-tab stack);
  a hard-coded `if (d.name == facilities)` in `app_router.dart` (breaks the data-driven rule).

## R2. One screen, three layouts (master-detail)

- **Decision**: `/facilities` builds `FacilitiesScreen(selectedId: null)` and `/facilities/:id`
  builds `FacilitiesScreen(selectedId: id)`. By window size: **compact** shows the list when no id and
  the details alone when there is one; **medium and larger** show list and details side by side through
  `DisplayFeatureLayout` (so a hinge never sits under content). With no id on medium+, the details pane
  shows a short "اختار منشأة" hint.
- **Why**: the same URL always means the same facility at any width, so resizing, rotating and
  folding keep the selection (FR-013); on compact the details page is pushed on top of the list page,
  so the list page and its scroll position stay alive underneath.
- **Back from details**: the app bar's back runs `pop` when it can, and otherwise `go('/facilities')`
  (a deep link or a medium-to-compact resize can leave no list below).
- **Rejected**: separate details screens per size (state is lost on resize); a nested navigator inside
  the pane (back gesture and web address would disagree).

## R3. Today's availability summary

- **Decision**: a pure `TodayAvailability` rule takes the unit slots of today (from
  `AvailabilityRepository.slots(unitId, today, today)`) and the resolved few-left threshold. Count =
  sum of `remaining` over bookable slots that have not started; level = `none` when 0, `few` when
  count is at most the threshold (BR-45), otherwise `plenty`. A facility closed today (no slots) is
  `none`. The same result feeds `FacilityCard.availability` and `availableCount` and the details
  section.
- **Why**: the Foundation already computes slots with windows, closures, hours and holds, so the
  summary reuses it instead of re-deriving availability (FR-027). The 002 card README says the
  catalogue feature decides the level, and the threshold is a setting (`fewLeftThreshold`), resolved
  at facility scope.
- **Trainer facilities**: slots are requested without a trainer filter, which the repository treats
  as the unit's own slots; if the Foundation returns none for a trainer facility without a trainer,
  the rule falls back to the facility's unit slots only for the summary. Verified when writing tests
  (a task), not assumed here.
- **Rejected**: a new "availability today" method on the repository (a second source of truth);
  computing from hours alone (ignores bookings and holds).

## R4. Suggestions and featured facilities

- **Decision**: `SuggestionRule` is pure. Input: published facilities, the user's past bookings
  (any status that was a real booking: confirmed, attended, no-show), the facility ids of their
  upcoming confirmed bookings. Output: at most **4** `Suggestion(facility, reason)`: first facilities
  whose type the user booked before (reason `bookedTypeBefore(type)`), ordered by how often, then by
  name; then the rest in a fixed order (by name); never a facility with an upcoming booking. A guest or
  a user with no history gets the featured list instead, no personal reason.
- **Featured** (guest and fallback): published facilities, ordered by today's availability count
  descending then by name, capped at **6**. Both caps are named constants in
  `suggestion_rule.dart` and `home_screen.dart`'s section config, not settings, because the BRD does
  not define them and they are presentation choices.
- **Why**: deterministic, explainable, local, no AI (FR-004, CLAUDE.md).
- **Rejected**: a ranking model; collaborative filtering (needs other users' data and is AI-like).

## R5. State that survives navigation

- **Decision**: three small keep-alive Riverpod notifiers: the facility filter (`FacilityFilter`
  Freezed value), the list scroll offset, and nothing else. The list restores its offset when it is
  built again (a medium+ selection replaces the route's page and would otherwise reset it). Filters
  are not written to disk or the URL.
- **Why**: FR-013 and SC-006 only need the state to survive moving within the app, rotating,
  resizing and folding. The shell already keeps each branch alive.
- **Rejected**: filters in the URL (the share link must stay `/facilities/<id>`; query strings add a
  second contract); persisting to storage (stale filters on the next launch confuse a demo).

## R6. Seed data and photos

- **Decision**: reuse the Foundation seed (6 facilities from 3 owning units: a shared-lane pool, an
  exclusive-pitch futsal, a gym, tennis, a free hall closed Fridays, a trainer academy with 3
  trainers; a unit closure on pitch A). Add `seed_catalogue_extras.dart` with only what the stories
  need and the seed lacks: (a) one unit with its own hours (pool lane 6, evening only), (b) one
  facility-level closure that is upcoming (not current), so a "closed now" state is tested with a test
  fixture rather than a seed that would disturb other features' tests. It is wired in with one line
  where the data layer builds its lists. If adding to the seed breaks an existing test, the case moves
  to a test fixture instead of editing the Foundation's tests.
- **Photos**: the seed keeps `photos` empty. There are no real images and stock images are forbidden
  (design README), so every facility shows the "صورة المنشأة" placeholder. The carousel (one photo: no
  controls; several: swipe plus position indicator with Arabic labels) is verified by widget tests with
  injected `ImageProvider`s. **FR-029 is amended** to say this (spec edit in this plan step).
- **Rejected**: bundling stock or generated images; editing `seed_units.dart` (shared file that
  feature 003 may also touch).

## R7. Share link and the share action

- **Decision**: `FacilityLink.path(id)` returns `/facilities/<id>`; `FacilityLink.parse(location)`
  returns the id or null. The full URL is built from a base: on the web, the current origin plus the
  base href and the hash (`.../sprint-app/#/facilities/<id>`, because the app uses the hash URL
  strategy); on the other platforms, a compile-time `SPRINT_WEB_BASE` value that the deploy workflow
  sets to the Pages URL (a task adds the `--dart-define` to `deploy.yml`; until set, the share text is
  the facility name and the path). The action goes through `share_plus` (native share sheet on iOS and
  Android, the web share API or copy on web, desktop fallback) behind a tiny `ShareAction` seam so
  tests replace it, plus a copy-link item that uses `Clipboard`.
- **Why**: FR-024 and FR-025; a facility id never changes when the name does (clarify, 2026-11-16).
  The Foundation chose hash URLs (router comment, R10), so a reload reopens the same facility without
  server rewrites.
- **Native app links** (opening the installed app from outside) stay out of scope (spec).
- **Rejected**: a slug in the link (settled against in clarify); writing a custom share sheet
  (violates "native behaviour per platform").

## R8. Prices and "whose price"

- **Decision**: `PriceGroups` groups a facility's active units by (booking mode, internal amount,
  external amount); each group shows both tiers and its basis ("للمكان الواحد" for `SHARED`, "للحجز
  كله" for `EXCLUSIVE`, BR-16) and lists its unit names, or "كل الوحدات" when it covers all of them.
  The booking mode is read per unit from settings. A unit with no price is reported as "no price yet",
  never as 0. For a free facility the groups are empty and the page says "مجاني" (BR-19). The signed-in
  user's tier comes from `currentSessionProvider` (`Session.tier`) and is shown with the word "سعرك"
  on that column; the other column stays visible. `FacilityCard.price` follows its own README: both tiers for a guest, the user's tier with its audience label for a signed-in user. When a facility's priced units all share one price per tier, the card shows that price. When they differ, the card shows a range ("40–60 ج.م"), never a lone lowest price, so it cannot mislead like "ابتداءً من" (the README forbids that); the details page then shows each group.
- **Why**: the Foundation seed gives one price per tier per facility, so one price per tier is the common
  case; the range is a safety net for real data.
- **Rejected**: tier from verification status re-computed in the screen (the session already carries
  it, and it is frozen on a booking only in feature 6).

## R9. Keeping the merge with feature 003 easy

Feature 003 works in another working copy on its own branch and will touch the router, the ARB files,
the seed (users) and `pubspec.yaml`. This feature therefore: adds ARB keys only with the `catalogue`
prefix and in alphabetical blocks at the end of each file; adds routes only as sub-routes of the
facilities branch and never reorders existing ones; adds seed only in a new file; adds `subRoutes` to
`ShellDestination` as an optional field; does not touch `CLAUDE.md`, `docs/` or `identity`; and keeps
`pubspec.yaml` edits to one line. Merge order: 003 into `develop` first, then `develop` into this
branch (merge commit, never rebase, per the workflow) before the implement phase finishes.

## R10. What the screens read, and failure handling

- **Decision**: providers (Riverpod codegen, `AsyncValue`) return plain view models (see
  data-model.md). Each screen shows a skeleton while `loading`, a clear error with a retry action on
  `error` (retry invalidates the provider), and the content otherwise. Reads: catalogue (facilities,
  owning units, units, hours, closures, prices, trainers), identity (trainer names via `getUser`),
  availability (today's slots), bookings (`listForUser`), settings (resolved per facility / unit).
- **Failure test**: a test overrides the catalogue repository provider with one that throws once, then
  succeeds, to prove the error state and the retry (spec US-6).
- **Rejected**: screens calling repositories directly (no single loading and error path); a global
  error handler (the retry has to stay on the failed screen).
