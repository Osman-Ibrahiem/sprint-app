// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unit_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UnitSettings {

 BookingMode get bookingMode; int get capacity; int? get maxParticipants; int get bookingWindowDays; int get minLeadMinutes; int get slotGranularityMinutes; int get maxRangeHours; int get sessionMinutes; int get holdMinutes; int? get maxActiveBookingsPerUser; int get cancellationCutoffHours; int get refundPercent; int get checkInOpensMinutes; int get reminderLeadMinutes;
/// Create a copy of UnitSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnitSettingsCopyWith<UnitSettings> get copyWith => _$UnitSettingsCopyWithImpl<UnitSettings>(this as UnitSettings, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UnitSettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnitSettings&&(identical(other.bookingMode, _this.bookingMode) || other.bookingMode == _this.bookingMode)&&(identical(other.capacity, _this.capacity) || other.capacity == _this.capacity)&&(identical(other.maxParticipants, _this.maxParticipants) || other.maxParticipants == _this.maxParticipants)&&(identical(other.bookingWindowDays, _this.bookingWindowDays) || other.bookingWindowDays == _this.bookingWindowDays)&&(identical(other.minLeadMinutes, _this.minLeadMinutes) || other.minLeadMinutes == _this.minLeadMinutes)&&(identical(other.slotGranularityMinutes, _this.slotGranularityMinutes) || other.slotGranularityMinutes == _this.slotGranularityMinutes)&&(identical(other.maxRangeHours, _this.maxRangeHours) || other.maxRangeHours == _this.maxRangeHours)&&(identical(other.sessionMinutes, _this.sessionMinutes) || other.sessionMinutes == _this.sessionMinutes)&&(identical(other.holdMinutes, _this.holdMinutes) || other.holdMinutes == _this.holdMinutes)&&(identical(other.maxActiveBookingsPerUser, _this.maxActiveBookingsPerUser) || other.maxActiveBookingsPerUser == _this.maxActiveBookingsPerUser)&&(identical(other.cancellationCutoffHours, _this.cancellationCutoffHours) || other.cancellationCutoffHours == _this.cancellationCutoffHours)&&(identical(other.refundPercent, _this.refundPercent) || other.refundPercent == _this.refundPercent)&&(identical(other.checkInOpensMinutes, _this.checkInOpensMinutes) || other.checkInOpensMinutes == _this.checkInOpensMinutes)&&(identical(other.reminderLeadMinutes, _this.reminderLeadMinutes) || other.reminderLeadMinutes == _this.reminderLeadMinutes));
}


@override
int get hashCode {
  final _this = this as UnitSettings;
  return Object.hash(runtimeType,_this.bookingMode,_this.capacity,_this.maxParticipants,_this.bookingWindowDays,_this.minLeadMinutes,_this.slotGranularityMinutes,_this.maxRangeHours,_this.sessionMinutes,_this.holdMinutes,_this.maxActiveBookingsPerUser,_this.cancellationCutoffHours,_this.refundPercent,_this.checkInOpensMinutes,_this.reminderLeadMinutes);
}

@override
String toString() {
  final _this = this as UnitSettings;
  return 'UnitSettings(bookingMode: ${_this.bookingMode}, capacity: ${_this.capacity}, maxParticipants: ${_this.maxParticipants}, bookingWindowDays: ${_this.bookingWindowDays}, minLeadMinutes: ${_this.minLeadMinutes}, slotGranularityMinutes: ${_this.slotGranularityMinutes}, maxRangeHours: ${_this.maxRangeHours}, sessionMinutes: ${_this.sessionMinutes}, holdMinutes: ${_this.holdMinutes}, maxActiveBookingsPerUser: ${_this.maxActiveBookingsPerUser}, cancellationCutoffHours: ${_this.cancellationCutoffHours}, refundPercent: ${_this.refundPercent}, checkInOpensMinutes: ${_this.checkInOpensMinutes}, reminderLeadMinutes: ${_this.reminderLeadMinutes})';
}


}

