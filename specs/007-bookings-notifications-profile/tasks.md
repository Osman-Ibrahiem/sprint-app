---

description: "Task list for feature 007 — my bookings, cancellation, notifications, account and search"
---

# Tasks: My Bookings, Cancellation, Notifications, Account and Search

**Input**: Design documents from `/specs/007-bookings-notifications-profile/` (spec.md, plan.md, research.md R1–R14, data-model.md, contracts/repositories.md, contracts/routes.md, quickstart.md, design-pack/)

**Prerequisites**: plan.md, spec.md (clarified 2026-11-18)

**Tests**: Included. The constitution requires all automated tests to pass for a PR, and the cancel, refund, reminder and search rules are timing- and data-sensitive, so rule tests come before the code they cover.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an unfinished task)
- **[Story]**: US1 my bookings list · US2 booking details · US3 cancel a confirmed booking · US4 cancel a booking not yet paid · US5 notifications centre and bell · US6 reminders and permission · US7 account · US8 edit profile · US9 search · US10 every size, language, theme and every branch on demand
- Paths are relative to the worktree root (single Flutter package, see plan.md)

## Rules for every task

- Tokens only, no raw colours or numeric style literals (layout constants the tokens lack go to `lib/core/tokens/sprint_extras.dart` as named constants, R13); direction-aware layout; strings only in `lib/l10n/*.arb`, Arabic and English together, taking the Egyptian, non-imperative wording of `specs/007-bookings-notifications-profile/design-pack/` (replace "تمت الموافقة" with an Egyptian form; where the pack and `docs/design-system/README.md` disagree on copy, the README wins). Western digits; 12-hour Cairo time; amounts through `SprintFormat` ("80 ج.م" / "EGP 80"); booking codes, phones and emails in LTR isolates.
- Every number the BRD calls a setting (`cancellationCutoffHours`, `refundPercent`, `reminderLeadMinutes`, `fewLeftThreshold`) is read through `SettingsRepository` / `UnitSettings.resolve`, never typed into a screen or rule. Amounts, percentages, times and lead words in cancel and reminder texts come from the booking and the settings. Sample numbers in Figma (80, 40, 3 ساعات, الأحد 3:00 م) are samples only.
- Rules live behind the repositories and the pure services (`CancellationPolicy`, `ReminderPolicy`, `FacilitySearch`); screens only show outcomes. `lib/features/booking/domain/`, `lib/features/notifications/domain/` and `lib/features/catalogue/domain/` import nothing from Flutter, Riverpod or `data/` (existing guards plus the new one in T002). Presentation reads repository interfaces through `lib/core/providers/data_providers.dart`.
- No platform checks outside `lib/core/adaptive/`; dialogs through `showSprintDialog`, sheets through `showSprintSheet`, loaders through `AdaptiveLoader`, app bars through `AdaptiveAppBar`. Reuse 002 widgets (`BookingTicket`, `StatusBadge`, `SprintButton`, `SprintTextField`, `Skeleton`, `EmptyState`, `OptionGroup`). Icons through `SprintIcon` / `DirectionalIcon`.
- One primary `SprintButton` per screen. Every state carries a word or an icon, never colour alone. Targets at least 48 (including links, popover rows, sidebar rows and clear buttons). Motion respects `MediaQuery.disableAnimationsOf`. No Lottie: static art.
- No national ID, ID photo or card data on any new screen, log or share (NFR-06, SC-008).
- Do not edit `tokens.json` except the one sample string in T082; do not edit Figma. `docs/` edits only in the component README tasks of Phase 3 and in Phase 14.
- Commit messages cite BRD IDs. Branch `007-bookings-notifications-profile`. No force-push, no rebase, no push unless Osman says so.
- After editing an ARB file run `flutter gen-l10n`; after editing a Riverpod or Freezed file run `dart run build_runner build --delete-conflicting-outputs`.

---

## Phase 1: Setup

- [ ] T001 Run `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`, `flutter analyze` and `flutter test` on the clean branch; all must pass. Create `specs/007-bookings-notifications-profile/evidence.md` with a "Baseline" section (date, passing test count).
- [ ] T002 [P] Add `test/guards/notifications_domain_pure_test.dart` modelled on `test/guards/booking_domain_pure_test.dart`: files in `lib/features/notifications/domain/` may not import Flutter, Riverpod or `data/`.
- [ ] T003 [P] Add `test/guards/privacy_new_screens_test.dart`: source scan that no file under `lib/features/account/`, `lib/features/notifications/presentation/`, `lib/features/booking/presentation/bookings/`, `details/` and `cancel/` references `nationalId`, `maskNational`, `photoId` (ID card) or `cardLast4` (NFR-06, SC-008).

---

## Phase 2: Foundational domain and data (blocks every user story; tests first)

**Purpose**: all rules and repository changes, no UI.

