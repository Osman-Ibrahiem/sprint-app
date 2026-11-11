// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Booking {

 String get id; String get code; String get userId; String get facilityId; String get unitId; String? get trainerId; DateTime get start; DateTime get end; int get seats; PriceTier get tierAtBooking; int get priceAtBooking; BookingStatus get status; String get qrToken; DateTime? get holdExpiresAt; CancelledBy? get cancelledBy; String? get cancelReason;
/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookingCopyWith<Booking> get copyWith => _$BookingCopyWithImpl<Booking>(this as Booking, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Booking;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Booking&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.facilityId, _this.facilityId) || other.facilityId == _this.facilityId)&&(identical(other.unitId, _this.unitId) || other.unitId == _this.unitId)&&(identical(other.trainerId, _this.trainerId) || other.trainerId == _this.trainerId)&&(identical(other.start, _this.start) || other.start == _this.start)&&(identical(other.end, _this.end) || other.end == _this.end)&&(identical(other.seats, _this.seats) || other.seats == _this.seats)&&(identical(other.tierAtBooking, _this.tierAtBooking) || other.tierAtBooking == _this.tierAtBooking)&&(identical(other.priceAtBooking, _this.priceAtBooking) || other.priceAtBooking == _this.priceAtBooking)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.qrToken, _this.qrToken) || other.qrToken == _this.qrToken)&&(identical(other.holdExpiresAt, _this.holdExpiresAt) || other.holdExpiresAt == _this.holdExpiresAt)&&(identical(other.cancelledBy, _this.cancelledBy) || other.cancelledBy == _this.cancelledBy)&&(identical(other.cancelReason, _this.cancelReason) || other.cancelReason == _this.cancelReason));
}


@override
int get hashCode {
  final _this = this as Booking;
  return Object.hash(runtimeType,_this.id,_this.code,_this.userId,_this.facilityId,_this.unitId,_this.trainerId,_this.start,_this.end,_this.seats,_this.tierAtBooking,_this.priceAtBooking,_this.status,_this.qrToken,_this.holdExpiresAt,_this.cancelledBy,_this.cancelReason);
}

@override
String toString() {
  final _this = this as Booking;
  return 'Booking(id: ${_this.id}, code: ${_this.code}, userId: ${_this.userId}, facilityId: ${_this.facilityId}, unitId: ${_this.unitId}, trainerId: ${_this.trainerId}, start: ${_this.start}, end: ${_this.end}, seats: ${_this.seats}, tierAtBooking: ${_this.tierAtBooking}, priceAtBooking: ${_this.priceAtBooking}, status: ${_this.status}, qrToken: ${_this.qrToken}, holdExpiresAt: ${_this.holdExpiresAt}, cancelledBy: ${_this.cancelledBy}, cancelReason: ${_this.cancelReason})';
}


}

