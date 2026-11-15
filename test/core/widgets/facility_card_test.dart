import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/core/tokens/sprint_colors.g.dart';
import 'package:sprint/core/tokens/sprint_extras.dart';
import 'package:sprint/core/widgets/facility_card/facility_card.dart';

import '../../helpers/widget_harness.dart';

FacilityCard card({
  FacilityKind kind = FacilityKind.paid,
  FacilityCardLayout layout = FacilityCardLayout.vertical,
  String name = 'حمام السباحة',
  List<FacilityTag> tags = const [],
  AvailabilityLevel availability = AvailabilityLevel.plenty,
  FacilityPrice price = const FacilityPrice(
    amount: '120 ج.م',
    audienceLabel: 'سعر الطلاب والعاملين',
  ),
  ImageProvider? photo,
  Object? heroTag,
  VoidCallback? onTap,
}) =>
    FacilityCard(
      kind: kind,
      layout: layout,
      name: name,
      owningUnit: 'كلية التربية الرياضية',
      unitCount: 6,
      tags: tags,
      availability: availability,
      price: price,
      photo: photo,
      heroTag: heroTag,
      onTap: onTap ?? () {},
    );

void main() {
  final light = SprintColors.light;

  testWidgets('placeholder when no photo, with the Arabic words',
      (tester) async {
    await pumpWidgetUnderAndSettle(tester, card());
    expect(find.byKey(FacilityCard.placeholderKey), findsOneWidget);
    expect(find.text('صورة المنشأة'), findsOneWidget);
    expect(find.text('متاح النهارده'), findsOneWidget);
    expect(find.text('سعر الطلاب والعاملين'), findsOneWidget);
  });

  testWidgets('horizontal layout puts a 112-wide photo first', (tester) async {
    await pumpWidgetUnderAndSettle(
      tester,
      card(layout: FacilityCardLayout.horizontal),
    );
    final placeholder = tester.getRect(find.byKey(FacilityCard.placeholderKey));
    final whole = tester.getRect(find.byType(FacilityCard));
    expect(placeholder.width, SprintExtras.facilityPhotoWidth);
    // RTL: the start side is the right edge.
    expect(placeholder.right, closeTo(whole.right, 1));
  });

  testWidgets('more than three tags trips the debug assert', (tester) async {
    const tag = FacilityTag(label: 'x', kind: FacilityTagKind.sport);
    expect(
      () => card(tags: const [tag, tag, tag, tag]),
      throwsAssertionError,
    );
  });

  testWidgets('offer tag is volt and the old price is struck through',
      (tester) async {
    await pumpWidgetUnderAndSettle(
      tester,
      card(
        tags: const [FacilityTag(label: 'خصم 20%', kind: FacilityTagKind.offer)],
        price: const FacilityPrice(amount: '96 ج.م', oldAmount: '120 ج.م'),
      ),
    );
    final pill = tester.widget<Container>(
      find.ancestor(of: find.text('خصم 20%'), matching: find.byType(Container)).first,
    );
    expect((pill.decoration! as BoxDecoration).color, light.volt);
    final old = tester.widget<Text>(find.byKey(FacilityCard.oldPriceKey));
    expect(old.style!.decoration, TextDecoration.lineThrough);
    expect(old.style!.color, light.inkMuted);
  });

  testWidgets('availability levels each carry an icon and a word',
      (tester) async {
    for (final (level, word) in [
      (AvailabilityLevel.plenty, 'متاح النهارده'),
      (AvailabilityLevel.few, 'أماكن قليلة'),
      (AvailabilityLevel.none, 'مفيش مواعيد النهارده'),
    ]) {
      await pumpWidgetUnderAndSettle(tester, card(availability: level));
      expect(find.text(word), findsOneWidget);
    }
  });

  testWidgets('guest sees both prices; free shows مجاني and no price',
      (tester) async {
    await pumpWidgetUnderAndSettle(
      tester,
      card(
        price: const FacilityPrice(
          amount: '120 ج.م',
          audienceLabel: 'سعر الطلاب والعاملين',
          externalAmount: '200 ج.م',
        ),
      ),
    );
    expect(find.text('120 ج.م'), findsOneWidget);
    expect(find.textContaining('200 ج.م'), findsOneWidget);
    await pumpWidgetUnderAndSettle(tester, card(kind: FacilityKind.free));
    expect(find.text('مجاني'), findsOneWidget);
    expect(find.textContaining('ج.م'), findsNothing);
  });

  testWidgets('one pressable target, no button inside, fires onTap',
      (tester) async {
    var taps = 0;
    await pumpWidgetUnderAndSettle(tester, card(onTap: () => taps++));
    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.byType(TextButton), findsNothing);
    await tester.tap(find.byType(FacilityCard));
    expect(taps, 1);
  });

  testWidgets('shadow-card in Light, none in Dark', (tester) async {
    BoxDecoration shadowDecoration() => tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((d) => d.decoration)
        .whereType<BoxDecoration>()
        .firstWhere((d) => d.boxShadow != null && d.borderRadius != null);
    await pumpWidgetUnderAndSettle(tester, card());
    expect(shadowDecoration().boxShadow, isNotEmpty);
    await pumpWidgetUnderAndSettle(tester, card(), dark: true);
    expect(shadowDecoration().boxShadow, isEmpty);
  });

  testWidgets('a long Arabic name wraps without overflow at 200%',
      (tester) async {
    await pumpWidgetUnderAndSettle(
      tester,
      card(name: 'صالة اللياقة البدنية المتعددة الأغراض بكلية التربية الرياضية'),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('heroTag wraps the photo', (tester) async {
    await pumpWidgetUnderAndSettle(tester, card(heroTag: 'f-pool'));
    expect(find.byType(Hero), findsOneWidget);
  });

  testWidgets('spoken as one sentence', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpWidgetUnderAndSettle(tester, card());
    final label = tester.getSemantics(find.byType(FacilityCard)).label;
    expect(label, contains('حمام السباحة'));
    expect(label, contains('كلية التربية الرياضية'));
    expect(label, contains('متاح النهارده'));
    expect(label, contains('120 ج.م'));
    handle.dispose();
  });

  testWidgets('loading form has the same width and is silent to readers',
      (tester) async {
    final handle = tester.ensureSemantics();
    await pumpWidgetUnderAndSettle(tester, card());
    final width = tester.getSize(find.byType(FacilityCard)).width;
    await pumpWidgetUnder(tester, const FacilityCard.loading());
    expect(tester.getSize(find.byType(FacilityCard)).width, width);
    expect(find.byKey(FacilityCard.loadingKey), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('.+')), findsNothing);
    handle.dispose();
  });
}
