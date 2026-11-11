// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Attendance {

 String get bookingId; AttendanceStatus get status; AttendanceMethod get method; String get markedBy; DateTime get markedAt;
/// Create a copy of Attendance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceCopyWith<Attendance> get copyWith => _$AttendanceCopyWithImpl<Attendance>(this as Attendance, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Attendance;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Attendance&&(identical(other.bookingId, _this.bookingId) || other.bookingId == _this.bookingId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.method, _this.method) || other.method == _this.method)&&(identical(other.markedBy, _this.markedBy) || other.markedBy == _this.markedBy)&&(identical(other.markedAt, _this.markedAt) || other.markedAt == _this.markedAt));
}


@override
int get hashCode {
  final _this = this as Attendance;
  return Object.hash(runtimeType,_this.bookingId,_this.status,_this.method,_this.markedBy,_this.markedAt);
}

@override
String toString() {
  final _this = this as Attendance;
  return 'Attendance(bookingId: ${_this.bookingId}, status: ${_this.status}, method: ${_this.method}, markedBy: ${_this.markedBy}, markedAt: ${_this.markedAt})';
}


}

/// @nodoc
abstract mixin class $AttendanceCopyWith<$Res>  {
  factory $AttendanceCopyWith(Attendance value, $Res Function(Attendance) _then) = _$AttendanceCopyWithImpl;
@useResult
$Res call({
 String bookingId, AttendanceStatus status, AttendanceMethod method, String markedBy, DateTime markedAt
});




}
/// @nodoc
class _$AttendanceCopyWithImpl<$Res>
    implements $AttendanceCopyWith<$Res> {
  _$AttendanceCopyWithImpl(this._self, this._then);

  final Attendance _self;
  final $Res Function(Attendance) _then;

/// Create a copy of Attendance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookingId = null,Object? status = null,Object? method = null,Object? markedBy = null,Object? markedAt = null,}) {
  return _then(Attendance(
bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttendanceStatus,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as AttendanceMethod,markedBy: null == markedBy ? _self.markedBy : markedBy // ignore: cast_nullable_to_non_nullable
as String,markedAt: null == markedAt ? _self.markedAt : markedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Attendance].
extension AttendancePatterns on Attendance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Attendance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Attendance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Attendance value)  $default,){
final _that = this;
switch (_that) {
case _Attendance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Attendance value)?  $default,){
final _that = this;
switch (_that) {
case _Attendance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String bookingId,  AttendanceStatus status,  AttendanceMethod method,  String markedBy,  DateTime markedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Attendance() when $default != null:
return $default(_that.bookingId,_that.status,_that.method,_that.markedBy,_that.markedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String bookingId,  AttendanceStatus status,  AttendanceMethod method,  String markedBy,  DateTime markedAt)  $default,) {final _that = this;
switch (_that) {
case _Attendance():
return $default(_that.bookingId,_that.status,_that.method,_that.markedBy,_that.markedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String bookingId,  AttendanceStatus status,  AttendanceMethod method,  String markedBy,  DateTime markedAt)?  $default,) {final _that = this;
switch (_that) {
case _Attendance() when $default != null:
return $default(_that.bookingId,_that.status,_that.method,_that.markedBy,_that.markedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Attendance implements Attendance {
  const _Attendance({required this.bookingId, required this.status, required this.method, required this.markedBy, required this.markedAt});
  

@override final  String bookingId;
@override final  AttendanceStatus status;
@override final  AttendanceMethod method;
@override final  String markedBy;
@override final  DateTime markedAt;

/// Create a copy of Attendance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceCopyWith<_Attendance> get copyWith => __$AttendanceCopyWithImpl<_Attendance>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Attendance&&(identical(other.bookingId, bookingId) || other.bookingId == bookingId)&&(identical(other.status, status) || other.status == status)&&(identical(other.method, method) || other.method == method)&&(identical(other.markedBy, markedBy) || other.markedBy == markedBy)&&(identical(other.markedAt, markedAt) || other.markedAt == markedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,bookingId,status,method,markedBy,markedAt);
}

@override
String toString() {
    return 'Attendance(bookingId: $bookingId, status: $status, method: $method, markedBy: $markedBy, markedAt: $markedAt)';
}


}

/// @nodoc
abstract mixin class _$AttendanceCopyWith<$Res> implements $AttendanceCopyWith<$Res> {
  factory _$AttendanceCopyWith(_Attendance value, $Res Function(_Attendance) _then) = __$AttendanceCopyWithImpl;
@override @useResult
$Res call({
 String bookingId, AttendanceStatus status, AttendanceMethod method, String markedBy, DateTime markedAt
});




}
/// @nodoc
class __$AttendanceCopyWithImpl<$Res>
    implements _$AttendanceCopyWith<$Res> {
  __$AttendanceCopyWithImpl(this._self, this._then);

  final _Attendance _self;
  final $Res Function(_Attendance) _then;

/// Create a copy of Attendance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookingId = null,Object? status = null,Object? method = null,Object? markedBy = null,Object? markedAt = null,}) {
  return _then(_Attendance(
bookingId: null == bookingId ? _self.bookingId : bookingId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttendanceStatus,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as AttendanceMethod,markedBy: null == markedBy ? _self.markedBy : markedBy // ignore: cast_nullable_to_non_nullable
as String,markedAt: null == markedAt ? _self.markedAt : markedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
