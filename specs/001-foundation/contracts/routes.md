# Contract: Routes and deep links

**Spec**: FR-002 – FR-008, FR-029 | **Plan**: [../plan.md](../plan.md)

URL strategy: hash (`/#/path`). On Pages the app lives under `/sprint-app/`, so a facility
link looks like `https://<owner>.github.io/sprint-app/#/facilities/f1`.

| Path | Screen in this feature | Branch | Notes |
| --- | --- | --- | --- |
| `/` | redirects to `/home` | | |
| `/home` | Home placeholder | Home | Guest sees discovery placeholder; booker sees "upcoming" placeholder |
| `/facilities` | Facilities placeholder | Facilities | Child `/facilities/:facilityId` reserved for FR-CAT-02 |
| `/bookings` | My Bookings placeholder | My Bookings | Guest: sign-in prompt placeholder. Child `/bookings/:bookingId` reserved |
| `/profile` | Profile placeholder | Profile | Guest: sign-in prompt placeholder. Holds appearance and language entries |
| `/demo` | Demo screen | none (outside shell) | Tokens gallery, adaptive controls, theme/language switchers, user switcher, settings inspector; hidden from navigation, reachable by URL and pushed from Profile. The user switcher and inspector are removed with `--dart-define=HIDE_DEMO_TOOLS=true` |
| anything else | Not-found screen | none | Message plus a button back to `/home` |

Rules:

1. Exactly four top-level destinations, in this order: Home, Facilities, My Bookings, Profile.
   The order is mirrored by direction (Home at the start edge).
2. The selected branch survives a navigation-form change (tab bar / rail / sidebar) and keeps its
   own stack and scroll position.
3. Opening `/bookings` or `/profile` as a guest shows the placeholder with a sign-in prompt and
   does not redirect, so deep links stay stable (real redirects arrive with auth, US-01).
4. Role-specific destinations are extra branches computed from the current user's role
   assignments (`sectionsFor(roles)` gives the sections, `destinationRegistry` says which have a
   screen); the route table is built from that list, not hard-coded per role. The router is
   rebuilt only when the set of paths changes, so switching between a guest and a booker keeps it.
5. Route names are constants in one file; screens never build path strings by hand.
