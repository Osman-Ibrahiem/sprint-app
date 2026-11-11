// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bookable_unit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BookableUnit {

 String get id; String get facilityId; String get name; bool get isActive;
/// Create a copy of BookableUnit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookableUnitCopyWith<BookableUnit> get copyWith => _$BookableUnitCopyWithImpl<BookableUnit>(this as BookableUnit, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as BookableUnit;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookableUnit&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive));
}


@override
int get hashCode {
  final _this = this as BookableUnit;
  return Object.hash(runtimeType,_this.id,_this.facilityId,_this.name,_this.isActive);
}

@override
String toString() {
  final _this = this as BookableUnit;
  return 'BookableUnit(id: ${_this.id}, facilityId: ${_this.facilityId}, name: ${_this.name}, isActive: ${_this.isActive})';
}


}

/// @nodoc
abstract mixin class $BookableUnitCopyWith<$Res>  {
  factory $BookableUnitCopyWith(BookableUnit value, $Res Function(BookableUnit) _then) = _$BookableUnitCopyWithImpl;
@useResult
$Res call({
 String id, String facilityId, String name, bool isActive
});




}
/// @nodoc
class _$BookableUnitCopyWithImpl<$Res>
    implements $BookableUnitCopyWith<$Res> {
  _$BookableUnitCopyWithImpl(this._self, this._then);

  final BookableUnit _self;
  final $Res Function(BookableUnit) _then;

/// Create a copy of BookableUnit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? facilityId = null,Object? name = null,Object? isActive = null,}) {
  return _then(BookableUnit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BookableUnit].
extension BookableUnitPatterns on BookableUnit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookableUnit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookableUnit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookableUnit value)  $default,){
final _that = this;
switch (_that) {
case _BookableUnit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookableUnit value)?  $default,){
final _that = this;
switch (_that) {
case _BookableUnit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String facilityId,  String name,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookableUnit() when $default != null:
return $default(_that.id,_that.facilityId,_that.name,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String facilityId,  String name,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _BookableUnit():
return $default(_that.id,_that.facilityId,_that.name,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String facilityId,  String name,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _BookableUnit() when $default != null:
return $default(_that.id,_that.facilityId,_that.name,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc


class _BookableUnit implements BookableUnit {
  const _BookableUnit({required this.id, required this.facilityId, required this.name, this.isActive = true});
  

@override final  String id;
@override final  String facilityId;
@override final  String name;
@override@JsonKey() final  bool isActive;

/// Create a copy of BookableUnit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookableUnitCopyWith<_BookableUnit> get copyWith => __$BookableUnitCopyWithImpl<_BookableUnit>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookableUnit&&(identical(other.id, id) || other.id == id)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.name, name) || other.name == name)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,facilityId,name,isActive);
}

@override
String toString() {
    return 'BookableUnit(id: $id, facilityId: $facilityId, name: $name, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$BookableUnitCopyWith<$Res> implements $BookableUnitCopyWith<$Res> {
  factory _$BookableUnitCopyWith(_BookableUnit value, $Res Function(_BookableUnit) _then) = __$BookableUnitCopyWithImpl;
@override @useResult
$Res call({
 String id, String facilityId, String name, bool isActive
});




}
/// @nodoc
class __$BookableUnitCopyWithImpl<$Res>
    implements _$BookableUnitCopyWith<$Res> {
  __$BookableUnitCopyWithImpl(this._self, this._then);

  final _BookableUnit _self;
  final $Res Function(_BookableUnit) _then;

/// Create a copy of BookableUnit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? facilityId = null,Object? name = null,Object? isActive = null,}) {
  return _then(_BookableUnit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
