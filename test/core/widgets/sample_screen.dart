import 'package:flutter/material.dart';
import 'package:sprint/core/tokens/sprint_spacing.g.dart';
import 'package:sprint/core/widgets/design_system.dart';

/// A throwaway screen composed from widget properties and tokens only (SC-011):
/// a screen author never needs a hex value, a size literal or a platform check.
class SampleScreen extends StatelessWidget {
  const SampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime(2026, 11, 10);
    return ListView(
      padding: const EdgeInsetsDirectional.all(SprintSpacing.space4),
      children: [
        DayStrip(
          days: [
            for (var i = 0; i < 5; i++)
              DayStripDay(
                date: today.add(Duration(days: i)),
                hasAvailability: i != 3,
              ),
          ],
          today: today,
          onSelected: (_) {},
        ),
        const SizedBox(height: SprintSpacing.space4),
        Wrap(
          spacing: SprintSpacing.space2,
          runSpacing: SprintSpacing.space2,
          children: [
            for (var h = 16; h < 22; h++)
              SlotChip(
                start: DateTime(2026, 11, 10, h),
                state: h == 18 ? SlotState.fewLeft : SlotState.available,
                fewLeftThreshold: 2,
                remaining: h == 18 ? 1 : 6,
                onSelected: () {},
              ),
          ],
        ),
        const SizedBox(height: SprintSpacing.space4),
        FacilityCard(
          kind: FacilityKind.paid,
          name: 'حمام السباحة',
          owningUnit: 'كلية التربية الرياضية',
          unitCount: 6,
          tags: const [],
          availability: AvailabilityLevel.plenty,
          price: const FacilityPrice(amount: '120 ج.م'),
          onTap: () {},
        ),
        const SizedBox(height: SprintSpacing.space4),
        SprintButton(label: 'تأكيد الحجز', onPressed: () {}),
      ],
    );
  }
}
