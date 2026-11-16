import 'dart:convert';
import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';
import 'package:sprint/features/payments/domain/payment_provider.dart';
import 'package:sprint/features/settings/domain/booking_mode.dart';
import 'package:sprint/features/settings/domain/setting_definition.dart';
import 'package:sprint/features/settings/domain/setting_registry.dart';

/// `MonthDay` as `{"month": 8, "day": 31}` (BR-25).
class MonthDayConverter
    implements JsonConverter<MonthDay, Map<String, dynamic>> {
  const MonthDayConverter();

  @override
  MonthDay fromJson(Map<String, dynamic> json) =>
      MonthDay(json['month']! as int, json['day']! as int);

  @override
  Map<String, dynamic> toJson(MonthDay object) => {
    'month': object.month,
    'day': object.day,
  };
}

/// Encodes and decodes the stored value of a setting by its registry type, so
/// enums go by name and `MonthDay` as an object (research R1).
abstract final class SettingValueCodec {
  static Object? encode(Object? value) => switch (value) {
    final Enum e => e.name,
    final MonthDay m => const MonthDayConverter().toJson(m),
    _ => value,
  };

  static Object? decode(String keyName, Object? json) {
    if (json == null) return null;
    final def = settingRegistry[keyName];
    if (def is SettingDefinition<BookingMode>) {
      return BookingMode.values.byName(json as String);
    }
    if (def is SettingDefinition<PaymentProviderKind>) {
      return PaymentProviderKind.values.byName(json as String);
    }
    if (def is SettingDefinition<MonthDay>) {
      return const MonthDayConverter().fromJson(
        Map<String, dynamic>.from(json as Map),
      );
    }
    return json;
  }
}

/// Photo bytes as base64 text, for stores that only hold strings.
const _b64 = Base64Codec();

String bytesToBase64(Uint8List bytes) => _b64.encode(bytes);

Uint8List? bytesFromBase64(String? text) {
  if (text == null) return null;
  try {
    return Uint8List.fromList(_b64.decode(text));
  } on FormatException {
    return null;
  }
}
