// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'facility_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FacilityFilter {

 FacilityType? get type; String? get owningUnitId; bool? get free;
/// Create a copy of FacilityFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FacilityFilterCopyWith<FacilityFilter> get copyWith => _$FacilityFilterCopyWithImpl<FacilityFilter>(this as FacilityFilter, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FacilityFilter;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FacilityFilter&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.owningUnitId, _this.owningUnitId) || other.owningUnitId == _this.owningUnitId)&&(identical(other.free, _this.free) || other.free == _this.free));
}


@override
int get hashCode {
  final _this = this as FacilityFilter;
  return Object.hash(runtimeType,_this.type,_this.owningUnitId,_this.free);
}

@override
String toString() {
  final _this = this as FacilityFilter;
  return 'FacilityFilter(type: ${_this.type}, owningUnitId: ${_this.owningUnitId}, free: ${_this.free})';
}


}

/// @nodoc
abstract mixin class $FacilityFilterCopyWith<$Res>  {
  factory $FacilityFilterCopyWith(FacilityFilter value, $Res Function(FacilityFilter) _then) = _$FacilityFilterCopyWithImpl;
@useResult
$Res call({
 FacilityType? type, String? owningUnitId, bool? free
});




}
/// @nodoc
class _$FacilityFilterCopyWithImpl<$Res>
    implements $FacilityFilterCopyWith<$Res> {
  _$FacilityFilterCopyWithImpl(this._self, this._then);

  final FacilityFilter _self;
  final $Res Function(FacilityFilter) _then;

/// Create a copy of FacilityFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = freezed,Object? owningUnitId = freezed,Object? free = freezed,}) {
  return _then(FacilityFilter(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FacilityType?,owningUnitId: freezed == owningUnitId ? _self.owningUnitId : owningUnitId // ignore: cast_nullable_to_non_nullable
as String?,free: freezed == free ? _self.free : free // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [FacilityFilter].
extension FacilityFilterPatterns on FacilityFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FacilityFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FacilityFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FacilityFilter value)  $default,){
final _that = this;
switch (_that) {
case _FacilityFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FacilityFilter value)?  $default,){
final _that = this;
switch (_that) {
case _FacilityFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FacilityType? type,  String? owningUnitId,  bool? free)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FacilityFilter() when $default != null:
return $default(_that.type,_that.owningUnitId,_that.free);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FacilityType? type,  String? owningUnitId,  bool? free)  $default,) {final _that = this;
switch (_that) {
case _FacilityFilter():
return $default(_that.type,_that.owningUnitId,_that.free);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FacilityType? type,  String? owningUnitId,  bool? free)?  $default,) {final _that = this;
switch (_that) {
case _FacilityFilter() when $default != null:
return $default(_that.type,_that.owningUnitId,_that.free);case _:
  return null;

}
}

}

/// @nodoc


class _FacilityFilter extends FacilityFilter {
  const _FacilityFilter({this.type, this.owningUnitId, this.free}): super._();
  

@override final  FacilityType? type;
@override final  String? owningUnitId;
@override final  bool? free;

/// Create a copy of FacilityFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FacilityFilterCopyWith<_FacilityFilter> get copyWith => __$FacilityFilterCopyWithImpl<_FacilityFilter>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FacilityFilter&&(identical(other.type, type) || other.type == type)&&(identical(other.owningUnitId, owningUnitId) || other.owningUnitId == owningUnitId)&&(identical(other.free, free) || other.free == free));
}


@override
int get hashCode {
    return Object.hash(runtimeType,type,owningUnitId,free);
}

@override
String toString() {
    return 'FacilityFilter(type: $type, owningUnitId: $owningUnitId, free: $free)';
}


}

/// @nodoc
abstract mixin class _$FacilityFilterCopyWith<$Res> implements $FacilityFilterCopyWith<$Res> {
  factory _$FacilityFilterCopyWith(_FacilityFilter value, $Res Function(_FacilityFilter) _then) = __$FacilityFilterCopyWithImpl;
@override @useResult
$Res call({
 FacilityType? type, String? owningUnitId, bool? free
});




}
/// @nodoc
class __$FacilityFilterCopyWithImpl<$Res>
    implements _$FacilityFilterCopyWith<$Res> {
  __$FacilityFilterCopyWithImpl(this._self, this._then);

  final _FacilityFilter _self;
  final $Res Function(_FacilityFilter) _then;

/// Create a copy of FacilityFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = freezed,Object? owningUnitId = freezed,Object? free = freezed,}) {
  return _then(_FacilityFilter(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FacilityType?,owningUnitId: freezed == owningUnitId ? _self.owningUnitId : owningUnitId // ignore: cast_nullable_to_non_nullable
as String?,free: freezed == free ? _self.free : free // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
