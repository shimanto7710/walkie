// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'webrtc_offer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WebRTCOffer _$WebRTCOfferFromJson(Map<String, dynamic> json) {
  return _WebRTCOffer.fromJson(json);
}

/// @nodoc
mixin _$WebRTCOffer {
  String get sdp => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  String? get id => throw _privateConstructorUsedError;

  /// Serializes this WebRTCOffer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WebRTCOffer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WebRTCOfferCopyWith<WebRTCOffer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WebRTCOfferCopyWith<$Res> {
  factory $WebRTCOfferCopyWith(
          WebRTCOffer value, $Res Function(WebRTCOffer) then) =
      _$WebRTCOfferCopyWithImpl<$Res, WebRTCOffer>;
  @useResult
  $Res call({String sdp, String type, DateTime? createdAt, String? id});
}

/// @nodoc
class _$WebRTCOfferCopyWithImpl<$Res, $Val extends WebRTCOffer>
    implements $WebRTCOfferCopyWith<$Res> {
  _$WebRTCOfferCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WebRTCOffer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sdp = null,
    Object? type = null,
    Object? createdAt = freezed,
    Object? id = freezed,
  }) {
    return _then(_value.copyWith(
      sdp: null == sdp
          ? _value.sdp
          : sdp // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WebRTCOfferImplCopyWith<$Res>
    implements $WebRTCOfferCopyWith<$Res> {
  factory _$$WebRTCOfferImplCopyWith(
          _$WebRTCOfferImpl value, $Res Function(_$WebRTCOfferImpl) then) =
      __$$WebRTCOfferImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String sdp, String type, DateTime? createdAt, String? id});
}

/// @nodoc
class __$$WebRTCOfferImplCopyWithImpl<$Res>
    extends _$WebRTCOfferCopyWithImpl<$Res, _$WebRTCOfferImpl>
    implements _$$WebRTCOfferImplCopyWith<$Res> {
  __$$WebRTCOfferImplCopyWithImpl(
      _$WebRTCOfferImpl _value, $Res Function(_$WebRTCOfferImpl) _then)
      : super(_value, _then);

  /// Create a copy of WebRTCOffer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sdp = null,
    Object? type = null,
    Object? createdAt = freezed,
    Object? id = freezed,
  }) {
    return _then(_$WebRTCOfferImpl(
      sdp: null == sdp
          ? _value.sdp
          : sdp // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WebRTCOfferImpl implements _WebRTCOffer {
  const _$WebRTCOfferImpl(
      {required this.sdp, required this.type, this.createdAt, this.id});

  factory _$WebRTCOfferImpl.fromJson(Map<String, dynamic> json) =>
      _$$WebRTCOfferImplFromJson(json);

  @override
  final String sdp;
  @override
  final String type;
  @override
  final DateTime? createdAt;
  @override
  final String? id;

  @override
  String toString() {
    return 'WebRTCOffer(sdp: $sdp, type: $type, createdAt: $createdAt, id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WebRTCOfferImpl &&
            (identical(other.sdp, sdp) || other.sdp == sdp) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, sdp, type, createdAt, id);

  /// Create a copy of WebRTCOffer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WebRTCOfferImplCopyWith<_$WebRTCOfferImpl> get copyWith =>
      __$$WebRTCOfferImplCopyWithImpl<_$WebRTCOfferImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WebRTCOfferImplToJson(
      this,
    );
  }
}

abstract class _WebRTCOffer implements WebRTCOffer {
  const factory _WebRTCOffer(
      {required final String sdp,
      required final String type,
      final DateTime? createdAt,
      final String? id}) = _$WebRTCOfferImpl;

  factory _WebRTCOffer.fromJson(Map<String, dynamic> json) =
      _$WebRTCOfferImpl.fromJson;

  @override
  String get sdp;
  @override
  String get type;
  @override
  DateTime? get createdAt;
  @override
  String? get id;

  /// Create a copy of WebRTCOffer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WebRTCOfferImplCopyWith<_$WebRTCOfferImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WebRTCAnswer _$WebRTCAnswerFromJson(Map<String, dynamic> json) {
  return _WebRTCAnswer.fromJson(json);
}

/// @nodoc
mixin _$WebRTCAnswer {
  String get sdp => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  String? get id => throw _privateConstructorUsedError;

  /// Serializes this WebRTCAnswer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WebRTCAnswer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WebRTCAnswerCopyWith<WebRTCAnswer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WebRTCAnswerCopyWith<$Res> {
  factory $WebRTCAnswerCopyWith(
          WebRTCAnswer value, $Res Function(WebRTCAnswer) then) =
      _$WebRTCAnswerCopyWithImpl<$Res, WebRTCAnswer>;
  @useResult
  $Res call({String sdp, String type, DateTime? createdAt, String? id});
}

/// @nodoc
class _$WebRTCAnswerCopyWithImpl<$Res, $Val extends WebRTCAnswer>
    implements $WebRTCAnswerCopyWith<$Res> {
  _$WebRTCAnswerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WebRTCAnswer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sdp = null,
    Object? type = null,
    Object? createdAt = freezed,
    Object? id = freezed,
  }) {
    return _then(_value.copyWith(
      sdp: null == sdp
          ? _value.sdp
          : sdp // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WebRTCAnswerImplCopyWith<$Res>
    implements $WebRTCAnswerCopyWith<$Res> {
  factory _$$WebRTCAnswerImplCopyWith(
          _$WebRTCAnswerImpl value, $Res Function(_$WebRTCAnswerImpl) then) =
      __$$WebRTCAnswerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String sdp, String type, DateTime? createdAt, String? id});
}

/// @nodoc
class __$$WebRTCAnswerImplCopyWithImpl<$Res>
    extends _$WebRTCAnswerCopyWithImpl<$Res, _$WebRTCAnswerImpl>
    implements _$$WebRTCAnswerImplCopyWith<$Res> {
  __$$WebRTCAnswerImplCopyWithImpl(
      _$WebRTCAnswerImpl _value, $Res Function(_$WebRTCAnswerImpl) _then)
      : super(_value, _then);

  /// Create a copy of WebRTCAnswer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sdp = null,
    Object? type = null,
    Object? createdAt = freezed,
    Object? id = freezed,
  }) {
    return _then(_$WebRTCAnswerImpl(
      sdp: null == sdp
          ? _value.sdp
          : sdp // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WebRTCAnswerImpl implements _WebRTCAnswer {
  const _$WebRTCAnswerImpl(
      {required this.sdp, required this.type, this.createdAt, this.id});

  factory _$WebRTCAnswerImpl.fromJson(Map<String, dynamic> json) =>
      _$$WebRTCAnswerImplFromJson(json);

  @override
  final String sdp;
  @override
  final String type;
  @override
  final DateTime? createdAt;
  @override
  final String? id;

  @override
  String toString() {
    return 'WebRTCAnswer(sdp: $sdp, type: $type, createdAt: $createdAt, id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WebRTCAnswerImpl &&
            (identical(other.sdp, sdp) || other.sdp == sdp) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, sdp, type, createdAt, id);

  /// Create a copy of WebRTCAnswer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WebRTCAnswerImplCopyWith<_$WebRTCAnswerImpl> get copyWith =>
      __$$WebRTCAnswerImplCopyWithImpl<_$WebRTCAnswerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WebRTCAnswerImplToJson(
      this,
    );
  }
}

abstract class _WebRTCAnswer implements WebRTCAnswer {
  const factory _WebRTCAnswer(
      {required final String sdp,
      required final String type,
      final DateTime? createdAt,
      final String? id}) = _$WebRTCAnswerImpl;

  factory _WebRTCAnswer.fromJson(Map<String, dynamic> json) =
      _$WebRTCAnswerImpl.fromJson;

  @override
  String get sdp;
  @override
  String get type;
  @override
  DateTime? get createdAt;
  @override
  String? get id;

  /// Create a copy of WebRTCAnswer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WebRTCAnswerImplCopyWith<_$WebRTCAnswerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WebRTCIceCandidate _$WebRTCIceCandidateFromJson(Map<String, dynamic> json) {
  return _WebRTCIceCandidate.fromJson(json);
}

/// @nodoc
mixin _$WebRTCIceCandidate {
  String get candidate => throw _privateConstructorUsedError;
  String? get sdpMid => throw _privateConstructorUsedError;
  int? get sdpMLineIndex => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  String? get id => throw _privateConstructorUsedError;

  /// Serializes this WebRTCIceCandidate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WebRTCIceCandidate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WebRTCIceCandidateCopyWith<WebRTCIceCandidate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WebRTCIceCandidateCopyWith<$Res> {
  factory $WebRTCIceCandidateCopyWith(
          WebRTCIceCandidate value, $Res Function(WebRTCIceCandidate) then) =
      _$WebRTCIceCandidateCopyWithImpl<$Res, WebRTCIceCandidate>;
  @useResult
  $Res call(
      {String candidate,
      String? sdpMid,
      int? sdpMLineIndex,
      DateTime? createdAt,
      String? id});
}

/// @nodoc
class _$WebRTCIceCandidateCopyWithImpl<$Res, $Val extends WebRTCIceCandidate>
    implements $WebRTCIceCandidateCopyWith<$Res> {
  _$WebRTCIceCandidateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WebRTCIceCandidate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? candidate = null,
    Object? sdpMid = freezed,
    Object? sdpMLineIndex = freezed,
    Object? createdAt = freezed,
    Object? id = freezed,
  }) {
    return _then(_value.copyWith(
      candidate: null == candidate
          ? _value.candidate
          : candidate // ignore: cast_nullable_to_non_nullable
              as String,
      sdpMid: freezed == sdpMid
          ? _value.sdpMid
          : sdpMid // ignore: cast_nullable_to_non_nullable
              as String?,
      sdpMLineIndex: freezed == sdpMLineIndex
          ? _value.sdpMLineIndex
          : sdpMLineIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WebRTCIceCandidateImplCopyWith<$Res>
    implements $WebRTCIceCandidateCopyWith<$Res> {
  factory _$$WebRTCIceCandidateImplCopyWith(_$WebRTCIceCandidateImpl value,
          $Res Function(_$WebRTCIceCandidateImpl) then) =
      __$$WebRTCIceCandidateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String candidate,
      String? sdpMid,
      int? sdpMLineIndex,
      DateTime? createdAt,
      String? id});
}

/// @nodoc
class __$$WebRTCIceCandidateImplCopyWithImpl<$Res>
    extends _$WebRTCIceCandidateCopyWithImpl<$Res, _$WebRTCIceCandidateImpl>
    implements _$$WebRTCIceCandidateImplCopyWith<$Res> {
  __$$WebRTCIceCandidateImplCopyWithImpl(_$WebRTCIceCandidateImpl _value,
      $Res Function(_$WebRTCIceCandidateImpl) _then)
      : super(_value, _then);

  /// Create a copy of WebRTCIceCandidate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? candidate = null,
    Object? sdpMid = freezed,
    Object? sdpMLineIndex = freezed,
    Object? createdAt = freezed,
    Object? id = freezed,
  }) {
    return _then(_$WebRTCIceCandidateImpl(
      candidate: null == candidate
          ? _value.candidate
          : candidate // ignore: cast_nullable_to_non_nullable
              as String,
      sdpMid: freezed == sdpMid
          ? _value.sdpMid
          : sdpMid // ignore: cast_nullable_to_non_nullable
              as String?,
      sdpMLineIndex: freezed == sdpMLineIndex
          ? _value.sdpMLineIndex
          : sdpMLineIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WebRTCIceCandidateImpl implements _WebRTCIceCandidate {
  const _$WebRTCIceCandidateImpl(
      {required this.candidate,
      this.sdpMid,
      this.sdpMLineIndex,
      this.createdAt,
      this.id});

  factory _$WebRTCIceCandidateImpl.fromJson(Map<String, dynamic> json) =>
      _$$WebRTCIceCandidateImplFromJson(json);

  @override
  final String candidate;
  @override
  final String? sdpMid;
  @override
  final int? sdpMLineIndex;
  @override
  final DateTime? createdAt;
  @override
  final String? id;

  @override
  String toString() {
    return 'WebRTCIceCandidate(candidate: $candidate, sdpMid: $sdpMid, sdpMLineIndex: $sdpMLineIndex, createdAt: $createdAt, id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WebRTCIceCandidateImpl &&
            (identical(other.candidate, candidate) ||
                other.candidate == candidate) &&
            (identical(other.sdpMid, sdpMid) || other.sdpMid == sdpMid) &&
            (identical(other.sdpMLineIndex, sdpMLineIndex) ||
                other.sdpMLineIndex == sdpMLineIndex) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, candidate, sdpMid, sdpMLineIndex, createdAt, id);

  /// Create a copy of WebRTCIceCandidate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WebRTCIceCandidateImplCopyWith<_$WebRTCIceCandidateImpl> get copyWith =>
      __$$WebRTCIceCandidateImplCopyWithImpl<_$WebRTCIceCandidateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WebRTCIceCandidateImplToJson(
      this,
    );
  }
}

abstract class _WebRTCIceCandidate implements WebRTCIceCandidate {
  const factory _WebRTCIceCandidate(
      {required final String candidate,
      final String? sdpMid,
      final int? sdpMLineIndex,
      final DateTime? createdAt,
      final String? id}) = _$WebRTCIceCandidateImpl;

  factory _WebRTCIceCandidate.fromJson(Map<String, dynamic> json) =
      _$WebRTCIceCandidateImpl.fromJson;

  @override
  String get candidate;
  @override
  String? get sdpMid;
  @override
  int? get sdpMLineIndex;
  @override
  DateTime? get createdAt;
  @override
  String? get id;

  /// Create a copy of WebRTCIceCandidate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WebRTCIceCandidateImplCopyWith<_$WebRTCIceCandidateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
