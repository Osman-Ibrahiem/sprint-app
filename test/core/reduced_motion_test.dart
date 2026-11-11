import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/tokens/reduced_motion.dart';
import 'package:sprint/core/tokens/sprint_motion.g.dart';

void main() {
  Future<(Duration, Duration, bool)> probe(
    WidgetTester tester, {
    required bool disabled,
  }) async {
    late (Duration, Duration, bool) out;
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: disabled),
        child: Builder(
          builder: (context) {
            out = (
              ReducedMotion.fade(context, SprintMotion.durationBase),
              ReducedMotion.skip(context, SprintMotion.durationBase),
              ReducedMotion.of(context),
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return out;
  }

  testWidgets('normal motion keeps the given duration', (tester) async {
    final (fade, skip, reduced) = await probe(tester, disabled: false);
    expect(reduced, isFalse);
    expect(fade, SprintMotion.durationBase);
    expect(skip, SprintMotion.durationBase);
  });

  testWidgets('reduced motion becomes a duration-fast fade or zero',
      (tester) async {
    final (fade, skip, reduced) = await probe(tester, disabled: true);
    expect(reduced, isTrue);
    expect(fade, SprintMotion.durationFast);
    expect(skip, Duration.zero);
  });
}
