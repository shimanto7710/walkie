// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'webrtc_media_stream.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$WebRTCMediaStream {
  String get streamId => throw _privateConstructorUsedError;
  WebRTCMediaType get type => throw _privateConstructorUsedError;
  bool get isLocal => throw _privateConstructorUsedError;
  bool get isEnabled => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get constraints => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of WebRTCMediaStream
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WebRTCMediaStreamCopyWith<WebRTCMediaStream> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WebRTCMediaStreamCopyWith<$Res> {
  factory $WebRTCMediaStreamCopyWith(
          WebRTCMediaStream value, $Res Function(WebRTCMediaStream) then) =
      _$WebRTCMediaStreamCopyWithImpl<$Res, WebRTCMediaStream>;
  @useResult
  $Res call(
      {String streamId,
      WebRTCMediaType type,
      bool isLocal,
      bool isEnabled,
      String? userId,
      Map<String, dynamic>? constraints,
      DateTime? createdAt});
}

/// @nodoc
class _$WebRTCMediaStreamCopyWithImpl<$Res, $Val extends WebRTCMediaStream>
    implements $WebRTCMediaStreamCopyWith<$Res> {
  _$WebRTCMediaStreamCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WebRTCMediaStream
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? streamId = null,
    Object? type = null,
    Object? isLocal = null,
    Object? isEnabled = null,
    Object? userId = freezed,
    Object? constraints = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      streamId: null == streamId
          ? _value.streamId
          : streamId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as WebRTCMediaType,
      isLocal: null == isLocal
          ? _value.isLocal
          : isLocal // ignore: cast_nullable_to_non_nullable
              as bool,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      constraints: freezed == constraints
          ? _value.constraints
          : constraints // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WebRTCMediaStreamImplCopyWith<$Res>
    implements $WebRTCMediaStreamCopyWith<$Res> {
  factory _$$WebRTCMediaStreamImplCopyWith(_$WebRTCMediaStreamImpl value,
          $Res Function(_$WebRTCMediaStreamImpl) then) =
      __$$WebRTCMediaStreamImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String streamId,
      WebRTCMediaType type,
      bool isLocal,
      bool isEnabled,
      String? userId,
      Map<String, dynamic>? constraints,
      DateTime? createdAt});
}

/// @nodoc
class __$$WebRTCMediaStreamImplCopyWithImpl<$Res>
    extends _$WebRTCMediaStreamCopyWithImpl<$Res, _$WebRTCMediaStreamImpl>
    implements _$$WebRTCMediaStreamImplCopyWith<$Res> {
  __$$WebRTCMediaStreamImplCopyWithImpl(_$WebRTCMediaStreamImpl _value,
      $Res Function(_$WebRTCMediaStreamImpl) _then)
      : super(_value, _then);

  /// Create a copy of WebRTCMediaStream
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? streamId = null,
    Object? type = null,
    Object? isLocal = null,
    Object? isEnabled = null,
    Object? userId = freezed,
    Object? constraints = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$WebRTCMediaStreamImpl(
      streamId: null == streamId
          ? _value.streamId
          : streamId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as WebRTCMediaType,
      isLocal: null == isLocal
          ? _value.isLocal
          : isLocal // ignore: cast_nullable_to_non_nullable
              as bool,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      constraints: freezed == constraints
          ? _value._constraints
          : constraints // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$WebRTCMediaStreamImpl implements _WebRTCMediaStream {
  const _$WebRTCMediaStreamImpl(
      {required this.streamId,
      required this.type,
      required this.isLocal,
      required this.isEnabled,
      this.userId,
      final Map<String, dynamic>? constraints,
      this.createdAt})
      : _constraints = constraints;

  @override
  final String streamId;
  @override
  final WebRTCMediaType type;
  @override
  final bool isLocal;
  @override
  final bool isEnabled;
  @override
  final String? userId;
  final Map<String, dynamic>? _constraints;
  @override
  Map<String, dynamic>? get constraints {
    final value = _constraints;
    if (value == null) return null;
    if (_constraints is EqualUnmodifiableMapView) return _constraints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'WebRTCMediaStream(streamId: $streamId, type: $type, isLocal: $isLocal, isEnabled: $isEnabled, userId: $userId, constraints: $constraints, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WebRTCMediaStreamImpl &&
            (identical(other.streamId, streamId) ||
                other.streamId == streamId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.isLocal, isLocal) || other.isLocal == isLocal) &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality()
                .equals(other._constraints, _constraints) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      streamId,
      type,
      isLocal,
      isEnabled,
      userId,
      const DeepCollectionEquality().hash(_constraints),
      createdAt);

  /// Create a copy of WebRTCMediaStream
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WebRTCMediaStreamImplCopyWith<_$WebRTCMediaStreamImpl> get copyWith =>
      __$$WebRTCMediaStreamImplCopyWithImpl<_$WebRTCMediaStreamImpl>(
          this, _$identity);
}

