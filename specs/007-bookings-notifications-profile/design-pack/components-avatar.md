# Avatar
Node: 278:35479 (size 64 at 278:35476)
Covers: FR-MYB-03
- Circle (`radius-full`) `primary-soft`, initials `title` (20/30, 600) in `on-primary-soft`. Sizes: 64 on Account and Edit profile, 48 in lists (only 64 drawn).
- Initials: first letters of the first two names (Figma default "سم"). With a photo the image fills the circle.
- Changing the photo is one of the two editable profile fields (name and photo, FR-MYB-03).

## Round 3 (2026-11-18)
- Node unchanged 278:35479. Variants now: photo=false (initials) and photo=true. photo=true shows the user photo as an image fill clipped to `radius-full`; Figma draws a placeholder (a 32 "Photo placeholder" icon centred on `primary-soft`, seen in 299:44323), so real photos need no extra chrome.
- In Edit profile "تغيير الصورة" (ghost, `primary`) and, only when a photo exists, "حذف الصورة" (ghost, `danger`) sit beside it, both 48 high, hugging; the row wraps when they do not fit. "حذف الصورة" returns the avatar to initials (no confirm drawn).
- Frame 299:44323 is a plain frame holding the placeholder, not an Avatar instance: the component's photo=true variant itself is not instanced in any frame read.
