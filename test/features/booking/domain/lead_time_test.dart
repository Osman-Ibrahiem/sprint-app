import 'package:flutter_test/flutter_test.dart';
import 'package:sprint/features/booking/domain/lead_time.dart';
import 'package:sprint/features/booking/presentation/lead_time_text.dart';
import 'package:sprint/l10n/gen/app_localizations_ar.dart';
import 'package:sprint/l10n/gen/app_localizations_en.dart';

void main() {
  test('describeLead splits hours and a half hour', () {
    expect(describeLead(60).hours, 1);
    expect(describeLead(60).halfHour, isFalse);
    expect(describeLead(90).hours, 1);
    expect(describeLead(90).halfHour, isTrue);
    expect(describeLead(30).hours, 0);
    expect(describeLead(30).halfHour, isTrue);
    expect(describeLead(180).hours, 3);
    expect(describeLead(45).minutes, 45);
  });

  test('Arabic wording', () {
    final l = AppLocalizationsAr();
    expect(leadTimeText(l, 60), 'ساعة');
    expect(leadTimeText(l, 90), 'ساعة ونص');
    expect(leadTimeText(l, 120), 'ساعتين');
    expect(leadTimeText(l, 180), '3 ساعات');
    expect(leadTimeText(l, 30), 'نص ساعة');
    expect(leadTimeText(l, 45), '45 دقيقة');
  });

  test('English wording', () {
    final l = AppLocalizationsEn();
    expect(leadTimeText(l, 60), '1 hour');
    expect(leadTimeText(l, 90), '1.5 hours');
    expect(leadTimeText(l, 120), '2 hours');
    expect(leadTimeText(l, 180), '3 hours');
    expect(leadTimeText(l, 45), '45 minutes');
  });
}
