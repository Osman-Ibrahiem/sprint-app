// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'email_code.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EmailCode {

 String get userId; CodePurpose get purpose; String get code; DateTime get expiresAt; DateTime get resendAfter; int get wrongTries;
/// Create a copy of EmailCode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmailCodeCopyWith<EmailCode> get copyWith => _$EmailCodeCopyWithImpl<EmailCode>(this as EmailCode, _$identity);

  /// Serializes this EmailCode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EmailCode;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmailCode&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.purpose, _this.purpose) || other.purpose == _this.purpose)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.resendAfter, _this.resendAfter) || other.resendAfter == _this.resendAfter)&&(identical(other.wrongTries, _this.wrongTries) || other.wrongTries == _this.wrongTries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EmailCode;
  return Object.hash(runtimeType,_this.userId,_this.purpose,_this.code,_this.expiresAt,_this.resendAfter,_this.wrongTries);
}

@override
String toString() {
  final _this = this as EmailCode;
  return 'EmailCode(userId: ${_this.userId}, purpose: ${_this.purpose}, code: ${_this.code}, expiresAt: ${_this.expiresAt}, resendAfter: ${_this.resendAfter}, wrongTries: ${_this.wrongTries})';
}


}

/// @nodoc
abstract mixin class $EmailCodeCopyWith<$Res>  {
  factory $EmailCodeCopyWith(EmailCode value, $Res Function(EmailCode) _then) = _$EmailCodeCopyWithImpl;
@useResult
$Res call({
 String userId, CodePurpose purpose, String code, DateTime expiresAt, DateTime resendAfter, int wrongTries
});




}
/// @nodoc
class _$EmailCodeCopyWithImpl<$Res>
    implements $EmailCodeCopyWith<$Res> {
  _$EmailCodeCopyWithImpl(this._self, this._then);

  final EmailCode _self;
  final $Res Function(EmailCode) _then;

/// Create a copy of EmailCode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? purpose = null,Object? code = null,Object? expiresAt = null,Object? resendAfter = null,Object? wrongTries = null,}) {
  return _then(EmailCode(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as CodePurpose,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,resendAfter: null == resendAfter ? _self.resendAfter : resendAfter // ignore: cast_nullable_to_non_nullable
as DateTime,wrongTries: null == wrongTries ? _self.wrongTries : wrongTries // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [EmailCode].
extension EmailCodePatterns on EmailCode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmailCode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmailCode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmailCode value)  $default,){
final _that = this;
switch (_that) {
case _EmailCode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmailCode value)?  $default,){
final _that = this;
switch (_that) {
case _EmailCode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  CodePurpose purpose,  String code,  DateTime expiresAt,  DateTime resendAfter,  int wrongTries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmailCode() when $default != null:
return $default(_that.userId,_that.purpose,_that.code,_that.expiresAt,_that.resendAfter,_that.wrongTries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  CodePurpose purpose,  String code,  DateTime expiresAt,  DateTime resendAfter,  int wrongTries)  $default,) {final _that = this;
switch (_that) {
case _EmailCode():
return $default(_that.userId,_that.purpose,_that.code,_that.expiresAt,_that.resendAfter,_that.wrongTries);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  CodePurpose purpose,  String code,  DateTime expiresAt,  DateTime resendAfter,  int wrongTries)?  $default,) {final _that = this;
switch (_that) {
case _EmailCode() when $default != null:
return $default(_that.userId,_that.purpose,_that.code,_that.expiresAt,_that.resendAfter,_that.wrongTries);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EmailCode implements EmailCode {
  const _EmailCode({required this.userId, required this.purpose, required this.code, required this.expiresAt, required this.resendAfter, this.wrongTries = 0});
  factory _EmailCode.fromJson(Map<String, dynamic> json) => _$EmailCodeFromJson(json);

@override final  String userId;
@override final  CodePurpose purpose;
@override final  String code;
@override final  DateTime expiresAt;
@override final  DateTime resendAfter;
@override@JsonKey() final  int wrongTries;

/// Create a copy of EmailCode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmailCodeCopyWith<_EmailCode> get copyWith => __$EmailCodeCopyWithImpl<_EmailCode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmailCodeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmailCode&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.code, code) || other.code == code)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.resendAfter, resendAfter) || other.resendAfter == resendAfter)&&(identical(other.wrongTries, wrongTries) || other.wrongTries == wrongTries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,userId,purpose,code,expiresAt,resendAfter,wrongTries);
}

@override
String toString() {
    return 'EmailCode(userId: $userId, purpose: $purpose, code: $code, expiresAt: $expiresAt, resendAfter: $resendAfter, wrongTries: $wrongTries)';
}


}

/// @nodoc
abstract mixin class _$EmailCodeCopyWith<$Res> implements $EmailCodeCopyWith<$Res> {
  factory _$EmailCodeCopyWith(_EmailCode value, $Res Function(_EmailCode) _then) = __$EmailCodeCopyWithImpl;
@override @useResult
$Res call({
 String userId, CodePurpose purpose, String code, DateTime expiresAt, DateTime resendAfter, int wrongTries
});




}
/// @nodoc
class __$EmailCodeCopyWithImpl<$Res>
    implements _$EmailCodeCopyWith<$Res> {
  __$EmailCodeCopyWithImpl(this._self, this._then);

  final _EmailCode _self;
  final $Res Function(_EmailCode) _then;

/// Create a copy of EmailCode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? purpose = null,Object? code = null,Object? expiresAt = null,Object? resendAfter = null,Object? wrongTries = null,}) {
  return _then(_EmailCode(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as CodePurpose,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,resendAfter: null == resendAfter ? _self.resendAfter : resendAfter // ignore: cast_nullable_to_non_nullable
as DateTime,wrongTries: null == wrongTries ? _self.wrongTries : wrongTries // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
