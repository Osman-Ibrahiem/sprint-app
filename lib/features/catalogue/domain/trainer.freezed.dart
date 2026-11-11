// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Trainer {

 String get id; String get userId; List<String> get facilityIds; String get bio; int get trainerCapacity;
/// Create a copy of Trainer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainerCopyWith<Trainer> get copyWith => _$TrainerCopyWithImpl<Trainer>(this as Trainer, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Trainer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Trainer&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&const DeepCollectionEquality().equals(other.facilityIds, _this.facilityIds)&&(identical(other.bio, _this.bio) || other.bio == _this.bio)&&(identical(other.trainerCapacity, _this.trainerCapacity) || other.trainerCapacity == _this.trainerCapacity));
}


@override
int get hashCode {
  final _this = this as Trainer;
  return Object.hash(runtimeType,_this.id,_this.userId,const DeepCollectionEquality().hash(_this.facilityIds),_this.bio,_this.trainerCapacity);
}

@override
String toString() {
  final _this = this as Trainer;
  return 'Trainer(id: ${_this.id}, userId: ${_this.userId}, facilityIds: ${_this.facilityIds}, bio: ${_this.bio}, trainerCapacity: ${_this.trainerCapacity})';
}


}

/// @nodoc
abstract mixin class $TrainerCopyWith<$Res>  {
  factory $TrainerCopyWith(Trainer value, $Res Function(Trainer) _then) = _$TrainerCopyWithImpl;
@useResult
$Res call({
 String id, String userId, List<String> facilityIds, String bio, int trainerCapacity
});




}
/// @nodoc
class _$TrainerCopyWithImpl<$Res>
    implements $TrainerCopyWith<$Res> {
  _$TrainerCopyWithImpl(this._self, this._then);

  final Trainer _self;
  final $Res Function(Trainer) _then;

/// Create a copy of Trainer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? facilityIds = null,Object? bio = null,Object? trainerCapacity = null,}) {
  return _then(Trainer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,facilityIds: null == facilityIds ? _self.facilityIds : facilityIds // ignore: cast_nullable_to_non_nullable
as List<String>,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,trainerCapacity: null == trainerCapacity ? _self.trainerCapacity : trainerCapacity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Trainer].
extension TrainerPatterns on Trainer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Trainer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Trainer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Trainer value)  $default,){
final _that = this;
switch (_that) {
case _Trainer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Trainer value)?  $default,){
final _that = this;
switch (_that) {
case _Trainer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  List<String> facilityIds,  String bio,  int trainerCapacity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Trainer() when $default != null:
return $default(_that.id,_that.userId,_that.facilityIds,_that.bio,_that.trainerCapacity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  List<String> facilityIds,  String bio,  int trainerCapacity)  $default,) {final _that = this;
switch (_that) {
case _Trainer():
return $default(_that.id,_that.userId,_that.facilityIds,_that.bio,_that.trainerCapacity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  List<String> facilityIds,  String bio,  int trainerCapacity)?  $default,) {final _that = this;
switch (_that) {
case _Trainer() when $default != null:
return $default(_that.id,_that.userId,_that.facilityIds,_that.bio,_that.trainerCapacity);case _:
  return null;

}
}

}

/// @nodoc


class _Trainer implements Trainer {
  const _Trainer({required this.id, required this.userId, required  List<String> facilityIds, required this.bio, required this.trainerCapacity}): _facilityIds = facilityIds;
  

@override final  String id;
@override final  String userId;
 final  List<String> _facilityIds;
@override List<String> get facilityIds {
  if (_facilityIds is EqualUnmodifiableListView) return _facilityIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_facilityIds);
}

@override final  String bio;
@override final  int trainerCapacity;

/// Create a copy of Trainer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainerCopyWith<_Trainer> get copyWith => __$TrainerCopyWithImpl<_Trainer>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Trainer&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other.facilityIds, _facilityIds)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.trainerCapacity, trainerCapacity) || other.trainerCapacity == trainerCapacity));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,const DeepCollectionEquality().hash(_facilityIds),bio,trainerCapacity);
}

@override
String toString() {
    return 'Trainer(id: $id, userId: $userId, facilityIds: $facilityIds, bio: $bio, trainerCapacity: $trainerCapacity)';
}


}

/// @nodoc
abstract mixin class _$TrainerCopyWith<$Res> implements $TrainerCopyWith<$Res> {
  factory _$TrainerCopyWith(_Trainer value, $Res Function(_Trainer) _then) = __$TrainerCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, List<String> facilityIds, String bio, int trainerCapacity
});




}
/// @nodoc
class __$TrainerCopyWithImpl<$Res>
    implements _$TrainerCopyWith<$Res> {
  __$TrainerCopyWithImpl(this._self, this._then);

  final _Trainer _self;
  final $Res Function(_Trainer) _then;

/// Create a copy of Trainer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? facilityIds = null,Object? bio = null,Object? trainerCapacity = null,}) {
  return _then(_Trainer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,facilityIds: null == facilityIds ? _self._facilityIds : facilityIds // ignore: cast_nullable_to_non_nullable
as List<String>,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,trainerCapacity: null == trainerCapacity ? _self.trainerCapacity : trainerCapacity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
