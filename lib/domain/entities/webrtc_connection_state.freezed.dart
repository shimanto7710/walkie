// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'webrtc_connection_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$WebRTCConnectionState {
  WebRTCConnectionStatus get status => throw _privateConstructorUsedError;
  bool get isInitialized => throw _privateConstructorUsedError;
  bool get isMuted => throw _privateConstructorUsedError;
  bool get isSpeakerOn => throw _privateConstructorUsedError;
  bool get isAudioEnabled => throw _privateConstructorUsedError;
  bool get isLocalAudioEnabled => throw _privateConstructorUsedError;
  bool get isRemoteAudioEnabled => throw _privateConstructorUsedError;
  String? get localUserId => throw _privateConstructorUsedError;
  String? get remoteUserId => throw _privateConstructorUsedError;
  String? get roomId => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  int get connectionAttempts => throw _privateConstructorUsedError;
  int get maxConnectionAttempts => throw _privateConstructorUsedError;
  DateTime? get lastConnectedAt => throw _privateConstructorUsedError;
  DateTime? get lastDisconnectedAt => throw _privateConstructorUsedError;

  /// Create a copy of WebRTCConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WebRTCConnectionStateCopyWith<WebRTCConnectionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WebRTCConnectionStateCopyWith<$Res> {
  factory $WebRTCConnectionStateCopyWith(WebRTCConnectionState value,
          $Res Function(WebRTCConnectionState) then) =
      _$WebRTCConnectionStateCopyWithImpl<$Res, WebRTCConnectionState>;
  @useResult
  $Res call(
      {WebRTCConnectionStatus status,
      bool isInitialized,
      bool isMuted,
      bool isSpeakerOn,
      bool isAudioEnabled,
      bool isLocalAudioEnabled,
      bool isRemoteAudioEnabled,
      String? localUserId,
      String? remoteUserId,
      String? roomId,
      String? errorMessage,
      int connectionAttempts,
      int maxConnectionAttempts,
      DateTime? lastConnectedAt,
      DateTime? lastDisconnectedAt});
}

/// @nodoc
class _$WebRTCConnectionStateCopyWithImpl<$Res,
        $Val extends WebRTCConnectionState>
    implements $WebRTCConnectionStateCopyWith<$Res> {
  _$WebRTCConnectionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WebRTCConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? isInitialized = null,
    Object? isMuted = null,
    Object? isSpeakerOn = null,
    Object? isAudioEnabled = null,
    Object? isLocalAudioEnabled = null,
    Object? isRemoteAudioEnabled = null,
    Object? localUserId = freezed,
    Object? remoteUserId = freezed,
    Object? roomId = freezed,
    Object? errorMessage = freezed,
    Object? connectionAttempts = null,
    Object? maxConnectionAttempts = null,
    Object? lastConnectedAt = freezed,
    Object? lastDisconnectedAt = freezed,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as WebRTCConnectionStatus,
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
      isMuted: null == isMuted
          ? _value.isMuted
          : isMuted // ignore: cast_nullable_to_non_nullable
              as bool,
      isSpeakerOn: null == isSpeakerOn
          ? _value.isSpeakerOn
          : isSpeakerOn // ignore: cast_nullable_to_non_nullable
              as bool,
      isAudioEnabled: null == isAudioEnabled
          ? _value.isAudioEnabled
          : isAudioEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      isLocalAudioEnabled: null == isLocalAudioEnabled
          ? _value.isLocalAudioEnabled
          : isLocalAudioEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      isRemoteAudioEnabled: null == isRemoteAudioEnabled
          ? _value.isRemoteAudioEnabled
          : isRemoteAudioEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      localUserId: freezed == localUserId
          ? _value.localUserId
          : localUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      remoteUserId: freezed == remoteUserId
          ? _value.remoteUserId
          : remoteUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      roomId: freezed == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      connectionAttempts: null == connectionAttempts
          ? _value.connectionAttempts
          : connectionAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      maxConnectionAttempts: null == maxConnectionAttempts
          ? _value.maxConnectionAttempts
          : maxConnectionAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      lastConnectedAt: freezed == lastConnectedAt
          ? _value.lastConnectedAt
          : lastConnectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastDisconnectedAt: freezed == lastDisconnectedAt
          ? _value.lastDisconnectedAt
          : lastDisconnectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WebRTCConnectionStateImplCopyWith<$Res>
    implements $WebRTCConnectionStateCopyWith<$Res> {
  factory _$$WebRTCConnectionStateImplCopyWith(
          _$WebRTCConnectionStateImpl value,
          $Res Function(_$WebRTCConnectionStateImpl) then) =
      __$$WebRTCConnectionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {WebRTCConnectionStatus status,
      bool isInitialized,
      bool isMuted,
      bool isSpeakerOn,
      bool isAudioEnabled,
      bool isLocalAudioEnabled,
      bool isRemoteAudioEnabled,
      String? localUserId,
      String? remoteUserId,
      String? roomId,
      String? errorMessage,
      int connectionAttempts,
      int maxConnectionAttempts,
      DateTime? lastConnectedAt,
      DateTime? lastDisconnectedAt});
}

