// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainer_availability.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TrainerAvailability {

 String get trainerId; String get unitId; int get dayOfWeek; int get fromMinutes; int get toMinutes;
/// Create a copy of TrainerAvailability
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainerAvailabilityCopyWith<TrainerAvailability> get copyWith => _$TrainerAvailabilityCopyWithImpl<TrainerAvailability>(this as TrainerAvailability, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TrainerAvailability;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainerAvailability&&(identical(other.trainerId, _this.trainerId) || other.trainerId == _this.trainerId)&&(identical(other.unitId, _this.unitId) || other.unitId == _this.unitId)&&(identical(other.dayOfWeek, _this.dayOfWeek) || other.dayOfWeek == _this.dayOfWeek)&&(identical(other.fromMinutes, _this.fromMinutes) || other.fromMinutes == _this.fromMinutes)&&(identical(other.toMinutes, _this.toMinutes) || other.toMinutes == _this.toMinutes));
}


@override
int get hashCode {
  final _this = this as TrainerAvailability;
  return Object.hash(runtimeType,_this.trainerId,_this.unitId,_this.dayOfWeek,_this.fromMinutes,_this.toMinutes);
}

@override
String toString() {
  final _this = this as TrainerAvailability;
  return 'TrainerAvailability(trainerId: ${_this.trainerId}, unitId: ${_this.unitId}, dayOfWeek: ${_this.dayOfWeek}, fromMinutes: ${_this.fromMinutes}, toMinutes: ${_this.toMinutes})';
}


}

/// @nodoc
abstract mixin class $TrainerAvailabilityCopyWith<$Res>  {
  factory $TrainerAvailabilityCopyWith(TrainerAvailability value, $Res Function(TrainerAvailability) _then) = _$TrainerAvailabilityCopyWithImpl;
@useResult
$Res call({
 String trainerId, String unitId, int dayOfWeek, int fromMinutes, int toMinutes
});




}
/// @nodoc
class _$TrainerAvailabilityCopyWithImpl<$Res>
    implements $TrainerAvailabilityCopyWith<$Res> {
  _$TrainerAvailabilityCopyWithImpl(this._self, this._then);

  final TrainerAvailability _self;
  final $Res Function(TrainerAvailability) _then;

/// Create a copy of TrainerAvailability
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trainerId = null,Object? unitId = null,Object? dayOfWeek = null,Object? fromMinutes = null,Object? toMinutes = null,}) {
  return _then(TrainerAvailability(
trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,unitId: null == unitId ? _self.unitId : unitId // ignore: cast_nullable_to_non_nullable
as String,dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int,fromMinutes: null == fromMinutes ? _self.fromMinutes : fromMinutes // ignore: cast_nullable_to_non_nullable
as int,toMinutes: null == toMinutes ? _self.toMinutes : toMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TrainerAvailability].
extension TrainerAvailabilityPatterns on TrainerAvailability {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrainerAvailability value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrainerAvailability() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrainerAvailability value)  $default,){
final _that = this;
switch (_that) {
case _TrainerAvailability():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrainerAvailability value)?  $default,){
final _that = this;
switch (_that) {
case _TrainerAvailability() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String trainerId,  String unitId,  int dayOfWeek,  int fromMinutes,  int toMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainerAvailability() when $default != null:
return $default(_that.trainerId,_that.unitId,_that.dayOfWeek,_that.fromMinutes,_that.toMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String trainerId,  String unitId,  int dayOfWeek,  int fromMinutes,  int toMinutes)  $default,) {final _that = this;
switch (_that) {
case _TrainerAvailability():
return $default(_that.trainerId,_that.unitId,_that.dayOfWeek,_that.fromMinutes,_that.toMinutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String trainerId,  String unitId,  int dayOfWeek,  int fromMinutes,  int toMinutes)?  $default,) {final _that = this;
switch (_that) {
case _TrainerAvailability() when $default != null:
return $default(_that.trainerId,_that.unitId,_that.dayOfWeek,_that.fromMinutes,_that.toMinutes);case _:
  return null;

}
}

}

/// @nodoc


class _TrainerAvailability implements TrainerAvailability {
  const _TrainerAvailability({required this.trainerId, required this.unitId, required this.dayOfWeek, required this.fromMinutes, required this.toMinutes});
  

@override final  String trainerId;
@override final  String unitId;
@override final  int dayOfWeek;
@override final  int fromMinutes;
@override final  int toMinutes;

/// Create a copy of TrainerAvailability
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainerAvailabilityCopyWith<_TrainerAvailability> get copyWith => __$TrainerAvailabilityCopyWithImpl<_TrainerAvailability>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainerAvailability&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.unitId, unitId) || other.unitId == unitId)&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.fromMinutes, fromMinutes) || other.fromMinutes == fromMinutes)&&(identical(other.toMinutes, toMinutes) || other.toMinutes == toMinutes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,trainerId,unitId,dayOfWeek,fromMinutes,toMinutes);
}

@override
String toString() {
    return 'TrainerAvailability(trainerId: $trainerId, unitId: $unitId, dayOfWeek: $dayOfWeek, fromMinutes: $fromMinutes, toMinutes: $toMinutes)';
}


}

/// @nodoc
abstract mixin class _$TrainerAvailabilityCopyWith<$Res> implements $TrainerAvailabilityCopyWith<$Res> {
  factory _$TrainerAvailabilityCopyWith(_TrainerAvailability value, $Res Function(_TrainerAvailability) _then) = __$TrainerAvailabilityCopyWithImpl;
@override @useResult
$Res call({
 String trainerId, String unitId, int dayOfWeek, int fromMinutes, int toMinutes
});




}
/// @nodoc
class __$TrainerAvailabilityCopyWithImpl<$Res>
    implements _$TrainerAvailabilityCopyWith<$Res> {
  __$TrainerAvailabilityCopyWithImpl(this._self, this._then);

  final _TrainerAvailability _self;
  final $Res Function(_TrainerAvailability) _then;

/// Create a copy of TrainerAvailability
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trainerId = null,Object? unitId = null,Object? dayOfWeek = null,Object? fromMinutes = null,Object? toMinutes = null,}) {
  return _then(_TrainerAvailability(
trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,unitId: null == unitId ? _self.unitId : unitId // ignore: cast_nullable_to_non_nullable
as String,dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int,fromMinutes: null == fromMinutes ? _self.fromMinutes : fromMinutes // ignore: cast_nullable_to_non_nullable
as int,toMinutes: null == toMinutes ? _self.toMinutes : toMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
