# Contracts: routes (feature 007)

| Path | Where | Access | Notes |
| --- | --- | --- | --- |
| `/bookings` | shell, branch `bookings` | open (a guest sees the account gate content) | list; compact: segment in `?seg=upcoming|past`; medium and up: list plus details, first booking selected |
| `/bookings/:bookingId` | sub-route of `bookings` | account, owner only (`BookingOwnerGate`) | details; compact pushed, wide: the detail pane of the list |
| `/bookings/:bookingId/confirmed` | existing (006) | account, owner | unchanged |
| `/bookings/:bookingId/receipt` | existing (006) | account, owner | now opens for any status with a succeeded payment |
| `/bookings/:bookingId/cancelled` | sub-route | account, owner | result screen after a cancel (also the redirect target for a booking cancelled elsewhere) |
| `/notifications` | shell, new branch `notifications` | account (signed-in) | compact: hidden from the tab bar, reachable from the bell, back button, origin tab highlighted; medium and up: a destination |
| `/profile` | shell, branch `profile` | open (guest card) | account screen |
| `/profile/edit` | sub-route of `profile` | account | edit profile (pushed on every size; a pane from the medium class is not required) |
| `/profile/verification` | existing (003) | account | unchanged |
| `/facilities?q=<text>&focus=search` | existing branch | open | `q` filters the list; `focus=search` opens the field with suggestions |
| `/facilities/:id?q=<text>` | existing | open | master-detail keeps `q` |
| `/demo` | existing | demo | two new actions |

**Redirects**: a guest on `/notifications`, `/bookings/:id` or `/profile/edit` goes to `/sign-in?from=` (`requireAccount`, as 003). A booking id that is not the user's shows the not-found state, never another user's data (FR-009). `AppSection.notifications` exists only in the booker's sections; other roles' destinations are unchanged.

**Shell rules**: on compact the `notifications` destination is not an item of the tab bar; the shell keeps the last visible root index for the highlight. From medium up it is an item with the unread badge between "حجوزاتي" and "حسابي".
