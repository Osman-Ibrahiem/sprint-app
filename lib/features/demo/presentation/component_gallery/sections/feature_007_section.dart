import 'package:flutter/material.dart' hide Banner;
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/adaptive/adaptive_dialog.dart';
import 'package:sprint/core/motion/skeleton.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/widgets/avatar/avatar.dart';
import 'package:sprint/core/widgets/banner/banner.dart';
import 'package:sprint/core/widgets/booking_row/booking_row.dart';
import 'package:sprint/core/widgets/notification_bell/notification_bell.dart';
import 'package:sprint/core/widgets/notification_card/notification_card.dart';
import 'package:sprint/core/widgets/popover/popover.dart';
import 'package:sprint/core/widgets/segmented_control/segmented_control.dart';
import 'package:sprint/core/widgets/settings_row/settings_row.dart';
import 'package:sprint/core/widgets/sprint_button/sprint_button.dart';
import 'package:sprint/core/widgets/sprint_text_field/sprint_text_field.dart';
import 'package:sprint/core/widgets/status_badge/sprint_status.dart';
import 'package:sprint/features/demo/presentation/component_gallery/gallery_section.dart';
import 'package:sprint/l10n/gen/app_localizations.dart';

const double _frameWidth = SprintExtras.confirmationColumn;

/// The feature 007 components with their states: bell, notification card,
/// booking row (selected), segmented control, settings rows, avatar, banner
/// tones, locked and search fields, dialog, popover and skeletons.
class Feature007Section extends StatefulWidget {
  const Feature007Section({required this.l10n, super.key});

  final AppLocalizations l10n;

  @override
  State<Feature007Section> createState() => _Feature007SectionState();
}

class _Feature007SectionState extends State<Feature007Section> {
  int _segment = 0;

  @override
  Widget build(BuildContext context) {
    final l = widget.l10n;
    return GallerySection(
      title: l.gallery007Section,
      caption: l.gallerySampleNote,
      children: [
        NotificationBell(unread: 3, onTap: () {}),
        NotificationBell(unread: 0, onTap: () {}),
        SizedBox(
          width: _frameWidth,
          child: NotificationCard(
            icon: PhosphorIconsRegular.checkCircle,
            tone: NotificationTone.success,
            title: l.gallery007SampleTitle,
            body: l.gallery007SampleBody,
            time: l.gallery007SampleTime,
            unread: true,
            onTap: () {},
          ),
        ),
        SizedBox(
          width: _frameWidth,
          child: NotificationCard(
            icon: PhosphorIconsRegular.xCircle,
            tone: NotificationTone.danger,
            title: l.gallery007SampleTitle,
            body: l.gallery007SampleBody,
            time: l.gallery007SampleTime,
            unread: false,
            onTap: () {},
          ),
        ),
        for (final selected in [false, true])
          SizedBox(
            width: _frameWidth,
            child: BookingRow(
              status: SprintStatus.confirmed,
              facilityName: l.gallery007SampleBody,
              notes: l.gallery007SampleBody,
              dateLabel: l.gallery007SampleDate,
              isToday: selected,
              code: 'SP-1042',
              action: l.gallery007SampleAction,
              onTap: () {},
              semanticLabel: l.gallery007SampleDate,
              selected: selected,
            ),
          ),
        SizedBox(
          width: _frameWidth,
          child: SegmentedControl(
            labels: [l.gallery007SampleUpcoming, l.gallery007SamplePast],
            selected: _segment,
            onChanged: (v) => setState(() => _segment = v),
          ),
        ),
        SizedBox(
          width: _frameWidth,
          child: Column(
            children: [
              SettingsRow(
                label: l.gallery007SampleLanguage,
                value: l.gallery007SampleLanguageValue,
                type: SettingsRowType.value,
                onTap: () {},
              ),
              SettingsRow(label: l.gallery007SampleLanguage, onTap: () {}),
              SettingsRow(
                label: l.gallery007SampleSignOut,
                type: SettingsRowType.destructive,
                onTap: () {},
              ),
            ],
          ),
        ),
        Avatar(name: l.gallery007SampleName),
        Avatar(name: l.gallery007SampleName, size: 48),
        for (final tone in BannerTone.values)
          SizedBox(
            width: _frameWidth,
            child: Banner(tone: tone, text: l.gallery007SampleBanner),
          ),
        SizedBox(
          width: _frameWidth,
          child: SprintTextField(
            label: l.gallery007SampleEmailLabel,
            type: SprintTextFieldType.email,
            locked: true,
            lockedValue: 'mona@tanta.edu.eg',
            helper: l.gallery007SampleLockedHelper,
          ),
        ),
        SizedBox(
          width: _frameWidth,
          child: SprintTextField(
            label: l.gallery007SampleSearch,
            type: SprintTextFieldType.search,
            controller: TextEditingController(text: l.gallery007SampleSearch),
            onClear: () {},
            cancelLabel: l.gallery007SampleSearchCancel,
            onCancel: () {},
          ),
        ),
        SprintButton(
          label: l.gallery007OpenDialog,
          variant: SprintButtonVariant.secondary,
          onPressed: () => showSprintDialog<void>(
            context: context,
            title: l.gallery007DialogTitle,
            message: l.gallery007SampleBanner,
            actions: [
              SprintDialogAction(label: l.gallery007DialogBack),
              SprintDialogAction(
                label: l.gallery007DialogTitle,
                isDestructive: true,
              ),
            ],
          ),
        ),
        Builder(
          builder: (anchor) => SprintButton(
            label: l.gallery007OpenPopover,
            variant: SprintButtonVariant.secondary,
            onPressed: () => showSprintPopover<String>(
              anchorContext: anchor,
              options: [
                PopoverOption(
                  value: 'ar',
                  label: l.gallery007SampleLanguageValue,
                  selected: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: _frameWidth, child: ProfileCardSkeleton()),
        const SizedBox(width: _frameWidth, child: SettingsRowSkeleton()),
      ],
    );
  }
}
