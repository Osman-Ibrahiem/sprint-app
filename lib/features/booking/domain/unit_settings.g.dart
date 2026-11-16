// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UnitSettings _$UnitSettingsFromJson(Map<String, dynamic> json) =>
    _UnitSettings(
      bookingMode: $enumDecode(_$BookingModeEnumMap, json['bookingMode']),
      capacity: (json['capacity'] as num).toInt(),
      maxParticipants: (json['maxParticipants'] as num?)?.toInt(),
      bookingWindowDays: (json['bookingWindowDays'] as num).toInt(),
      minLeadMinutes: (json['minLeadMinutes'] as num).toInt(),
      slotGranularityMinutes: (json['slotGranularityMinutes'] as num).toInt(),
      maxRangeHours: (json['maxRangeHours'] as num).toInt(),
      sessionMinutes: (json['sessionMinutes'] as num).toInt(),
      holdMinutes: (json['holdMinutes'] as num).toInt(),
      maxActiveBookingsPerUser: (json['maxActiveBookingsPerUser'] as num?)
          ?.toInt(),
      cancellationCutoffHours: (json['cancellationCutoffHours'] as num).toInt(),
      refundPercent: (json['refundPercent'] as num).toInt(),
      checkInOpensMinutes: (json['checkInOpensMinutes'] as num).toInt(),
      reminderLeadMinutes: (json['reminderLeadMinutes'] as num).toInt(),
    );

Map<String, dynamic> _$UnitSettingsToJson(_UnitSettings instance) =>
    <String, dynamic>{
      'bookingMode': _$BookingModeEnumMap[instance.bookingMode]!,
      'capacity': instance.capacity,
      'maxParticipants': instance.maxParticipants,
      'bookingWindowDays': instance.bookingWindowDays,
      'minLeadMinutes': instance.minLeadMinutes,
      'slotGranularityMinutes': instance.slotGranularityMinutes,
      'maxRangeHours': instance.maxRangeHours,
      'sessionMinutes': instance.sessionMinutes,
      'holdMinutes': instance.holdMinutes,
      'maxActiveBookingsPerUser': instance.maxActiveBookingsPerUser,
      'cancellationCutoffHours': instance.cancellationCutoffHours,
      'refundPercent': instance.refundPercent,
      'checkInOpensMinutes': instance.checkInOpensMinutes,
      'reminderLeadMinutes': instance.reminderLeadMinutes,
    };

const _$BookingModeEnumMap = {
  BookingMode.exclusive: 'exclusive',
  BookingMode.shared: 'shared',
};