/// @nodoc
abstract mixin class $UnitSettingsCopyWith<$Res>  {
  factory $UnitSettingsCopyWith(UnitSettings value, $Res Function(UnitSettings) _then) = _$UnitSettingsCopyWithImpl;
@useResult
$Res call({
 BookingMode bookingMode, int capacity, int? maxParticipants, int bookingWindowDays, int minLeadMinutes, int slotGranularityMinutes, int maxRangeHours, int sessionMinutes, int holdMinutes, int? maxActiveBookingsPerUser, int cancellationCutoffHours, int refundPercent, int checkInOpensMinutes, int reminderLeadMinutes
});




}
/// @nodoc
class _$UnitSettingsCopyWithImpl<$Res>
    implements $UnitSettingsCopyWith<$Res> {
  _$UnitSettingsCopyWithImpl(this._self, this._then);

  final UnitSettings _self;
  final $Res Function(UnitSettings) _then;

/// Create a copy of UnitSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookingMode = null,Object? capacity = null,Object? maxParticipants = freezed,Object? bookingWindowDays = null,Object? minLeadMinutes = null,Object? slotGranularityMinutes = null,Object? maxRangeHours = null,Object? sessionMinutes = null,Object? holdMinutes = null,Object? maxActiveBookingsPerUser = freezed,Object? cancellationCutoffHours = null,Object? refundPercent = null,Object? checkInOpensMinutes = null,Object? reminderLeadMinutes = null,}) {
  return _then(UnitSettings(
bookingMode: null == bookingMode ? _self.bookingMode : bookingMode // ignore: cast_nullable_to_non_nullable
as BookingMode,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,maxParticipants: freezed == maxParticipants ? _self.maxParticipants : maxParticipants // ignore: cast_nullable_to_non_nullable
as int?,bookingWindowDays: null == bookingWindowDays ? _self.bookingWindowDays : bookingWindowDays // ignore: cast_nullable_to_non_nullable
as int,minLeadMinutes: null == minLeadMinutes ? _self.minLeadMinutes : minLeadMinutes // ignore: cast_nullable_to_non_nullable
as int,slotGranularityMinutes: null == slotGranularityMinutes ? _self.slotGranularityMinutes : slotGranularityMinutes // ignore: cast_nullable_to_non_nullable
as int,maxRangeHours: null == maxRangeHours ? _self.maxRangeHours : maxRangeHours // ignore: cast_nullable_to_non_nullable
as int,sessionMinutes: null == sessionMinutes ? _self.sessionMinutes : sessionMinutes // ignore: cast_nullable_to_non_nullable
as int,holdMinutes: null == holdMinutes ? _self.holdMinutes : holdMinutes // ignore: cast_nullable_to_non_nullable
as int,maxActiveBookingsPerUser: freezed == maxActiveBookingsPerUser ? _self.maxActiveBookingsPerUser : maxActiveBookingsPerUser // ignore: cast_nullable_to_non_nullable
as int?,cancellationCutoffHours: null == cancellationCutoffHours ? _self.cancellationCutoffHours : cancellationCutoffHours // ignore: cast_nullable_to_non_nullable
as int,refundPercent: null == refundPercent ? _self.refundPercent : refundPercent // ignore: cast_nullable_to_non_nullable
as int,checkInOpensMinutes: null == checkInOpensMinutes ? _self.checkInOpensMinutes : checkInOpensMinutes // ignore: cast_nullable_to_non_nullable
as int,reminderLeadMinutes: null == reminderLeadMinutes ? _self.reminderLeadMinutes : reminderLeadMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [UnitSettings].
extension UnitSettingsPatterns on UnitSettings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnitSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnitSettings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnitSettings value)  $default,){
final _that = this;
switch (_that) {
case _UnitSettings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnitSettings value)?  $default,){
final _that = this;
switch (_that) {
case _UnitSettings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BookingMode bookingMode,  int capacity,  int? maxParticipants,  int bookingWindowDays,  int minLeadMinutes,  int slotGranularityMinutes,  int maxRangeHours,  int sessionMinutes,  int holdMinutes,  int? maxActiveBookingsPerUser,  int cancellationCutoffHours,  int refundPercent,  int checkInOpensMinutes,  int reminderLeadMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnitSettings() when $default != null:
return $default(_that.bookingMode,_that.capacity,_that.maxParticipants,_that.bookingWindowDays,_that.minLeadMinutes,_that.slotGranularityMinutes,_that.maxRangeHours,_that.sessionMinutes,_that.holdMinutes,_that.maxActiveBookingsPerUser,_that.cancellationCutoffHours,_that.refundPercent,_that.checkInOpensMinutes,_that.reminderLeadMinutes);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BookingMode bookingMode,  int capacity,  int? maxParticipants,  int bookingWindowDays,  int minLeadMinutes,  int slotGranularityMinutes,  int maxRangeHours,  int sessionMinutes,  int holdMinutes,  int? maxActiveBookingsPerUser,  int cancellationCutoffHours,  int refundPercent,  int checkInOpensMinutes,  int reminderLeadMinutes)  $default,) {final _that = this;
switch (_that) {
case _UnitSettings():
return $default(_that.bookingMode,_that.capacity,_that.maxParticipants,_that.bookingWindowDays,_that.minLeadMinutes,_that.slotGranularityMinutes,_that.maxRangeHours,_that.sessionMinutes,_that.holdMinutes,_that.maxActiveBookingsPerUser,_that.cancellationCutoffHours,_that.refundPercent,_that.checkInOpensMinutes,_that.reminderLeadMinutes);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BookingMode bookingMode,  int capacity,  int? maxParticipants,  int bookingWindowDays,  int minLeadMinutes,  int slotGranularityMinutes,  int maxRangeHours,  int sessionMinutes,  int holdMinutes,  int? maxActiveBookingsPerUser,  int cancellationCutoffHours,  int refundPercent,  int checkInOpensMinutes,  int reminderLeadMinutes)?  $default,) {final _that = this;
switch (_that) {
case _UnitSettings() when $default != null:
return $default(_that.bookingMode,_that.capacity,_that.maxParticipants,_that.bookingWindowDays,_that.minLeadMinutes,_that.slotGranularityMinutes,_that.maxRangeHours,_that.sessionMinutes,_that.holdMinutes,_that.maxActiveBookingsPerUser,_that.cancellationCutoffHours,_that.refundPercent,_that.checkInOpensMinutes,_that.reminderLeadMinutes);case _:
  return null;

}
}

}

