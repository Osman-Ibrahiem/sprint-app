// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credential.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Credential {

 String get userId; String get salt; String get hash; int get failedAttempts; DateTime? get lockedUntil;
/// Create a copy of Credential
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CredentialCopyWith<Credential> get copyWith => _$CredentialCopyWithImpl<Credential>(this as Credential, _$identity);

  /// Serializes this Credential to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Credential;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Credential&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.salt, _this.salt) || other.salt == _this.salt)&&(identical(other.hash, _this.hash) || other.hash == _this.hash)&&(identical(other.failedAttempts, _this.failedAttempts) || other.failedAttempts == _this.failedAttempts)&&(identical(other.lockedUntil, _this.lockedUntil) || other.lockedUntil == _this.lockedUntil));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Credential;
  return Object.hash(runtimeType,_this.userId,_this.salt,_this.hash,_this.failedAttempts,_this.lockedUntil);
}

@override
String toString() {
  final _this = this as Credential;
  return 'Credential(userId: ${_this.userId}, salt: ${_this.salt}, hash: ${_this.hash}, failedAttempts: ${_this.failedAttempts}, lockedUntil: ${_this.lockedUntil})';
}


}

/// @nodoc
abstract mixin class $CredentialCopyWith<$Res>  {
  factory $CredentialCopyWith(Credential value, $Res Function(Credential) _then) = _$CredentialCopyWithImpl;
@useResult
$Res call({
 String userId, String salt, String hash, int failedAttempts, DateTime? lockedUntil
});




}
/// @nodoc
class _$CredentialCopyWithImpl<$Res>
    implements $CredentialCopyWith<$Res> {
  _$CredentialCopyWithImpl(this._self, this._then);

  final Credential _self;
  final $Res Function(Credential) _then;

/// Create a copy of Credential
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? salt = null,Object? hash = null,Object? failedAttempts = null,Object? lockedUntil = freezed,}) {
  return _then(Credential(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,salt: null == salt ? _self.salt : salt // ignore: cast_nullable_to_non_nullable
as String,hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,failedAttempts: null == failedAttempts ? _self.failedAttempts : failedAttempts // ignore: cast_nullable_to_non_nullable
as int,lockedUntil: freezed == lockedUntil ? _self.lockedUntil : lockedUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Credential].
extension CredentialPatterns on Credential {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Credential value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Credential() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Credential value)  $default,){
final _that = this;
switch (_that) {
case _Credential():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Credential value)?  $default,){
final _that = this;
switch (_that) {
case _Credential() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String salt,  String hash,  int failedAttempts,  DateTime? lockedUntil)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Credential() when $default != null:
return $default(_that.userId,_that.salt,_that.hash,_that.failedAttempts,_that.lockedUntil);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String salt,  String hash,  int failedAttempts,  DateTime? lockedUntil)  $default,) {final _that = this;
switch (_that) {
case _Credential():
return $default(_that.userId,_that.salt,_that.hash,_that.failedAttempts,_that.lockedUntil);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String salt,  String hash,  int failedAttempts,  DateTime? lockedUntil)?  $default,) {final _that = this;
switch (_that) {
case _Credential() when $default != null:
return $default(_that.userId,_that.salt,_that.hash,_that.failedAttempts,_that.lockedUntil);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Credential implements Credential {
  const _Credential({required this.userId, required this.salt, required this.hash, this.failedAttempts = 0, this.lockedUntil});
  factory _Credential.fromJson(Map<String, dynamic> json) => _$CredentialFromJson(json);

@override final  String userId;
@override final  String salt;
@override final  String hash;
@override@JsonKey() final  int failedAttempts;
@override final  DateTime? lockedUntil;

/// Create a copy of Credential
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CredentialCopyWith<_Credential> get copyWith => __$CredentialCopyWithImpl<_Credential>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CredentialToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Credential&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.salt, salt) || other.salt == salt)&&(identical(other.hash, hash) || other.hash == hash)&&(identical(other.failedAttempts, failedAttempts) || other.failedAttempts == failedAttempts)&&(identical(other.lockedUntil, lockedUntil) || other.lockedUntil == lockedUntil));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,userId,salt,hash,failedAttempts,lockedUntil);
}

@override
String toString() {
    return 'Credential(userId: $userId, salt: $salt, hash: $hash, failedAttempts: $failedAttempts, lockedUntil: $lockedUntil)';
}


}

/// @nodoc
abstract mixin class _$CredentialCopyWith<$Res> implements $CredentialCopyWith<$Res> {
  factory _$CredentialCopyWith(_Credential value, $Res Function(_Credential) _then) = __$CredentialCopyWithImpl;
@override @useResult
$Res call({
 String userId, String salt, String hash, int failedAttempts, DateTime? lockedUntil
});




}
/// @nodoc
class __$CredentialCopyWithImpl<$Res>
    implements _$CredentialCopyWith<$Res> {
  __$CredentialCopyWithImpl(this._self, this._then);

  final _Credential _self;
  final $Res Function(_Credential) _then;

/// Create a copy of Credential
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? salt = null,Object? hash = null,Object? failedAttempts = null,Object? lockedUntil = freezed,}) {
  return _then(_Credential(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,salt: null == salt ? _self.salt : salt // ignore: cast_nullable_to_non_nullable
as String,hash: null == hash ? _self.hash : hash // ignore: cast_nullable_to_non_nullable
as String,failedAttempts: null == failedAttempts ? _self.failedAttempts : failedAttempts // ignore: cast_nullable_to_non_nullable
as int,lockedUntil: freezed == lockedUntil ? _self.lockedUntil : lockedUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
