import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/option_group.dart';
import 'package:sprint/features/payments/data/fake_gateway_controller.dart';
import 'package:sprint/features/payments/domain/payment_provider.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// "الدفع التجريبي": what the fake provider does once the simulated page
/// confirms, so every branch of payment can be shown on purpose (FR-010,
/// SC-002): success, failure, or a delayed success. Shown only while the
/// `paymentProvider` setting is the fake, and with the other demo tools.
/// The only presentation code besides the provider page that may read
/// `fakeGatewayProvider`.
class DemoPaymentSection extends ConsumerStatefulWidget {
  const DemoPaymentSection({super.key});

  static const keyOf = ValueKey<String>('demo-payment');

  @override
  ConsumerState<DemoPaymentSection> createState() => _DemoPaymentSectionState();
}

enum _Kind { success, fail, delay }

/// Delay presets in seconds; the last is "past the maximum Hold".
const List<int> _presetSeconds = [5, 30, 90];
const int _afterMax = -1;

class _DemoPaymentSectionState extends ConsumerState<DemoPaymentSection> {
  bool? _isFake;
  int _holdMaxMinutes = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = ref.read(settingsRepositoryProvider);
    final kind = await settings.resolve(SettingKeys.paymentProvider);
    final max = await settings.resolve(SettingKeys.holdMaxMinutes);
    if (!mounted) return;
    setState(() {
      _isFake = kind == PaymentProviderKind.fake;
      _holdMaxMinutes = max;
    });
  }

  /// `holdMaxMinutes` + 1 minute: the answer that comes after the Hold's
  /// maximum, to show the late refund (BR-46).
  Duration get _afterMaxDelay => Duration(minutes: _holdMaxMinutes + 1);

  _Kind _kindOf(FakeOutcome o) => switch (o.name) {
    'fail' => _Kind.fail,
    'delay' => _Kind.delay,
    _ => _Kind.success,
  };

  int _presetOf(FakeOutcome o) {
    final d = o.delay;
    if (d == null) return _presetSeconds[1];
    if (d == _afterMaxDelay) return _afterMax;
    return _presetSeconds.contains(d.inSeconds) ? d.inSeconds : _presetSeconds[1];
  }

  void _setKind(FakeGatewayController gateway, _Kind kind) {
    gateway.outcome = switch (kind) {
      _Kind.success => const FakeOutcome.succeed(),
      _Kind.fail => const FakeOutcome.fail(),
      _Kind.delay => FakeOutcome.delay(Duration(seconds: _presetSeconds[1])),
    };
    setState(() {});
  }

  void _setPreset(FakeGatewayController gateway, int preset) {
    gateway.outcome = FakeOutcome.delay(
      preset == _afterMax ? _afterMaxDelay : Duration(seconds: preset),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isFake != true) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final gateway = ref.watch(fakeGatewayProvider);
    final outcome = gateway.outcome;
    final kind = _kindOf(outcome);

    final current = switch (kind) {
      _Kind.success => l10n.demoPaymentSuccess,
      _Kind.fail => l10n.demoPaymentFail,
      _Kind.delay => l10n.demoPaymentDelayCurrent(outcome.delay!.inSeconds),
    };

    return Column(
      key: DemoPaymentSection.keyOf,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.demoPaymentTitle, style: context.text.title),
        const SizedBox(height: SprintSpacing.space1),
        Text(
          l10n.demoPaymentNote,
          style: context.text.body.copyWith(color: colors.inkMuted),
        ),
        const SizedBox(height: SprintSpacing.space3),
        OptionGroup<_Kind>(
          title: l10n.demoPaymentTitle,
          selected: kind,
          onSelected: (k) => _setKind(gateway, k),
          options: [
            (_Kind.success, l10n.demoPaymentSuccess),
            (_Kind.fail, l10n.demoPaymentFail),
            (_Kind.delay, l10n.demoPaymentDelay),
          ],
        ),
        if (kind == _Kind.delay) ...[
          const SizedBox(height: SprintSpacing.space3),
          OptionGroup<int>(
            title: l10n.demoPaymentDelay,
            selected: _presetOf(outcome),
            onSelected: (p) => _setPreset(gateway, p),
            options: [
              for (final s in _presetSeconds)
                (s, l10n.demoPaymentDelayPreset(s)),
              (_afterMax, l10n.demoPaymentDelayAfterMax),
            ],
          ),
        ],
        const SizedBox(height: SprintSpacing.space2),
        Text(
          l10n.demoPaymentCurrent(current),
          key: const ValueKey<String>('demo-payment-current'),
          style: context.text.caption.copyWith(color: colors.inkMuted),
        ),
      ],
    );
  }
}