/// @nodoc


class _UnitSettings implements UnitSettings {
  const _UnitSettings({required this.bookingMode, required this.capacity, this.maxParticipants, required this.bookingWindowDays, required this.minLeadMinutes, required this.slotGranularityMinutes, required this.maxRangeHours, required this.sessionMinutes, required this.holdMinutes, this.maxActiveBookingsPerUser, required this.cancellationCutoffHours, required this.refundPercent, required this.checkInOpensMinutes, required this.reminderLeadMinutes});
  

@override final  BookingMode bookingMode;
@override final  int capacity;
@override final  int? maxParticipants;
@override final  int bookingWindowDays;
@override final  int minLeadMinutes;
@override final  int slotGranularityMinutes;
@override final  int maxRangeHours;
@override final  int sessionMinutes;
@override final  int holdMinutes;
@override final  int? maxActiveBookingsPerUser;
@override final  int cancellationCutoffHours;
@override final  int refundPercent;
@override final  int checkInOpensMinutes;
@override final  int reminderLeadMinutes;

/// Create a copy of UnitSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnitSettingsCopyWith<_UnitSettings> get copyWith => __$UnitSettingsCopyWithImpl<_UnitSettings>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnitSettings&&(identical(other.bookingMode, bookingMode) || other.bookingMode == bookingMode)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.maxParticipants, maxParticipants) || other.maxParticipants == maxParticipants)&&(identical(other.bookingWindowDays, bookingWindowDays) || other.bookingWindowDays == bookingWindowDays)&&(identical(other.minLeadMinutes, minLeadMinutes) || other.minLeadMinutes == minLeadMinutes)&&(identical(other.slotGranularityMinutes, slotGranularityMinutes) || other.slotGranularityMinutes == slotGranularityMinutes)&&(identical(other.maxRangeHours, maxRangeHours) || other.maxRangeHours == maxRangeHours)&&(identical(other.sessionMinutes, sessionMinutes) || other.sessionMinutes == sessionMinutes)&&(identical(other.holdMinutes, holdMinutes) || other.holdMinutes == holdMinutes)&&(identical(other.maxActiveBookingsPerUser, maxActiveBookingsPerUser) || other.maxActiveBookingsPerUser == maxActiveBookingsPerUser)&&(identical(other.cancellationCutoffHours, cancellationCutoffHours) || other.cancellationCutoffHours == cancellationCutoffHours)&&(identical(other.refundPercent, refundPercent) || other.refundPercent == refundPercent)&&(identical(other.checkInOpensMinutes, checkInOpensMinutes) || other.checkInOpensMinutes == checkInOpensMinutes)&&(identical(other.reminderLeadMinutes, reminderLeadMinutes) || other.reminderLeadMinutes == reminderLeadMinutes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,bookingMode,capacity,maxParticipants,bookingWindowDays,minLeadMinutes,slotGranularityMinutes,maxRangeHours,sessionMinutes,holdMinutes,maxActiveBookingsPerUser,cancellationCutoffHours,refundPercent,checkInOpensMinutes,reminderLeadMinutes);
}

