// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sheet_batch.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SheetProblem {

 int get rowNumber; String get reasonCode;
/// Create a copy of SheetProblem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SheetProblemCopyWith<SheetProblem> get copyWith => _$SheetProblemCopyWithImpl<SheetProblem>(this as SheetProblem, _$identity);

  /// Serializes this SheetProblem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SheetProblem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SheetProblem&&(identical(other.rowNumber, _this.rowNumber) || other.rowNumber == _this.rowNumber)&&(identical(other.reasonCode, _this.reasonCode) || other.reasonCode == _this.reasonCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SheetProblem;
  return Object.hash(runtimeType,_this.rowNumber,_this.reasonCode);
}

@override
String toString() {
  final _this = this as SheetProblem;
  return 'SheetProblem(rowNumber: ${_this.rowNumber}, reasonCode: ${_this.reasonCode})';
}


}

/// @nodoc
abstract mixin class $SheetProblemCopyWith<$Res>  {
  factory $SheetProblemCopyWith(SheetProblem value, $Res Function(SheetProblem) _then) = _$SheetProblemCopyWithImpl;
@useResult
$Res call({
 int rowNumber, String reasonCode
});




}
/// @nodoc
class _$SheetProblemCopyWithImpl<$Res>
    implements $SheetProblemCopyWith<$Res> {
  _$SheetProblemCopyWithImpl(this._self, this._then);

  final SheetProblem _self;
  final $Res Function(SheetProblem) _then;

/// Create a copy of SheetProblem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rowNumber = null,Object? reasonCode = null,}) {
  return _then(SheetProblem(
rowNumber: null == rowNumber ? _self.rowNumber : rowNumber // ignore: cast_nullable_to_non_nullable
as int,reasonCode: null == reasonCode ? _self.reasonCode : reasonCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SheetProblem].
extension SheetProblemPatterns on SheetProblem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SheetProblem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SheetProblem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SheetProblem value)  $default,){
final _that = this;
switch (_that) {
case _SheetProblem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SheetProblem value)?  $default,){
final _that = this;
switch (_that) {
case _SheetProblem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rowNumber,  String reasonCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SheetProblem() when $default != null:
return $default(_that.rowNumber,_that.reasonCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rowNumber,  String reasonCode)  $default,) {final _that = this;
switch (_that) {
case _SheetProblem():
return $default(_that.rowNumber,_that.reasonCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rowNumber,  String reasonCode)?  $default,) {final _that = this;
switch (_that) {
case _SheetProblem() when $default != null:
return $default(_that.rowNumber,_that.reasonCode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SheetProblem implements SheetProblem {
  const _SheetProblem({required this.rowNumber, required this.reasonCode});
  factory _SheetProblem.fromJson(Map<String, dynamic> json) => _$SheetProblemFromJson(json);

@override final  int rowNumber;
@override final  String reasonCode;

/// Create a copy of SheetProblem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SheetProblemCopyWith<_SheetProblem> get copyWith => __$SheetProblemCopyWithImpl<_SheetProblem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SheetProblemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SheetProblem&&(identical(other.rowNumber, rowNumber) || other.rowNumber == rowNumber)&&(identical(other.reasonCode, reasonCode) || other.reasonCode == reasonCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,rowNumber,reasonCode);
}

@override
String toString() {
    return 'SheetProblem(rowNumber: $rowNumber, reasonCode: $reasonCode)';
}


}

/// @nodoc
abstract mixin class _$SheetProblemCopyWith<$Res> implements $SheetProblemCopyWith<$Res> {
  factory _$SheetProblemCopyWith(_SheetProblem value, $Res Function(_SheetProblem) _then) = __$SheetProblemCopyWithImpl;
@override @useResult
$Res call({
 int rowNumber, String reasonCode
});




}
/// @nodoc
class __$SheetProblemCopyWithImpl<$Res>
    implements _$SheetProblemCopyWith<$Res> {
  __$SheetProblemCopyWithImpl(this._self, this._then);

  final _SheetProblem _self;
  final $Res Function(_SheetProblem) _then;

/// Create a copy of SheetProblem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rowNumber = null,Object? reasonCode = null,}) {
  return _then(_SheetProblem(
rowNumber: null == rowNumber ? _self.rowNumber : rowNumber // ignore: cast_nullable_to_non_nullable
as int,reasonCode: null == reasonCode ? _self.reasonCode : reasonCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SheetBatch {

 String get id; String get uploadedBy; String get fileName; DateTime get uploadedAt; String? get owningUnitId; int get rowsRead; int get rowsAdded; int get duplicates; int get invalid; int get approved; List<SheetProblem> get problems;
/// Create a copy of SheetBatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SheetBatchCopyWith<SheetBatch> get copyWith => _$SheetBatchCopyWithImpl<SheetBatch>(this as SheetBatch, _$identity);

  /// Serializes this SheetBatch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SheetBatch;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SheetBatch&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.uploadedBy, _this.uploadedBy) || other.uploadedBy == _this.uploadedBy)&&(identical(other.fileName, _this.fileName) || other.fileName == _this.fileName)&&(identical(other.uploadedAt, _this.uploadedAt) || other.uploadedAt == _this.uploadedAt)&&(identical(other.owningUnitId, _this.owningUnitId) || other.owningUnitId == _this.owningUnitId)&&(identical(other.rowsRead, _this.rowsRead) || other.rowsRead == _this.rowsRead)&&(identical(other.rowsAdded, _this.rowsAdded) || other.rowsAdded == _this.rowsAdded)&&(identical(other.duplicates, _this.duplicates) || other.duplicates == _this.duplicates)&&(identical(other.invalid, _this.invalid) || other.invalid == _this.invalid)&&(identical(other.approved, _this.approved) || other.approved == _this.approved)&&const DeepCollectionEquality().equals(other.problems, _this.problems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SheetBatch;
  return Object.hash(runtimeType,_this.id,_this.uploadedBy,_this.fileName,_this.uploadedAt,_this.owningUnitId,_this.rowsRead,_this.rowsAdded,_this.duplicates,_this.invalid,_this.approved,const DeepCollectionEquality().hash(_this.problems));
}

@override
String toString() {
  final _this = this as SheetBatch;
  return 'SheetBatch(id: ${_this.id}, uploadedBy: ${_this.uploadedBy}, fileName: ${_this.fileName}, uploadedAt: ${_this.uploadedAt}, owningUnitId: ${_this.owningUnitId}, rowsRead: ${_this.rowsRead}, rowsAdded: ${_this.rowsAdded}, duplicates: ${_this.duplicates}, invalid: ${_this.invalid}, approved: ${_this.approved}, problems: ${_this.problems})';
}


}

/// @nodoc
abstract mixin class $SheetBatchCopyWith<$Res>  {
  factory $SheetBatchCopyWith(SheetBatch value, $Res Function(SheetBatch) _then) = _$SheetBatchCopyWithImpl;
@useResult
$Res call({
 String id, String uploadedBy, String fileName, DateTime uploadedAt, String? owningUnitId, int rowsRead, int rowsAdded, int duplicates, int invalid, int approved, List<SheetProblem> problems
});




}
/// @nodoc
class _$SheetBatchCopyWithImpl<$Res>
    implements $SheetBatchCopyWith<$Res> {
  _$SheetBatchCopyWithImpl(this._self, this._then);

  final SheetBatch _self;
  final $Res Function(SheetBatch) _then;

/// Create a copy of SheetBatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? uploadedBy = null,Object? fileName = null,Object? uploadedAt = null,Object? owningUnitId = freezed,Object? rowsRead = null,Object? rowsAdded = null,Object? duplicates = null,Object? invalid = null,Object? approved = null,Object? problems = null,}) {
  return _then(SheetBatch(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,uploadedBy: null == uploadedBy ? _self.uploadedBy : uploadedBy // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,uploadedAt: null == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,owningUnitId: freezed == owningUnitId ? _self.owningUnitId : owningUnitId // ignore: cast_nullable_to_non_nullable
as String?,rowsRead: null == rowsRead ? _self.rowsRead : rowsRead // ignore: cast_nullable_to_non_nullable
as int,rowsAdded: null == rowsAdded ? _self.rowsAdded : rowsAdded // ignore: cast_nullable_to_non_nullable
as int,duplicates: null == duplicates ? _self.duplicates : duplicates // ignore: cast_nullable_to_non_nullable
as int,invalid: null == invalid ? _self.invalid : invalid // ignore: cast_nullable_to_non_nullable
as int,approved: null == approved ? _self.approved : approved // ignore: cast_nullable_to_non_nullable
as int,problems: null == problems ? _self.problems : problems // ignore: cast_nullable_to_non_nullable
as List<SheetProblem>,
  ));
}

}


/// Adds pattern-matching-related methods to [SheetBatch].
extension SheetBatchPatterns on SheetBatch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SheetBatch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SheetBatch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SheetBatch value)  $default,){
final _that = this;
switch (_that) {
case _SheetBatch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SheetBatch value)?  $default,){
final _that = this;
switch (_that) {
case _SheetBatch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String uploadedBy,  String fileName,  DateTime uploadedAt,  String? owningUnitId,  int rowsRead,  int rowsAdded,  int duplicates,  int invalid,  int approved,  List<SheetProblem> problems)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SheetBatch() when $default != null:
return $default(_that.id,_that.uploadedBy,_that.fileName,_that.uploadedAt,_that.owningUnitId,_that.rowsRead,_that.rowsAdded,_that.duplicates,_that.invalid,_that.approved,_that.problems);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String uploadedBy,  String fileName,  DateTime uploadedAt,  String? owningUnitId,  int rowsRead,  int rowsAdded,  int duplicates,  int invalid,  int approved,  List<SheetProblem> problems)  $default,) {final _that = this;
switch (_that) {
case _SheetBatch():
return $default(_that.id,_that.uploadedBy,_that.fileName,_that.uploadedAt,_that.owningUnitId,_that.rowsRead,_that.rowsAdded,_that.duplicates,_that.invalid,_that.approved,_that.problems);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String uploadedBy,  String fileName,  DateTime uploadedAt,  String? owningUnitId,  int rowsRead,  int rowsAdded,  int duplicates,  int invalid,  int approved,  List<SheetProblem> problems)?  $default,) {final _that = this;
switch (_that) {
case _SheetBatch() when $default != null:
return $default(_that.id,_that.uploadedBy,_that.fileName,_that.uploadedAt,_that.owningUnitId,_that.rowsRead,_that.rowsAdded,_that.duplicates,_that.invalid,_that.approved,_that.problems);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SheetBatch implements SheetBatch {
  const _SheetBatch({required this.id, required this.uploadedBy, required this.fileName, required this.uploadedAt, this.owningUnitId, this.rowsRead = 0, this.rowsAdded = 0, this.duplicates = 0, this.invalid = 0, this.approved = 0,  List<SheetProblem> problems = const []}): _problems = problems;
  factory _SheetBatch.fromJson(Map<String, dynamic> json) => _$SheetBatchFromJson(json);

@override final  String id;
@override final  String uploadedBy;
@override final  String fileName;
@override final  DateTime uploadedAt;
@override final  String? owningUnitId;
@override@JsonKey() final  int rowsRead;
@override@JsonKey() final  int rowsAdded;
@override@JsonKey() final  int duplicates;
@override@JsonKey() final  int invalid;
@override@JsonKey() final  int approved;
 final  List<SheetProblem> _problems;
@override@JsonKey() List<SheetProblem> get problems {
  if (_problems is EqualUnmodifiableListView) return _problems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_problems);
}


/// Create a copy of SheetBatch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SheetBatchCopyWith<_SheetBatch> get copyWith => __$SheetBatchCopyWithImpl<_SheetBatch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SheetBatchToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SheetBatch&&(identical(other.id, id) || other.id == id)&&(identical(other.uploadedBy, uploadedBy) || other.uploadedBy == uploadedBy)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.uploadedAt, uploadedAt) || other.uploadedAt == uploadedAt)&&(identical(other.owningUnitId, owningUnitId) || other.owningUnitId == owningUnitId)&&(identical(other.rowsRead, rowsRead) || other.rowsRead == rowsRead)&&(identical(other.rowsAdded, rowsAdded) || other.rowsAdded == rowsAdded)&&(identical(other.duplicates, duplicates) || other.duplicates == duplicates)&&(identical(other.invalid, invalid) || other.invalid == invalid)&&(identical(other.approved, approved) || other.approved == approved)&&const DeepCollectionEquality().equals(other.problems, _problems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,uploadedBy,fileName,uploadedAt,owningUnitId,rowsRead,rowsAdded,duplicates,invalid,approved,const DeepCollectionEquality().hash(_problems));
}

@override
String toString() {
    return 'SheetBatch(id: $id, uploadedBy: $uploadedBy, fileName: $fileName, uploadedAt: $uploadedAt, owningUnitId: $owningUnitId, rowsRead: $rowsRead, rowsAdded: $rowsAdded, duplicates: $duplicates, invalid: $invalid, approved: $approved, problems: $problems)';
}


}

/// @nodoc
abstract mixin class _$SheetBatchCopyWith<$Res> implements $SheetBatchCopyWith<$Res> {
  factory _$SheetBatchCopyWith(_SheetBatch value, $Res Function(_SheetBatch) _then) = __$SheetBatchCopyWithImpl;
@override @useResult
$Res call({
 String id, String uploadedBy, String fileName, DateTime uploadedAt, String? owningUnitId, int rowsRead, int rowsAdded, int duplicates, int invalid, int approved, List<SheetProblem> problems
});




}
/// @nodoc
class __$SheetBatchCopyWithImpl<$Res>
    implements _$SheetBatchCopyWith<$Res> {
  __$SheetBatchCopyWithImpl(this._self, this._then);

  final _SheetBatch _self;
  final $Res Function(_SheetBatch) _then;

/// Create a copy of SheetBatch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? uploadedBy = null,Object? fileName = null,Object? uploadedAt = null,Object? owningUnitId = freezed,Object? rowsRead = null,Object? rowsAdded = null,Object? duplicates = null,Object? invalid = null,Object? approved = null,Object? problems = null,}) {
  return _then(_SheetBatch(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,uploadedBy: null == uploadedBy ? _self.uploadedBy : uploadedBy // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,uploadedAt: null == uploadedAt ? _self.uploadedAt : uploadedAt // ignore: cast_nullable_to_non_nullable
as DateTime,owningUnitId: freezed == owningUnitId ? _self.owningUnitId : owningUnitId // ignore: cast_nullable_to_non_nullable
as String?,rowsRead: null == rowsRead ? _self.rowsRead : rowsRead // ignore: cast_nullable_to_non_nullable
as int,rowsAdded: null == rowsAdded ? _self.rowsAdded : rowsAdded // ignore: cast_nullable_to_non_nullable
as int,duplicates: null == duplicates ? _self.duplicates : duplicates // ignore: cast_nullable_to_non_nullable
as int,invalid: null == invalid ? _self.invalid : invalid // ignore: cast_nullable_to_non_nullable
as int,approved: null == approved ? _self.approved : approved // ignore: cast_nullable_to_non_nullable
as int,problems: null == problems ? _self._problems : problems // ignore: cast_nullable_to_non_nullable
as List<SheetProblem>,
  ));
}


}

// dart format on
