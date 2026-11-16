// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'simulated_email.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SimulatedEmail {

 String get id; String get to; String get subject; String get body; CodePurpose get purpose; DateTime get sentAt;
/// Create a copy of SimulatedEmail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SimulatedEmailCopyWith<SimulatedEmail> get copyWith => _$SimulatedEmailCopyWithImpl<SimulatedEmail>(this as SimulatedEmail, _$identity);

  /// Serializes this SimulatedEmail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SimulatedEmail;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SimulatedEmail&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.to, _this.to) || other.to == _this.to)&&(identical(other.subject, _this.subject) || other.subject == _this.subject)&&(identical(other.body, _this.body) || other.body == _this.body)&&(identical(other.purpose, _this.purpose) || other.purpose == _this.purpose)&&(identical(other.sentAt, _this.sentAt) || other.sentAt == _this.sentAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SimulatedEmail;
  return Object.hash(runtimeType,_this.id,_this.to,_this.subject,_this.body,_this.purpose,_this.sentAt);
}

@override
String toString() {
  final _this = this as SimulatedEmail;
  return 'SimulatedEmail(id: ${_this.id}, to: ${_this.to}, subject: ${_this.subject}, body: ${_this.body}, purpose: ${_this.purpose}, sentAt: ${_this.sentAt})';
}


}

/// @nodoc
abstract mixin class $SimulatedEmailCopyWith<$Res>  {
  factory $SimulatedEmailCopyWith(SimulatedEmail value, $Res Function(SimulatedEmail) _then) = _$SimulatedEmailCopyWithImpl;
@useResult
$Res call({
 String id, String to, String subject, String body, CodePurpose purpose, DateTime sentAt
});




}
/// @nodoc
class _$SimulatedEmailCopyWithImpl<$Res>
    implements $SimulatedEmailCopyWith<$Res> {
  _$SimulatedEmailCopyWithImpl(this._self, this._then);

  final SimulatedEmail _self;
  final $Res Function(SimulatedEmail) _then;

/// Create a copy of SimulatedEmail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? to = null,Object? subject = null,Object? body = null,Object? purpose = null,Object? sentAt = null,}) {
  return _then(SimulatedEmail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as CodePurpose,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SimulatedEmail].
extension SimulatedEmailPatterns on SimulatedEmail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SimulatedEmail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SimulatedEmail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SimulatedEmail value)  $default,){
final _that = this;
switch (_that) {
case _SimulatedEmail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SimulatedEmail value)?  $default,){
final _that = this;
switch (_that) {
case _SimulatedEmail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String to,  String subject,  String body,  CodePurpose purpose,  DateTime sentAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SimulatedEmail() when $default != null:
return $default(_that.id,_that.to,_that.subject,_that.body,_that.purpose,_that.sentAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String to,  String subject,  String body,  CodePurpose purpose,  DateTime sentAt)  $default,) {final _that = this;
switch (_that) {
case _SimulatedEmail():
return $default(_that.id,_that.to,_that.subject,_that.body,_that.purpose,_that.sentAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String to,  String subject,  String body,  CodePurpose purpose,  DateTime sentAt)?  $default,) {final _that = this;
switch (_that) {
case _SimulatedEmail() when $default != null:
return $default(_that.id,_that.to,_that.subject,_that.body,_that.purpose,_that.sentAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SimulatedEmail implements SimulatedEmail {
  const _SimulatedEmail({required this.id, required this.to, required this.subject, required this.body, required this.purpose, required this.sentAt});
  factory _SimulatedEmail.fromJson(Map<String, dynamic> json) => _$SimulatedEmailFromJson(json);

@override final  String id;
@override final  String to;
@override final  String subject;
@override final  String body;
@override final  CodePurpose purpose;
@override final  DateTime sentAt;

/// Create a copy of SimulatedEmail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SimulatedEmailCopyWith<_SimulatedEmail> get copyWith => __$SimulatedEmailCopyWithImpl<_SimulatedEmail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SimulatedEmailToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SimulatedEmail&&(identical(other.id, id) || other.id == id)&&(identical(other.to, to) || other.to == to)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.body, body) || other.body == body)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.sentAt, sentAt) || other.sentAt == sentAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,to,subject,body,purpose,sentAt);
}

@override
String toString() {
    return 'SimulatedEmail(id: $id, to: $to, subject: $subject, body: $body, purpose: $purpose, sentAt: $sentAt)';
}


}

/// @nodoc
abstract mixin class _$SimulatedEmailCopyWith<$Res> implements $SimulatedEmailCopyWith<$Res> {
  factory _$SimulatedEmailCopyWith(_SimulatedEmail value, $Res Function(_SimulatedEmail) _then) = __$SimulatedEmailCopyWithImpl;
@override @useResult
$Res call({
 String id, String to, String subject, String body, CodePurpose purpose, DateTime sentAt
});




}
/// @nodoc
class __$SimulatedEmailCopyWithImpl<$Res>
    implements _$SimulatedEmailCopyWith<$Res> {
  __$SimulatedEmailCopyWithImpl(this._self, this._then);

  final _SimulatedEmail _self;
  final $Res Function(_SimulatedEmail) _then;

/// Create a copy of SimulatedEmail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? to = null,Object? subject = null,Object? body = null,Object? purpose = null,Object? sentAt = null,}) {
  return _then(_SimulatedEmail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as CodePurpose,sentAt: null == sentAt ? _self.sentAt : sentAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