- [x] T004 [P] Write `test/features/booking/domain/cancel_preview_test.dart` first: `CancellationPolicy.preview` for `full` (refundPercent 100), `partial` (50 on 80 → 40), `none` (0), `free` (`priceAtBooking == 0`), `closed` (after `start - cutoffHours`), `notAllowed` (attended, no-show, cancelled, expired, or `paymentPending: true`), facility cancel always `full` and not after `end` (BR-32), `cancelUntil == start - cancellationCutoffHours`.
- [x] T005 Add `cancelledAt` (`DateTime?`, UTC) to `lib/features/booking/domain/booking.dart` and let `Booking.cancel(by, {reason, at})` accept `pendingPayment` for `CancelledBy.owner` (data-model: transitions; `cancelledAt` set with `cancelledBy`, null for every other status); regenerate freezed and json. Update existing tests that assert `cancel` from other statuses.
- [x] T006 Create `lib/features/booking/domain/cancel_preview.dart` (`CancelKind {full, partial, none, free, closed, notAllowed}` and `CancelPreview{kind, paidAmount, refundAmount, refundPercent, cancelUntil}`; refund `paidAmount * refundPercent ~/ 100`, 0 for `none`, `free` and not-yet-paid) and add `preview(...)` with the `paymentPending` flag to `lib/features/booking/domain/cancellation_policy.dart`; make `decide(...)` call `preview()` and keep `canOfferCancel` as the single "button shown" check. T004 passes.
- [x] T007 [P] Write `test/features/notifications/domain/notification_kind_test.dart`: `NotificationKind.fromWire` for the eight wire values (`booking.confirmed`, `booking.reminder`, `booking.cancelled_by_admin`, `booking.cancelled_by_owner`, `payment.refunded_auto`, `verification.pending`, `verification.approved`, `verification.rejected`) and `unknown` for anything else; round-trip through `Notification` JSON keeps the wire string.
- [x] T008 Create `lib/features/notifications/domain/notification_kind.dart` (closed enum with `wire` and `fromWire`, `unknown` fallback). Update `lib/features/notifications/domain/notification.dart` with a `kind` getter reading `type`; payload keys `bookingId`, `code`, `verificationId`, `reason`, `amount` documented. Tests T007 pass.
- [x] T009 [P] Write `test/features/notifications/data/in_memory_notification_repository_test.dart`: `changes` fires on `push`, `markRead`, `markAllRead`; `markAllRead(userId, at)` only touches that user's unread; `push` is an upsert by id (same id twice → one record, the first `readAt` kept); newest first; the "cancelled by me" record (`readAt == sentAt`) never counts as unread.
- [x] T010 Extend `lib/features/notifications/domain/notification_repository.dart` with `Stream<void> get changes` and `markAllRead(String userId, DateTime at)`, make `push` an upsert, and implement them in `lib/features/notifications/data/in_memory_notification_repository.dart` (contracts/repositories.md). T009 passes; the data layer snapshot still decodes old saves.
- [x] T011 [P] Write `test/features/booking/data/booking_cancel_007_test.dart` first (use `DataEnv`, `test/helpers/data_env.dart`): owner cancel from `confirmed` before the cutoff refunds the computed amount once and writes a `booking.cancelled_by_owner` notification with `readAt == sentAt` and payload `bookingId`, `code`, `amount`; second `cancel` call returns the already-cancelled booking and creates no second refund or notification; after the cutoff → `CancellationClosed`; free booking → no refund, notification still written; admin cancel → 100% whatever `refundPercent`, notification `booking.cancelled_by_admin`; owner cancel from `pendingPayment` while holding and latest payment not `pending` → `CANCELLED` by owner, no refund, place free for another booker at once (BR-48); with a payment `pending` → `InvalidTransition`; Hold already ended → `InvalidTransition` and the booking is `EXPIRED`; `previewCancel` never mutates.
- [x] T012 Implement in `lib/features/booking/data/in_memory_booking_repository.dart` and `lib/features/booking/domain/booking_repository.dart`: `cancel` for `pendingPayment` (releases the Hold, sets `cancelledAt`, no refund), `Future<CancelPreview> previewCancel(String id, String actorUserId)`, the owner-cancel notification (kind `bookingCancelledByOwner`, `readAt = now`), idempotent second cancel, set `cancelledAt` on every cancel. T011 passes.
- [x] T013 [P] Write `test/features/booking/data/booked_counts_test.dart`: `bookedCounts(since)` counts `CONFIRMED` and `ATTENDED` bookings with `start >= since` per facility across all users; cancelled, expired and pending are ignored.
- [x] T014 Implement `Future<Map<String, int>> bookedCounts({required DateTime since})` in the interface and the in-memory repository. T013 passes.
- [x] T015 [P] Write `test/features/booking/data/housekeeping_no_show_test.dart` with `fake_async`: the keepAlive housekeeping provider also calls `markNoShows()` so a confirmed booking past its end becomes `NO_SHOW` (BR-37) with an Attendance row and no penalty, and `ATTENDED` bookings are untouched.
- [x] T016 Extend `holdHousekeeping` in `lib/features/booking/presentation/providers/checkout_providers.dart` so the same timer also calls `markNoShows()`; add a `bookingsRevision`-style invalidation if the lists need it. T015 passes.
- [x] T017 [P] Write `test/features/notifications/domain/reminder_policy_test.dart` first: `ReminderPolicy.due(bookings, existingReminderIds, now, leadMinutesFor)` returns a confirmed booking when `start - leadMinutes <= now < end`, not before, not after the end, not when `rem-<bookingId>` exists, not for cancelled, attended, no-show, expired or pending bookings; changing `leadMinutes` after a record exists never re-creates it.
- [x] T018 Create `lib/features/notifications/domain/reminder_policy.dart` (pure) and `lib/features/notifications/data/reminder_scheduler.dart` plus `lib/features/notifications/presentation/providers/reminder_providers.dart`: a keepAlive provider that runs the policy on build, every 60 seconds and on app resume (`WidgetsBindingObserver`), resolves `reminderLeadMinutes` with `UnitSettings.resolve` per booking, and writes `Notification(id: 'rem-<bookingId>', kind: bookingReminder, payload {bookingId, code})` through the repository; add `forceReminder(String bookingId)` for `/demo` (same record, no window check). Test the 60-second tick and the resume path with `fake_async` in `test/features/notifications/data/reminder_scheduler_test.dart`. T017 passes.
- [ ] T019 [P] Write `test/features/identity/data/update_profile_test.dart`: `updateProfile(userId, name:, avatarId:, clearAvatar:)` trims the name and requires "at least 2 characters after trimming" else `Err(InvalidName)`; never changes `email`, `phone` or `nationalId`; signals `changes`; the session refreshes with the new name.
- [ ] T020 Add `avatarId` (`String?`) to `lib/features/identity/domain/user.dart` (regenerate freezed and json), `updateProfile(...)` and `InvalidName` to `lib/features/identity/domain/identity_repository.dart` (and `lib/core/result/failure.dart`), implement in `lib/features/identity/data/in_memory_identity_repository.dart` (move `updateUser` behind the interface). T019 passes.
- [ ] T021 [P] Create `lib/features/identity/presentation/profile_photo_provider.dart` and `avatar_encoder.dart`: `ProfilePhotoStore.save/load/delete` over the existing photo store (`avatar-<userId>`, `StorageFull` on failure), encoder with max side 512 and JPEG quality 80 reusing the ID card encoder code path; `profilePhotoProvider(userId)`. Test in `test/features/identity/presentation/profile_photo_test.dart` (save, load, delete, StorageFull, oversize image downscaled, unsupported file → friendly failure keeps the old photo).
- [ ] T022 [P] Write `test/features/catalogue/domain/facility_search_test.dart` first: `ArabicNormalizer` drops tashkeel and unifies أ إ آ → ا, ة → ه, ى → ي and lowercases Latin; `FacilitySearch.filter` matches name, type label and owning unit name; order "open today by `today.count` descending, then closed today, ties by normalised name"; spaces-only and empty query return all; very long and mixed Arabic and English text never throws.
- [ ] T023 Create `lib/features/catalogue/domain/arabic_normalizer.dart`, `facility_search.dart` and `search_suggestions.dart` (pure; `SearchSuggestions{mostBooked: two facility ids by count, ties by name; recents}`). T022 passes.
- [ ] T024 [P] Write `test/features/catalogue/data/device_stores_test.dart`: `RecentSearchesStore.add` keeps at most 5 terms, newest first, deduplicated by normalised form, `clear` empties, works when `shared_preferences` is null or throws; `NotificationPermissionStore` stores `granted` / `denied` / absent.
- [ ] T025 Create `lib/features/catalogue/data/recent_searches_store.dart` and `lib/features/notifications/data/notification_permission_store.dart` over `preferencesProvider` (keys `recentSearches` and `notifPermission`, try/catch like `LocaleNotifier`); clear both from the demo reset. T024 passes.
- [ ] T026 Relax the `receipt` provider in `lib/features/booking/presentation/providers/checkout_providers.dart` from "confirmed" to "has a succeeded payment" (R10) and show the refund line when a refund exists; update `test/features/booking/presentation/` receipt tests.
- [ ] T027 Remove the mark-as-read side effect from `lib/features/verification/presentation/verification_notice.dart` (the centre owns read state, R5); keep its card unchanged; update its tests.
- [ ] T028 Extend the seed (`lib/core/seed/seed_bookings.dart`, `seed_misc.dart`) per data-model "Seed additions": demo booker bookings that are cancellable with a reminder available, inside the cutoff, paid, free, and past ones in each final status; confirmed and attended bookings across facilities in the last 30 days so "most booked" is not a tie; notifications of every kind (some unread, including "cancelled by me" and the automatic refund). Booking codes stay `SP-1xxx`. Add `test/core/seed/seed_007_test.dart` asserting each of those cases exists.
- [ ] T029 Add providers in `lib/features/booking/presentation/providers/my_bookings_providers.dart` and `lib/features/notifications/presentation/providers/notification_providers.dart`: `myBookings(segment)` (upcoming = confirmed or pending payment not yet ended, by start ascending; past = everything else newest first; invalidated by `bookings.changes`), `bookingDetails(id)` (booking, latest payment, refund, facility, unit, trainer, settings), `notificationsList`, `unreadCount` (excludes records with `readAt` set, capped for display at 99+), all through the interfaces. Tests in `test/features/booking/presentation/providers/my_bookings_providers_test.dart` and `test/features/notifications/presentation/providers/unread_count_test.dart`.

