import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprint/app/router/routes.dart';
import 'package:sprint/core/adaptive/adaptive_app_bar.dart';
import 'package:sprint/core/adaptive/adaptive_back_button.dart';
import 'package:sprint/core/l10n/ltr_isolate.dart';
import 'package:sprint/core/l10n/sprint_format.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/time/cairo_time.dart';
import 'package:sprint/core/time/clock_provider.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/tokens/sprint_radius.g.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/core/widgets/sprint_text_field/sprint_text_field.dart';
import 'package:sprint/features/booking/presentation/checkout/hold_banner.dart';
import 'package:sprint/features/booking/presentation/providers/checkout_providers.dart';
import 'package:sprint/features/payments/presentation/card_format.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// The simulated provider page (R5): what a hosted gateway page would be.
/// It lives outside the shell, validates the format of a test card and tells
/// the fake provider only the last four digits (FR-009, BR-28). Leaving by
/// back or "إلغاء" is a cancel on the provider (BR-47), not a failure.
///
/// A session the fake no longer knows (the app restarted since it was opened)
/// or one that already has its answer sends the booker back to the booking
/// and never starts a payment (FR-024).
class FakeGatewayScreen extends ConsumerWidget {
  const FakeGatewayScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final known = ref.watch(fakeGatewayProvider).session(sessionId);
    if (known == null || known.settled) {
      final target = ref.watch(bookingOfSessionProvider(sessionId));
      return target.when(
        data: (t) => _Redirect(location: t ?? AppPaths.home),
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const _Redirect(location: AppPaths.home),
      );
    }
    return _GatewayForm(
      sessionId: sessionId,
      bookingId: known.bookingId,
      amount: known.amount,
    );
  }
}

class _Redirect extends StatefulWidget {
  const _Redirect({required this.location});
  final String location;

  @override
  State<_Redirect> createState() => _RedirectState();
}

class _RedirectState extends State<_Redirect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(widget.location);
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _GatewayForm extends ConsumerStatefulWidget {
  const _GatewayForm({
    required this.sessionId,
    required this.bookingId,
    required this.amount,
  });

  final String sessionId;
  final String bookingId;
  final int amount;

  @override
  ConsumerState<_GatewayForm> createState() => _GatewayFormState();
}

class _GatewayFormState extends ConsumerState<_GatewayForm> {
  // What is typed lives here only and is cleared on dispose (FR-009).
  final _number = TextEditingController();
  final _expiry = TextEditingController();
  final _cvc = TextEditingController();
  final _name = TextEditingController();