@override
String toString() {
    return 'UnitSettings(bookingMode: $bookingMode, capacity: $capacity, maxParticipants: $maxParticipants, bookingWindowDays: $bookingWindowDays, minLeadMinutes: $minLeadMinutes, slotGranularityMinutes: $slotGranularityMinutes, maxRangeHours: $maxRangeHours, sessionMinutes: $sessionMinutes, holdMinutes: $holdMinutes, maxActiveBookingsPerUser: $maxActiveBookingsPerUser, cancellationCutoffHours: $cancellationCutoffHours, refundPercent: $refundPercent, checkInOpensMinutes: $checkInOpensMinutes, reminderLeadMinutes: $reminderLeadMinutes)';
}


}

/// @nodoc
abstract mixin class _$UnitSettingsCopyWith<$Res> implements $UnitSettingsCopyWith<$Res> {
  factory _$UnitSettingsCopyWith(_UnitSettings value, $Res Function(_UnitSettings) _then) = __$UnitSettingsCopyWithImpl;
@override @useResult
$Res call({
 BookingMode bookingMode, int capacity, int? maxParticipants, int bookingWindowDays, int minLeadMinutes, int slotGranularityMinutes, int maxRangeHours, int sessionMinutes, int holdMinutes, int? maxActiveBookingsPerUser, int cancellationCutoffHours, int refundPercent, int checkInOpensMinutes, int reminderLeadMinutes
});




}
/// @nodoc
class __$UnitSettingsCopyWithImpl<$Res>
    implements _$UnitSettingsCopyWith<$Res> {
  __$UnitSettingsCopyWithImpl(this._self, this._then);

  final _UnitSettings _self;
  final $Res Function(_UnitSettings) _then;

/// Create a copy of UnitSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookingMode = null,Object? capacity = null,Object? maxParticipants = freezed,Object? bookingWindowDays = null,Object? minLeadMinutes = null,Object? slotGranularityMinutes = null,Object? maxRangeHours = null,Object? sessionMinutes = null,Object? holdMinutes = null,Object? maxActiveBookingsPerUser = freezed,Object? cancellationCutoffHours = null,Object? refundPercent = null,Object? checkInOpensMinutes = null,Object? reminderLeadMinutes = null,}) {
  return _then(_UnitSettings(
bookingMode: null == bookingMode ? _self.bookingMode : bookingMode // ignore: cast_nullable_to_non_nullable
as BookingMode,capacity: null == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as int,maxParticipants: freezed == maxParticipants ? _self.maxParticipants : maxParticipants // ignore: cast_nullable_to_non_nullable
as int?,bookingWindowDays: null == bookingWindowDays ? _self.bookingWindowDays : bookingWindowDays // ignore: cast_nullable_to_non_nullable
as int,minLeadMinutes: null == minLeadMinutes ? _self.minLeadMinutes : minLeadMinutes // ignore: cast_nullable_to_non_nullable
as int,slotGranularityMinutes: null == slotGranularityMinutes ? _self.slotGranularityMinutes : slotGranularityMinutes // ignore: cast_nullable_to_non_nullable
as int,maxRangeHours: null == maxRangeHours ? _self.maxRangeHours : maxRangeHours // ignore: cast_nullable_to_non_nullable
as int,sessionMinutes: null == sessionMinutes ? _self.sessionMinutes : sessionMinutes // ignore: cast_nullable_to_non_nullable
as int,holdMinutes: null == holdMinutes ? _self.holdMinutes : holdMinutes // ignore: cast_nullable_to_non_nullable
as int,maxActiveBookingsPerUser: freezed == maxActiveBookingsPerUser ? _self.maxActiveBookingsPerUser : maxActiveBookingsPerUser // ignore: cast_nullable_to_non_nullable
as int?,cancellationCutoffHours: null == cancellationCutoffHours ? _self.cancellationCutoffHours : cancellationCutoffHours // ignore: cast_nullable_to_non_nullable
as int,refundPercent: null == refundPercent ? _self.refundPercent : refundPercent // ignore: cast_nullable_to_non_nullable
as int,checkInOpensMinutes: null == checkInOpensMinutes ? _self.checkInOpensMinutes : checkInOpensMinutes // ignore: cast_nullable_to_non_nullable
as int,reminderLeadMinutes: null == reminderLeadMinutes ? _self.reminderLeadMinutes : reminderLeadMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
