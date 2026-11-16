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

 String get id; String get userId; VerificationType get type; String get nationalId;/// University or staff code: 1 to 20 digits or letters.
 String get code; String get owningUnitId; VerificationStatus get status; VerificationMethod get method; DateTime get submittedAt; String? get photoId; String? get reviewerId;/// Required (at least 10 characters) when rejected (BR-26).
 String? get reason; DateTime? get decidedAt; DateTime? get expiresAt;
/// Create a copy of Verification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VerificationCopyWith<Verification> get copyWith => _$VerificationCopyWithImpl<Verification>(this as Verification, _$identity);

  /// Serializes this Verification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Verification;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Verification&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.nationalId, _this.nationalId) || other.nationalId == _this.nationalId)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.owningUnitId, _this.owningUnitId) || other.owningUnitId == _this.owningUnitId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.method, _this.method) || other.method == _this.method)&&(identical(other.submittedAt, _this.submittedAt) || other.submittedAt == _this.submittedAt)&&(identical(other.photoId, _this.photoId) || other.photoId == _this.photoId)&&(identical(other.reviewerId, _this.reviewerId) || other.reviewerId == _this.reviewerId)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.decidedAt, _this.decidedAt) || other.decidedAt == _this.decidedAt)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Verification;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.type,_this.nationalId,_this.code,_this.owningUnitId,_this.status,_this.method,_this.submittedAt,_this.photoId,_this.reviewerId,_this.reason,_this.decidedAt,_this.expiresAt);
}

@override
String toString() {
  final _this = this as Verification;
  return 'Verification(id: ${_this.id}, userId: ${_this.userId}, type: ${_this.type}, nationalId: ${_this.nationalId}, code: ${_this.code}, owningUnitId: ${_this.owningUnitId}, status: ${_this.status}, method: ${_this.method}, submittedAt: ${_this.submittedAt}, photoId: ${_this.photoId}, reviewerId: ${_this.reviewerId}, reason: ${_this.reason}, decidedAt: ${_this.decidedAt}, expiresAt: ${_this.expiresAt})';
}


}

