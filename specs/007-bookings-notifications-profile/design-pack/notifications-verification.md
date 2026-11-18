# Notifications · verification
Covers: US-13, FR-NTF-01, FR-NTF-02 (verification outcomes from US-02/US-03)
Node: Compact Light 298:42545 (Dark and Medium/Expanded/Large: not located, not read)
Screenshots: images/notifications-verification-compact-light.png
## Layout
### Compact (390 x 844)
Same shell as notifications.md (status bar 54, AdaptiveAppBar "رجوع" + "الإشعارات", Actions row with ghost "تعليم الكل كمقروء" 120 x 48, tab bar with الرئيسية highlighted as "pushed from Home"). Content column gap `space-3`, padding x `space-4`, bottom 120. Three NotificationCards, each 110 high, `surface`, radius `radius-lg`, padding `space-4`, gap `space-3`, icon tile 40 circle with icon 20:
1. Rejected: `danger-soft` + x-circle, UNREAD (dot 8). Time "أمس". Title "توثيق الحساب مرفوض". Body "السبب: الصورة مش واضحة" (reason line, example from the reviewer). Tap: opens the verification request (annotation, FR-NTF-01).
2. Under review: `warning-soft` + clock, UNREAD. Time "3:12 م". Title "توثيق الحساب قيد المراجعة". Body "طلب التوثيق بيتراجع. لحد ما يتقبل هتحجز بالسعر الكامل". Tap: opens the verification request status.
3. Approved: `success-soft` + check-circle, read (no dot). Time "الخميس". Title "توثيق الحساب تمت الموافقة". Body "الأسعار الداخلية بقت سارية على الحجوزات الجديدة". Tap: opens Account.
## Text
Time `caption` `ink-muted`; title `headline` `ink` 1 line; body `body` `ink-muted` max 2 lines.
## States
unread true/false per card as above. Three outcome kinds exist; "expired" verification has no card drawn.
## Dark theme
Not read.
## Not in Figma / findings
- Copy: "تمت الموافقة" is Modern Standard Arabic and "مرفوض"/"قيد المراجعة" are the StatusBadge words; titles read as noun phrases (OK for the no-imperative rule) but the approved title breaks the Egyptian-dialect rule; the older list card used "حسابك اتوثّق". Confirm with Osman which one wins.
- The reason line must come from the verifier's note (BR rejection reason); long reasons need a hug-height card, not clipping (110 is fixed here).
- Mismatch with notifications.md card 4 (verification "حسابك اتوثّق", read, `primary-soft` + shield-check): the verification frame uses `success-soft` + check-circle for approved. The `primary-soft` + shield-check tile in components-notification-card.md therefore applies to a generic verification notice only; implement the three outcome tiles from this frame.
- Tap navigation targets (verification request screen, Account) belong to feature 3; routes: take from the spec.
