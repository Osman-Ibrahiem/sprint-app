// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sheet_row.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SheetRow {

 String get nationalId; String get code; VerificationType get type; String get uploadedBy; String get batchId; String? get owningUnitId;
/// Create a copy of SheetRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SheetRowCopyWith<SheetRow> get copyWith => _$SheetRowCopyWithImpl<SheetRow>(this as SheetRow, _$identity);

  /// Serializes this SheetRow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SheetRow;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SheetRow&&(identical(other.nationalId, _this.nationalId) || other.nationalId == _this.nationalId)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.uploadedBy, _this.uploadedBy) || other.uploadedBy == _this.uploadedBy)&&(identical(other.batchId, _this.batchId) || other.batchId == _this.batchId)&&(identical(other.owningUnitId, _this.owningUnitId) || other.owningUnitId == _this.owningUnitId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SheetRow;
  return Object.hash(runtimeType,_this.nationalId,_this.code,_this.type,_this.uploadedBy,_this.batchId,_this.owningUnitId);
}

@override
String toString() {
  final _this = this as SheetRow;
  return 'SheetRow(nationalId: ${_this.nationalId}, code: ${_this.code}, type: ${_this.type}, uploadedBy: ${_this.uploadedBy}, batchId: ${_this.batchId}, owningUnitId: ${_this.owningUnitId})';
}


}

/// @nodoc
abstract mixin class $SheetRowCopyWith<$Res>  {
  factory $SheetRowCopyWith(SheetRow value, $Res Function(SheetRow) _then) = _$SheetRowCopyWithImpl;
@useResult
$Res call({
 String nationalId, String code, VerificationType type, String uploadedBy, String batchId, String? owningUnitId
});




}
/// @nodoc
class _$SheetRowCopyWithImpl<$Res>
    implements $SheetRowCopyWith<$Res> {
  _$SheetRowCopyWithImpl(this._self, this._then);

  final SheetRow _self;
  final $Res Function(SheetRow) _then;

/// Create a copy of SheetRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nationalId = null,Object? code = null,Object? type = null,Object? uploadedBy = null,Object? batchId = null,Object? owningUnitId = freezed,}) {
  return _then(SheetRow(
nationalId: null == nationalId ? _self.nationalId : nationalId // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as VerificationType,uploadedBy: null == uploadedBy ? _self.uploadedBy : uploadedBy // ignore: cast_nullable_to_non_nullable
as String,batchId: null == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as String,owningUnitId: freezed == owningUnitId ? _self.owningUnitId : owningUnitId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SheetRow].
extension SheetRowPatterns on SheetRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SheetRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SheetRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SheetRow value)  $default,){
final _that = this;
switch (_that) {
case _SheetRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SheetRow value)?  $default,){
final _that = this;
switch (_that) {
case _SheetRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String nationalId,  String code,  VerificationType type,  String uploadedBy,  String batchId,  String? owningUnitId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SheetRow() when $default != null:
return $default(_that.nationalId,_that.code,_that.type,_that.uploadedBy,_that.batchId,_that.owningUnitId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String nationalId,  String code,  VerificationType type,  String uploadedBy,  String batchId,  String? owningUnitId)  $default,) {final _that = this;
switch (_that) {
case _SheetRow():
return $default(_that.nationalId,_that.code,_that.type,_that.uploadedBy,_that.batchId,_that.owningUnitId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String nationalId,  String code,  VerificationType type,  String uploadedBy,  String batchId,  String? owningUnitId)?  $default,) {final _that = this;
switch (_that) {
case _SheetRow() when $default != null:
return $default(_that.nationalId,_that.code,_that.type,_that.uploadedBy,_that.batchId,_that.owningUnitId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SheetRow implements SheetRow {
  const _SheetRow({required this.nationalId, required this.code, required this.type, required this.uploadedBy, required this.batchId, this.owningUnitId});
  factory _SheetRow.fromJson(Map<String, dynamic> json) => _$SheetRowFromJson(json);

@override final  String nationalId;
@override final  String code;
@override final  VerificationType type;
@override final  String uploadedBy;
@override final  String batchId;
@override final  String? owningUnitId;

/// Create a copy of SheetRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SheetRowCopyWith<_SheetRow> get copyWith => __$SheetRowCopyWithImpl<_SheetRow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SheetRowToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SheetRow&&(identical(other.nationalId, nationalId) || other.nationalId == nationalId)&&(identical(other.code, code) || other.code == code)&&(identical(other.type, type) || other.type == type)&&(identical(other.uploadedBy, uploadedBy) || other.uploadedBy == uploadedBy)&&(identical(other.batchId, batchId) || other.batchId == batchId)&&(identical(other.owningUnitId, owningUnitId) || other.owningUnitId == owningUnitId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,nationalId,code,type,uploadedBy,batchId,owningUnitId);
}

@override
String toString() {
    return 'SheetRow(nationalId: $nationalId, code: $code, type: $type, uploadedBy: $uploadedBy, batchId: $batchId, owningUnitId: $owningUnitId)';
}


}

/// @nodoc
abstract mixin class _$SheetRowCopyWith<$Res> implements $SheetRowCopyWith<$Res> {
  factory _$SheetRowCopyWith(_SheetRow value, $Res Function(_SheetRow) _then) = __$SheetRowCopyWithImpl;
@override @useResult
$Res call({
 String nationalId, String code, VerificationType type, String uploadedBy, String batchId, String? owningUnitId
});




}
/// @nodoc
class __$SheetRowCopyWithImpl<$Res>
    implements _$SheetRowCopyWith<$Res> {
  __$SheetRowCopyWithImpl(this._self, this._then);

  final _SheetRow _self;
  final $Res Function(_SheetRow) _then;

/// Create a copy of SheetRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nationalId = null,Object? code = null,Object? type = null,Object? uploadedBy = null,Object? batchId = null,Object? owningUnitId = freezed,}) {
  return _then(_SheetRow(
nationalId: null == nationalId ? _self.nationalId : nationalId // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as VerificationType,uploadedBy: null == uploadedBy ? _self.uploadedBy : uploadedBy // ignore: cast_nullable_to_non_nullable
as String,batchId: null == batchId ? _self.batchId : batchId // ignore: cast_nullable_to_non_nullable
as String,owningUnitId: freezed == owningUnitId ? _self.owningUnitId : owningUnitId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
