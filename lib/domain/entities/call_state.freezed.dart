// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'call_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CallState {
  bool get isConnected => throw _privateConstructorUsedError;
  bool get isConnecting => throw _privateConstructorUsedError;
  bool get isMuted => throw _privateConstructorUsedError;
  bool get isSpeakerOn => throw _privateConstructorUsedError;
  CallStatus get status => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  String? get localUserId => throw _privateConstructorUsedError;
  String? get remoteUserId => throw _privateConstructorUsedError;

  /// Create a copy of CallState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CallStateCopyWith<CallState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CallStateCopyWith<$Res> {
  factory $CallStateCopyWith(CallState value, $Res Function(CallState) then) =
      _$CallStateCopyWithImpl<$Res, CallState>;
  @useResult
  $Res call(
      {bool isConnected,
      bool isConnecting,
      bool isMuted,
      bool isSpeakerOn,
      CallStatus status,
      String? errorMessage,
      String? localUserId,
      String? remoteUserId});
}

/// @nodoc
class _$CallStateCopyWithImpl<$Res, $Val extends CallState>
    implements $CallStateCopyWith<$Res> {
  _$CallStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CallState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isConnected = null,
    Object? isConnecting = null,
    Object? isMuted = null,
    Object? isSpeakerOn = null,
    Object? status = null,
    Object? errorMessage = freezed,
    Object? localUserId = freezed,
    Object? remoteUserId = freezed,
  }) {
    return _then(_value.copyWith(
      isConnected: null == isConnected
          ? _value.isConnected
          : isConnected // ignore: cast_nullable_to_non_nullable
              as bool,
      isConnecting: null == isConnecting
          ? _value.isConnecting
          : isConnecting // ignore: cast_nullable_to_non_nullable
              as bool,
      isMuted: null == isMuted
          ? _value.isMuted
          : isMuted // ignore: cast_nullable_to_non_nullable
              as bool,
      isSpeakerOn: null == isSpeakerOn
          ? _value.isSpeakerOn
          : isSpeakerOn // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as CallStatus,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      localUserId: freezed == localUserId
          ? _value.localUserId
          : localUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      remoteUserId: freezed == remoteUserId
          ? _value.remoteUserId
          : remoteUserId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CallStateImplCopyWith<$Res>
    implements $CallStateCopyWith<$Res> {
  factory _$$CallStateImplCopyWith(
          _$CallStateImpl value, $Res Function(_$CallStateImpl) then) =
      __$$CallStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isConnected,
      bool isConnecting,
      bool isMuted,
      bool isSpeakerOn,
      CallStatus status,
      String? errorMessage,
      String? localUserId,
      String? remoteUserId});
}

/// @nodoc
class __$$CallStateImplCopyWithImpl<$Res>
    extends _$CallStateCopyWithImpl<$Res, _$CallStateImpl>
    implements _$$CallStateImplCopyWith<$Res> {
  __$$CallStateImplCopyWithImpl(
      _$CallStateImpl _value, $Res Function(_$CallStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of CallState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isConnected = null,
    Object? isConnecting = null,
    Object? isMuted = null,
    Object? isSpeakerOn = null,
    Object? status = null,
    Object? errorMessage = freezed,
    Object? localUserId = freezed,
    Object? remoteUserId = freezed,
  }) {
    return _then(_$CallStateImpl(
      isConnected: null == isConnected
          ? _value.isConnected
          : isConnected // ignore: cast_nullable_to_non_nullable
              as bool,
      isConnecting: null == isConnecting
          ? _value.isConnecting
          : isConnecting // ignore: cast_nullable_to_non_nullable
              as bool,
      isMuted: null == isMuted
          ? _value.isMuted
          : isMuted // ignore: cast_nullable_to_non_nullable
              as bool,
      isSpeakerOn: null == isSpeakerOn
          ? _value.isSpeakerOn
          : isSpeakerOn // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as CallStatus,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      localUserId: freezed == localUserId
          ? _value.localUserId
          : localUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      remoteUserId: freezed == remoteUserId
          ? _value.remoteUserId
          : remoteUserId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$CallStateImpl implements _CallState {
  const _$CallStateImpl(
      {this.isConnected = false,
      this.isConnecting = false,
      this.isMuted = false,
      this.isSpeakerOn = false,
      this.status = CallStatus.idle,
      this.errorMessage,
      this.localUserId,
      this.remoteUserId});

  @override
  @JsonKey()
  final bool isConnected;
  @override
  @JsonKey()
  final bool isConnecting;
  @override
  @JsonKey()
  final bool isMuted;
  @override
  @JsonKey()
  final bool isSpeakerOn;
  @override
  @JsonKey()
  final CallStatus status;
  @override
  final String? errorMessage;
  @override
  final String? localUserId;
  @override
  final String? remoteUserId;

  @override
  String toString() {
    return 'CallState(isConnected: $isConnected, isConnecting: $isConnecting, isMuted: $isMuted, isSpeakerOn: $isSpeakerOn, status: $status, errorMessage: $errorMessage, localUserId: $localUserId, remoteUserId: $remoteUserId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CallStateImpl &&
            (identical(other.isConnected, isConnected) ||
                other.isConnected == isConnected) &&
            (identical(other.isConnecting, isConnecting) ||
                other.isConnecting == isConnecting) &&
            (identical(other.isMuted, isMuted) || other.isMuted == isMuted) &&
            (identical(other.isSpeakerOn, isSpeakerOn) ||
                other.isSpeakerOn == isSpeakerOn) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.localUserId, localUserId) ||
                other.localUserId == localUserId) &&
            (identical(other.remoteUserId, remoteUserId) ||
                other.remoteUserId == remoteUserId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isConnected, isConnecting,
      isMuted, isSpeakerOn, status, errorMessage, localUserId, remoteUserId);

  /// Create a copy of CallState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CallStateImplCopyWith<_$CallStateImpl> get copyWith =>
      __$$CallStateImplCopyWithImpl<_$CallStateImpl>(this, _$identity);
}

abstract class _CallState implements CallState {
  const factory _CallState(
      {final bool isConnected,
      final bool isConnecting,
      final bool isMuted,
      final bool isSpeakerOn,
      final CallStatus status,
      final String? errorMessage,
      final String? localUserId,
      final String? remoteUserId}) = _$CallStateImpl;

  @override
  bool get isConnected;
  @override
  bool get isConnecting;
  @override
  bool get isMuted;
  @override
  bool get isSpeakerOn;
  @override
  CallStatus get status;
  @override
  String? get errorMessage;
  @override
  String? get localUserId;
  @override
  String? get remoteUserId;

  /// Create a copy of CallState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CallStateImplCopyWith<_$CallStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
