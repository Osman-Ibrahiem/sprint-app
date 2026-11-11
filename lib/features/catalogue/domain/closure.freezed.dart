// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'closure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Closure {

 String get id; ClosureScope get scope; String get scopeId; DateTime get from; DateTime get to; String get reason;
/// Create a copy of Closure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClosureCopyWith<Closure> get copyWith => _$ClosureCopyWithImpl<Closure>(this as Closure, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Closure;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Closure&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.scope, _this.scope) || other.scope == _this.scope)&&(identical(other.scopeId, _this.scopeId) || other.scopeId == _this.scopeId)&&(identical(other.from, _this.from) || other.from == _this.from)&&(identical(other.to, _this.to) || other.to == _this.to)&&(identical(other.reason, _this.reason) || other.reason == _this.reason));
}


@override
int get hashCode {
  final _this = this as Closure;
  return Object.hash(runtimeType,_this.id,_this.scope,_this.scopeId,_this.from,_this.to,_this.reason);
}

@override
String toString() {
  final _this = this as Closure;
  return 'Closure(id: ${_this.id}, scope: ${_this.scope}, scopeId: ${_this.scopeId}, from: ${_this.from}, to: ${_this.to}, reason: ${_this.reason})';
}


}

/// @nodoc
abstract mixin class $ClosureCopyWith<$Res>  {
  factory $ClosureCopyWith(Closure value, $Res Function(Closure) _then) = _$ClosureCopyWithImpl;
@useResult
$Res call({
 String id, ClosureScope scope, String scopeId, DateTime from, DateTime to, String reason
});




}
/// @nodoc
class _$ClosureCopyWithImpl<$Res>
    implements $ClosureCopyWith<$Res> {
  _$ClosureCopyWithImpl(this._self, this._then);

  final Closure _self;
  final $Res Function(Closure) _then;

/// Create a copy of Closure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? scope = null,Object? scopeId = null,Object? from = null,Object? to = null,Object? reason = null,}) {
  return _then(Closure(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as ClosureScope,scopeId: null == scopeId ? _self.scopeId : scopeId // ignore: cast_nullable_to_non_nullable
as String,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Closure].
extension ClosurePatterns on Closure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Closure value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Closure() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Closure value)  $default,){
final _that = this;
switch (_that) {
case _Closure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Closure value)?  $default,){
final _that = this;
switch (_that) {
case _Closure() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  ClosureScope scope,  String scopeId,  DateTime from,  DateTime to,  String reason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Closure() when $default != null:
return $default(_that.id,_that.scope,_that.scopeId,_that.from,_that.to,_that.reason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  ClosureScope scope,  String scopeId,  DateTime from,  DateTime to,  String reason)  $default,) {final _that = this;
switch (_that) {
case _Closure():
return $default(_that.id,_that.scope,_that.scopeId,_that.from,_that.to,_that.reason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  ClosureScope scope,  String scopeId,  DateTime from,  DateTime to,  String reason)?  $default,) {final _that = this;
switch (_that) {
case _Closure() when $default != null:
return $default(_that.id,_that.scope,_that.scopeId,_that.from,_that.to,_that.reason);case _:
  return null;

}
}

}

/// @nodoc


class _Closure implements Closure {
  const _Closure({required this.id, required this.scope, required this.scopeId, required this.from, required this.to, required this.reason});
  

@override final  String id;
@override final  ClosureScope scope;
@override final  String scopeId;
@override final  DateTime from;
@override final  DateTime to;
@override final  String reason;

/// Create a copy of Closure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClosureCopyWith<_Closure> get copyWith => __$ClosureCopyWithImpl<_Closure>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Closure&&(identical(other.id, id) || other.id == id)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.scopeId, scopeId) || other.scopeId == scopeId)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,scope,scopeId,from,to,reason);
}

@override
String toString() {
    return 'Closure(id: $id, scope: $scope, scopeId: $scopeId, from: $from, to: $to, reason: $reason)';
}


}

/// @nodoc
abstract mixin class _$ClosureCopyWith<$Res> implements $ClosureCopyWith<$Res> {
  factory _$ClosureCopyWith(_Closure value, $Res Function(_Closure) _then) = __$ClosureCopyWithImpl;
@override @useResult
$Res call({
 String id, ClosureScope scope, String scopeId, DateTime from, DateTime to, String reason
});




}
/// @nodoc
class __$ClosureCopyWithImpl<$Res>
    implements _$ClosureCopyWith<$Res> {
  __$ClosureCopyWithImpl(this._self, this._then);

  final _Closure _self;
  final $Res Function(_Closure) _then;

/// Create a copy of Closure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? scope = null,Object? scopeId = null,Object? from = null,Object? to = null,Object? reason = null,}) {
  return _then(_Closure(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as ClosureScope,scopeId: null == scopeId ? _self.scopeId : scopeId // ignore: cast_nullable_to_non_nullable
as String,from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
