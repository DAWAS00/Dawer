// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ReportRequest _$ReportRequestFromJson(Map<String, dynamic> json) {
  return _ReportRequest.fromJson(json);
}

/// @nodoc
mixin _$ReportRequest {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  ReportTemplate get template => throw _privateConstructorUsedError;
  DateTime get requestedAt => throw _privateConstructorUsedError;
  DateTime get periodStart => throw _privateConstructorUsedError;
  DateTime get periodEnd => throw _privateConstructorUsedError;
  ReportStatus get status => throw _privateConstructorUsedError;
  String? get downloadUrl => throw _privateConstructorUsedError;

  /// Serializes this ReportRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReportRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportRequestCopyWith<ReportRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportRequestCopyWith<$Res> {
  factory $ReportRequestCopyWith(
    ReportRequest value,
    $Res Function(ReportRequest) then,
  ) = _$ReportRequestCopyWithImpl<$Res, ReportRequest>;
  @useResult
  $Res call({
    String id,
    String userId,
    ReportTemplate template,
    DateTime requestedAt,
    DateTime periodStart,
    DateTime periodEnd,
    ReportStatus status,
    String? downloadUrl,
  });
}

/// @nodoc
class _$ReportRequestCopyWithImpl<$Res, $Val extends ReportRequest>
    implements $ReportRequestCopyWith<$Res> {
  _$ReportRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReportRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? template = null,
    Object? requestedAt = null,
    Object? periodStart = null,
    Object? periodEnd = null,
    Object? status = null,
    Object? downloadUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            template: null == template
                ? _value.template
                : template // ignore: cast_nullable_to_non_nullable
                      as ReportTemplate,
            requestedAt: null == requestedAt
                ? _value.requestedAt
                : requestedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            periodStart: null == periodStart
                ? _value.periodStart
                : periodStart // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            periodEnd: null == periodEnd
                ? _value.periodEnd
                : periodEnd // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ReportStatus,
            downloadUrl: freezed == downloadUrl
                ? _value.downloadUrl
                : downloadUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReportRequestImplCopyWith<$Res>
    implements $ReportRequestCopyWith<$Res> {
  factory _$$ReportRequestImplCopyWith(
    _$ReportRequestImpl value,
    $Res Function(_$ReportRequestImpl) then,
  ) = __$$ReportRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    ReportTemplate template,
    DateTime requestedAt,
    DateTime periodStart,
    DateTime periodEnd,
    ReportStatus status,
    String? downloadUrl,
  });
}

/// @nodoc
class __$$ReportRequestImplCopyWithImpl<$Res>
    extends _$ReportRequestCopyWithImpl<$Res, _$ReportRequestImpl>
    implements _$$ReportRequestImplCopyWith<$Res> {
  __$$ReportRequestImplCopyWithImpl(
    _$ReportRequestImpl _value,
    $Res Function(_$ReportRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReportRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? template = null,
    Object? requestedAt = null,
    Object? periodStart = null,
    Object? periodEnd = null,
    Object? status = null,
    Object? downloadUrl = freezed,
  }) {
    return _then(
      _$ReportRequestImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        template: null == template
            ? _value.template
            : template // ignore: cast_nullable_to_non_nullable
                  as ReportTemplate,
        requestedAt: null == requestedAt
            ? _value.requestedAt
            : requestedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        periodStart: null == periodStart
            ? _value.periodStart
            : periodStart // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        periodEnd: null == periodEnd
            ? _value.periodEnd
            : periodEnd // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ReportStatus,
        downloadUrl: freezed == downloadUrl
            ? _value.downloadUrl
            : downloadUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReportRequestImpl implements _ReportRequest {
  const _$ReportRequestImpl({
    required this.id,
    required this.userId,
    required this.template,
    required this.requestedAt,
    required this.periodStart,
    required this.periodEnd,
    this.status = ReportStatus.pending,
    this.downloadUrl,
  });

  factory _$ReportRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReportRequestImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final ReportTemplate template;
  @override
  final DateTime requestedAt;
  @override
  final DateTime periodStart;
  @override
  final DateTime periodEnd;
  @override
  @JsonKey()
  final ReportStatus status;
  @override
  final String? downloadUrl;

  @override
  String toString() {
    return 'ReportRequest(id: $id, userId: $userId, template: $template, requestedAt: $requestedAt, periodStart: $periodStart, periodEnd: $periodEnd, status: $status, downloadUrl: $downloadUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.template, template) ||
                other.template == template) &&
            (identical(other.requestedAt, requestedAt) ||
                other.requestedAt == requestedAt) &&
            (identical(other.periodStart, periodStart) ||
                other.periodStart == periodStart) &&
            (identical(other.periodEnd, periodEnd) ||
                other.periodEnd == periodEnd) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.downloadUrl, downloadUrl) ||
                other.downloadUrl == downloadUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    template,
    requestedAt,
    periodStart,
    periodEnd,
    status,
    downloadUrl,
  );

  /// Create a copy of ReportRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportRequestImplCopyWith<_$ReportRequestImpl> get copyWith =>
      __$$ReportRequestImplCopyWithImpl<_$ReportRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReportRequestImplToJson(this);
  }
}

abstract class _ReportRequest implements ReportRequest {
  const factory _ReportRequest({
    required final String id,
    required final String userId,
    required final ReportTemplate template,
    required final DateTime requestedAt,
    required final DateTime periodStart,
    required final DateTime periodEnd,
    final ReportStatus status,
    final String? downloadUrl,
  }) = _$ReportRequestImpl;

  factory _ReportRequest.fromJson(Map<String, dynamic> json) =
      _$ReportRequestImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  ReportTemplate get template;
  @override
  DateTime get requestedAt;
  @override
  DateTime get periodStart;
  @override
  DateTime get periodEnd;
  @override
  ReportStatus get status;
  @override
  String? get downloadUrl;

  /// Create a copy of ReportRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportRequestImplCopyWith<_$ReportRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