/// @nodoc
abstract mixin class $VerificationCopyWith<$Res>  {
  factory $VerificationCopyWith(Verification value, $Res Function(Verification) _then) = _$VerificationCopyWithImpl;
@useResult
$Res call({
 String id, String userId, VerificationType type, String nationalId, String code, String owningUnitId, VerificationStatus status, VerificationMethod method, DateTime submittedAt, String? photoId, String? reviewerId, String? reason, DateTime? decidedAt, DateTime? expiresAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? nationalId = null,Object? code = null,Object? owningUnitId = null,Object? status = null,Object? method = null,Object? submittedAt = null,Object? photoId = freezed,Object? reviewerId = freezed,Object? reason = freezed,Object? decidedAt = freezed,Object? expiresAt = freezed,}) {
  return _then(Verification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as VerificationType,nationalId: null == nationalId ? _self.nationalId : nationalId // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,owningUnitId: null == owningUnitId ? _self.owningUnitId : owningUnitId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VerificationStatus,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as VerificationMethod,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,photoId: freezed == photoId ? _self.photoId : photoId // ignore: cast_nullable_to_non_nullable
as String?,reviewerId: freezed == reviewerId ? _self.reviewerId : reviewerId // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  VerificationType type,  String nationalId,  String code,  String owningUnitId,  VerificationStatus status,  VerificationMethod method,  DateTime submittedAt,  String? photoId,  String? reviewerId,  String? reason,  DateTime? decidedAt,  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Verification() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.nationalId,_that.code,_that.owningUnitId,_that.status,_that.method,_that.submittedAt,_that.photoId,_that.reviewerId,_that.reason,_that.decidedAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  VerificationType type,  String nationalId,  String code,  String owningUnitId,  VerificationStatus status,  VerificationMethod method,  DateTime submittedAt,  String? photoId,  String? reviewerId,  String? reason,  DateTime? decidedAt,  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _Verification():
return $default(_that.id,_that.userId,_that.type,_that.nationalId,_that.code,_that.owningUnitId,_that.status,_that.method,_that.submittedAt,_that.photoId,_that.reviewerId,_that.reason,_that.decidedAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  VerificationType type,  String nationalId,  String code,  String owningUnitId,  VerificationStatus status,  VerificationMethod method,  DateTime submittedAt,  String? photoId,  String? reviewerId,  String? reason,  DateTime? decidedAt,  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _Verification() when $default != null:
return $default(_that.id,_that.userId,_that.type,_that.nationalId,_that.code,_that.owningUnitId,_that.status,_that.method,_that.submittedAt,_that.photoId,_that.reviewerId,_that.reason,_that.decidedAt,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Verification extends Verification {
  const _Verification({required this.id, required this.userId, required this.type, required this.nationalId, required this.code, required this.owningUnitId, required this.status, required this.method, required this.submittedAt, this.photoId, this.reviewerId, this.reason, this.decidedAt, this.expiresAt}): super._();
  factory _Verification.fromJson(Map<String, dynamic> json) => _$VerificationFromJson(json);

@override final  String id;
@override final  String userId;
@override final  VerificationType type;
@override final  String nationalId;
/// University or staff code: 1 to 20 digits or letters.
@override final  String code;
@override final  String owningUnitId;
@override final  VerificationStatus status;
@override final  VerificationMethod method;
@override final  DateTime submittedAt;
@override final  String? photoId;
@override final  String? reviewerId;
/// Required (at least 10 characters) when rejected (BR-26).
@override final  String? reason;
@override final  DateTime? decidedAt;
@override final  DateTime? expiresAt;

/// Create a copy of Verification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VerificationCopyWith<_Verification> get copyWith => __$VerificationCopyWithImpl<_Verification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VerificationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Verification&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.nationalId, nationalId) || other.nationalId == nationalId)&&(identical(other.code, code) || other.code == code)&&(identical(other.owningUnitId, owningUnitId) || other.owningUnitId == owningUnitId)&&(identical(other.status, status) || other.status == status)&&(identical(other.method, method) || other.method == method)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.photoId, photoId) || other.photoId == photoId)&&(identical(other.reviewerId, reviewerId) || other.reviewerId == reviewerId)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.decidedAt, decidedAt) || other.decidedAt == decidedAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,type,nationalId,code,owningUnitId,status,method,submittedAt,photoId,reviewerId,reason,decidedAt,expiresAt);
}

@override
String toString() {
    return 'Verification(id: $id, userId: $userId, type: $type, nationalId: $nationalId, code: $code, owningUnitId: $owningUnitId, status: $status, method: $method, submittedAt: $submittedAt, photoId: $photoId, reviewerId: $reviewerId, reason: $reason, decidedAt: $decidedAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$VerificationCopyWith<$Res> implements $VerificationCopyWith<$Res> {
  factory _$VerificationCopyWith(_Verification value, $Res Function(_Verification) _then) = __$VerificationCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, VerificationType type, String nationalId, String code, String owningUnitId, VerificationStatus status, VerificationMethod method, DateTime submittedAt, String? photoId, String? reviewerId, String? reason, DateTime? decidedAt, DateTime? expiresAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? nationalId = null,Object? code = null,Object? owningUnitId = null,Object? status = null,Object? method = null,Object? submittedAt = null,Object? photoId = freezed,Object? reviewerId = freezed,Object? reason = freezed,Object? decidedAt = freezed,Object? expiresAt = freezed,}) {
  return _then(_Verification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as VerificationType,nationalId: null == nationalId ? _self.nationalId : nationalId // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,owningUnitId: null == owningUnitId ? _self.owningUnitId : owningUnitId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VerificationStatus,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as VerificationMethod,submittedAt: null == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as DateTime,photoId: freezed == photoId ? _self.photoId : photoId // ignore: cast_nullable_to_non_nullable
as String?,reviewerId: freezed == reviewerId ? _self.reviewerId : reviewerId // ignore: cast_nullable_to_non_nullable
as String?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,decidedAt: freezed == decidedAt ? _self.decidedAt : decidedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
