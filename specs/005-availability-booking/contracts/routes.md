# Contract: Routes

The Foundation's and feature 004's route rules stay: routes are built from destination data, paths
come from `AppPaths`, the web uses hash URLs, and the facilities routes sit inside the shell under the
facilities tab. This feature changes one route's screen and adds three children.

## Paths and names

| Constant | Value | Screen | Access |
| --- | --- | --- | --- |
| `AppPaths.facilitySchedule(id, [selection])` | `/facilities/<id>/schedule` | the schedule (replaces the "قريبًا" screen) | open |
| `AppPaths.bookingSummary(id, selection, {shown})` | `/facilities/<id>/schedule/summary` | the booking summary | account |
| `AppPaths.bookingCheckout(id, selection)` | `/facilities/<id>/schedule/checkout` | "قريبًا" checkout hand-off (feature 6 replaces it) | account |
| `AppPaths.bookingDone(id, bookingId)` | `/facilities/<id>/schedule/done/<bookingId>` | free-booking success | account |

Names: `facilitySchedule` (exists), `bookingSummary`, `bookingCheckout`, `bookingDone`. The three new
routes are `GatedRoute`s with `RouteAccess(requiresAccount: true)`.

## Query parameters (the selection)

| Name | Format | Example | On |
| --- | --- | --- | --- |
| `day` | Cairo date `yyyy-MM-dd` | `2026-11-19` | schedule, summary, checkout |
| `unit` | unit id | `u-pool-2` | schedule, summary, checkout |
| `trainer` | trainer id | `tr-1` | trainer path only |
| `start`, `end` | Cairo wall-clock `HHmm` | `1700`, `1900` | when a time is chosen; always on summary and checkout |
| `shown` | whole EGP the schedule displayed | `40` | summary only |

Built and parsed only by `ScheduleSelection`; screens never assemble the query by hand.

## Behaviour

| Situation | Result |
| --- | --- |
| Tap "عرض المواعيد" on a facility | pushes `/facilities/<id>/schedule`; back returns to the facility |
| Open the schedule with no parameters | first day with availability and first unit with places are shown; the address is not rewritten until the user chooses something |
| Change day, unit, trainer or time | the current location is **replaced** with the new query; the back stack does not grow |
| Back from the schedule after any number of selections | the facility page, in one step |
| Reload on web with a selection in the address | the same day, unit, trainer and time reopen (FR-012) |
| A parameter is invalid or no longer available | defaults are used, the address is replaced, and a notice says the earlier choice is no longer available |
| Missing or unpublished facility id | feature 004's not-found screen |
| Trainer facility with no `trainer` parameter | the trainer step shows; day and time parameters are ignored |
| "متابعة" as a signed-in user, quote succeeds | pushes `summary` with the same selection plus `shown` |
| "متابعة" as a guest | account gate over the schedule (`requireAccount`); on return the schedule is ready and waits for a new tap |
| Guest opens `summary`, `checkout` or `done` directly | redirect to `/sign-in?from=<location>`, then back to it |
| `summary` or `checkout` opened without a complete selection | redirect to the schedule with whatever is valid |
| Back from `summary` | the schedule with the same selection (FR-031) |
| "متابعة للدفع" on the summary, quote succeeds | pushes `checkout`; back returns to the summary |
| "تأكيد الحجز" on the summary, booking created | `go` to `done/<bookingId>`; back from it lands on the schedule, never on the summary (FR-030) |
| A quote or create refusal on the summary | back to the schedule, time cleared, notice shown |
| `done/<bookingId>` for a booking that is missing or not the signed-in user's | not-found screen with a way home |
| "الرجوع للرئيسية" on the success screen | `go('/home')` |
| Medium and larger windows | every route above renders in the details pane beside the facilities list; compact shows it full screen |
| Window resized, rotated, folded or unfolded | the location does not change, so the selection is kept (FR-042) |
| Sign-out on `summary`, `checkout` or `done` | the router's redirect sends the person to `/sign-in?from=<that location>`; signing in again returns to it |
