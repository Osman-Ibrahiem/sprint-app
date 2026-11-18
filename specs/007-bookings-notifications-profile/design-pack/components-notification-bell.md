# NotificationBell
Node: 275:33666 (variant unread=true count "2" at 275:33661)
Covers: FR-NTF-02, US-13
- Size 48 circle, `surface` fill, radius `radius-full`; bell icon 24 (Phosphor Regular, not mirrored).
- Badge: `danger` fill, `on-danger` text `micro` (12/16 500), min width 18, padding-x 5, radius-full, at top 6, offset 26 from the bell's start.
- Variants: unread=true (badge with count), unread=false (no badge, count 0).
- Placement (round 2): Home booker and Account headers (read): bell at the physical left (inline-end in RTL), title/greeting at the right. Account loading shows the unread=false variant (no badge). Facilities and My bookings headers not re-read.
- Used in the header of the four main Compact screens (Home, Facilities, My bookings, Account). Opens Notifications as a pushed screen with back. Not shown to guests or on Medium+ (rail/sidebar carries the badge).
- Hit area: 48 (meets rule). Screen-reader label with the unread count: not in Figma.
