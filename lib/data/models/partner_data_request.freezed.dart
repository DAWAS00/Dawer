// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'partner_data_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PartnerDataRequest _$PartnerDataRequestFromJson(Map<String, dynamic> json) {
  return _PartnerDataRequest.fromJson(json);
}

/// @nodoc
mixin _$PartnerDataRequest {
  String get id => throw _privateConstructorUsedError;
  String get companyName => throw _privateConstructorUsedError;
  String get contactName => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  PartnerDataRequestStatus get status => throw _privateConstructorUsedError;
  DateTime get requestedAt => throw _privateConstructorUsedError;

  /// Serializes this PartnerDataRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PartnerDataRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PartnerDataRequestCopyWith<PartnerDataRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PartnerDataRequestCopyWith<$Res> {
  factory $PartnerDataRequestCopyWith(
    PartnerDataRequest value,
    $Res Function(PartnerDataRequest) then,
  ) = _$PartnerDataRequestCopyWithImpl<$Res, PartnerDataRequest>;
  @useResult
  $Res call({
    String id,
    String companyName,
    String contactName,
    String email,
    String? phone,
    String message,
    PartnerDataRequestStatus status,
    DateTime requestedAt,
  });
}

/// @nodoc
class _$PartnerDataRequestCopyWithImpl<$Res, $Val extends PartnerDataRequest>
    implements $PartnerDataRequestCopyWith<$Res> {
  _$PartnerDataRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PartnerDataRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyName = null,
    Object? contactName = null,
    Object? email = null,
    Object? phone = freezed,
    Object? message = null,
    Object? status = null,
    Object? requestedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            companyName: null == companyName
                ? _value.companyName
                : companyName // ignore: cast_nullable_to_non_nullable
                      as String,
            contactName: null == contactName
                ? _value.contactName
                : contactName // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as PartnerDataRequestStatus,
            requestedAt: null == requestedAt
                ? _value.requestedAt
                : requestedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PartnerDataRequestImplCopyWith<$Res>
    implements $PartnerDataRequestCopyWith<$Res> {
  factory _$$PartnerDataRequestImplCopyWith(
    _$PartnerDataRequestImpl value,
    $Res Function(_$PartnerDataRequestImpl) then,
  ) = __$$PartnerDataRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String companyName,
    String contactName,
    String email,
    String? phone,
    String message,
    PartnerDataRequestStatus status,
    DateTime requestedAt,
  });
}

/// @nodoc
class __$$PartnerDataRequestImplCopyWithImpl<$Res>
    extends _$PartnerDataRequestCopyWithImpl<$Res, _$PartnerDataRequestImpl>
    implements _$$PartnerDataRequestImplCopyWith<$Res> {
  __$$PartnerDataRequestImplCopyWithImpl(
    _$PartnerDataRequestImpl _value,
    $Res Function(_$PartnerDataRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PartnerDataRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? companyName = null,
    Object? contactName = null,
    Object? email = null,
    Object? phone = freezed,
    Object? message = null,
    Object? status = null,
    Object? requestedAt = null,
  }) {
    return _then(
      _$PartnerDataRequestImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        companyName: null == companyName
            ? _value.companyName
            : companyName // ignore: cast_nullable_to_non_nullable
                  as String,
        contactName: null == contactName
            ? _value.contactName
            : contactName // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as PartnerDataRequestStatus,
        requestedAt: null == requestedAt
            ? _value.requestedAt
            : requestedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PartnerDataRequestImpl implements _PartnerDataRequest {
  const _$PartnerDataRequestImpl({
    required this.id,
    required this.companyName,
    required this.contactName,
    required this.email,
    this.phone,
    required this.message,
    this.status = PartnerDataRequestStatus.pending,
    required this.requestedAt,
  });

  factory _$PartnerDataRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$PartnerDataRequestImplFromJson(json);

  @override
  final String id;
  @override
  final String companyName;
  @override
  final String contactName;
  @override
  final String email;
  @override
  final String? phone;
  @override
  final String message;
  @override
  @JsonKey()
  final PartnerDataRequestStatus status;
  @override
  final DateTime requestedAt;

  @override
  String toString() {
    return 'PartnerDataRequest(id: $id, companyName: $companyName, contactName: $contactName, email: $email, phone: $phone, message: $message, status: $status, requestedAt: $requestedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PartnerDataRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.companyName, companyName) ||
                other.companyName == companyName) &&
            (identical(other.contactName, contactName) ||
                other.contactName == contactName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.requestedAt, requestedAt) ||
                other.requestedAt == requestedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    companyName,
    contactName,
    email,
    phone,
    message,
    status,
    requestedAt,
  );

  /// Create a copy of PartnerDataRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PartnerDataRequestImplCopyWith<_$PartnerDataRequestImpl> get copyWith =>
      __$$PartnerDataRequestImplCopyWithImpl<_$PartnerDataRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PartnerDataRequestImplToJson(this);
  }
}

abstract class _PartnerDataRequest implements PartnerDataRequest {
  const factory _PartnerDataRequest({
    required final String id,
    required final String companyName,
    required final String contactName,
    required final String email,
    final String? phone,
    required final String message,
    final PartnerDataRequestStatus status,
    required final DateTime requestedAt,
  }) = _$PartnerDataRequestImpl;

  factory _PartnerDataRequest.fromJson(Map<String, dynamic> json) =
      _$PartnerDataRequestImpl.fromJson;

  @override
  String get id;
  @override
  String get companyName;
  @override
  String get contactName;
  @override
  String get email;
  @override
  String? get phone;
  @override
  String get message;
  @override
  PartnerDataRequestStatus get status;
  @override
  DateTime get requestedAt;

  /// Create a copy of PartnerDataRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PartnerDataRequestImplCopyWith<_$PartnerDataRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
