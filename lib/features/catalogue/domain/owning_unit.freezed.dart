// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'owning_unit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OwningUnit {

 String get id; String get name; OwningUnitType get type;
/// Create a copy of OwningUnit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OwningUnitCopyWith<OwningUnit> get copyWith => _$OwningUnitCopyWithImpl<OwningUnit>(this as OwningUnit, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OwningUnit;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OwningUnit&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type));
}


@override
int get hashCode {
  final _this = this as OwningUnit;
  return Object.hash(runtimeType,_this.id,_this.name,_this.type);
}

@override
String toString() {
  final _this = this as OwningUnit;
  return 'OwningUnit(id: ${_this.id}, name: ${_this.name}, type: ${_this.type})';
}


}

/// @nodoc
abstract mixin class $OwningUnitCopyWith<$Res>  {
  factory $OwningUnitCopyWith(OwningUnit value, $Res Function(OwningUnit) _then) = _$OwningUnitCopyWithImpl;
@useResult
$Res call({
 String id, String name, OwningUnitType type
});




}
/// @nodoc
class _$OwningUnitCopyWithImpl<$Res>
    implements $OwningUnitCopyWith<$Res> {
  _$OwningUnitCopyWithImpl(this._self, this._then);

  final OwningUnit _self;
  final $Res Function(OwningUnit) _then;

/// Create a copy of OwningUnit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,}) {
  return _then(OwningUnit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OwningUnitType,
  ));
}

}


/// Adds pattern-matching-related methods to [OwningUnit].
extension OwningUnitPatterns on OwningUnit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OwningUnit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OwningUnit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OwningUnit value)  $default,){
final _that = this;
switch (_that) {
case _OwningUnit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OwningUnit value)?  $default,){
final _that = this;
switch (_that) {
case _OwningUnit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  OwningUnitType type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OwningUnit() when $default != null:
return $default(_that.id,_that.name,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  OwningUnitType type)  $default,) {final _that = this;
switch (_that) {
case _OwningUnit():
return $default(_that.id,_that.name,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  OwningUnitType type)?  $default,) {final _that = this;
switch (_that) {
case _OwningUnit() when $default != null:
return $default(_that.id,_that.name,_that.type);case _:
  return null;

}
}

}

/// @nodoc


class _OwningUnit implements OwningUnit {
  const _OwningUnit({required this.id, required this.name, required this.type});
  

@override final  String id;
@override final  String name;
@override final  OwningUnitType type;

/// Create a copy of OwningUnit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OwningUnitCopyWith<_OwningUnit> get copyWith => __$OwningUnitCopyWithImpl<_OwningUnit>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OwningUnit&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,type);
}

@override
String toString() {
    return 'OwningUnit(id: $id, name: $name, type: $type)';
}


}

/// @nodoc
abstract mixin class _$OwningUnitCopyWith<$Res> implements $OwningUnitCopyWith<$Res> {
  factory _$OwningUnitCopyWith(_OwningUnit value, $Res Function(_OwningUnit) _then) = __$OwningUnitCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, OwningUnitType type
});




}
/// @nodoc
class __$OwningUnitCopyWithImpl<$Res>
    implements _$OwningUnitCopyWith<$Res> {
  __$OwningUnitCopyWithImpl(this._self, this._then);

  final _OwningUnit _self;
  final $Res Function(_OwningUnit) _then;

/// Create a copy of OwningUnit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,}) {
  return _then(_OwningUnit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as OwningUnitType,
  ));
}


}

// dart format on