/// @nodoc
class __$$WebRTCConnectionStateImplCopyWithImpl<$Res>
    extends _$WebRTCConnectionStateCopyWithImpl<$Res,
        _$WebRTCConnectionStateImpl>
    implements _$$WebRTCConnectionStateImplCopyWith<$Res> {
  __$$WebRTCConnectionStateImplCopyWithImpl(_$WebRTCConnectionStateImpl _value,
      $Res Function(_$WebRTCConnectionStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of WebRTCConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? isInitialized = null,
    Object? isMuted = null,
    Object? isSpeakerOn = null,
    Object? isAudioEnabled = null,
    Object? isLocalAudioEnabled = null,
    Object? isRemoteAudioEnabled = null,
    Object? localUserId = freezed,
    Object? remoteUserId = freezed,
    Object? roomId = freezed,
    Object? errorMessage = freezed,
    Object? connectionAttempts = null,
    Object? maxConnectionAttempts = null,
    Object? lastConnectedAt = freezed,
    Object? lastDisconnectedAt = freezed,
  }) {
    return _then(_$WebRTCConnectionStateImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as WebRTCConnectionStatus,
      isInitialized: null == isInitialized
          ? _value.isInitialized
          : isInitialized // ignore: cast_nullable_to_non_nullable
              as bool,
      isMuted: null == isMuted
          ? _value.isMuted
          : isMuted // ignore: cast_nullable_to_non_nullable
              as bool,
      isSpeakerOn: null == isSpeakerOn
          ? _value.isSpeakerOn
          : isSpeakerOn // ignore: cast_nullable_to_non_nullable
              as bool,
      isAudioEnabled: null == isAudioEnabled
          ? _value.isAudioEnabled
          : isAudioEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      isLocalAudioEnabled: null == isLocalAudioEnabled
          ? _value.isLocalAudioEnabled
          : isLocalAudioEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      isRemoteAudioEnabled: null == isRemoteAudioEnabled
          ? _value.isRemoteAudioEnabled
          : isRemoteAudioEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      localUserId: freezed == localUserId
          ? _value.localUserId
          : localUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      remoteUserId: freezed == remoteUserId
          ? _value.remoteUserId
          : remoteUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      roomId: freezed == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      connectionAttempts: null == connectionAttempts
          ? _value.connectionAttempts
          : connectionAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      maxConnectionAttempts: null == maxConnectionAttempts
          ? _value.maxConnectionAttempts
          : maxConnectionAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      lastConnectedAt: freezed == lastConnectedAt
          ? _value.lastConnectedAt
          : lastConnectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastDisconnectedAt: freezed == lastDisconnectedAt
          ? _value.lastDisconnectedAt
          : lastDisconnectedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$WebRTCConnectionStateImpl implements _WebRTCConnectionState {
  const _$WebRTCConnectionStateImpl(
      {this.status = WebRTCConnectionStatus.disconnected,
      this.isInitialized = false,
      this.isMuted = false,
      this.isSpeakerOn = false,
      this.isAudioEnabled = false,
      this.isLocalAudioEnabled = false,
      this.isRemoteAudioEnabled = false,
      this.localUserId,
      this.remoteUserId,
      this.roomId,
      this.errorMessage,
      this.connectionAttempts = 0,
      this.maxConnectionAttempts = 0,
      this.lastConnectedAt,
      this.lastDisconnectedAt});

  @override
  @JsonKey()
  final WebRTCConnectionStatus status;
  @override
  @JsonKey()
  final bool isInitialized;
  @override
  @JsonKey()
  final bool isMuted;
  @override
  @JsonKey()
  final bool isSpeakerOn;
  @override
  @JsonKey()
  final bool isAudioEnabled;
  @override
  @JsonKey()
  final bool isLocalAudioEnabled;
  @override
  @JsonKey()
  final bool isRemoteAudioEnabled;
  @override
  final String? localUserId;
  @override
  final String? remoteUserId;
  @override
  final String? roomId;
  @override
  final String? errorMessage;
  @override
  @JsonKey()
  final int connectionAttempts;
  @override
  @JsonKey()
  final int maxConnectionAttempts;
  @override
  final DateTime? lastConnectedAt;
  @override
  final DateTime? lastDisconnectedAt;

  @override
  String toString() {
    return 'WebRTCConnectionState(status: $status, isInitialized: $isInitialized, isMuted: $isMuted, isSpeakerOn: $isSpeakerOn, isAudioEnabled: $isAudioEnabled, isLocalAudioEnabled: $isLocalAudioEnabled, isRemoteAudioEnabled: $isRemoteAudioEnabled, localUserId: $localUserId, remoteUserId: $remoteUserId, roomId: $roomId, errorMessage: $errorMessage, connectionAttempts: $connectionAttempts, maxConnectionAttempts: $maxConnectionAttempts, lastConnectedAt: $lastConnectedAt, lastDisconnectedAt: $lastDisconnectedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WebRTCConnectionStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isInitialized, isInitialized) ||
                other.isInitialized == isInitialized) &&
            (identical(other.isMuted, isMuted) || other.isMuted == isMuted) &&
            (identical(other.isSpeakerOn, isSpeakerOn) ||
                other.isSpeakerOn == isSpeakerOn) &&
            (identical(other.isAudioEnabled, isAudioEnabled) ||
                other.isAudioEnabled == isAudioEnabled) &&
            (identical(other.isLocalAudioEnabled, isLocalAudioEnabled) ||
                other.isLocalAudioEnabled == isLocalAudioEnabled) &&
            (identical(other.isRemoteAudioEnabled, isRemoteAudioEnabled) ||
                other.isRemoteAudioEnabled == isRemoteAudioEnabled) &&
            (identical(other.localUserId, localUserId) ||
                other.localUserId == localUserId) &&
            (identical(other.remoteUserId, remoteUserId) ||
                other.remoteUserId == remoteUserId) &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.connectionAttempts, connectionAttempts) ||
                other.connectionAttempts == connectionAttempts) &&
            (identical(other.maxConnectionAttempts, maxConnectionAttempts) ||
                other.maxConnectionAttempts == maxConnectionAttempts) &&
            (identical(other.lastConnectedAt, lastConnectedAt) ||
                other.lastConnectedAt == lastConnectedAt) &&
            (identical(other.lastDisconnectedAt, lastDisconnectedAt) ||
                other.lastDisconnectedAt == lastDisconnectedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      status,
      isInitialized,
      isMuted,
      isSpeakerOn,
      isAudioEnabled,
      isLocalAudioEnabled,
      isRemoteAudioEnabled,
      localUserId,
      remoteUserId,
      roomId,
      errorMessage,
      connectionAttempts,
      maxConnectionAttempts,
      lastConnectedAt,
      lastDisconnectedAt);

  /// Create a copy of WebRTCConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WebRTCConnectionStateImplCopyWith<_$WebRTCConnectionStateImpl>
      get copyWith => __$$WebRTCConnectionStateImplCopyWithImpl<
          _$WebRTCConnectionStateImpl>(this, _$identity);
}

abstract class _WebRTCConnectionState implements WebRTCConnectionState {
  const factory _WebRTCConnectionState(
      {final WebRTCConnectionStatus status,
      final bool isInitialized,
      final bool isMuted,
      final bool isSpeakerOn,
      final bool isAudioEnabled,
      final bool isLocalAudioEnabled,
      final bool isRemoteAudioEnabled,
      final String? localUserId,
      final String? remoteUserId,
      final String? roomId,
      final String? errorMessage,
      final int connectionAttempts,
      final int maxConnectionAttempts,
      final DateTime? lastConnectedAt,
      final DateTime? lastDisconnectedAt}) = _$WebRTCConnectionStateImpl;

  @override
  WebRTCConnectionStatus get status;
  @override
  bool get isInitialized;
  @override
  bool get isMuted;
  @override
  bool get isSpeakerOn;
  @override
  bool get isAudioEnabled;
  @override
  bool get isLocalAudioEnabled;
  @override
  bool get isRemoteAudioEnabled;
  @override
  String? get localUserId;
  @override
  String? get remoteUserId;
  @override
  String? get roomId;
  @override
  String? get errorMessage;
  @override
  int get connectionAttempts;
  @override
  int get maxConnectionAttempts;
  @override
  DateTime? get lastConnectedAt;
  @override
  DateTime? get lastDisconnectedAt;

  /// Create a copy of WebRTCConnectionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WebRTCConnectionStateImplCopyWith<_$WebRTCConnectionStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
