// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'damage_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DamageReport {

 String get id; String get assetId; String get reportedBy; String get description; List<String> get photos; DamageReportStatus get status; String? get linkedClosureId;
/// Create a copy of DamageReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DamageReportCopyWith<DamageReport> get copyWith => _$DamageReportCopyWithImpl<DamageReport>(this as DamageReport, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DamageReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DamageReport&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.assetId, _this.assetId) || other.assetId == _this.assetId)&&(identical(other.reportedBy, _this.reportedBy) || other.reportedBy == _this.reportedBy)&&(identical(other.description, _this.description) || other.description == _this.description)&&const DeepCollectionEquality().equals(other.photos, _this.photos)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.linkedClosureId, _this.linkedClosureId) || other.linkedClosureId == _this.linkedClosureId));
}


@override
int get hashCode {
  final _this = this as DamageReport;
  return Object.hash(runtimeType,_this.id,_this.assetId,_this.reportedBy,_this.description,const DeepCollectionEquality().hash(_this.photos),_this.status,_this.linkedClosureId);
}

@override
String toString() {
  final _this = this as DamageReport;
  return 'DamageReport(id: ${_this.id}, assetId: ${_this.assetId}, reportedBy: ${_this.reportedBy}, description: ${_this.description}, photos: ${_this.photos}, status: ${_this.status}, linkedClosureId: ${_this.linkedClosureId})';
}


}

/// @nodoc
abstract mixin class $DamageReportCopyWith<$Res>  {
  factory $DamageReportCopyWith(DamageReport value, $Res Function(DamageReport) _then) = _$DamageReportCopyWithImpl;
@useResult
$Res call({
 String id, String assetId, String reportedBy, String description, List<String> photos, DamageReportStatus status, String? linkedClosureId
});




}
/// @nodoc
class _$DamageReportCopyWithImpl<$Res>
    implements $DamageReportCopyWith<$Res> {
  _$DamageReportCopyWithImpl(this._self, this._then);

  final DamageReport _self;
  final $Res Function(DamageReport) _then;

/// Create a copy of DamageReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? assetId = null,Object? reportedBy = null,Object? description = null,Object? photos = null,Object? status = null,Object? linkedClosureId = freezed,}) {
  return _then(DamageReport(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,assetId: null == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as String,reportedBy: null == reportedBy ? _self.reportedBy : reportedBy // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DamageReportStatus,linkedClosureId: freezed == linkedClosureId ? _self.linkedClosureId : linkedClosureId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DamageReport].
extension DamageReportPatterns on DamageReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DamageReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DamageReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DamageReport value)  $default,){
final _that = this;
switch (_that) {
case _DamageReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DamageReport value)?  $default,){
final _that = this;
switch (_that) {
case _DamageReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String assetId,  String reportedBy,  String description,  List<String> photos,  DamageReportStatus status,  String? linkedClosureId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DamageReport() when $default != null:
return $default(_that.id,_that.assetId,_that.reportedBy,_that.description,_that.photos,_that.status,_that.linkedClosureId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String assetId,  String reportedBy,  String description,  List<String> photos,  DamageReportStatus status,  String? linkedClosureId)  $default,) {final _that = this;
switch (_that) {
case _DamageReport():
return $default(_that.id,_that.assetId,_that.reportedBy,_that.description,_that.photos,_that.status,_that.linkedClosureId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String assetId,  String reportedBy,  String description,  List<String> photos,  DamageReportStatus status,  String? linkedClosureId)?  $default,) {final _that = this;
switch (_that) {
case _DamageReport() when $default != null:
return $default(_that.id,_that.assetId,_that.reportedBy,_that.description,_that.photos,_that.status,_that.linkedClosureId);case _:
  return null;

}
}

}

/// @nodoc


class _DamageReport implements DamageReport {
  const _DamageReport({required this.id, required this.assetId, required this.reportedBy, required this.description,  List<String> photos = const <String>[], required this.status, this.linkedClosureId}): _photos = photos;
  

@override final  String id;
@override final  String assetId;
@override final  String reportedBy;
@override final  String description;
 final  List<String> _photos;
@override@JsonKey() List<String> get photos {
  if (_photos is EqualUnmodifiableListView) return _photos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photos);
}

@override final  DamageReportStatus status;
@override final  String? linkedClosureId;

/// Create a copy of DamageReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DamageReportCopyWith<_DamageReport> get copyWith => __$DamageReportCopyWithImpl<_DamageReport>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DamageReport&&(identical(other.id, id) || other.id == id)&&(identical(other.assetId, assetId) || other.assetId == assetId)&&(identical(other.reportedBy, reportedBy) || other.reportedBy == reportedBy)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.photos, _photos)&&(identical(other.status, status) || other.status == status)&&(identical(other.linkedClosureId, linkedClosureId) || other.linkedClosureId == linkedClosureId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,assetId,reportedBy,description,const DeepCollectionEquality().hash(_photos),status,linkedClosureId);
}

@override
String toString() {
    return 'DamageReport(id: $id, assetId: $assetId, reportedBy: $reportedBy, description: $description, photos: $photos, status: $status, linkedClosureId: $linkedClosureId)';
}


}

/// @nodoc
abstract mixin class _$DamageReportCopyWith<$Res> implements $DamageReportCopyWith<$Res> {
  factory _$DamageReportCopyWith(_DamageReport value, $Res Function(_DamageReport) _then) = __$DamageReportCopyWithImpl;
@override @useResult
$Res call({
 String id, String assetId, String reportedBy, String description, List<String> photos, DamageReportStatus status, String? linkedClosureId
});




}
/// @nodoc
class __$DamageReportCopyWithImpl<$Res>
    implements _$DamageReportCopyWith<$Res> {
  __$DamageReportCopyWithImpl(this._self, this._then);

  final _DamageReport _self;
  final $Res Function(_DamageReport) _then;

/// Create a copy of DamageReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? assetId = null,Object? reportedBy = null,Object? description = null,Object? photos = null,Object? status = null,Object? linkedClosureId = freezed,}) {
  return _then(_DamageReport(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,assetId: null == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as String,reportedBy: null == reportedBy ? _self.reportedBy : reportedBy // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,photos: null == photos ? _self._photos : photos // ignore: cast_nullable_to_non_nullable
as List<String>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DamageReportStatus,linkedClosureId: freezed == linkedClosureId ? _self.linkedClosureId : linkedClosureId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
