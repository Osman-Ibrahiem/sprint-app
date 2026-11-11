// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'role_assignment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RoleAssignment {

 String get userId; Role get role; RoleScopeType get scopeType; String? get scopeId;
/// Create a copy of RoleAssignment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoleAssignmentCopyWith<RoleAssignment> get copyWith => _$RoleAssignmentCopyWithImpl<RoleAssignment>(this as RoleAssignment, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RoleAssignment;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoleAssignment&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.scopeType, _this.scopeType) || other.scopeType == _this.scopeType)&&(identical(other.scopeId, _this.scopeId) || other.scopeId == _this.scopeId));
}


@override
int get hashCode {
  final _this = this as RoleAssignment;
  return Object.hash(runtimeType,_this.userId,_this.role,_this.scopeType,_this.scopeId);
}

@override
String toString() {
  final _this = this as RoleAssignment;
  return 'RoleAssignment(userId: ${_this.userId}, role: ${_this.role}, scopeType: ${_this.scopeType}, scopeId: ${_this.scopeId})';
}


}

/// @nodoc
abstract mixin class $RoleAssignmentCopyWith<$Res>  {
  factory $RoleAssignmentCopyWith(RoleAssignment value, $Res Function(RoleAssignment) _then) = _$RoleAssignmentCopyWithImpl;
@useResult
$Res call({
 String userId, Role role, RoleScopeType scopeType, String? scopeId
});




}
/// @nodoc
class _$RoleAssignmentCopyWithImpl<$Res>
    implements $RoleAssignmentCopyWith<$Res> {
  _$RoleAssignmentCopyWithImpl(this._self, this._then);

  final RoleAssignment _self;
  final $Res Function(RoleAssignment) _then;

/// Create a copy of RoleAssignment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? role = null,Object? scopeType = null,Object? scopeId = freezed,}) {
  return _then(RoleAssignment(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role,scopeType: null == scopeType ? _self.scopeType : scopeType // ignore: cast_nullable_to_non_nullable
as RoleScopeType,scopeId: freezed == scopeId ? _self.scopeId : scopeId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RoleAssignment].
extension RoleAssignmentPatterns on RoleAssignment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoleAssignment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoleAssignment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoleAssignment value)  $default,){
final _that = this;
switch (_that) {
case _RoleAssignment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoleAssignment value)?  $default,){
final _that = this;
switch (_that) {
case _RoleAssignment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  Role role,  RoleScopeType scopeType,  String? scopeId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoleAssignment() when $default != null:
return $default(_that.userId,_that.role,_that.scopeType,_that.scopeId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  Role role,  RoleScopeType scopeType,  String? scopeId)  $default,) {final _that = this;
switch (_that) {
case _RoleAssignment():
return $default(_that.userId,_that.role,_that.scopeType,_that.scopeId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  Role role,  RoleScopeType scopeType,  String? scopeId)?  $default,) {final _that = this;
switch (_that) {
case _RoleAssignment() when $default != null:
return $default(_that.userId,_that.role,_that.scopeType,_that.scopeId);case _:
  return null;

}
}

}

/// @nodoc


class _RoleAssignment implements RoleAssignment {
  const _RoleAssignment({required this.userId, required this.role, required this.scopeType, this.scopeId});
  

@override final  String userId;
@override final  Role role;
@override final  RoleScopeType scopeType;
@override final  String? scopeId;

/// Create a copy of RoleAssignment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoleAssignmentCopyWith<_RoleAssignment> get copyWith => __$RoleAssignmentCopyWithImpl<_RoleAssignment>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoleAssignment&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role)&&(identical(other.scopeType, scopeType) || other.scopeType == scopeType)&&(identical(other.scopeId, scopeId) || other.scopeId == scopeId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,userId,role,scopeType,scopeId);
}

@override
String toString() {
    return 'RoleAssignment(userId: $userId, role: $role, scopeType: $scopeType, scopeId: $scopeId)';
}


}

/// @nodoc
abstract mixin class _$RoleAssignmentCopyWith<$Res> implements $RoleAssignmentCopyWith<$Res> {
  factory _$RoleAssignmentCopyWith(_RoleAssignment value, $Res Function(_RoleAssignment) _then) = __$RoleAssignmentCopyWithImpl;
@override @useResult
$Res call({
 String userId, Role role, RoleScopeType scopeType, String? scopeId
});




}
/// @nodoc
class __$RoleAssignmentCopyWithImpl<$Res>
    implements _$RoleAssignmentCopyWith<$Res> {
  __$RoleAssignmentCopyWithImpl(this._self, this._then);

  final _RoleAssignment _self;
  final $Res Function(_RoleAssignment) _then;

/// Create a copy of RoleAssignment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? role = null,Object? scopeType = null,Object? scopeId = freezed,}) {
  return _then(_RoleAssignment(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as Role,scopeType: null == scopeType ? _self.scopeType : scopeType // ignore: cast_nullable_to_non_nullable
as RoleScopeType,scopeId: freezed == scopeId ? _self.scopeId : scopeId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
