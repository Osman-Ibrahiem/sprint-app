# Feature Specification: Checkout with Hold and Sandbox Payment, Confirmation Ticket

**Feature Branch**: `006-checkout-hold-payment` (spec directory `006-checkout-hold-payment`)

**Created**: 2026-11-17

**Status**: Draft

**Input**: User description: "Feature 006 — Checkout with hold and sandbox payment, confirmation ticket (US-10, US-12, plus the paid path of US-06). Design pack in `specs/006-checkout-hold-payment/design-pack/`. Replaces `CheckoutComingSoonScreen` from 005."

**BRD coverage**: FR-BKG-04 (the summary repeated on the payment screen), FR-BKG-05 (the Hold while paying and its expiry), FR-PAY-01 (paying through the one payment-provider interface), FR-PAY-02 (success confirms, failure returns to the same summary with retry, the "confirming" and "still waiting" states, leaving and cancelling per BR-47), FR-PAY-03 (S: a receipt for each successful payment, generated on the device in P1 with a text-share fallback), FR-MYB-01 (confirmation screen with booking code, QR and details), FR-NTF-01 (the in-app confirmation record only). User stories: **US-06** second half (pays successfully → `CONFIRMED`; of two simultaneous bookers only one wins, now with a Hold), **US-07** paid path (a paid place in a shared unit is held and paid), **US-10** (complete), **US-11** (the frozen tier price is what is charged), **US-12** (complete for paid and free bookings, push itself is P2/backend). Business rules: BR-11, BR-12, BR-13 (checked again when the booking is created), BR-16, BR-17 (price frozen on the booking), BR-19 (free bookings skip payment and get the same confirmation ticket), BR-28 (only the provider confirms), BR-29 (provider behind one interface, chosen by a setting), BR-30 and BR-31 (cancellation policy shown, not applied), BR-33 (payment attributed to the owning unit), BR-39 (the reminder lead shown on the confirmation), BR-46 (extended Hold up to `holdMaxMinutes` and automatic full refund), BR-47 (leaving payment and cancelling on the provider page). NFRs: NFR-01, NFR-02, NFR-03, NFR-04, NFR-05, NFR-09, NFR-10. Builds on `specs/001-foundation/` (Hold policy, payment provider interface, fake provider, settings, repositories), `specs/002-design-system-widgets/` (`BookingTicket`, `StatusBadge`, `SprintButton`, `SprintTextField`), `specs/003-auth-verification/` (account gate, tier) and `specs/005-availability-booking/` (schedule, summary, selection in the address, free-booking success screen).

## Scope decisions

These are settled (BRD and `docs/decisions.md` 2026-11-17) and are not reopened here.

- **This feature replaces the "قريبًا" checkout screen.** "متابعة للدفع" on the 005 summary now creates the booking `PENDING_PAYMENT` with a Hold and opens the payment screen.
- **The Hold starts when the booker enters payment** (BR-12), not when they press "الدفع". Its length is `holdMinutes` (10 by default) and every countdown is computed from the booking's hold expiry, never from a local timer alone.
- **The extended Hold (BR-46).** While a payment is pending at the provider, the Hold extends until the provider answers, up to `holdMaxMinutes` from entering payment (20 by default). If the provider confirms in time, the booking is `CONFIRMED`. If the confirmation arrives after the maximum and the place was taken, the payment is refunded 100% automatically. The screens show the outcome; the rule lives behind the repositories.
- **Leaving and cancelling (BR-47).** Leaving the payment screen while holding asks first ("ترك الدفع؟"), and leaving releases the Hold at once (`EXPIRED`). "إلغاء" on the provider page is a cancellation, not a failure: the booker returns to the payment screen with a "الدفع اتلغى" banner and the Hold keeps running. There is no way out while "بنأكد الدفع" shows.
- **Failure keeps the Hold.** A failed payment returns the booker to the same summary with "إعادة المحاولة" while the Hold lasts (US-10). There is no attempt limit; the Hold is the only limit. BR-12's "لو الدفع فشل … الـ Hold بيتلغي" is reworded in the BRD in this PR to match US-10 (decisions.md 2026-11-17).
- **The provider page is simulated inside the app in P1.** It has card fields with test data only. Card data is never stored, logged or passed to the payment provider interface, which only knows the amount and the booking. In P2 the real provider page replaces it without changing the flow.
- **The receipt is a PDF generated on the device** (FR-PAY-03), with sharing as text when generation fails.
- **One confirmation ticket for paid and free bookings.** The 005 free-booking success screen is replaced by the same confirmation screen, without the "paid" row and the receipt entry.
- **Settings are read, never hard-coded:** `holdMinutes`, `holdMaxMinutes`, `cancellationCutoffHours`, `refundPercent`, `reminderLeadMinutes` and `paymentProvider`, all with university → facility → unit inheritance.
- **`copy.md` in the design pack is the reference for every string.** Where Figma and the design pack differ in wording, the design pack wins.

