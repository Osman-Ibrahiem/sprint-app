import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:sprint/core/widgets/design_system.dart';

/// One plain-valued instance of every design-system widget, built with no
/// provider, repository or setting (FR-010).
Map<String, Widget> plainWidgets() => {
      'SprintButton': SprintButton(label: 'تأكيد الحجز', onPressed: () {}),
      'SprintTextField': const SprintTextField(label: 'الاسم'),
      'SlotChip': SlotChip(
        start: DateTime(2026, 11, 10, 18),
        state: SlotState.available,
        fewLeftThreshold: 2,
        remaining: 5,
        onSelected: () {},
      ),
      'DayStrip': DayStrip(
        days: [
          for (var i = 0; i < 3; i++)
            DayStripDay(
              date: DateTime(2026, 11, 10 + i),
              hasAvailability: true,
            ),
        ],
        today: DateTime(2026, 11, 10),
        onSelected: (_) {},
      ),
      'StatusBadge': const StatusBadge(status: SprintStatus.confirmed),
      'SprintLogo': const SprintLogo(variant: LogoVariant.tilePrimary),
      'FacilityCard': FacilityCard(
        kind: FacilityKind.paid,
        name: 'حمام السباحة',
        owningUnit: 'كلية التربية الرياضية',
        unitCount: 6,
        tags: const [],
        availability: AvailabilityLevel.plenty,
        price: const FacilityPrice(amount: '120 ج.م'),
        onTap: () {},
      ),
      'BookingTicket': BookingTicket(
        state: BookingTicketState.upcoming,
        status: SprintStatus.confirmed,
        facilityName: 'حمام السباحة',
        unitName: 'حارة 3',
        start: DateTime(2026, 11, 10, 17),
        end: DateTime(2026, 11, 10, 18),
        qrToken: 'qr.abc.x',
        code: 'SPR-4821',
        paid: '120 ج.م',
      ),
      'AppNavigation': AppNavigation(
        destinations: const [
          NavDestination(
            label: 'الرئيسية',
            icon: PhosphorIconsRegular.house,
            selectedIcon: PhosphorIconsFill.house,
          ),
          NavDestination(
            label: 'حجوزاتي',
            icon: PhosphorIconsRegular.calendar,
            selectedIcon: PhosphorIconsFill.calendar,
          ),
        ],
        selected: 0,
        onSelected: (_) {},
      ),
      'StatTile': const StatTile(
        label: 'الإيراد',
        period: 'الأسبوع ده',
        value: '1,250,000',
      ),
    };