abstract class _WebRTCMediaStream implements WebRTCMediaStream {
  const factory _WebRTCMediaStream(
      {required final String streamId,
      required final WebRTCMediaType type,
      required final bool isLocal,
      required final bool isEnabled,
      final String? userId,
      final Map<String, dynamic>? constraints,
      final DateTime? createdAt}) = _$WebRTCMediaStreamImpl;

  @override
  String get streamId;
  @override
  WebRTCMediaType get type;
  @override
  bool get isLocal;
  @override
  bool get isEnabled;
  @override
  String? get userId;
  @override
  Map<String, dynamic>? get constraints;
  @override
  DateTime? get createdAt;

  /// Create a copy of WebRTCMediaStream
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WebRTCMediaStreamImplCopyWith<_$WebRTCMediaStreamImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$WebRTCMediaConstraints {
  bool get audio => throw _privateConstructorUsedError;
  WebRTCAudioConstraints get audioConstraints =>
      throw _privateConstructorUsedError;

  /// Create a copy of WebRTCMediaConstraints
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WebRTCMediaConstraintsCopyWith<WebRTCMediaConstraints> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WebRTCMediaConstraintsCopyWith<$Res> {
  factory $WebRTCMediaConstraintsCopyWith(WebRTCMediaConstraints value,
          $Res Function(WebRTCMediaConstraints) then) =
      _$WebRTCMediaConstraintsCopyWithImpl<$Res, WebRTCMediaConstraints>;
  @useResult
  $Res call({bool audio, WebRTCAudioConstraints audioConstraints});

  $WebRTCAudioConstraintsCopyWith<$Res> get audioConstraints;
}

/// @nodoc
class _$WebRTCMediaConstraintsCopyWithImpl<$Res,
        $Val extends WebRTCMediaConstraints>
    implements $WebRTCMediaConstraintsCopyWith<$Res> {
  _$WebRTCMediaConstraintsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WebRTCMediaConstraints
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? audio = null,
    Object? audioConstraints = null,
  }) {
    return _then(_value.copyWith(
      audio: null == audio
          ? _value.audio
          : audio // ignore: cast_nullable_to_non_nullable
              as bool,
      audioConstraints: null == audioConstraints
          ? _value.audioConstraints
          : audioConstraints // ignore: cast_nullable_to_non_nullable
              as WebRTCAudioConstraints,
    ) as $Val);
  }