## Clarifications

### Session 2026-11-17

- Q: Are "إضافة للتقويم" and the real Lottie moments part of 006? → A: No. Both are deferred to feature 11 (Osman's instruction for this spec). 006 shows static placeholders (icon and text) for success and payment failure, and no "إضافة للتقويم" action.
- Q: When the Hold maximum has passed and the booking is `EXPIRED`, and the provider then confirms while the place is still free, is the booking confirmed? → A: No. An `EXPIRED` booking never comes back; any late success after the maximum (or after "ترك الدفع") is refunded 100% automatically, whether the place was taken or not.
- Q: When the Hold was extended for a pending payment (BR-46) and the provider then answers with failure or cancel, does the booker keep the extra time to retry? → A: No. The extension lasts only until the provider answers. If the normal Hold has already passed when a failed or cancelled answer arrives, the booking becomes `EXPIRED` at once and the expired state shows; if the normal Hold has not passed yet, the Hold keeps its normal expiry (/speckit-analyze H1, approved by Osman 2026-11-17).
- Q: Which booking code format does the demo use? → A: The existing generator's `SP-1xxx` for every booking, seed included. The `SPR-4F7K2` style in Figma is a sample only (/speckit-analyze H2).
- Q: What does the fake provider's "delay" outcome end with? → A: Success after the chosen delay. The delay length is chosen in `/demo` so both "confirmed within the maximum" and "after the maximum, refunded" can be recorded; failure is its own outcome.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Pay for a held place and get a confirmed ticket (Priority: P1)

A signed-in booker on the 005 summary of a paid slot taps "متابعة للدفع". The place is held for them and a payment screen shows the Hold countdown, the booking summary, the cancellation policy and the payment method with a test-mode tag. They tap "الدفع · 80 ج.م", fill the test card on the provider page, confirm, see "بنأكد الدفع", and land on "حجزك اتأكد" with the booking ticket (code and QR).

**Why this priority**: This is the second half of US-06 and all of US-12. Without it no paid booking can be completed, and the recorded defense video has a dead end.

**Independent Test**: With the fake provider set to succeed, book a paid lane and a paid pitch from the seed data end to end, and check the booking is `CONFIRMED`, a payment is recorded for the facility's owning unit, an in-app confirmation record exists, and the place shows as taken on the schedule for another account.

**Acceptance Scenarios**:

1. **Given** the 005 summary of a paid selection, **When** the booker taps "متابعة للدفع", **Then** availability and conflicts are checked again (BR-11, BR-13), a booking is created `PENDING_PAYMENT` with a Hold expiring after `holdMinutes`, and the payment screen opens.
2. **Given** the payment screen, **When** it shows, **Then** it has, in order: the Hold banner ("المكان متحجز لك لحد ما الدفع يخلص" and "فاضل {m:ss} دقيقة، وبعدها المكان يرجع متاح"), the summary card (facility, unit, trainer if any, time, tier, total at the frozen price), the cancellation policy card filled from `cancellationCutoffHours` and `refundPercent`, the payment method card, and one main action "الدفع · {amount}".
3. **Given** the configured provider is the fake or the sandbox, **When** the payment method card and the provider page show, **Then** the test-mode tag "وضع الاختبار · مفيش فلوس حقيقية بتتخصم" is visible; it is not shown for any other provider.
4. **Given** the booker taps "الدفع", **When** the provider page opens, **Then** it shows the amount, "سبرنت · {facility}", four card fields, the notice that the page belongs to the provider, "تأكيد الدفع · {amount}" and "إلغاء", with the Hold countdown still visible.
5. **Given** the provider page, **When** the booker confirms, **Then** the "بنأكد الدفع" screen shows with a loader, the booking card with "في انتظار الدفع", and the live Hold countdown; it has no back action.
6. **Given** the provider reports success, **When** the confirmation arrives, **Then** the booking becomes `CONFIRMED`, the payment is recorded `succeeded` with its paid time and the facility's owning unit (BR-33), an in-app confirmation record is written (FR-NTF-01), and the confirmation screen opens.
7. **Given** the confirmation screen, **When** it shows, **Then** it has no back to payment, a success illustration placeholder, "حجزك اتأكد", the line "وصلك إشعار بالتفاصيل، وهنفكرك قبل الميعاد بـ{lead}" with the lead built from `reminderLeadMinutes`, the booking ticket (time strip, "مؤكد", facility, unit, trainer, date and time, booking code, QR on white, "المدفوع {amount}", and the cancellation line "الإلغاء متاح لحد {until}" or "الإلغاء مش متاح"), a "إيصال الدفع" entry, and "الرجوع للرئيسية".
8. **Given** the booking code on the ticket, **When** the booker activates copy, **Then** the code is copied and "اتنسخ" is announced and shown.
9. **Given** a confirmed booking's link, **When** it is opened again later (refresh, restart, share), **Then** the confirmation screen shows the booking as it is now, from the stored data.

---

### User Story 2 - Payment fails and I try again while the place is held (Priority: P1)

The provider reports a failure. The booker returns to the same summary, titled "ملخص الحجز", with "الدفع ماتمّش. ممكن تحاول تاني", the Hold still counting, and "إعادة المحاولة · {amount}".

**Why this priority**: US-10 first criterion and FR-PAY-02. A defense video must show failure handled cleanly.

**Independent Test**: Set the fake provider to fail from `/demo`, pay, check the failure state and the unchanged Hold; switch the provider to succeed, retry, and check the booking confirms with a second payment record.

**Acceptance Scenarios**:

1. **Given** the provider reports failure, **When** the booker returns, **Then** the booking stays `PENDING_PAYMENT`, the payment is recorded `failed`, the Hold expiry is unchanged (unless the Hold had been extended and its normal expiry has passed, in which case the booking is `EXPIRED` and the expired state shows, FR-016), and the screen shows the failure message (icon and words, not colour alone), the Hold banner, the summary, the policy, the payment method and "إعادة المحاولة · {amount}".
2. **Given** the failure state, **When** the booker retries, **Then** a new payment starts and the flow continues as in Story 1; there is no limit on attempts while the Hold lasts.
3. **Given** the failure state, **When** the Hold runs out on screen, **Then** the screen turns into the "المهلة خلصت" state without any action from the booker.

---

### User Story 3 - The Hold runs out (Priority: P1)

The booker waits too long. In the last minute the banner turns to "المهلة على وشك تخلص" with the seconds left. When it reaches zero with no pending payment, the booking expires, the place returns to others, and "المهلة خلصت" offers "اختيار ميعاد تاني" and "الرجوع للرئيسية".

**Why this priority**: US-10 second criterion, BR-12 and FR-BKG-05.

**Independent Test**: Set `holdMinutes` to 1 through the demo settings, enter payment, wait, and check the last-minute banner, the expired screen, the booking `EXPIRED`, and the slot available again to another account.

**Acceptance Scenarios**:

1. **Given** less than 60 seconds left, **When** the banner shows, **Then** it changes to the danger style with "المهلة على وشك تخلص" and "فاضل {seconds} ثانية، وبعدها المكان يرجع متاح", and it is announced once.
2. **Given** the Hold reaches its expiry with no pending payment, **When** this happens on the payment, failure or cancelled state, **Then** the booking becomes `EXPIRED`, the place is available to others at once, and the screen shows "المهلة خلصت", "المكان رجع متاح للناس. ممكن تختار الميعاد من جديد.", the booking card with "انتهت المهلة", "اختيار ميعاد تاني" and "الرجوع للرئيسية".
3. **Given** "اختيار ميعاد تاني", **When** activated, **Then** the facility's schedule opens without the old selection.
4. **Given** the app was closed or in the background, **When** it opens again before the expiry, **Then** the countdown shows the correct remaining time; **When** it opens after the expiry, **Then** the expired state shows.
5. **Given** the payment screen is open, **When** the window is resized, the device is folded or unfolded, or the theme or language changes, **Then** the Hold keeps its expiry and the countdown does not restart.

---

### User Story 4 - Confirmation is slow, and the Hold waits for the provider (Priority: P1)

The booker confirms on the provider page but no answer comes for a while. After a short wait the screen changes to "لسه مستنيين تأكيد الدفع", explaining that if they were charged and the booking isn't confirmed the money comes back automatically. The Hold extends while the payment is pending, up to the maximum.

**Why this priority**: BR-28 and BR-46. This is the case where real money could be taken without a booking, and the screen promises a behaviour that must exist.

**Independent Test**: Set the fake provider to "delay" from `/demo` with a delay longer than the Hold, pay, and check: the processing screen, then the awaiting screen; the Hold expiry moves forward but never past entry + `holdMaxMinutes`; a late success within the maximum confirms; a late success after the maximum with the place taken creates a 100% refund and leaves the booking `EXPIRED`.

**Acceptance Scenarios**:

1. **Given** the processing screen, **When** no answer arrives within the processing wait, **Then** the awaiting screen shows "لسه مستنيين تأكيد الدفع", its explanation, the booking card with "في انتظار الدفع", "تحديث الحالة" and "الرجوع للحجوزات"; updates keep arriving on their own.
2. **Given** a pending payment, **When** the original Hold expiry passes, **Then** the booking stays `PENDING_PAYMENT`, its Hold expiry is extended (never beyond entry time + `holdMaxMinutes`), the place stays held, and every countdown on screen follows the new expiry.
3. **Given** "تحديث الحالة", **When** activated, **Then** the latest provider status is read at once; it never confirms anything by itself (BR-28).
4. **Given** the provider succeeds before the maximum, **Then** the booking confirms as in Story 1.
5. **Given** the maximum passes with the payment still pending, **Then** the booking becomes `EXPIRED` and the place is released; **When** the provider later reports success and the place has been taken, **Then** a refund of 100% of the payment is recorded automatically and attributed to the owning unit; **When** the place is still free at that moment, **Then** the booking is still not confirmed and the payment is refunded 100% (an expired booking never comes back, clarify 2026-11-17).
6. **Given** "الرجوع للحجوزات", **When** activated, **Then** the booker goes to the "حجوزاتي" tab, the booking stays `PENDING_PAYMENT`, and the outcome is applied in the background and written as an in-app record.

---

### User Story 5 - Leave payment, or cancel on the provider page (Priority: P1)

The booker changes their mind. Back on the payment screen asks "ترك الدفع؟"; leaving releases the place. On the provider page "إلغاء" returns to the payment screen with "الدفع اتلغى · المكان لسه متحجز لك، وممكن تحاول تاني".

**Why this priority**: BR-47. Without it a back gesture could silently keep or silently drop a place.

**Independent Test**: Enter payment, use back on each platform (button, gesture, browser back), choose each dialog action, and check the booking status; open the provider page, cancel, and check the banner, the unchanged Hold and the payment record.

**Acceptance Scenarios**:

1. **Given** the payment screen while holding (including the failed and cancelled states), **When** the booker goes back by any means (app bar back, system back, edge swipe, browser back, closing the screen), **Then** a platform dialog asks "ترك الدفع؟" with "لو سبت الصفحة دلوقتي، المكان بيرجع متاح للناس.", a destructive "ترك الدفع" and "إكمال الدفع".
2. **Given** the dialog, **When** "ترك الدفع" is chosen, **Then** the Hold is released at once, the booking becomes `EXPIRED`, and the booker returns to the 005 summary with the same selection; **When** "إكمال الدفع" is chosen, **Then** nothing changes.
3. **Given** the provider page, **When** "إلغاء" is chosen, **Then** the booker returns to the payment screen with the "الدفع اتلغى" banner, the booking stays `PENDING_PAYMENT` with the same Hold expiry, the payment is recorded as cancelled (not failed), and "الدفع · {amount}" starts a new payment.
4. **Given** the processing screen, **When** the booker tries to go back, **Then** nothing happens (no back action is offered and system back is absorbed).

---

### User Story 6 - Keep a receipt (Priority: P2)

From the confirmation of a paid booking the booker opens "إيصال الدفع" and sees the receipt: receipt number, booking code, date, unit, tier, payment method ("بطاقة تنتهي بـ {last4} · اختبار"), total paid, and the test-mode tag. They save it as PDF or share it.

**Why this priority**: FR-PAY-03 is "S" in the BRD.

**Independent Test**: Confirm a paid booking, open the receipt, save as PDF on each platform (share sheet on mobile, download on web), and force a generation failure to check that sharing as text still works.

**Acceptance Scenarios**:

1. **Given** a `succeeded` payment, **When** the receipt opens, **Then** every row shows, with the receipt number of the form `RC-YYMMDD-NNNN` and the codes in left-to-right isolates; the owning unit is recorded but not shown.
2. **Given** "حفظ الإيصال PDF", **When** activated, **Then** a PDF with the same rows (Arabic, RTL, Cairo) is generated on the device and handed to the platform's save or share; **When** generation fails, **Then** the receipt is offered as text through share instead, with a message in words.
3. **Given** "مشاركة الإيصال", **When** activated, **Then** the receipt is shared as text through the platform share (or copied on platforms without share, with "اتنسخ").
4. **Given** a free booking or a booking with no `succeeded` payment, **Then** there is no receipt entry and the receipt link shows a not-found message.
5. **Given** the receipt text, **Then** it never contains a full card number, expiry or security code.

---

### User Story 7 - The demo can show success, failure and delay on demand (Priority: P2)

Whoever records the demo opens `/demo` and sets the fake provider's next outcome: success, failure, or delay (with a delay length), so each branch of the flow can be recorded without editing code.

**Why this priority**: The defense is a recorded video (decisions 2026-11-16). Every branch must be reachable on purpose.

**Independent Test**: For each outcome in `/demo`, run a payment and check the matching screen; reset demo data and check the outcome returns to success.

**Acceptance Scenarios**:

1. **Given** `/demo`, **When** it shows the payment section, **Then** it offers the outcome (نجاح · فشل · تأخير) and, for delay, the delay length (a delayed payment ends in success); the current choice is visible.
2. **Given** an outcome is chosen, **When** payments run, **Then** each payment follows it until it is changed; resetting demo data returns it to success.
3. **Given** the provider page, **Then** it also accepts the published test card numbers, and the outcome is decided by the demo setting, not by what is typed.

---

### User Story 8 - Free bookings get the same ticket (Priority: P2)

A free-facility booking (BR-19) still confirms at once without payment, but now lands on the same confirmation screen with the ticket and QR, the row "السعر · مجاني", and no receipt.

**Why this priority**: US-12 applies to every booking and the 005 simple success screen was a placeholder.

**Independent Test**: Book a free range on seed data and check the confirmation screen, ticket, QR, absence of the receipt entry, and the in-app record.

**Acceptance Scenarios**:

1. **Given** a free selection, **When** confirmed from the summary, **Then** the booking is `CONFIRMED` without a Hold or payment, an in-app confirmation record is written, and the confirmation screen shows "السعر · مجاني" and no receipt entry.

---

### User Story 9 - It works on every screen, language and theme (Priority: P2)

Every screen in this flow works on compact, medium, expanded and large windows, in Arabic (RTL) and English, light and dark, with platform-native navigation, dialogs and back behaviour, keyboard focus and screen readers.

**Why this priority**: NFR-01 – NFR-04 and the design rules in `CLAUDE.md`.

**Independent Test**: Walk the whole flow on each window class in both languages and themes, with text scale 200%, keyboard only on web, and a screen reader on one mobile platform.

**Acceptance Scenarios**:

1. **Given** compact, **Then** each screen is one column and the payment and confirmation actions sit in a fixed bottom bar.
2. **Given** medium and wider, **Then** the payment screen has two columns (payment column and summary column) per the design pack, with the action at the end of the payment column; the provider page, processing, awaiting and receipt screens are one centred column; the confirmation is one column on medium and two columns (ticket and message) on expanded and large.
3. **Given** a foldable with a hinge across the two columns, **Then** content is moved to one side of the hinge.
4. **Given** text scale 200%, **Then** no text is cut (long text wraps), including the policy card in the medium summary column.
5. **Given** a screen reader, **Then** the countdown is announced every 30 seconds and once at the last minute (not every second), failure and expiry titles are announced once, the pay button reads its full amount, the booking code reads character by character, and the QR is labelled "رمز الحضور، اعرضه للمدرب".
6. **Given** reduced motion, **Then** no countdown or success animation plays; numbers still update.
7. **Given** either theme, **Then** the QR is dark modules on white with its quiet zone.

---

### Edge Cases

- **Two bookers race for the last place.** The second "متابعة للدفع" is refused because the first booking's live Hold takes the place; the second booker sees "الميعاد ده اتحجز" on the 005 summary or schedule (US-06).
- **The booker already has an overlapping booking or live Hold** when entering payment: refused with the 005 overlap message (BR-13).
- **The tier changes between summary and payment** (verification approved in between): the booking freezes the tier and price at creation (BR-17), and the payment screen always shows that frozen amount, which is the amount charged. No separate notice is shown; the window is a few seconds and the summary already re-quotes on every open.
- **The settings change while a Hold is live** (`holdMinutes`, `holdMaxMinutes`): the live booking keeps its expiry and maximum (both stored on the booking at creation); new bookings use the new values.
- **`holdMaxMinutes` set lower than `holdMinutes`**: the maximum is treated as equal to `holdMinutes` (no extension).
- **The payment link opened by another account, by a guest, or for a booking that is no longer `PENDING_PAYMENT`**: an account gate, a no-access screen, or the screen matching the booking's current status (confirmed → confirmation; expired → expired state; cancelled → not found).
- **Refresh or restart on the provider page or processing screen**: the flow resumes from the stored booking and payment (pending → processing or awaiting; no new payment is started).
- **The provider answers after the booker left with "ترك الدفع"**: the booking is `EXPIRED`; a late success is refunded 100% automatically (same path as BR-46).
- **Network or provider start error** before the provider page: a message in words on the payment screen, no payment recorded as failed, Hold unchanged.
- **The booking starts before the Hold would end** (very late booking): the Hold never runs past the slot's start; it is capped there.
- **A cancellation cutoff already passed** at confirmation: the ticket shows "الإلغاء مش متاح". The same holds on the payment screen: when the booking is made after its cutoff, the policy card says "الإلغاء مش متاح" instead of naming a time that has passed (Osman, 2026-11-18, walk D5).

## Requirements *(mandatory)*

### Functional Requirements

**Entering payment and the Hold**

- **FR-001**: "متابعة للدفع" on the summary of a paid selection MUST create the booking through the booking repository, which re-checks permission, availability and conflicts (BR-11, BR-13), freezes the tier and price (BR-17), sets status `PENDING_PAYMENT` and a Hold expiry of entry time + `holdMinutes` (BR-12), all as one step.
- **FR-002**: A refused creation MUST return the booker to the 005 summary or schedule with the existing refusal messages; nothing is held.
- **FR-003**: Every countdown MUST be computed from the booking's stored Hold expiry and the current time, update every second on screen, survive leaving and returning to the app, and never restart on layout, theme or language changes.
- **FR-004**: A booking whose Hold expired with no pending payment MUST become `EXPIRED` and release its place at once for every other booker; this is applied by the repository whenever bookings are read or written and on a periodic check while the app runs.
- **FR-005**: The Hold banner MUST switch to the last-minute style and wording when less than 60 seconds are left, with the word and icon, not colour alone.

**Payment screen and provider**

- **FR-006**: The payment screen MUST show the Hold banner, the booking summary (reusing the 005 summary rows), the cancellation policy built from `cancellationCutoffHours` and `refundPercent`, the payment method, and one primary action "الدفع · {amount}" with the frozen amount.
- **FR-007**: The test-mode tag MUST show on the payment method card, provider page and receipt when, and only when, the `paymentProvider` setting is the fake or the sandbox.
- **FR-008**: All payments MUST go through the payment provider interface (BR-29); screens MUST NOT know which provider answers. Only the provider's reported status may confirm a booking (BR-28).
- **FR-009**: The simulated provider page MUST collect card details only for display and validation of format, MUST NOT store, log, persist or pass them anywhere, and MUST keep only the last four digits for the receipt's method line.
- **FR-010**: The fake provider's outcome MUST be controllable from `/demo`: success, failure, or delay (with a length), kept until changed and reset with the demo data.

**Outcomes**

- **FR-011**: On success the booking MUST become `CONFIRMED`, the payment MUST be recorded `succeeded` with its paid time, amount, provider and the facility's owning unit (BR-33), and an in-app confirmation record MUST be written (FR-NTF-01). This is the only notification of a normal payment flow: a failure or a cancel is shown on screen and is not written as a notification.
- **FR-012**: On failure the booking MUST stay `PENDING_PAYMENT` with the same Hold (except as FR-016 says for an extended Hold), the payment MUST be recorded `failed`, and the screen MUST show the failure state with "إعادة المحاولة · {amount}"; retries are unlimited while the Hold lasts.
- **FR-013**: "إلغاء" on the provider page MUST record the payment as cancelled (distinct from failed), keep the booking and Hold unchanged (except as FR-016 says for an extended Hold), and show the payment screen with the "الدفع اتلغى" banner (BR-47).
- **FR-014**: After the provider page, the processing screen MUST show with no back action until an answer arrives; if none arrives within a processing wait (20 seconds by default, a constant of the presentation, not a business setting), the awaiting screen MUST show.
- **FR-015**: The awaiting screen MUST keep listening for the outcome, offer "تحديث الحالة" (an immediate status read that never confirms by itself) and "الرجوع للحجوزات" (to the "حجوزاتي" tab, leaving the booking pending and updated in the background).

**Extended Hold and automatic refund (BR-46)**

- **FR-016**: While a payment is pending, a Hold that reaches its expiry MUST be extended until the provider answers, never beyond entry time + `holdMaxMinutes`, and never beyond the slot's start; the place stays held meanwhile. The extension ends with the answer: an extended Hold ends with the provider's answer: if the normal Hold (`holdStartedAt + holdMinutes`) has already passed when a `failed` or `cancelled` answer arrives, the booking becomes `EXPIRED` at once (BR-46 "لحد رد المزوّد"); a success confirms as in FR-011.
- **FR-017**: When the maximum passes with the payment still pending, the booking MUST become `EXPIRED` and the place released.
- **FR-018**: A success that arrives for a booking that is no longer `PENDING_PAYMENT` (expired by the maximum, or left with "ترك الدفع") MUST trigger an automatic 100% refund through the provider, recorded and attributed to the owning unit, and an in-app record telling the booker the money was returned.

**Leaving (BR-47)**

- **FR-019**: Every way of leaving the payment screen while holding MUST ask "ترك الدفع؟" with a platform dialog; "ترك الدفع" MUST release the Hold at once (`EXPIRED`) and return to the 005 summary with the same selection; "إكمال الدفع" changes nothing.
- **FR-020**: The processing screen MUST absorb every back action.

**Confirmation and ticket**

- **FR-021**: The confirmation screen MUST show the success placeholder, "حجزك اتأكد", the line with the reminder lead built from `reminderLeadMinutes` (plural-aware: "ساعة"، "ساعتين"، "3 ساعات"، "ساعة ونص"), the `BookingTicket` (today or upcoming state, code, QR, price or "مجاني", cancellation line from `cancellationCutoffHours`), the receipt entry for paid bookings, and "الرجوع للرئيسية". It has no back to payment.
- **FR-022**: The booking code MUST be copyable with a visible and spoken "اتنسخ".
- **FR-023**: Free bookings (BR-19) MUST land on the same confirmation screen with "السعر · مجاني" and no receipt entry, replacing the 005 simple success screen.
- **FR-024**: The confirmation, receipt and payment screens MUST be reachable by link and rebuilt from stored data after a refresh or restart; a link to a booking in another status shows that status's screen.

**Receipt (FR-PAY-03)**

- **FR-025**: For each `succeeded` payment a receipt MUST be available with number (`RC-` + compact date + sequence), booking code, date, unit, tier, method with last four digits and "اختبار" in test mode, and total paid.
- **FR-026**: "حفظ الإيصال PDF" MUST generate the PDF on the device (Arabic, RTL, the app font) and hand it to the platform save or share; on failure it MUST fall back to sharing the receipt as text, with a message.
- **FR-027**: "مشاركة الإيصال" MUST share the receipt as text (or copy it where share is unavailable).

**Access**

- **FR-028**: All screens in this flow require an account and belong to the booking's owner; others see the existing no-access screen, guests the account gate with return.

**Presentation rules**

- **FR-029**: Every string MUST come from the l10n files with the keys and wording of `design-pack/copy.md`, in Arabic and English, with no imperative verbs, Western digits, 12-hour time, amounts as "80 ج.م" / "EGP 80", and codes, amounts and card digits in left-to-right isolates.
- **FR-030**: Layout MUST follow window width per `design-pack/adaptive.md`; navigation bars, dialogs, back gestures and loaders MUST follow the platform; tokens only.
- **FR-031**: Screen-reader behaviour MUST follow Story 9 scenario 5; reduced motion MUST stop every animation in the flow.
- **FR-032**: Success and failure illustrations MUST be static placeholders (icon and text) in this feature; Lottie arrives in feature 11.

### Key Entities

- **Booking** (existing): gains a mutable Hold expiry (extended under BR-46) and the time payment was entered, from which the maximum is computed. Statuses unchanged.
- **Payment** (existing): one per attempt, attributed to the owning unit; status pending, succeeded, failed, or cancelled (cancelled on the provider page, BR-47); holds the paid time and the card's last four digits (only these, and only for the receipt).
- **Refund** (existing): created automatically at 100% for a late success on a booking that is no longer pending (BR-46).
- **Receipt** (derived): a view of a succeeded payment and its booking with a receipt number; not stored separately.
- **In-app notification record** (existing): booking confirmed; payment refunded automatically.
- **Fake provider outcome** (demo state): success, failure, or delay with a length.
- **Settings** (existing, plus one): `holdMinutes`, `holdMaxMinutes` (new, default 20), `cancellationCutoffHours`, `refundPercent`, `reminderLeadMinutes`, `paymentProvider`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A signed-in booker completes a paid booking from the summary to the confirmed ticket in under 60 seconds with the fake provider set to succeed, on every window class.
- **SC-002**: Each branch (success, failure then retry, cancel then retry, leave, last minute, expiry, slow confirmation within the maximum, slow confirmation after the maximum with refund) can be reached on purpose from `/demo` and recorded end to end, with no dead end and no code change.
- **SC-003**: In 100% of automated runs, no booking is `CONFIRMED` without a `succeeded` payment from the provider, and no held place is bookable by anyone else until the Hold ends.
- **SC-004**: In 100% of automated runs, a Hold never extends past entry + `holdMaxMinutes`, and every late success on a non-pending booking produces exactly one 100% refund.
- **SC-005**: The countdown on screen is never more than 1 second off the stored expiry, including after the app returns from the background.
- **SC-006**: No card number, expiry or security code appears in stored data, logs, receipts or shares (checked by tests).
- **SC-007**: Every screen in the flow passes the walk in Arabic and English, light and dark, on compact, medium, expanded and large, at text scale 200% with no cut text, keyboard-only on web, and with a screen reader.
- **SC-008**: Changing any of the six settings in the demo settings inspector changes the behaviour and wording of the next booking with no code change.

## Out of scope

This feature is UI-first on mock data. These are explicitly not part of it:

- **Backend**: no Supabase, no Firebase, no server, no webhooks, no real database and no real push. The in-memory repositories and the fake provider enforce BR-12, BR-28, BR-46 and BR-47 as the backend will later.
- **A real payment gateway**: P1 runs the fake provider (and only the sandbox shape behind the same interface). No real money, no real card processing, no provider SDK, and the university's e-collection platform is P2.
- **SMS** and any paid service: not used in P1.
- **Booking cancellation by the booker or an admin, cancellation refunds, and their screens** (US-13, FR-PAY-04, BR-30 – BR-32 applied): feature 7. The policy is only shown.
- **My bookings list, reminders, the notifications centre and profile** (US-13, US-14, FR-MYB-02, FR-MYB-03): feature 7. "الرجوع للحجوزات" goes to the existing tab placeholder; in-app records are written but their screen is feature 7.
- **Offers on the price** (BR-20, US-24): feature 10. The charged amount is the frozen tier price.
- **Real Lottie animations** (success, payment failure): feature 11. Static placeholders here.
- **"إضافة للتقويم"** (add to calendar): deferred to feature 11 (see Assumptions); not shown in this feature.
- **Raising screen brightness on the ticket** (C2): only if trivially available; otherwise later.
- **Trainer check-in by QR** (US-15 – US-17): feature 8. The QR is shown, not scanned.
- **Admin views of payments and revenue reports**: features 9 and 10.
- **Android-specific Figma frames**: not drawn; the adaptive primitives decide.
- **Anything from P2**: university system integration, SMS, the e-collection platform.

## Assumptions

- **Add to calendar and Lottie are deferred to feature 11** (settled in clarify 2026-11-17): in 006 the success and failure moments are static placeholders and there is no "إضافة للتقويم" action.
- **`holdMaxMinutes` is a new setting** (BR-46, default 20) with the same inheritance as `holdMinutes`.
- **The processing-to-awaiting wait (20 seconds) is a presentation constant**, not a business setting, because the BRD does not define it.
- **Seed and demo data**: the sample booking is "حمام السباحة الأوليمبي · حارة 3 · الكابتن أحمد سامي · 5:00 – 6:00 م · داخلي موثّق 80 ج.م", with a code from the existing seed generator (`SP-1xxx`), receipt `RC-261108-0482`; and one free confirmed sample. Figma's `SPR-4F7K2` and `SPR-Q4N7A` are samples only (clarify 2026-11-17).
- **The 005 summary keeps its role.** It is the screen the booker returns to after "ترك الدفع"; the failure state reuses the payment screen with the title "ملخص الحجز".
- **The rules already exist behind the repositories.** The Foundation built the Hold policy, the provider interface, the fake provider and the booking repository's pay step; this feature extends them (pending payments, extension, cancelled status, refunds on late success, demo control) rather than duplicating rules in the screens.
