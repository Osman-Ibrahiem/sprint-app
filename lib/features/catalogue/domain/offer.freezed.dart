// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'offer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Offer {

 String get id; OfferScope get scope; String? get scopeId; int get discountPercent; Set<int> get days; int get fromMinutes; int get toMinutes; PriceTier? get tier; DateTime get validFrom; DateTime get validTo;
/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferCopyWith<Offer> get copyWith => _$OfferCopyWithImpl<Offer>(this as Offer, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Offer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Offer&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.scope, _this.scope) || other.scope == _this.scope)&&(identical(other.scopeId, _this.scopeId) || other.scopeId == _this.scopeId)&&(identical(other.discountPercent, _this.discountPercent) || other.discountPercent == _this.discountPercent)&&const DeepCollectionEquality().equals(other.days, _this.days)&&(identical(other.fromMinutes, _this.fromMinutes) || other.fromMinutes == _this.fromMinutes)&&(identical(other.toMinutes, _this.toMinutes) || other.toMinutes == _this.toMinutes)&&(identical(other.tier, _this.tier) || other.tier == _this.tier)&&(identical(other.validFrom, _this.validFrom) || other.validFrom == _this.validFrom)&&(identical(other.validTo, _this.validTo) || other.validTo == _this.validTo));
}


@override
int get hashCode {
  final _this = this as Offer;
  return Object.hash(runtimeType,_this.id,_this.scope,_this.scopeId,_this.discountPercent,const DeepCollectionEquality().hash(_this.days),_this.fromMinutes,_this.toMinutes,_this.tier,_this.validFrom,_this.validTo);
}

@override
String toString() {
  final _this = this as Offer;
  return 'Offer(id: ${_this.id}, scope: ${_this.scope}, scopeId: ${_this.scopeId}, discountPercent: ${_this.discountPercent}, days: ${_this.days}, fromMinutes: ${_this.fromMinutes}, toMinutes: ${_this.toMinutes}, tier: ${_this.tier}, validFrom: ${_this.validFrom}, validTo: ${_this.validTo})';
}


}

/// @nodoc
abstract mixin class $OfferCopyWith<$Res>  {
  factory $OfferCopyWith(Offer value, $Res Function(Offer) _then) = _$OfferCopyWithImpl;
@useResult
$Res call({
 String id, OfferScope scope, String? scopeId, int discountPercent, Set<int> days, int fromMinutes, int toMinutes, PriceTier? tier, DateTime validFrom, DateTime validTo
});




}
/// @nodoc
class _$OfferCopyWithImpl<$Res>
    implements $OfferCopyWith<$Res> {
  _$OfferCopyWithImpl(this._self, this._then);

  final Offer _self;
  final $Res Function(Offer) _then;

/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? scope = null,Object? scopeId = freezed,Object? discountPercent = null,Object? days = null,Object? fromMinutes = null,Object? toMinutes = null,Object? tier = freezed,Object? validFrom = null,Object? validTo = null,}) {
  return _then(Offer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as OfferScope,scopeId: freezed == scopeId ? _self.scopeId : scopeId // ignore: cast_nullable_to_non_nullable
as String?,discountPercent: null == discountPercent ? _self.discountPercent : discountPercent // ignore: cast_nullable_to_non_nullable
as int,days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as Set<int>,fromMinutes: null == fromMinutes ? _self.fromMinutes : fromMinutes // ignore: cast_nullable_to_non_nullable
as int,toMinutes: null == toMinutes ? _self.toMinutes : toMinutes // ignore: cast_nullable_to_non_nullable
as int,tier: freezed == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as PriceTier?,validFrom: null == validFrom ? _self.validFrom : validFrom // ignore: cast_nullable_to_non_nullable
as DateTime,validTo: null == validTo ? _self.validTo : validTo // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Offer].
extension OfferPatterns on Offer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Offer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Offer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Offer value)  $default,){
final _that = this;
switch (_that) {
case _Offer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Offer value)?  $default,){
final _that = this;
switch (_that) {
case _Offer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  OfferScope scope,  String? scopeId,  int discountPercent,  Set<int> days,  int fromMinutes,  int toMinutes,  PriceTier? tier,  DateTime validFrom,  DateTime validTo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Offer() when $default != null:
return $default(_that.id,_that.scope,_that.scopeId,_that.discountPercent,_that.days,_that.fromMinutes,_that.toMinutes,_that.tier,_that.validFrom,_that.validTo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  OfferScope scope,  String? scopeId,  int discountPercent,  Set<int> days,  int fromMinutes,  int toMinutes,  PriceTier? tier,  DateTime validFrom,  DateTime validTo)  $default,) {final _that = this;
switch (_that) {
case _Offer():
return $default(_that.id,_that.scope,_that.scopeId,_that.discountPercent,_that.days,_that.fromMinutes,_that.toMinutes,_that.tier,_that.validFrom,_that.validTo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  OfferScope scope,  String? scopeId,  int discountPercent,  Set<int> days,  int fromMinutes,  int toMinutes,  PriceTier? tier,  DateTime validFrom,  DateTime validTo)?  $default,) {final _that = this;
switch (_that) {
case _Offer() when $default != null:
return $default(_that.id,_that.scope,_that.scopeId,_that.discountPercent,_that.days,_that.fromMinutes,_that.toMinutes,_that.tier,_that.validFrom,_that.validTo);case _:
  return null;

}
}

}

/// @nodoc


class _Offer implements Offer {
  const _Offer({required this.id, required this.scope, this.scopeId, required this.discountPercent, required  Set<int> days, required this.fromMinutes, required this.toMinutes, this.tier, required this.validFrom, required this.validTo}): _days = days;
  

@override final  String id;
@override final  OfferScope scope;
@override final  String? scopeId;
@override final  int discountPercent;
 final  Set<int> _days;
@override Set<int> get days {
  if (_days is EqualUnmodifiableSetView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_days);
}

@override final  int fromMinutes;
@override final  int toMinutes;
@override final  PriceTier? tier;
@override final  DateTime validFrom;
@override final  DateTime validTo;

/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferCopyWith<_Offer> get copyWith => __$OfferCopyWithImpl<_Offer>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Offer&&(identical(other.id, id) || other.id == id)&&(identical(other.scope, scope) || other.scope == scope)&&(identical(other.scopeId, scopeId) || other.scopeId == scopeId)&&(identical(other.discountPercent, discountPercent) || other.discountPercent == discountPercent)&&const DeepCollectionEquality().equals(other.days, _days)&&(identical(other.fromMinutes, fromMinutes) || other.fromMinutes == fromMinutes)&&(identical(other.toMinutes, toMinutes) || other.toMinutes == toMinutes)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.validFrom, validFrom) || other.validFrom == validFrom)&&(identical(other.validTo, validTo) || other.validTo == validTo));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,scope,scopeId,discountPercent,const DeepCollectionEquality().hash(_days),fromMinutes,toMinutes,tier,validFrom,validTo);
}