/// @nodoc
abstract mixin class $BookingCopyWith<$Res>  {
  factory $BookingCopyWith(Booking value, $Res Function(Booking) _then) = _$BookingCopyWithImpl;
@useResult
$Res call({
 String id, String code, String userId, String facilityId, String unitId, String? trainerId, DateTime start, DateTime end, int seats, PriceTier tierAtBooking, int priceAtBooking, BookingStatus status, String qrToken, DateTime? holdExpiresAt, CancelledBy? cancelledBy, String? cancelReason
});




}
/// @nodoc
class _$BookingCopyWithImpl<$Res>
    implements $BookingCopyWith<$Res> {
  _$BookingCopyWithImpl(this._self, this._then);

  final Booking _self;
  final $Res Function(Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? userId = null,Object? facilityId = null,Object? unitId = null,Object? trainerId = freezed,Object? start = null,Object? end = null,Object? seats = null,Object? tierAtBooking = null,Object? priceAtBooking = null,Object? status = null,Object? qrToken = null,Object? holdExpiresAt = freezed,Object? cancelledBy = freezed,Object? cancelReason = freezed,}) {
  return _then(Booking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as String,unitId: null == unitId ? _self.unitId : unitId // ignore: cast_nullable_to_non_nullable
as String,trainerId: freezed == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String?,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime,seats: null == seats ? _self.seats : seats // ignore: cast_nullable_to_non_nullable
as int,tierAtBooking: null == tierAtBooking ? _self.tierAtBooking : tierAtBooking // ignore: cast_nullable_to_non_nullable
as PriceTier,priceAtBooking: null == priceAtBooking ? _self.priceAtBooking : priceAtBooking // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,qrToken: null == qrToken ? _self.qrToken : qrToken // ignore: cast_nullable_to_non_nullable
as String,holdExpiresAt: freezed == holdExpiresAt ? _self.holdExpiresAt : holdExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledBy: freezed == cancelledBy ? _self.cancelledBy : cancelledBy // ignore: cast_nullable_to_non_nullable
as CancelledBy?,cancelReason: freezed == cancelReason ? _self.cancelReason : cancelReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Booking].
extension BookingPatterns on Booking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Booking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Booking value)  $default,){
final _that = this;
switch (_that) {
case _Booking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Booking value)?  $default,){
final _that = this;
switch (_that) {
case _Booking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String code,  String userId,  String facilityId,  String unitId,  String? trainerId,  DateTime start,  DateTime end,  int seats,  PriceTier tierAtBooking,  int priceAtBooking,  BookingStatus status,  String qrToken,  DateTime? holdExpiresAt,  CancelledBy? cancelledBy,  String? cancelReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.code,_that.userId,_that.facilityId,_that.unitId,_that.trainerId,_that.start,_that.end,_that.seats,_that.tierAtBooking,_that.priceAtBooking,_that.status,_that.qrToken,_that.holdExpiresAt,_that.cancelledBy,_that.cancelReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String code,  String userId,  String facilityId,  String unitId,  String? trainerId,  DateTime start,  DateTime end,  int seats,  PriceTier tierAtBooking,  int priceAtBooking,  BookingStatus status,  String qrToken,  DateTime? holdExpiresAt,  CancelledBy? cancelledBy,  String? cancelReason)  $default,) {final _that = this;
switch (_that) {
case _Booking():
return $default(_that.id,_that.code,_that.userId,_that.facilityId,_that.unitId,_that.trainerId,_that.start,_that.end,_that.seats,_that.tierAtBooking,_that.priceAtBooking,_that.status,_that.qrToken,_that.holdExpiresAt,_that.cancelledBy,_that.cancelReason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String code,  String userId,  String facilityId,  String unitId,  String? trainerId,  DateTime start,  DateTime end,  int seats,  PriceTier tierAtBooking,  int priceAtBooking,  BookingStatus status,  String qrToken,  DateTime? holdExpiresAt,  CancelledBy? cancelledBy,  String? cancelReason)?  $default,) {final _that = this;
switch (_that) {
case _Booking() when $default != null:
return $default(_that.id,_that.code,_that.userId,_that.facilityId,_that.unitId,_that.trainerId,_that.start,_that.end,_that.seats,_that.tierAtBooking,_that.priceAtBooking,_that.status,_that.qrToken,_that.holdExpiresAt,_that.cancelledBy,_that.cancelReason);case _:
  return null;

}
}

}

/// @nodoc


