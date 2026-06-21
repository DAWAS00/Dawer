// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_proof.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OrderProof _$OrderProofFromJson(Map<String, dynamic> json) {
  return _OrderProof.fromJson(json);
}

/// @nodoc
mixin _$OrderProof {
  String get imagePath => throw _privateConstructorUsedError;
  DateTime get capturedAt => throw _privateConstructorUsedError;
  double get lat => throw _privateConstructorUsedError;
  double get lng => throw _privateConstructorUsedError;
  String get checksum => throw _privateConstructorUsedError;

  /// Serializes this OrderProof to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderProof
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderProofCopyWith<OrderProof> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderProofCopyWith<$Res> {
  factory $OrderProofCopyWith(
    OrderProof value,
    $Res Function(OrderProof) then,
  ) = _$OrderProofCopyWithImpl<$Res, OrderProof>;
  @useResult
  $Res call({
    String imagePath,
    DateTime capturedAt,
    double lat,
    double lng,
    String checksum,
  });
}

/// @nodoc
class _$OrderProofCopyWithImpl<$Res, $Val extends OrderProof>
    implements $OrderProofCopyWith<$Res> {
  _$OrderProofCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderProof
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imagePath = null,
    Object? capturedAt = null,
    Object? lat = null,
    Object? lng = null,
    Object? checksum = null,
  }) {
    return _then(
      _value.copyWith(
            imagePath: null == imagePath
                ? _value.imagePath
                : imagePath // ignore: cast_nullable_to_non_nullable
                      as String,
            capturedAt: null == capturedAt
                ? _value.capturedAt
                : capturedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lat: null == lat
                ? _value.lat
                : lat // ignore: cast_nullable_to_non_nullable
                      as double,
            lng: null == lng
                ? _value.lng
                : lng // ignore: cast_nullable_to_non_nullable
                      as double,
            checksum: null == checksum
                ? _value.checksum
                : checksum // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrderProofImplCopyWith<$Res>
    implements $OrderProofCopyWith<$Res> {
  factory _$$OrderProofImplCopyWith(
    _$OrderProofImpl value,
    $Res Function(_$OrderProofImpl) then,
  ) = __$$OrderProofImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String imagePath,
    DateTime capturedAt,
    double lat,
    double lng,
    String checksum,
  });
}

/// @nodoc
class __$$OrderProofImplCopyWithImpl<$Res>
    extends _$OrderProofCopyWithImpl<$Res, _$OrderProofImpl>
    implements _$$OrderProofImplCopyWith<$Res> {
  __$$OrderProofImplCopyWithImpl(
    _$OrderProofImpl _value,
    $Res Function(_$OrderProofImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderProof
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imagePath = null,
    Object? capturedAt = null,
    Object? lat = null,
    Object? lng = null,
    Object? checksum = null,
  }) {
    return _then(
      _$OrderProofImpl(
        imagePath: null == imagePath
            ? _value.imagePath
            : imagePath // ignore: cast_nullable_to_non_nullable
                  as String,
        capturedAt: null == capturedAt
            ? _value.capturedAt
            : capturedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lat: null == lat
            ? _value.lat
            : lat // ignore: cast_nullable_to_non_nullable
                  as double,
        lng: null == lng
            ? _value.lng
            : lng // ignore: cast_nullable_to_non_nullable
                  as double,
        checksum: null == checksum
            ? _value.checksum
            : checksum // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderProofImpl implements _OrderProof {
  const _$OrderProofImpl({
    required this.imagePath,
    required this.capturedAt,
    required this.lat,
    required this.lng,
    required this.checksum,
  });

  factory _$OrderProofImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderProofImplFromJson(json);

  @override
  final String imagePath;
  @override
  final DateTime capturedAt;
  @override
  final double lat;
  @override
  final double lng;
  @override
  final String checksum;

  @override
  String toString() {
    return 'OrderProof(imagePath: $imagePath, capturedAt: $capturedAt, lat: $lat, lng: $lng, checksum: $checksum)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderProofImpl &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.capturedAt, capturedAt) ||
                other.capturedAt == capturedAt) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.checksum, checksum) ||
                other.checksum == checksum));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, imagePath, capturedAt, lat, lng, checksum);

  /// Create a copy of OrderProof
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderProofImplCopyWith<_$OrderProofImpl> get copyWith =>
      __$$OrderProofImplCopyWithImpl<_$OrderProofImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderProofImplToJson(this);
  }
}

abstract class _OrderProof implements OrderProof {
  const factory _OrderProof({
    required final String imagePath,
    required final DateTime capturedAt,
    required final double lat,
    required final double lng,
    required final String checksum,
  }) = _$OrderProofImpl;

  factory _OrderProof.fromJson(Map<String, dynamic> json) =
      _$OrderProofImpl.fromJson;

  @override
  String get imagePath;
  @override
  DateTime get capturedAt;
  @override
  double get lat;
  @override
  double get lng;
  @override
  String get checksum;

  /// Create a copy of OrderProof
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderProofImplCopyWith<_$OrderProofImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
