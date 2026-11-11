// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'facility.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Facility {

 String get id; String get owningUnitId; String get name; FacilityType get type; String get description; List<String> get photos; String get location; bool get isFree; bool get requiresTrainer; bool get isPublished;
/// Create a copy of Facility
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FacilityCopyWith<Facility> get copyWith => _$FacilityCopyWithImpl<Facility>(this as Facility, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Facility;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Facility&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.owningUnitId, _this.owningUnitId) || other.owningUnitId == _this.owningUnitId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.description, _this.description) || other.description == _this.description)&&const DeepCollectionEquality().equals(other.photos, _this.photos)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.isFree, _this.isFree) || other.isFree == _this.isFree)&&(identical(other.requiresTrainer, _this.requiresTrainer) || other.requiresTrainer == _this.requiresTrainer)&&(identical(other.isPublished, _this.isPublished) || other.isPublished == _this.isPublished));
}


@override
int get hashCode {
  final _this = this as Facility;
  return Object.hash(runtimeType,_this.id,_this.owningUnitId,_this.name,_this.type,_this.description,const DeepCollectionEquality().hash(_this.photos),_this.location,_this.isFree,_this.requiresTrainer,_this.isPublished);
}

@override
String toString() {
  final _this = this as Facility;
  return 'Facility(id: ${_this.id}, owningUnitId: ${_this.owningUnitId}, name: ${_this.name}, type: ${_this.type}, description: ${_this.description}, photos: ${_this.photos}, location: ${_this.location}, isFree: ${_this.isFree}, requiresTrainer: ${_this.requiresTrainer}, isPublished: ${_this.isPublished})';
}


}

/// @nodoc
abstract mixin class $FacilityCopyWith<$Res>  {
  factory $FacilityCopyWith(Facility value, $Res Function(Facility) _then) = _$FacilityCopyWithImpl;
@useResult
$Res call({
 String id, String owningUnitId, String name, FacilityType type, String description, List<String> photos, String location, bool isFree, bool requiresTrainer, bool isPublished
});




}
/// @nodoc
class _$FacilityCopyWithImpl<$Res>
    implements $FacilityCopyWith<$Res> {
  _$FacilityCopyWithImpl(this._self, this._then);

  final Facility _self;
  final $Res Function(Facility) _then;

/// Create a copy of Facility
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? owningUnitId = null,Object? name = null,Object? type = null,Object? description = null,Object? photos = null,Object? location = null,Object? isFree = null,Object? requiresTrainer = null,Object? isPublished = null,}) {
  return _then(Facility(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,owningUnitId: null == owningUnitId ? _self.owningUnitId : owningUnitId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FacilityType,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<String>,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,isFree: null == isFree ? _self.isFree : isFree // ignore: cast_nullable_to_non_nullable
as bool,requiresTrainer: null == requiresTrainer ? _self.requiresTrainer : requiresTrainer // ignore: cast_nullable_to_non_nullable
as bool,isPublished: null == isPublished ? _self.isPublished : isPublished // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Facility].
extension FacilityPatterns on Facility {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Facility value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Facility() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Facility value)  $default,){
final _that = this;
switch (_that) {
case _Facility():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Facility value)?  $default,){
final _that = this;
switch (_that) {
case _Facility() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String owningUnitId,  String name,  FacilityType type,  String description,  List<String> photos,  String location,  bool isFree,  bool requiresTrainer,  bool isPublished)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Facility() when $default != null:
return $default(_that.id,_that.owningUnitId,_that.name,_that.type,_that.description,_that.photos,_that.location,_that.isFree,_that.requiresTrainer,_that.isPublished);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String owningUnitId,  String name,  FacilityType type,  String description,  List<String> photos,  String location,  bool isFree,  bool requiresTrainer,  bool isPublished)  $default,) {final _that = this;
switch (_that) {
case _Facility():
return $default(_that.id,_that.owningUnitId,_that.name,_that.type,_that.description,_that.photos,_that.location,_that.isFree,_that.requiresTrainer,_that.isPublished);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String owningUnitId,  String name,  FacilityType type,  String description,  List<String> photos,  String location,  bool isFree,  bool requiresTrainer,  bool isPublished)?  $default,) {final _that = this;
switch (_that) {
case _Facility() when $default != null:
return $default(_that.id,_that.owningUnitId,_that.name,_that.type,_that.description,_that.photos,_that.location,_that.isFree,_that.requiresTrainer,_that.isPublished);case _:
  return null;

}
}

}

