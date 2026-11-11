// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'operating_hours.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OperatingHours {

 String get ownerId; int get dayOfWeek; int get openMinutes; int get closeMinutes;
/// Create a copy of OperatingHours
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OperatingHoursCopyWith<OperatingHours> get copyWith => _$OperatingHoursCopyWithImpl<OperatingHours>(this as OperatingHours, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OperatingHours;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OperatingHours&&(identical(other.ownerId, _this.ownerId) || other.ownerId == _this.ownerId)&&(identical(other.dayOfWeek, _this.dayOfWeek) || other.dayOfWeek == _this.dayOfWeek)&&(identical(other.openMinutes, _this.openMinutes) || other.openMinutes == _this.openMinutes)&&(identical(other.closeMinutes, _this.closeMinutes) || other.closeMinutes == _this.closeMinutes));
}


@override
int get hashCode {
  final _this = this as OperatingHours;
  return Object.hash(runtimeType,_this.ownerId,_this.dayOfWeek,_this.openMinutes,_this.closeMinutes);
}

@override
String toString() {
  final _this = this as OperatingHours;
  return 'OperatingHours(ownerId: ${_this.ownerId}, dayOfWeek: ${_this.dayOfWeek}, openMinutes: ${_this.openMinutes}, closeMinutes: ${_this.closeMinutes})';
}


}

/// @nodoc
abstract mixin class $OperatingHoursCopyWith<$Res>  {
  factory $OperatingHoursCopyWith(OperatingHours value, $Res Function(OperatingHours) _then) = _$OperatingHoursCopyWithImpl;
@useResult
$Res call({
 String ownerId, int dayOfWeek, int openMinutes, int closeMinutes
});




}
/// @nodoc
class _$OperatingHoursCopyWithImpl<$Res>
    implements $OperatingHoursCopyWith<$Res> {
  _$OperatingHoursCopyWithImpl(this._self, this._then);

  final OperatingHours _self;
  final $Res Function(OperatingHours) _then;

/// Create a copy of OperatingHours
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ownerId = null,Object? dayOfWeek = null,Object? openMinutes = null,Object? closeMinutes = null,}) {
  return _then(OperatingHours(
ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int,openMinutes: null == openMinutes ? _self.openMinutes : openMinutes // ignore: cast_nullable_to_non_nullable
as int,closeMinutes: null == closeMinutes ? _self.closeMinutes : closeMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OperatingHours].
extension OperatingHoursPatterns on OperatingHours {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OperatingHours value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OperatingHours() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OperatingHours value)  $default,){
final _that = this;
switch (_that) {
case _OperatingHours():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OperatingHours value)?  $default,){
final _that = this;
switch (_that) {
case _OperatingHours() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ownerId,  int dayOfWeek,  int openMinutes,  int closeMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OperatingHours() when $default != null:
return $default(_that.ownerId,_that.dayOfWeek,_that.openMinutes,_that.closeMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ownerId,  int dayOfWeek,  int openMinutes,  int closeMinutes)  $default,) {final _that = this;
switch (_that) {
case _OperatingHours():
return $default(_that.ownerId,_that.dayOfWeek,_that.openMinutes,_that.closeMinutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ownerId,  int dayOfWeek,  int openMinutes,  int closeMinutes)?  $default,) {final _that = this;
switch (_that) {
case _OperatingHours() when $default != null:
return $default(_that.ownerId,_that.dayOfWeek,_that.openMinutes,_that.closeMinutes);case _:
  return null;

}
}

}

/// @nodoc


class _OperatingHours implements OperatingHours {
  const _OperatingHours({required this.ownerId, required this.dayOfWeek, required this.openMinutes, required this.closeMinutes});
  

@override final  String ownerId;
@override final  int dayOfWeek;
@override final  int openMinutes;
@override final  int closeMinutes;

/// Create a copy of OperatingHours
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OperatingHoursCopyWith<_OperatingHours> get copyWith => __$OperatingHoursCopyWithImpl<_OperatingHours>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OperatingHours&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.dayOfWeek, dayOfWeek) || other.dayOfWeek == dayOfWeek)&&(identical(other.openMinutes, openMinutes) || other.openMinutes == openMinutes)&&(identical(other.closeMinutes, closeMinutes) || other.closeMinutes == closeMinutes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,ownerId,dayOfWeek,openMinutes,closeMinutes);
}

@override
String toString() {
    return 'OperatingHours(ownerId: $ownerId, dayOfWeek: $dayOfWeek, openMinutes: $openMinutes, closeMinutes: $closeMinutes)';
}


}

/// @nodoc
abstract mixin class _$OperatingHoursCopyWith<$Res> implements $OperatingHoursCopyWith<$Res> {
  factory _$OperatingHoursCopyWith(_OperatingHours value, $Res Function(_OperatingHours) _then) = __$OperatingHoursCopyWithImpl;
@override @useResult
$Res call({
 String ownerId, int dayOfWeek, int openMinutes, int closeMinutes
});




}
/// @nodoc
class __$OperatingHoursCopyWithImpl<$Res>
    implements _$OperatingHoursCopyWith<$Res> {
  __$OperatingHoursCopyWithImpl(this._self, this._then);

  final _OperatingHours _self;
  final $Res Function(_OperatingHours) _then;

/// Create a copy of OperatingHours
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ownerId = null,Object? dayOfWeek = null,Object? openMinutes = null,Object? closeMinutes = null,}) {
  return _then(_OperatingHours(
ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,dayOfWeek: null == dayOfWeek ? _self.dayOfWeek : dayOfWeek // ignore: cast_nullable_to_non_nullable
as int,openMinutes: null == openMinutes ? _self.openMinutes : openMinutes // ignore: cast_nullable_to_non_nullable
as int,closeMinutes: null == closeMinutes ? _self.closeMinutes : closeMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
