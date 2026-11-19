# Research: Feature 007

Facts come from a read-only survey of the code on 2026-11-18 (paths in brackets). Each entry is a decision, the reason, and what was rejected.

## R1. Bell on compact, destination on wide, one route

**Facts**: There is no shared header; each root screen builds its own title (`PlaceholderPage`, `HomeScreen`, `FacilityListView`). `NavDestination` already supports `badgeCount` but `AdaptiveShell` never passes it. `baseRegistry` maps sections to `baseDestinations` by index. `buildAppRouter` has a `hiddenDestinations` parameter.

**Decision**: Add `AppSection.notifications` and a shell destination at `/notifications` (a real branch of the shell, so tab bar, rail and sidebar keep working). `AdaptiveShell` (a) passes `badgeCount` from the unread provider, (b) on compact leaves that branch out of the tab bar items and (c) remembers the last visible root index, so on compact `/notifications` keeps the tab the booker came from highlighted (design pack: pushed screen with the origin tab selected). A shared `RootHeader` (title plus `NotificationBell`) is used by the four root screens; it shows the bell only on compact and only for a signed-in user. The notifications screen on compact has a back button (pushed); from medium up it is a plain destination.

**Alternatives rejected**: a top-level route outside the shell (loses the tab bar, which Figma keeps visible); one bell in the shell for every screen (the shell has no app bar and Figma puts the bell in each root header); a separate wide-only route (state lost when folding).

## R2. Booking details route and master-detail

**Decision**: `/bookings/:bookingId` renders details. At compact it is a pushed screen; from medium up the same route renders list plus details through the pattern 004 already uses for facilities (`FacilitiesScreen({selectedId, paneBuilder})`): `MyBookingsScreen({selectedId})`. `/bookings` on wide redirects the view to the first booking of the active segment (selection is in the address, so fold and unfold keep it; the segment is a query `?seg=past`). `/bookings/:id/confirmed` and `/receipt` stay. The details route is gated (`requiresAccount`) and wrapped in `BookingOwnerGate`.

**Rejected**: a separate wide route (duplicates screens); state in a provider only (lost on reload and not shareable in the demo).

## R3. One pure cancel rule shared by the dialog and the repository

**Facts**: `CancellationPolicy.decide` computes the refund as `paidAmount * refundPercent ~/ 100` and only allows `confirmed`; the UI hand-computes `cancelUntil`; `canOfferCancel` is only used in tests.

**Decision**: add `CancelPreview preview({booking, now, by, cutoffHours, refundPercent, paidAmount, paymentPending})` returning `kind` (`full`, `partial`, `none`, `free`, `closed`, `notAllowed`), `refundAmount`, `paidAmount`, `cancelUntil`. `decide()` calls `preview()` so the dialog and the repository cannot disagree. "Free" is `priceAtBooking == 0` (spec). The UI wording is chosen from `kind`; amounts and times come from the preview. `canOfferCancel` becomes the single "is the button shown" check for details, reminders and the dialog re-check at confirm time (FR-012).

## R4. BR-48: cancel while holding

**Facts**: `Booking.cancel` works only from `confirmed`; `PENDING_PAYMENT` ends in `CONFIRMED` or `EXPIRED`.

**Decision**: `Booking.cancel` also accepts `pendingPayment` (owner only). The repository allows it only when the Hold is running and the latest payment is not `pending` (processing at the provider, BR-47); it releases the Hold, sets `CancelledBy.owner`, `cancelledAt`, creates no refund, and writes the already-read "cancelled by me" record. Cancelled by the facility stays `confirmed` only (a pending booking is never cancelled by admin in P1). The BRD adds BR-48 and the new arrow in the state diagram.

## R5. Typed notification kinds without a schema bump

**Facts**: `Notification.type` is a free string; types in use are `booking.confirmed`, `booking.reminder` (seed only), `booking.cancelled_by_admin`, `payment.refunded_auto`, `verification.pending|approved|rejected`. An owner cancel writes no notification. The repository interface has no change signal, no bulk read, no unread count. `VerificationNotice` marks verification notifications read by itself.

**Decision**: keep `type` a string in JSON and add a closed `NotificationKind` enum with `fromWire` that falls back to a safe generic kind, plus the new wire value `booking.cancelled_by_owner`. Eight kinds are displayed: the seven in the spec and `payment.refunded_auto` (006 already writes it; shown as "رجع لك المبلغ"). The interface gains `Stream<void> get changes` and `markAllRead(userId, at)`; unread count is computed from `list`. `push` becomes an upsert by id so reminders are idempotent. `VerificationNotice` stops marking read (the centre owns read state). No `schemaVersion` bump: old snapshots decode because the field is unchanged.

**Rejected**: an enum in the JSON (breaks the saved demo data); computing the unread count in the screen (two sources of truth).

## R6. Reminders without a backend