**Checkpoint**: domain and data complete and green (`flutter test` for these folders).

---

## Phase 3: Foundational shared widgets and navigation (blocks every screen)

- [ ] T030 [P] Add the new layout constants of the design pack (rail 88 and the Medium pane widths 260, 300, 360, 400, selected border 2, bottom padding 140, spacer 32, row and skeleton heights 190, 194, 210, 52, 72, 140) as named constants in `lib/core/tokens/sprint_extras.dart`; update the two `TODO(tokens)` comments only if they are resolved.
- [ ] T031 [P] Create `lib/core/widgets/notification_bell/` (`NotificationBell`: 48 target, bell icon, `unread` count badge hidden at 0 and capped 99+, Arabic semantic label with the count) with README `docs/design-system/components/NotificationBell/README.md` and widget tests.
- [ ] T032 [P] Create `lib/core/widgets/notification_card/` (`NotificationCard`: kind icon tile, title, body line, time, unread dot and weight; optional action slot; `unread` true/false) with README and tests (unread vs read, text scale 200%, RTL).
- [ ] T033 [P] Create `lib/core/widgets/booking_row/` (`BookingRow`: facility, unit, date pill that wraps instead of overflowing, `StatusBadge`, code in an LTR isolate, `selected` state with the 2px primary border drawn inside so the height does not change) and `lib/core/widgets/segmented_control/` (`SegmentedControl`: two segments, optional counts, keyboard arrows, 48 high) with READMEs and tests.
- [ ] T034 [P] Create `lib/core/widgets/settings_row/` (`SettingsRow` types `value`, `navigation`, `destructive`; 52 high rows with 48 targets, mirrored chevron, danger label with sign-out icon mirrored in RTL), `lib/core/widgets/avatar/` (`Avatar` sizes 64 and 48; photo from bytes or the initial; `photo` false/true) with READMEs and tests.
- [ ] T035 [P] Generalise `InfoBanner` (`lib/features/booking/presentation/widgets/`) into `lib/core/widgets/banner/` (`Banner` tones `hold`, `neutral`, `success`, `info`, `danger`; icon per use; 48 or 72 high by wrap) and migrate its callers; README and tests including the `info` tone on `primary-soft`.
- [ ] T036 Create `lib/core/widgets/popover/` (`SprintPopover`: anchored overlay panel `surface-raised`, 48-high option rows, Escape and outside tap dismissal, focus returns to the anchor, no platform checks) and extend `lib/core/adaptive/sprint_dialog.dart` so `showSprintDialog` renders `WideDialog` (400 wide, centred, `surface-raised`, destructive action last in reading order) from the medium window class and the platform dialog below; dialog actions are 48 high everywhere. README for `WideDialog` and `Popover`; golden-free widget tests per window class and platform harness (`test/helpers/adaptive_harness.dart`).
- [ ] T037 [P] Extend `lib/core/widgets/sprint_text_field/` with the `locked` state (`ink-muted` on `surface-sunken`, lock icon, helper line, announced as read-only with the reason) and the search type's `filled` state with a 48x48 clear button (20 icon) and an optional "إلغاء" slot; update `docs/design-system/components/TextField/README.md`; tests.
- [ ] T038 [P] Add `Skeleton` shapes `profile-card` and `settings-row` to `lib/core/motion/skeleton.dart` (shape of the real account: a 140 card with a circle and two lines, then settings rows) with tests.
- [ ] T039 Add all new components to the gallery at `/demo/components` (`lib/features/demo/presentation/` gallery sections) with their states; extend the widget export `lib/core/widgets/design_system.dart`.
- [ ] T040 Add the shared strings of the new widgets to `lib/l10n/app_ar.arb` and `app_en.arb` (bell label, mark all read, locked field helper, cancel and close labels, dialog buttons) and run `flutter gen-l10n`; `test/guards/arb_parity_test.dart` must pass.
- [ ] T041 Navigation: add `AppSection.notifications` (booker only, between bookings and profile) in `lib/features/identity/domain/app_section.dart` and the role-to-sections mapping; register `/notifications` as a shell destination in `lib/app/router/routes.dart` and `destinations.dart` (replace the positional registry with a keyed lookup so adding a section cannot shift others); add the sub-routes of contracts/routes.md (`/bookings/:bookingId`, `/bookings/:bookingId/cancelled`, `/profile/edit`) with `GatedRoute(requiresAccount: true)` and `BookingOwnerGate`; update `test/app/router/` tests (guest redirected to sign-in with `from`, other users' booking id shows not-found).
- [ ] T042 Shell: in `lib/app/shell/adaptive_shell.dart` pass `badgeCount` from `unreadCount` to the notifications `NavDestination`, hide that destination from the tab bar on the compact class, and keep the last visible root index so `/notifications` and `/profile/edit` on compact highlight the tab the booker came from (the pushed Edit profile highlights "حسابي"); keep number-key shortcuts for the visible items. Tests in `test/app/shell/adaptive_shell_007_test.dart` (compact: four tabs, no notifications item; medium: five items with badge; resize keeps selection; guest has none).
- [ ] T043 Create `lib/app/shell/root_header.dart` (`RootHeader`: title plus `NotificationBell` at the end, bell only on compact and only for a signed-in user, no badge while loading) and use it in `HomeScreen`, `FacilityListView`, the new `MyBookingsScreen` and `AccountScreen`; tests per window class and guest.

**Checkpoint**: shell, routes and widgets in place; the app runs with the placeholders still wired.

---

## Phase 4: User Story 1 — See my bookings, upcoming and past (P1)

**Goal**: replace `BookingsPlaceholder` with the real list. **Independent test**: signed in as the demo booker, "حجوزاتي" lists upcoming in time order, "السابقة" lists finished, cancelled and expired, and every row opens its details; a guest still sees the account gate.

- [ ] T044 [P] [US1] Write `test/features/booking/presentation/bookings/my_bookings_screen_test.dart`: upcoming ordered by start with status word and icon; switch to past newest first; three empty states (nothing at all with "استعراض المنشآت", upcoming empty with past present, past empty); first row selected at medium and up with details beside it and "مفيش حجز محدد" in the detail area when the segment is empty; compact row tap pushes details; resize and fold keep selection and segment; guest still gets the account gate; 200% text and RTL.
- [ ] T045 [US1] Create `lib/features/booking/presentation/bookings/` (`my_bookings_screen.dart` with `selectedId` like `FacilitiesScreen`, `bookings_list.dart`, `bookings_master_detail.dart`, `booking_row_data.dart`) using `RootHeader`, `SegmentedControl` (counts on the lists, none on the empty), `BookingRow`, `EmptyState` with static art, skeleton while loading, `AdaptiveRefresh`; segment in `?seg=`; strings `bookings*` in both ARB files.
- [ ] T046 [US1] Wire `bookings` in `lib/app/router/routes.dart` to `MyBookingsScreen`, delete `lib/app/shell/placeholders/bookings_placeholder.dart`, and update tests that referenced it.
- [ ] T047 [US1] Home: make `UpcomingBookingsSection` rows open `/bookings/:id`, make "كل حجوزاتي" open `/bookings`, take the status from the booking instead of the hard-coded badge, and keep the link hit area at 48 (`lib/features/catalogue/presentation/home/upcoming_bookings_section.dart`, `home_screen.dart`); update `test/features/catalogue/` Home tests.
- [ ] T048 [US1] Acceptance test `test/acceptance/us14_my_bookings_test.dart` covering spec Story 1 scenarios 1–6.

---

## Phase 5: User Story 2 — Open a booking and understand its state (P1)

**Goal**: details for every status. **Independent test**: open one booking in each of the six statuses and check content and actions.

- [ ] T049 [P] [US2] Write `test/features/booking/presentation/details/booking_details_screen_test.dart`: confirmed before the cutoff shows the ticket, QR and the cancel action; confirmed after the cutoff shows no cancel and the "until when" line computed from the setting; pending payment shows the Hold countdown, "إكمال الدفع" and cancel only while holding; attended, no-show (neutral banner, no penalty wording), cancelled and expired show their banners, "المبلغ" and "ما اتدفعش" where unpaid, no check-in implication; the ticket status comes from the booking, not hard-coded; the receipt link appears for paid bookings of any status; another user's booking id shows not-found and reveals nothing; status changes to attended or no-show while open without leaving; tier row says "داخلي" or "خارجي" only.
- [ ] T050 [US2] Create `lib/features/booking/presentation/details/` (`booking_details_screen.dart` pushed on compact and as the detail pane in the master-detail, `details_actions.dart`, `status_banner.dart` using `Banner` tones, `receipt_link.dart`); use `bookingDetails(id)`; fix `booking_confirmed_screen.dart` to stop hard-coding `SprintStatus.confirmed` on the ticket; keep `cancelUntil` from `CancelPreview` instead of hand computation; strings `bookingDetails*`.
- [ ] T051 [US2] Wire `/bookings/:bookingId` to `BookingDetailsScreen` (inside the master-detail from the medium class) in `routes.dart`; deep link and refresh keep working.
- [ ] T052 [US2] Acceptance test `test/acceptance/us14_booking_details_test.dart` covering spec Story 2 scenarios 1–6.

---

## Phase 6: User Story 3 — Cancel a confirmed booking and get the right refund (P1)

**Goal**: cancel with a computed, honest confirmation. **Independent test**: cancel a paid booking at 100%, 50 and 0, then a free one, then a facility cancel; check amount, wording and the notification.

- [ ] T053 [P] [US3] Write `test/features/booking/presentation/cancel/cancel_dialog_test.dart`: dialog text for `full`, `partial` ("هترجع X من Y ج.م" with X computed from `refundPercent`), `none`, `free` (no refund line); the refund line says "على نفس وسيلة الدفع" and promises no time; the dialog calls `previewCancel` on open and `cancel` re-checks: cutoff passed meanwhile → "فات وقت الإلغاء" and nothing changes; already cancelled → friendly "already cancelled" state; destructive action 48 high and last in reading order on wide; native dialog on compact per platform.
- [ ] T054 [US3] Create `lib/features/booking/presentation/cancel/` (`cancel_dialog.dart` through `showSprintDialog`, `cancel_wording.dart` mapping `CancelKind` to ARB keys with parameters, `cancel_result_screen.dart` for `/bookings/:bookingId/cancelled` with banner and refund line, "العودة للحجوزات"); `cancel_providers.dart` for the action state; the details screen's cancel action opens the dialog; strings `cancel*`.
- [ ] T055 [US3] Facility cancel display: details and result show the cause ("لغته إدارة المنشأة"), 100% refund whatever the settings (BR-32) and "اتبلّغت فورًا" (BR-41); test in `test/features/booking/presentation/cancel/facility_cancel_view_test.dart`.
- [ ] T056 [US3] Acceptance test `test/acceptance/us13_cancel_test.dart` covering spec Story 3 scenarios 1–6, changing `refundPercent` and `cancellationCutoffHours` through the settings repository in the test.

---

## Phase 7: User Story 4 — Cancel a booking I haven't paid yet (P1)

**Goal**: BR-48 in the UI. **Independent test**: start a paid booking, cancel it from "حجوزاتي" while holding, and book the same place with another user at once.

- [ ] T057 [P] [US4] Write `test/features/booking/presentation/cancel/pending_cancel_test.dart`: the action shows only in the details of a booking holding with no payment pending; short dialog ("هنلغي الحجز ومفيش فلوس اتسحبت") with no amount; after confirming the status is "اتلغى" (not "منتهي"), the place is bookable by another user immediately; with the fake provider set to delay and a payment processing the action is not offered; Hold ended meanwhile → expired state, no cancel.
- [ ] T058 [US4] Implement the pending-cancel dialog, wording and state in `lib/features/booking/presentation/cancel/` and `details_actions.dart` over the repository's `cancel` for `pendingPayment`; strings.
- [ ] T059 [US4] Acceptance test `test/acceptance/us13_pending_cancel_test.dart` covering spec Story 4 scenarios 1–3 including the release for another booker.

---

## Phase 8: User Story 5 — Notifications centre and bell (P1)

**Goal**: a real centre with kinds, unread state and destinations. **Independent test**: book, trigger a reminder and a facility cancel, receive a verification decision; the centre shows each, the badge counts correctly, tapping leads to the right place.

- [ ] T060 [P] [US5] Write `test/features/notifications/presentation/notifications_screen_test.dart`: newest first with kind icon, wording and time; opening one marks it read; "تعليم الكل كمقروء" (48 target at the end of the header) clears the badge; each of the eight kinds renders and opens its destination (booking kinds → details by `payload.bookingId`; verification kinds → account verification area; rejected shows the reason, BR-26; unknown kind → plain card); empty state; "cancelled by me" never counts as unread; bell badge hidden at zero and while loading, capped at 99+; guest has no bell or destination; window class change keeps unread state and scroll; text scale 200% and RTL.
- [ ] T061 [US5] Create `lib/features/notifications/presentation/notifications_screen.dart` and `notification_card_data.dart` (kind → icon, title key, body, destination), using `NotificationCard`, `EmptyState`, skeleton, `AdaptiveRefresh`; pushed with a back button on compact, a destination from medium up; wire `/notifications` and the bell in `RootHeader`; strings `notifications*` (Egyptian wording for every kind, including approved verification).
- [ ] T062 [US5] Acceptance test `test/acceptance/us14_notifications_test.dart` covering spec Story 5 scenarios 1–7.

---

## Phase 9: User Story 6 — Reminders and permission (P1)

**Goal**: reminder with a display-time cancel decision, and the simulated permission. **Independent test**: bring the next confirmed booking into the reminder window from `/demo`, open the reminder before the cutoff (cancel shown) and after (cancel hidden with a line).

- [ ] T063 [P] [US6] Write `test/features/notifications/presentation/reminder_card_test.dart` with a movable clock: before the cutoff the card offers "إلغاء الحجز" (opens the cancel dialog); after the cutoff the action is gone, a line says the cancel closed and the whole card opens the booking; cancelled or finished booking keeps the reminder without the action; lead time words come from `reminderLeadMinutes`, not from text; the checker running many times produces one record.
- [ ] T064 [US6] Implement the reminder card variant in `notification_card_data.dart` and the screen (decision from `canOfferCancel` at build time and rebuilt when the clock ticks); strings with parameters.
- [ ] T065 [P] [US6] Write `test/features/notifications/presentation/permission_dialog_test.dart`: the dialog appears once at the first moment the booker reaches the notification step, stores the answer through `NotificationPermissionStore`, changes nothing visible but the stored choice; asking again only from the Account row (US7).
- [ ] T066 [US6] Create `lib/features/notifications/presentation/permission_dialog.dart` and `providers/permission_provider.dart` (through `showSprintDialog`; shown once after the first successful booking confirmation or the first visit to the centre, whichever comes first) and strings.
- [ ] T067 [US6] `/demo` actions: in `lib/features/demo/presentation/demo_screen.dart` add a section with "إظهار تذكير حجزي الجاي" (`forceReminder` for the next confirmed booking) and "إلغاء من الإدارة" (choose a confirmed booking, cancel as admin through the repository); both reset with the demo data (`resetDemoDataProvider`); test in `test/features/demo/demo_007_actions_test.dart`.
- [ ] T068 [US6] Acceptance test `test/acceptance/us13_reminder_test.dart` covering spec Story 6 scenarios 1–5.

---

## Phase 10: User Story 7 — My account (P1)

**Goal**: replace `ProfilePlaceholder`. **Independent test**: walk each verification state, change language and appearance, sign out, and open as a guest.

- [ ] T069 [P] [US7] Write `test/features/account/presentation/account_screen_test.dart`: shows name, photo or initial, email (LTR isolate), verification status per state with tier wording and the entry to the verification request, rows in order (البيانات الشخصية, اللغة, المظهر, الإشعارات with "مفعّلة" or "متوقفة", تسجيل الخروج); the Account "الإشعارات" row reflects the stored permission answer and reopens the permission dialog without affecting the centre or badge; no national ID or ID photo anywhere; language and appearance change the app at once and persist (sheet on compact, popover from medium); sign out asks first then returns to guest keeping demo data; guest card with sign-in and sign-up plus language and appearance; loading uses the real-shaped skeleton and no badge; 200% text and RTL.
- [ ] T070 [US7] Create `lib/features/account/presentation/` (`account_screen.dart` with `RootHeader`, `account_guest_card.dart`, `language_picker.dart`, `appearance_picker.dart` through `showSprintSheet` with popover rows from medium up, `sign_out_flow.dart`) reusing `AccountCard`'s verification pieces (`VerificationStatusBadge`, `VerificationSlot`, `VerificationNotice`) and `SettingsRow`, `Avatar`; wire `profile` in `routes.dart`, delete `lib/app/shell/placeholders/profile_placeholder.dart`; strings `account*` (Egyptian wording).
- [ ] T071 [US7] Acceptance test `test/acceptance/us14_account_test.dart` covering spec Story 7 scenarios 1–5.

---

## Phase 11: User Story 8 — Edit my name and photo (P2)

**Goal**: FR-MYB-03 edit rule. **Independent test**: change the name, choose and remove a photo, save; the account shows the new data.

- [ ] T072 [P] [US8] Write `test/features/account/presentation/edit_profile_screen_test.dart`: Save disabled until the name is valid and changed or the photo changed; name shorter than two characters (after trimming) shows the inline error "الاسم لازم يكون حرفين على الأقل" and blocks saving; photo from camera or gallery (camera only when `cameraAvailableOf`), replace, remove ("حذف الصورة", 48 target); email and phone shown locked with the helper "مربوط بتسجيل الدخول ومش بيتعدل من هنا", announced as read-only with the reason and shown left-to-right; the new data appears in the account and the saved snapshot; failed or oversize photo keeps the old one with a friendly error; pushed screen keeps "حسابي" highlighted on compact; guest cannot reach it.
- [ ] T073 [US8] Create `lib/features/account/presentation/edit_profile_screen.dart` using `SprintTextField` (`locked`), `Avatar`, the photo picker pattern of `id_card_photo_picker.dart` with `avatar_encoder.dart`, `updateProfile`; wire `/profile/edit`; strings `editProfile*`; acceptance test `test/acceptance/us14_edit_profile_test.dart` covering spec Story 8 scenarios 1–5.

---

## Phase 12: User Story 9 — Search facilities (P1)

**Goal**: search from Home and Facilities. **Independent test**: search "سباحة", a facility name, an owning unit and a word with no match; check ordering, the empty-field suggestions, recents and the no-results state with a filter on.

- [ ] T074 [P] [US9] Write `test/features/catalogue/presentation/search/search_flow_test.dart`: empty focused field shows two "الأكتر حجزًا" suggestions and up to five recents with "مسح الكل"; typing shows results ordered "open today by places available, then closed, then name" with the existing facility card and the result count through `catalogueResultCount` (no count line at zero); clear button (48 target) empties and "إلغاء" leaves search on compact; a result tap opens the details (beside the results from the medium class) and adds the term to recents; no match shows the empty state with "مسح الفلاتر" when a filter is on and no count line; guest and booker behave the same; closed-today facility appears last; `?q=` survives resize and master-detail; suggestions popover from medium up, full screen on compact.
- [ ] T075 [US9] Create `lib/features/catalogue/presentation/search/` (`search_field.dart` using `SprintTextField` search type, `search_suggestions_view.dart` with `SprintPopover` from medium up, `search_results_header.dart`, `search_providers.dart` composing `facilitySummariesProvider`, `FacilitySearch`, `bookedCounts` over the last 30 days of the demo clock, and the recents store); add the field to `HomeScreen` and `FacilityListView` (navigates to `/facilities?focus=search`); `q` and `focus` in the address; reuse `facilitiesSearchHint`; strings `search*`; remove the dead `lib/app/shell/placeholders/facilities_placeholder.dart` if still unused.
- [ ] T076 [US9] Acceptance test `test/acceptance/us01_search_test.dart` covering spec Story 9 scenarios 1–7.

---

## Phase 13: User Story 10 — Every size, language, theme and every branch on demand (P2)

- [ ] T077 [P] [US10] `test/features/007_matrix_test.dart`: for each new screen (my bookings, details, cancel dialog and result, notifications, account, edit profile, search) pump at 390, 720, 1194 and 1440 wide, Arabic and English, light and dark, at text scale 2.0, asserting no overflow, 48 minimum targets (including links, popover rows, sidebar rows, clear buttons), visible focus ring on keyboard platforms, Arabic semantic labels, status always with word or icon; fold simulation (display feature) keeps selection.
- [ ] T078 [P] [US10] `test/acceptance/us007_no_dead_ends_test.dart`: from Home, the four tabs, notifications, booking details, search and every `/demo` action, as guest and as booker, no route ends on a placeholder, "قريبًا" or a screen without a way back (FR-036, SC-009); `BookingsPlaceholder` and `ProfilePlaceholder` no longer exist.
- [ ] T079 [US10] Fix whatever T077 and T078 find; keyboard-only walk on web for search, cancel dialog and notifications (Escape closes popover and dialogs, focus returns to the trigger).

---

## Phase 14: Polish, documents and release

- [ ] T080 [P] Write `specs/007-bookings-notifications-profile/copy-review.md` like 005 and 006: every new string, Arabic and English, checked against the copy rules (no imperative verbs, Egyptian wording, Western digits, 12-hour time); fix the ARB files where a string fails.
- [ ] T081 Update `docs/BRD.md` (this PR, agreed with Osman 2026-11-18): add BR-48 and the arrow `PENDING_PAYMENT → CANCELLED` in the state diagram and the final-states text; FR-CAT-05 and a search criterion in US-01 and a row in §10; FR-MYB-03 wording (edit name and photo, email and phone read-only, appearance); FR-NTF-01 and BR-41 (verification decisions, owner cancel record); US-13 (reminder after the cutoff without the action, free booking cancel releases the place without refund) and US-14 (edit profile criterion). Keep ID numbering, do not renumber.
- [ ] T082 Add the 2026-11-18 entries to `docs/decisions.md` with reasons: Dr. Sara's demo is a web link for guest and booker; search added (FR-CAT-05); notification bell on compact and destination on wide; BR-48; self-cancel record already read; reminder checker with a demo action; Account notifications row; Lottie and offers postponed; booking code sample `SP-`; `docs/design-system/components/` READMEs for the new components and the AppNavigation README (bell, notifications destination, badge); change the `code` sample in `docs/design-system/tokens.json` from `SPR-7K2Q9` to `SP-1042` and regenerate `tokens.css` and the Dart tokens if the generator checks the file (run the existing generator, record the diff).
- [ ] T083 Update `CLAUDE.md` "Current state" and the feature list (feature 7 built; next is feature 8 and the planned Figma refactor).
- [ ] T084 Run `flutter analyze`, `flutter test` (all guards) and `flutter build web --release --base-href /sprint-app/`; all must pass.
- [ ] T085 Walk `quickstart.md` on web at compact (iPhone width) and desktop widths, Arabic then English, light then dark, plus one iOS simulator pass if available; record SC-001 to SC-009 and what was not checked in `evidence.md` with screenshots per window class.
- [ ] T086 Re-run the Figma comparison for the nodes marked "not read" in the pack with Osman's session (design QA), then delete `specs/007-bookings-notifications-profile/design-pack/` (CI fails the PR while it exists).
- [ ] T087 Prepare the pull request description against `develop` (do not push or open it until Osman says so): BRD IDs (US-13, US-14, US-01; FR-MYB-02, FR-MYB-03, FR-NTF-01, FR-NTF-02, FR-PAY-04, FR-CAT-05; BR-30, BR-31, BR-32, BR-39, BR-40, BR-41, BR-45, BR-48), the out-of-scope list, the interface additions (Complexity Tracking), BRD and decisions changes, and the evidence file.

---

## Dependencies and execution order

- **Phase 1** first. **Phase 2** blocks every story; inside it: tests before their code (T004→T006, T007→T008, T009→T010, T011→T012, T013→T014, T015→T016, T017→T018, T019→T020, T022→T023, T024→T025); T005 before T011 and T012; T008 before T018 and T012; T028 after T012 and T008; T029 after T012, T014, T010.
- **Phase 3** needs Phase 2 for T041 to T043 (not for the widgets T030 to T040, which can start together with Phase 2).
- **US1** needs Phase 2 and Phase 3. **US2** needs US1's route (T045, T046). **US3** needs US2 (details screen). **US4** needs US3's dialog (T054). **US5** needs T043 and T010. **US6** needs US5 and US3 (cancel dialog). **US7** needs T041 to T043 and T034, T036. **US8** needs US7. **US9** needs T023, T025, T036, T037 and the Facilities screen only. **US10** needs US1 to US9.
- US3, US4 and US6 all edit `details_actions.dart` or `notification_card_data.dart`, so their implementation tasks go one after another even with several people; test tasks can be written in parallel.

### Parallel examples

- Phase 2: T004, T007, T009, T011, T013, T015, T017, T019, T021, T022, T024 (tests) together; then their implementations in pairs on different files.
- Phase 3: T030 to T040 (widgets) together while Phase 2 finishes.
- After US2: US5 (T060, T061), US7 (T069, T070) and US9 (T074, T075) can run side by side with US3 and US4.

## Implementation strategy

- **MVP for Dr. Sara's link**: Phase 1, Phase 2, Phase 3, US1, US2, US3 (my bookings, details and cancel): the dead ends the 2026-11-18 walk found are closed. Then US5 and US7 (notifications and account), then US9 (search), then US4, US6, US8.
- **Demo recording**: add T067 early so reminders and facility cancels can be shown on demand.
- **Last**: US10, Phase 14, the design pack deletion (T086) just before the PR.
- Keep each commit small and green: one task, one commit, BRD IDs in the message. No push without Osman.