class _Booking extends Booking {
  const _Booking({required this.id, required this.code, required this.userId, required this.facilityId, required this.unitId, this.trainerId, required this.start, required this.end, required this.seats, required this.tierAtBooking, required this.priceAtBooking, required this.status, required this.qrToken, this.holdExpiresAt, this.cancelledBy, this.cancelReason}): super._();
  

@override final  String id;
@override final  String code;
@override final  String userId;
@override final  String facilityId;
@override final  String unitId;
@override final  String? trainerId;
@override final  DateTime start;
@override final  DateTime end;
@override final  int seats;
@override final  PriceTier tierAtBooking;
@override final  int priceAtBooking;
@override final  BookingStatus status;
@override final  String qrToken;
@override final  DateTime? holdExpiresAt;
@override final  CancelledBy? cancelledBy;
@override final  String? cancelReason;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookingCopyWith<_Booking> get copyWith => __$BookingCopyWithImpl<_Booking>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Booking&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.facilityId, facilityId) || other.facilityId == facilityId)&&(identical(other.unitId, unitId) || other.unitId == unitId)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.start, start) || other.start == start)&&(identical(other.end, end) || other.end == end)&&(identical(other.seats, seats) || other.seats == seats)&&(identical(other.tierAtBooking, tierAtBooking) || other.tierAtBooking == tierAtBooking)&&(identical(other.priceAtBooking, priceAtBooking) || other.priceAtBooking == priceAtBooking)&&(identical(other.status, status) || other.status == status)&&(identical(other.qrToken, qrToken) || other.qrToken == qrToken)&&(identical(other.holdExpiresAt, holdExpiresAt) || other.holdExpiresAt == holdExpiresAt)&&(identical(other.cancelledBy, cancelledBy) || other.cancelledBy == cancelledBy)&&(identical(other.cancelReason, cancelReason) || other.cancelReason == cancelReason));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,code,userId,facilityId,unitId,trainerId,start,end,seats,tierAtBooking,priceAtBooking,status,qrToken,holdExpiresAt,cancelledBy,cancelReason);
}

@override
String toString() {
    return 'Booking(id: $id, code: $code, userId: $userId, facilityId: $facilityId, unitId: $unitId, trainerId: $trainerId, start: $start, end: $end, seats: $seats, tierAtBooking: $tierAtBooking, priceAtBooking: $priceAtBooking, status: $status, qrToken: $qrToken, holdExpiresAt: $holdExpiresAt, cancelledBy: $cancelledBy, cancelReason: $cancelReason)';
}


}

/// @nodoc
abstract mixin class _$BookingCopyWith<$Res> implements $BookingCopyWith<$Res> {
  factory _$BookingCopyWith(_Booking value, $Res Function(_Booking) _then) = __$BookingCopyWithImpl;
@override @useResult
$Res call({
 String id, String code, String userId, String facilityId, String unitId, String? trainerId, DateTime start, DateTime end, int seats, PriceTier tierAtBooking, int priceAtBooking, BookingStatus status, String qrToken, DateTime? holdExpiresAt, CancelledBy? cancelledBy, String? cancelReason
});




}
/// @nodoc
class __$BookingCopyWithImpl<$Res>
    implements _$BookingCopyWith<$Res> {
  __$BookingCopyWithImpl(this._self, this._then);

  final _Booking _self;
  final $Res Function(_Booking) _then;

/// Create a copy of Booking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? userId = null,Object? facilityId = null,Object? unitId = null,Object? trainerId = freezed,Object? start = null,Object? end = null,Object? seats = null,Object? tierAtBooking = null,Object? priceAtBooking = null,Object? status = null,Object? qrToken = null,Object? holdExpiresAt = freezed,Object? cancelledBy = freezed,Object? cancelReason = freezed,}) {
  return _then(_Booking(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,facilityId: null == facilityId ? _self.facilityId : facilityId // ignore: cast_nullable_to_non_nullable
as String,unitId: null == unitId ? _self.unitId : unitId // ignore: cast_nullable_to_non_nullable
as String,trainerId: freezed == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String?,start: null == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime,end: null == end ? _self.end : end // ignore: cast_nullable_to_non_nullable
as DateTime,seats: null == seats ? _self.seats : seats // ignore: cast_nullable_to_non_nullable
as int,tierAtBooking: null == tierAtBooking ? _self.tierAtBooking : tierAtBooking // ignore: cast_nullable_to_non_nullable
as PriceTier,priceAtBooking: null == priceAtBooking ? _self.priceAtBooking : priceAtBooking // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BookingStatus,qrToken: null == qrToken ? _self.qrToken : qrToken // ignore: cast_nullable_to_non_nullable
as String,holdExpiresAt: freezed == holdExpiresAt ? _self.holdExpiresAt : holdExpiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledBy: freezed == cancelledBy ? _self.cancelledBy : cancelledBy // ignore: cast_nullable_to_non_nullable
as CancelledBy?,cancelReason: freezed == cancelReason ? _self.cancelReason : cancelReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