/// @nodoc


class _Facility implements Facility {
  const _Facility({required this.id, required this.owningUnitId, required this.name, required this.type, required this.description,  List<String> photos = const <String>[], required this.location, required this.isFree, required this.requiresTrainer, this.isPublished = true}): _photos = photos;
  

@override final  String id;
@override final  String owningUnitId;
@override final  String name;
@override final  FacilityType type;
@override final  String description;
 final  List<String> _photos;
@override@JsonKey() List<String> get photos {
  if (_photos is EqualUnmodifiableListView) return _photos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photos);
}

@override final  String location;
@override final  bool isFree;
@override final  bool requiresTrainer;
@override@JsonKey() final  bool isPublished;

/// Create a copy of Facility
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FacilityCopyWith<_Facility> get copyWith => __$FacilityCopyWithImpl<_Facility>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Facility&&(identical(other.id, id) || other.id == id)&&(identical(other.owningUnitId, owningUnitId) || other.owningUnitId == owningUnitId)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.photos, _photos)&&(identical(other.location, location) || other.location == location)&&(identical(other.isFree, isFree) || other.isFree == isFree)&&(identical(other.requiresTrainer, requiresTrainer) || other.requiresTrainer == requiresTrainer)&&(identical(other.isPublished, isPublished) || other.isPublished == isPublished));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,owningUnitId,name,type,description,const DeepCollectionEquality().hash(_photos),location,isFree,requiresTrainer,isPublished);
}

@override
String toString() {
    return 'Facility(id: $id, owningUnitId: $owningUnitId, name: $name, type: $type, description: $description, photos: $photos, location: $location, isFree: $isFree, requiresTrainer: $requiresTrainer, isPublished: $isPublished)';
}


}

/// @nodoc
abstract mixin class _$FacilityCopyWith<$Res> implements $FacilityCopyWith<$Res> {
  factory _$FacilityCopyWith(_Facility value, $Res Function(_Facility) _then) = __$FacilityCopyWithImpl;
@override @useResult
$Res call({
 String id, String owningUnitId, String name, FacilityType type, String description, List<String> photos, String location, bool isFree, bool requiresTrainer, bool isPublished
});




}
/// @nodoc
class __$FacilityCopyWithImpl<$Res>
    implements _$FacilityCopyWith<$Res> {
  __$FacilityCopyWithImpl(this._self, this._then);

  final _Facility _self;
  final $Res Function(_Facility) _then;

/// Create a copy of Facility
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? owningUnitId = null,Object? name = null,Object? type = null,Object? description = null,Object? photos = null,Object? location = null,Object? isFree = null,Object? requiresTrainer = null,Object? isPublished = null,}) {
  return _then(_Facility(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,owningUnitId: null == owningUnitId ? _self.owningUnitId : owningUnitId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FacilityType,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,photos: null == photos ? _self._photos : photos // ignore: cast_nullable_to_non_nullable
as List<String>,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,isFree: null == isFree ? _self.isFree : isFree // ignore: cast_nullable_to_non_nullable
as bool,requiresTrainer: null == requiresTrainer ? _self.requiresTrainer : requiresTrainer // ignore: cast_nullable_to_non_nullable
as bool,isPublished: null == isPublished ? _self.isPublished : isPublished // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