  bool _submitted = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _bind(_number, CardFormat.groupNumber);
    _bind(_expiry, CardFormat.groupExpiry);
    _bind(_cvc, (t) {
      final d = CardFormat.digits(t);
      return d.length > 4 ? d.substring(0, 4) : d;
    });
    _name.addListener(_refresh);
  }

  void _refresh() {
    if (mounted && _submitted) setState(() {});
  }

  /// Groups what is typed into [c] as it changes (digits keep their order in
  /// a left-to-right field, also in Arabic), and re-checks it once submitted.
  final Map<TextEditingController, VoidCallback> _listeners = {};

  void _bind(TextEditingController c, String Function(String) group) {
    void listener() {
      final grouped = group(c.text);
      if (grouped != c.text) {
        c.value = TextEditingValue(
          text: grouped,
          selection: TextSelection.collapsed(offset: grouped.length),
        );
      }
      _refresh();
    }

    _listeners[c] = listener;
    c.addListener(listener);
  }

  @override
  void dispose() {
    // Stop listening first: clearing notifies, and this state is going away.
    _listeners.forEach((c, l) => c.removeListener(l));
    _name.removeListener(_refresh);
    _number.clear();
    _expiry.clear();
    _cvc.clear();
    _name.clear();
    _number.dispose();
    _expiry.dispose();
    _cvc.dispose();
    _name.dispose();
    super.dispose();
  }

  DateTime get _nowCairo => CairoTime.toCairo(ref.read(appClockProvider).now());

  bool get _valid =>
      CardFormat.isValidNumber(_number.text) &&
      CardFormat.isValidExpiry(_expiry.text, _nowCairo) &&
      CardFormat.isValidCvc(_cvc.text) &&
      CardFormat.isValidName(_name.text);

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppPaths.home);
    }
  }

  void _confirm() {
    if (_done) return;
    setState(() => _submitted = true);
    if (!_valid) return;
    _done = true;
    // Only the last four digits leave this page.
    ref
        .read(fakeGatewayProvider)
        .confirm(widget.sessionId, cardLast4: CardFormat.last4(_number.text));
    _leave();
  }

  void _cancel() {
    if (_done) return;
    _done = true;
    ref.read(fakeGatewayProvider).cancel(widget.sessionId);
    _leave();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final format = SprintFormat.of(context);
    final remaining = ref.watch(holdCountdownProvider(widget.bookingId));
    final summary = ref.watch(checkoutSummaryProvider(widget.bookingId)).value;
    final settings = ref
        .watch(checkoutSettingsProvider(widget.bookingId))
        .value;
    final amount = format.price(widget.amount);

    String? err(bool bad, String text) => _submitted && bad ? text : null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _cancel();
      },
      child: Scaffold(
        backgroundColor: colors.bg,
        body: Column(
          children: [
            AdaptiveAppBar(
              title: l10n.gatewayTitle,
              leading: AdaptiveBackButton(onPressed: _cancel),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: SprintExtras.centredColumn,
                  ),
                  child: ListView(
                    padding: const EdgeInsetsDirectional.all(
                      SprintSpacing.space4,
                    ),
                    children: [
                      HoldBanner(
                        remaining: remaining ?? Duration.zero,
                        kind: HoldBannerKind.gateway,
                      ),
                      const SizedBox(height: SprintSpacing.space4),
                      Container(
                        padding: const EdgeInsetsDirectional.all(
                          SprintSpacing.space4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: SprintRadius.lgBorder,
                          border: Border.all(color: colors.line),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.gatewayAmountLabel,
                              style: context.text.label.copyWith(
                                color: colors.inkMuted,
                              ),
                            ),
                            LtrIsolate(
                              child: Text(
                                amount,
                                key: amountKey,
                                style: context.text.numberLg,
                              ),
                            ),
                            Text(
                              l10n.gatewayMerchant(summary?.facilityName ?? ''),
                              style: context.text.body.copyWith(
                                color: colors.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: SprintSpacing.space4),
                      SprintTextField(
                        label: l10n.gatewayCardNumber,
                        placeholder: '0000 0000 0000 0000',
                        type: SprintTextFieldType.nationalId,
                        controller: _number,
                        autofillHints: const [AutofillHints.creditCardNumber],
                        textInputAction: TextInputAction.next,
                        error: err(
                          !CardFormat.isValidNumber(_number.text),
                          l10n.gatewayErrCardNumber,
                        ),
                      ),
                      const SizedBox(height: SprintSpacing.space3),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SprintTextField(
                              label: l10n.gatewayCardExpiry,
                              placeholder: l10n.gatewayExpiryHint,
                              type: SprintTextFieldType.nationalId,
                              controller: _expiry,
                              autofillHints: const [
                                AutofillHints.creditCardExpirationDate,
                              ],
                              textInputAction: TextInputAction.next,
                              error: err(
                                !CardFormat.isValidExpiry(
                                  _expiry.text,
                                  _nowCairo,
                                ),
                                l10n.gatewayErrExpiry,
                              ),
                            ),
                          ),
                          const SizedBox(width: SprintSpacing.space3),
                          Expanded(
                            child: SprintTextField(
                              label: l10n.gatewayCardCvc,
                              type: SprintTextFieldType.nationalId,
                              controller: _cvc,
                              autofillHints: const [
                                AutofillHints.creditCardSecurityCode,
                              ],
                              textInputAction: TextInputAction.next,
                              error: err(
                                !CardFormat.isValidCvc(_cvc.text),
                                l10n.gatewayErrCvc,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: SprintSpacing.space3),
                      SprintTextField(
                        label: l10n.gatewayCardName,
                        placeholder: l10n.gatewayCardNameHint,
                        controller: _name,
                        autofillHints: const [AutofillHints.creditCardName],
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _confirm(),
                        error: err(
                          !CardFormat.isValidName(_name.text),
                          l10n.gatewayErrName,
                        ),
                      ),
                      const SizedBox(height: SprintSpacing.space4),
                      if (settings?.isTestProvider ?? true)
                        Container(
                          key: testTagKey,
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: SprintSpacing.space3,
                            vertical: SprintSpacing.space1,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primarySoft,
                            borderRadius: SprintRadius.fullBorder,
                          ),
                          child: Text(
                            l10n.checkoutSandboxTag,
                            style: context.text.caption.copyWith(
                              color: colors.onPrimarySoft,
                            ),
                          ),
                        ),
                      const SizedBox(height: SprintSpacing.space3),
                      Text(
                        l10n.gatewayNotice,
                        style: context.text.caption.copyWith(
                          color: colors.inkMuted,
                        ),
                      ),
                      const SizedBox(height: SprintSpacing.space4),
                      SprintButton(
                        key: confirmKey,
                        label: l10n.gatewayConfirm(amount),
                        onPressed: _confirm,
                      ),
                      const SizedBox(height: SprintSpacing.space2),
                      SprintButton(
                        key: cancelKey,
                        label: l10n.gatewayCancel,
                        variant: SprintButtonVariant.ghost,
                        onPressed: _cancel,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const amountKey = ValueKey<String>('gateway-amount');
const testTagKey = ValueKey<String>('gateway-test-tag');
const confirmKey = ValueKey<String>('gateway-confirm');
const cancelKey = ValueKey<String>('gateway-cancel');