**Decision**: pure `ReminderPolicy.due({bookings, existingReminderIds, now, leadMinutes})` returns the bookings whose `start - leadMinutes <= now < end`, status `confirmed`, with no `rem-<bookingId>` record yet. A `reminderScheduler` provider (keepAlive) runs it on build, every 60 seconds, and on app resume (`WidgetsBindingObserver`), and writes the records through the repository (deterministic id makes repeats harmless; `leadMinutes` comes from `UnitSettings.resolve` per booking). The record stores only the booking code and booking id; the cancel button is decided when the card is shown from `canOfferCancel` (FR-020). The `/demo` action `forceReminder` writes the same record for the next confirmed booking. Settings changes after the record exists do not move it.

**Rejected**: storing "cancellable" in the payload (stale after the cutoff, BR-40); a background isolate (no backend and no platform scheduling in P1).

## R7. Housekeeping: no-show and hold expiry in one timer

**Facts**: `markNoShows()` exists and is never called, so a booking past its end stays `confirmed`. `holdHousekeeping` already ticks for holds.

**Decision**: the same keepAlive timer also calls `markNoShows()` so details and lists change status without a reload (spec edge case). It writes the existing Attendance row (BR-37); no penalty.

## R8. Search is a query of the Facilities screen

**Facts**: no search field exists on the list; `FacilityFilter` and `listFacilities` have no text. `facilitySummariesProvider` already builds `FacilitySummary` with today's availability count and the owning unit name.

**Decision**: pure `FacilitySearch.filter(summaries, query)` with `ArabicNormalizer` (drop tashkeel, unify أ إ آ ا, ة ه, ى ي, lowercase Latin, collapse spaces) over name, type label and owning unit name; order by `today.count` descending, closed last, then name. The query lives in the address (`/facilities?q=…`, `/facilities/<id>?q=…`) so master-detail from 004 works unchanged and fold keeps it. The search field on Home and Facilities navigates to `/facilities?focus=search`. Suggestions: `BookingRepository.bookedCounts(since)` returns confirmed and attended counts per facility; the two highest (ties by name). Recents: `RecentSearchesStore` over `preferencesProvider` (key `recentSearches`, five, newest first, deduplicated after normalisation, null-tolerant like `locale`). A suggestion or recent tap fills the field and runs.

**Rejected**: a separate `/search` route (duplicates the list and master-detail); server-style search in the repository (the summaries are the data the UI already has).

## R9. Popovers and wide dialogs

**Facts**: there is no popover widget; `showSprintSheet` already becomes an anchored menu on desktop; `showSprintDialog` is the native dialog.

**Decision**: add `SprintPopover` (an anchored overlay with an arrow-less panel, `surface-raised`, keyboard and outside-tap dismissal) used for the search suggestions from medium up; keep `showSprintSheet(anchor:)` for language and appearance on wide, restyled with 48 rows. `showSprintDialog` renders the `WideDialog` surface (400 wide, centred, `surface-raised`, destructive action last in reading order) from the medium window class up and the platform dialog below (design pack, `adaptive.md`).

## R10. Receipt for any paid booking

**Facts**: the `receipt` provider returns null unless `confirmed`.

**Decision**: relax it to "has a succeeded payment" so attended, no-show and cancelled paid bookings still open their receipt from the details; refund line shown when a refund exists.

## R11. Profile photo and update

**Facts**: `User` has no photo; the photo store (`photo/<id>`) and the encoder exist for the ID card; `IdentityRepository` is read-only (the concrete class has `updateUser`).

**Decision**: `User.avatarId` (nullable, back-compatible). `IdentityRepository.updateProfile(userId, {name, avatarId})` validates (name at least 2 characters), saves, signals `changes`. Photo bytes go through a smaller `avatarEncoder` (max side 512, JPEG 80) into the existing store under `avatar-<userId>`; `profilePhotoProvider(userId)` reads them. Email and phone are never written from here. Camera versus gallery follows `cameraAvailableOf` as the ID card photo does.

## R12. Persistence and schema

**Decision**: `schemaVersion` stays 2. New persisted fields are nullable (`Booking.cancelledAt`, `User.avatarId`) or tolerant (`NotificationKind.fromWire`). Device-only state (recent searches, notification permission answer `notifPermission`) is in `shared_preferences` through the existing pattern; reset by the demo's reset action together with the data layer.

## R13. Layout constants without tokens

**Decision**: the design pack's raw numbers (rail 88, panes 260/300/360/400, selected border 2, bottom padding 140, spacer 32, skeleton shapes, row heights 190/194/210, settings row 52) are named constants in `SprintExtras` (constitution II), never inline.

## R14. Copy and l10n

**Decision**: strings follow the design pack where it is Egyptian and non-imperative; "تمت الموافقة" is replaced by an Egyptian form; every cancel and reminder string takes parameters (amount, percent, time, lead) so no number is text. New keys use the existing camelCase prefixes (`bookings*`, `bookingDetails*`, `cancel*`, `notifications*`, `account*`, `editProfile*`, `search*`); `arb_parity_test` keeps ar and en equal. `facilitiesSearchHint` (orphaned) is reused for the field.