  /// Create a copy of WebRTCMediaConstraints
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WebRTCAudioConstraintsCopyWith<$Res> get audioConstraints {
    return $WebRTCAudioConstraintsCopyWith<$Res>(_value.audioConstraints,
        (value) {
      return _then(_value.copyWith(audioConstraints: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WebRTCMediaConstraintsImplCopyWith<$Res>
    implements $WebRTCMediaConstraintsCopyWith<$Res> {
  factory _$$WebRTCMediaConstraintsImplCopyWith(
          _$WebRTCMediaConstraintsImpl value,
          $Res Function(_$WebRTCMediaConstraintsImpl) then) =
      __$$WebRTCMediaConstraintsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool audio, WebRTCAudioConstraints audioConstraints});

  @override
  $WebRTCAudioConstraintsCopyWith<$Res> get audioConstraints;
}

/// @nodoc
class __$$WebRTCMediaConstraintsImplCopyWithImpl<$Res>
    extends _$WebRTCMediaConstraintsCopyWithImpl<$Res,
        _$WebRTCMediaConstraintsImpl>
    implements _$$WebRTCMediaConstraintsImplCopyWith<$Res> {
  __$$WebRTCMediaConstraintsImplCopyWithImpl(
      _$WebRTCMediaConstraintsImpl _value,
      $Res Function(_$WebRTCMediaConstraintsImpl) _then)
      : super(_value, _then);

  /// Create a copy of WebRTCMediaConstraints
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? audio = null,
    Object? audioConstraints = null,
  }) {
    return _then(_$WebRTCMediaConstraintsImpl(
      audio: null == audio
          ? _value.audio
          : audio // ignore: cast_nullable_to_non_nullable
              as bool,
      audioConstraints: null == audioConstraints
          ? _value.audioConstraints
          : audioConstraints // ignore: cast_nullable_to_non_nullable
              as WebRTCAudioConstraints,
    ));
  }
}

/// @nodoc

class _$WebRTCMediaConstraintsImpl implements _WebRTCMediaConstraints {
  const _$WebRTCMediaConstraintsImpl(
      {this.audio = true,
      this.audioConstraints = const WebRTCAudioConstraints()});

  @override
  @JsonKey()
  final bool audio;
  @override
  @JsonKey()
  final WebRTCAudioConstraints audioConstraints;

  @override
  String toString() {
    return 'WebRTCMediaConstraints(audio: $audio, audioConstraints: $audioConstraints)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WebRTCMediaConstraintsImpl &&
            (identical(other.audio, audio) || other.audio == audio) &&
            (identical(other.audioConstraints, audioConstraints) ||
                other.audioConstraints == audioConstraints));
  }

  @override
  int get hashCode => Object.hash(runtimeType, audio, audioConstraints);

  /// Create a copy of WebRTCMediaConstraints
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WebRTCMediaConstraintsImplCopyWith<_$WebRTCMediaConstraintsImpl>
      get copyWith => __$$WebRTCMediaConstraintsImplCopyWithImpl<
          _$WebRTCMediaConstraintsImpl>(this, _$identity);
}

abstract class _WebRTCMediaConstraints implements WebRTCMediaConstraints {
  const factory _WebRTCMediaConstraints(
          {final bool audio, final WebRTCAudioConstraints audioConstraints}) =
      _$WebRTCMediaConstraintsImpl;

  @override
  bool get audio;
  @override
  WebRTCAudioConstraints get audioConstraints;