@override
String toString() {
    return 'Offer(id: $id, scope: $scope, scopeId: $scopeId, discountPercent: $discountPercent, days: $days, fromMinutes: $fromMinutes, toMinutes: $toMinutes, tier: $tier, validFrom: $validFrom, validTo: $validTo)';
}


}

/// @nodoc
abstract mixin class _$OfferCopyWith<$Res> implements $OfferCopyWith<$Res> {
  factory _$OfferCopyWith(_Offer value, $Res Function(_Offer) _then) = __$OfferCopyWithImpl;
@override @useResult
$Res call({
 String id, OfferScope scope, String? scopeId, int discountPercent, Set<int> days, int fromMinutes, int toMinutes, PriceTier? tier, DateTime validFrom, DateTime validTo
});




}
/// @nodoc
class __$OfferCopyWithImpl<$Res>
    implements _$OfferCopyWith<$Res> {
  __$OfferCopyWithImpl(this._self, this._then);

  final _Offer _self;
  final $Res Function(_Offer) _then;

/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? scope = null,Object? scopeId = freezed,Object? discountPercent = null,Object? days = null,Object? fromMinutes = null,Object? toMinutes = null,Object? tier = freezed,Object? validFrom = null,Object? validTo = null,}) {
  return _then(_Offer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,scope: null == scope ? _self.scope : scope // ignore: cast_nullable_to_non_nullable
as OfferScope,scopeId: freezed == scopeId ? _self.scopeId : scopeId // ignore: cast_nullable_to_non_nullable
as String?,discountPercent: null == discountPercent ? _self.discountPercent : discountPercent // ignore: cast_nullable_to_non_nullable
as int,days: null == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as Set<int>,fromMinutes: null == fromMinutes ? _self.fromMinutes : fromMinutes // ignore: cast_nullable_to_non_nullable
as int,toMinutes: null == toMinutes ? _self.toMinutes : toMinutes // ignore: cast_nullable_to_non_nullable
as int,tier: freezed == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as PriceTier?,validFrom: null == validFrom ? _self.validFrom : validFrom // ignore: cast_nullable_to_non_nullable
as DateTime,validTo: null == validTo ? _self.validTo : validTo // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
