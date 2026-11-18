# Account · sign out dialog
Covers: US-14, FR-MYB-03
Node: Compact Light 247:5937 (re-read round 2), Dark 247:6355 (not read). Wide: not in the index; uses the same AdaptiveDialog (not read).
Screenshots: images/account-signout-dialog-compact-light.png
## Layout
### Compact
Account (booker, bell with badge "2", tab bar with حسابي selected) behind a full-screen `scrim`. AdaptiveDialog centred: 270 wide, x=60, y=355, `surface-raised`, radius `radius-lg`.
- Body (padding x `space-4`, y `space-5`, gap `space-1`, centred): title, message.
- Actions row (top 1px `line`): two cells 135 wide, 48 high (min 48; fixed in round 2, was 44), split by a 1px `line` (drawn as the left border of the physical-left cell). Confirm "تسجيل الخروج" in the physical-left cell (inline-end in RTL) in `danger` (`body-strong`, 15/24 600), cancel "إلغاء" in the right cell in `primary` (`body`, 15/24 400).
## Text
- Title "تسجيل الخروج؟": `headline`, `ink`. Message "تقدر تدخل تاني في أي وقت بنفس الحساب.": `caption`, `ink`.
## States
Default only. iOS: Cupertino alert; Android: radius-xl dialog with actions at the end; Web: centred, Enter confirms, Esc closes (component description). Danger actions always pass through this dialog.
## Dark theme
Not read.
## Not in Figma
- 48dp is now met (round 2). Dialog is 270 wide (the Cupertino alert width); Android/Web variants follow the component description. "إلغاء" is a noun (fine). What happens to local demo data after sign out: spec.