  /// Create a copy of WebRTCMediaConstraints
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WebRTCMediaConstraintsImplCopyWith<_$WebRTCMediaConstraintsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$WebRTCAudioConstraints {
  bool get echoCancellation => throw _privateConstructorUsedError;
  bool get noiseSuppression => throw _privateConstructorUsedError;
  bool get autoGainControl => throw _privateConstructorUsedError;
  int get sampleRate => throw _privateConstructorUsedError;
  int get channelCount => throw _privateConstructorUsedError;

  /// Create a copy of WebRTCAudioConstraints
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WebRTCAudioConstraintsCopyWith<WebRTCAudioConstraints> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WebRTCAudioConstraintsCopyWith<$Res> {
  factory $WebRTCAudioConstraintsCopyWith(WebRTCAudioConstraints value,
          $Res Function(WebRTCAudioConstraints) then) =
      _$WebRTCAudioConstraintsCopyWithImpl<$Res, WebRTCAudioConstraints>;
  @useResult
  $Res call(
      {bool echoCancellation,
      bool noiseSuppression,
      bool autoGainControl,
      int sampleRate,
      int channelCount});
}

/// @nodoc
class _$WebRTCAudioConstraintsCopyWithImpl<$Res,
        $Val extends WebRTCAudioConstraints>
    implements $WebRTCAudioConstraintsCopyWith<$Res> {
  _$WebRTCAudioConstraintsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WebRTCAudioConstraints
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? echoCancellation = null,
    Object? noiseSuppression = null,
    Object? autoGainControl = null,
    Object? sampleRate = null,
    Object? channelCount = null,
  }) {
    return _then(_value.copyWith(
      echoCancellation: null == echoCancellation
          ? _value.echoCancellation
          : echoCancellation // ignore: cast_nullable_to_non_nullable
              as bool,
      noiseSuppression: null == noiseSuppression
          ? _value.noiseSuppression
          : noiseSuppression // ignore: cast_nullable_to_non_nullable
              as bool,
      autoGainControl: null == autoGainControl
          ? _value.autoGainControl
          : autoGainControl // ignore: cast_nullable_to_non_nullable
              as bool,
      sampleRate: null == sampleRate
          ? _value.sampleRate
          : sampleRate // ignore: cast_nullable_to_non_nullable
              as int,
      channelCount: null == channelCount
          ? _value.channelCount
          : channelCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WebRTCAudioConstraintsImplCopyWith<$Res>
    implements $WebRTCAudioConstraintsCopyWith<$Res> {
  factory _$$WebRTCAudioConstraintsImplCopyWith(
          _$WebRTCAudioConstraintsImpl value,
          $Res Function(_$WebRTCAudioConstraintsImpl) then) =
      __$$WebRTCAudioConstraintsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool echoCancellation,
      bool noiseSuppression,
      bool autoGainControl,
      int sampleRate,
      int channelCount});
}

/// @nodoc
class __$$WebRTCAudioConstraintsImplCopyWithImpl<$Res>
    extends _$WebRTCAudioConstraintsCopyWithImpl<$Res,
        _$WebRTCAudioConstraintsImpl>
    implements _$$WebRTCAudioConstraintsImplCopyWith<$Res> {
  __$$WebRTCAudioConstraintsImplCopyWithImpl(
      _$WebRTCAudioConstraintsImpl _value,
      $Res Function(_$WebRTCAudioConstraintsImpl) _then)
      : super(_value, _then);

  /// Create a copy of WebRTCAudioConstraints
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? echoCancellation = null,
    Object? noiseSuppression = null,
    Object? autoGainControl = null,
    Object? sampleRate = null,
    Object? channelCount = null,
  }) {
    return _then(_$WebRTCAudioConstraintsImpl(
      echoCancellation: null == echoCancellation
          ? _value.echoCancellation
          : echoCancellation // ignore: cast_nullable_to_non_nullable
              as bool,
      noiseSuppression: null == noiseSuppression
          ? _value.noiseSuppression
          : noiseSuppression // ignore: cast_nullable_to_non_nullable
              as bool,
      autoGainControl: null == autoGainControl
          ? _value.autoGainControl
          : autoGainControl // ignore: cast_nullable_to_non_nullable
              as bool,
      sampleRate: null == sampleRate
          ? _value.sampleRate
          : sampleRate // ignore: cast_nullable_to_non_nullable
              as int,
      channelCount: null == channelCount
          ? _value.channelCount
          : channelCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$WebRTCAudioConstraintsImpl implements _WebRTCAudioConstraints {
  const _$WebRTCAudioConstraintsImpl(
      {this.echoCancellation = true,
      this.noiseSuppression = true,
      this.autoGainControl = true,
      this.sampleRate = 48000,
      this.channelCount = 1});

  @override
  @JsonKey()
  final bool echoCancellation;
  @override
  @JsonKey()
  final bool noiseSuppression;
  @override
  @JsonKey()
  final bool autoGainControl;
  @override
  @JsonKey()
  final int sampleRate;
  @override
  @JsonKey()
  final int channelCount;

  @override
  String toString() {
    return 'WebRTCAudioConstraints(echoCancellation: $echoCancellation, noiseSuppression: $noiseSuppression, autoGainControl: $autoGainControl, sampleRate: $sampleRate, channelCount: $channelCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WebRTCAudioConstraintsImpl &&
            (identical(other.echoCancellation, echoCancellation) ||
                other.echoCancellation == echoCancellation) &&
            (identical(other.noiseSuppression, noiseSuppression) ||
                other.noiseSuppression == noiseSuppression) &&
            (identical(other.autoGainControl, autoGainControl) ||
                other.autoGainControl == autoGainControl) &&
            (identical(other.sampleRate, sampleRate) ||
                other.sampleRate == sampleRate) &&
            (identical(other.channelCount, channelCount) ||
                other.channelCount == channelCount));
  }

  @override
  int get hashCode => Object.hash(runtimeType, echoCancellation,
      noiseSuppression, autoGainControl, sampleRate, channelCount);

  /// Create a copy of WebRTCAudioConstraints
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WebRTCAudioConstraintsImplCopyWith<_$WebRTCAudioConstraintsImpl>
      get copyWith => __$$WebRTCAudioConstraintsImplCopyWithImpl<
          _$WebRTCAudioConstraintsImpl>(this, _$identity);
}

abstract class _WebRTCAudioConstraints implements WebRTCAudioConstraints {
  const factory _WebRTCAudioConstraints(
      {final bool echoCancellation,
      final bool noiseSuppression,
      final bool autoGainControl,
      final int sampleRate,
      final int channelCount}) = _$WebRTCAudioConstraintsImpl;

  @override
  bool get echoCancellation;
  @override
  bool get noiseSuppression;
  @override
  bool get autoGainControl;
  @override
  int get sampleRate;
  @override
  int get channelCount;

  /// Create a copy of WebRTCAudioConstraints
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WebRTCAudioConstraintsImplCopyWith<_$WebRTCAudioConstraintsImpl>
      get copyWith => throw _privateConstructorUsedError;
}
