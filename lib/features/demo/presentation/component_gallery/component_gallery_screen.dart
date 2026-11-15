import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint/core/adaptive/adaptive_app_bar.dart';
import 'package:sprint/core/adaptive/adaptive_platform_override.dart';
import 'package:sprint/core/adaptive/platform.dart';
import 'package:sprint/core/providers/data_providers.dart';
import 'package:sprint/core/tokens/context_extensions.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/option_group.dart';
import 'package:sprint/features/demo/presentation/component_gallery/sections/app_navigation_section.dart';
import 'package:sprint/features/demo/presentation/component_gallery/sections/booking_ticket_section.dart';
import 'package:sprint/features/demo/presentation/component_gallery/sections/button_section.dart';
import 'package:sprint/features/demo/presentation/component_gallery/sections/day_strip_section.dart';
import 'package:sprint/features/demo/presentation/component_gallery/sections/facility_card_section.dart';
import 'package:sprint/features/demo/presentation/component_gallery/sections/logo_section.dart';
import 'package:sprint/features/demo/presentation/component_gallery/sections/slot_chip_section.dart';
import 'package:sprint/features/demo/presentation/component_gallery/sections/stat_tile_section.dart';
import 'package:sprint/features/demo/presentation/component_gallery/sections/status_badge_section.dart';
import 'package:sprint/features/demo/presentation/component_gallery/sections/text_field_section.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

/// Reviewer-only gallery: every component section under controls for text
/// size, reduced motion and platform look (FR-065, FR-066).
class ComponentGalleryScreen extends ConsumerStatefulWidget {
  const ComponentGalleryScreen({super.key});

  static const textSizes = [1.0, 1.3, 1.5, 2.0];

  @override
  ConsumerState<ComponentGalleryScreen> createState() =>
      _ComponentGalleryScreenState();
}

class _ComponentGalleryScreenState extends ConsumerState<ComponentGalleryScreen> {
  double _textScale = 1;
  bool _reducedMotion = false;
  bool _motionInitialized = false;
  AdaptiveStyle _style = AdaptiveStyle.desktop;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_motionInitialized) {
      _motionInitialized = true;
      _reducedMotion = MediaQuery.disableAnimationsOf(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.watch(settingsRepositoryProvider);

    return FutureBuilder<(int, int)>(
      future: Future.wait([
        repo.resolve(SettingKeys.bookingWindowDays),
        repo.resolve(SettingKeys.fewLeftThreshold),
      ]).then((values) => (values[0], values[1])),
      builder: (context, snapshot) {
        final settings = snapshot.data ?? (30, 2);
        final sections = <Widget>[
          ButtonSection(l10n: l10n),
          TextFieldSection(l10n: l10n),
          SlotChipSection(l10n: l10n, fewLeftThreshold: settings.$2),
          DayStripSection(l10n: l10n, bookingWindowDays: settings.$1),
          StatusBadgeSection(l10n: l10n),
          LogoSection(l10n: l10n),
          FacilityCardSection(l10n: l10n),
          BookingTicketSection(l10n: l10n),
          AppNavigationSection(l10n: l10n),
          StatTileSection(l10n: l10n),
        ];

        return Scaffold(
          appBar: AdaptiveAppBar(title: l10n.galleryTitle),
          body: SafeArea(
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(_textScale),
                disableAnimations: _reducedMotion,
              ),
              child: AdaptivePlatformOverride(
                style: _style,
                child: ListView.separated(
                  key: const PageStorageKey<String>('component-gallery'),
                  padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
                  itemCount: sections.length + 1,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: SprintSpacing.space8),
                  itemBuilder: (context, index) {
                    if (index == 0) return _controls(context, l10n);
                    return sections[index - 1];
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _controls(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.gallerySampleNote,
          style: context.text.caption.copyWith(color: context.colors.inkMuted),
        ),
        const SizedBox(height: SprintSpacing.space4),
        OptionGroup<double>(
          title: l10n.galleryTextSize,
          selected: _textScale,
          onSelected: (value) => setState(() => _textScale = value),
          options: [
            for (final size in ComponentGalleryScreen.textSizes)
              (size, '${(size * 100).round()}%'),
          ],
        ),
        const SizedBox(height: SprintSpacing.space4),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.galleryReducedMotion,
                style: context.text.headline,
              ),
            ),
            Switch(
              value: _reducedMotion,
              onChanged: (value) => setState(() => _reducedMotion = value),
            ),
          ],
        ),
        const SizedBox(height: SprintSpacing.space4),
        OptionGroup<AdaptiveStyle>(
          title: l10n.galleryPlatformLook,
          selected: _style,
          onSelected: (value) => setState(() => _style = value),
          options: [
            (AdaptiveStyle.apple, l10n.galleryPlatformApple),
            (AdaptiveStyle.android, l10n.galleryPlatformAndroid),
            (AdaptiveStyle.desktop, l10n.galleryPlatformDesktop),
          ],
        ),
      ],
    );
  }
}
