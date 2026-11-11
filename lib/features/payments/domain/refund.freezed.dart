// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'refund.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Refund {

 String get id; String get paymentId; int get amount; String get reason; RefundStatus get status;
/// Create a copy of Refund
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RefundCopyWith<Refund> get copyWith => _$RefundCopyWithImpl<Refund>(this as Refund, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Refund;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Refund&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.paymentId, _this.paymentId) || other.paymentId == _this.paymentId)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.status, _this.status) || other.status == _this.status));
}


@override
int get hashCode {
  final _this = this as Refund;
  return Object.hash(runtimeType,_this.id,_this.paymentId,_this.amount,_this.reason,_this.status);
}

@override
String toString() {
  final _this = this as Refund;
  return 'Refund(id: ${_this.id}, paymentId: ${_this.paymentId}, amount: ${_this.amount}, reason: ${_this.reason}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $RefundCopyWith<$Res>  {
  factory $RefundCopyWith(Refund value, $Res Function(Refund) _then) = _$RefundCopyWithImpl;
@useResult
$Res call({
 String id, String paymentId, int amount, String reason, RefundStatus status
});




}
/// @nodoc
class _$RefundCopyWithImpl<$Res>
    implements $RefundCopyWith<$Res> {
  _$RefundCopyWithImpl(this._self, this._then);

  final Refund _self;
  final $Res Function(Refund) _then;

/// Create a copy of Refund
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? paymentId = null,Object? amount = null,Object? reason = null,Object? status = null,}) {
  return _then(Refund(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,paymentId: null == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RefundStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [Refund].
extension RefundPatterns on Refund {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Refund value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Refund() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Refund value)  $default,){
final _that = this;
switch (_that) {
case _Refund():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Refund value)?  $default,){
final _that = this;
switch (_that) {
case _Refund() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String paymentId,  int amount,  String reason,  RefundStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Refund() when $default != null:
return $default(_that.id,_that.paymentId,_that.amount,_that.reason,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String paymentId,  int amount,  String reason,  RefundStatus status)  $default,) {final _that = this;
switch (_that) {
case _Refund():
return $default(_that.id,_that.paymentId,_that.amount,_that.reason,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String paymentId,  int amount,  String reason,  RefundStatus status)?  $default,) {final _that = this;
switch (_that) {
case _Refund() when $default != null:
return $default(_that.id,_that.paymentId,_that.amount,_that.reason,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _Refund implements Refund {
  const _Refund({required this.id, required this.paymentId, required this.amount, required this.reason, required this.status});
  

@override final  String id;
@override final  String paymentId;
@override final  int amount;
@override final  String reason;
@override final  RefundStatus status;

/// Create a copy of Refund
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RefundCopyWith<_Refund> get copyWith => __$RefundCopyWithImpl<_Refund>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Refund&&(identical(other.id, id) || other.id == id)&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,paymentId,amount,reason,status);
}

@override
String toString() {
    return 'Refund(id: $id, paymentId: $paymentId, amount: $amount, reason: $reason, status: $status)';
}


}

/// @nodoc
abstract mixin class _$RefundCopyWith<$Res> implements $RefundCopyWith<$Res> {
  factory _$RefundCopyWith(_Refund value, $Res Function(_Refund) _then) = __$RefundCopyWithImpl;
@override @useResult
$Res call({
 String id, String paymentId, int amount, String reason, RefundStatus status
});




}
/// @nodoc
class __$RefundCopyWithImpl<$Res>
    implements _$RefundCopyWith<$Res> {
  __$RefundCopyWithImpl(this._self, this._then);

  final _Refund _self;
  final $Res Function(_Refund) _then;

/// Create a copy of Refund
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? paymentId = null,Object? amount = null,Object? reason = null,Object? status = null,}) {
  return _then(_Refund(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,paymentId: null == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RefundStatus,
  ));
}


}

// dart format on
