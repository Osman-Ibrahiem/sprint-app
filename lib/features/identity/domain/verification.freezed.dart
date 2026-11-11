// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Verification {

 String get userId; VerificationType get type; VerificationStatus get status; VerificationMethod get method; String? get reason; DateTime? get expiresAt;
/// Create a copy of Verification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerificationCopyWith<Verification> get copyWith => _$VerificationCopyWithImpl<Verification>(this as Verification, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Verification;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Verification&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.method, _this.method) || other.method == _this.method)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt));
}


@override
int get hashCode {
  final _this = this as Verification;
  return Object.hash(runtimeType,_this.userId,_this.type,_this.status,_this.method,_this.reason,_this.expiresAt);
}

@override
String toString() {
  final _this = this as Verification;
  return 'Verification(userId: ${_this.userId}, type: ${_this.type}, status: ${_this.status}, method: ${_this.method}, reason: ${_this.reason}, expiresAt: ${_this.expiresAt})';
}


}

/// @nodoc
abstract mixin class $VerificationCopyWith<$Res>  {
  factory $VerificationCopyWith(Verification value, $Res Function(Verification) _then) = _$VerificationCopyWithImpl;
@useResult
$Res call({
 String userId, VerificationType type, VerificationStatus status, VerificationMethod method, String? reason, DateTime? expiresAt
});




}
/// @nodoc
class _$VerificationCopyWithImpl<$Res>
    implements $VerificationCopyWith<$Res> {
  _$VerificationCopyWithImpl(this._self, this._then);

  final Verification _self;
  final $Res Function(Verification) _then;

/// Create a copy of Verification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? type = null,Object? status = null,Object? method = null,Object? reason = freezed,Object? expiresAt = freezed,}) {
  return _then(Verification(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as VerificationType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VerificationStatus,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as VerificationMethod,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Verification].
extension VerificationPatterns on Verification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Verification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Verification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Verification value)  $default,){
final _that = this;
switch (_that) {
case _Verification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Verification value)?  $default,){
final _that = this;
switch (_that) {
case _Verification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  VerificationType type,  VerificationStatus status,  VerificationMethod method,  String? reason,  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Verification() when $default != null:
return $default(_that.userId,_that.type,_that.status,_that.method,_that.reason,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  VerificationType type,  VerificationStatus status,  VerificationMethod method,  String? reason,  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _Verification():
return $default(_that.userId,_that.type,_that.status,_that.method,_that.reason,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  VerificationType type,  VerificationStatus status,  VerificationMethod method,  String? reason,  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _Verification() when $default != null:
return $default(_that.userId,_that.type,_that.status,_that.method,_that.reason,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc


class _Verification extends Verification {
  const _Verification({required this.userId, required this.type, required this.status, required this.method, this.reason, this.expiresAt}): super._();
  

@override final  String userId;
@override final  VerificationType type;
@override final  VerificationStatus status;
@override final  VerificationMethod method;
@override final  String? reason;
@override final  DateTime? expiresAt;

/// Create a copy of Verification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerificationCopyWith<_Verification> get copyWith => __$VerificationCopyWithImpl<_Verification>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Verification&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.method, method) || other.method == method)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,userId,type,status,method,reason,expiresAt);
}

@override
String toString() {
    return 'Verification(userId: $userId, type: $type, status: $status, method: $method, reason: $reason, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$VerificationCopyWith<$Res> implements $VerificationCopyWith<$Res> {
  factory _$VerificationCopyWith(_Verification value, $Res Function(_Verification) _then) = __$VerificationCopyWithImpl;
@override @useResult
$Res call({
 String userId, VerificationType type, VerificationStatus status, VerificationMethod method, String? reason, DateTime? expiresAt
});




}
/// @nodoc
class __$VerificationCopyWithImpl<$Res>
    implements _$VerificationCopyWith<$Res> {
  __$VerificationCopyWithImpl(this._self, this._then);

  final _Verification _self;
  final $Res Function(_Verification) _then;

/// Create a copy of Verification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? type = null,Object? status = null,Object? method = null,Object? reason = freezed,Object? expiresAt = freezed,}) {
  return _then(_Verification(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as VerificationType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VerificationStatus,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as VerificationMethod,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
