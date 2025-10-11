// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'webrtc_configuration.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$WebRTCConfiguration {
  List<WebRTCIceServer> get iceServers => throw _privateConstructorUsedError;
  WebRTCIceTransportPolicy get iceTransportPolicy =>
      throw _privateConstructorUsedError;
  WebRTCBundlePolicy get bundlePolicy => throw _privateConstructorUsedError;
  WebRTCRtcpMuxPolicy get rtcpMuxPolicy => throw _privateConstructorUsedError;
  WebRTCSdpSemantics get sdpSemantics => throw _privateConstructorUsedError;
  int get connectionTimeoutSeconds => throw _privateConstructorUsedError;
  int get maxConnectionAttempts => throw _privateConstructorUsedError;
  bool get enableDtlsSrtp => throw _privateConstructorUsedError;
  bool get enableRtpDataChannels => throw _privateConstructorUsedError;

  /// Create a copy of WebRTCConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WebRTCConfigurationCopyWith<WebRTCConfiguration> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WebRTCConfigurationCopyWith<$Res> {
  factory $WebRTCConfigurationCopyWith(
          WebRTCConfiguration value, $Res Function(WebRTCConfiguration) then) =
      _$WebRTCConfigurationCopyWithImpl<$Res, WebRTCConfiguration>;
  @useResult
  $Res call(
      {List<WebRTCIceServer> iceServers,
      WebRTCIceTransportPolicy iceTransportPolicy,
      WebRTCBundlePolicy bundlePolicy,
      WebRTCRtcpMuxPolicy rtcpMuxPolicy,
      WebRTCSdpSemantics sdpSemantics,
      int connectionTimeoutSeconds,
      int maxConnectionAttempts,
      bool enableDtlsSrtp,
      bool enableRtpDataChannels});
}

/// @nodoc
class _$WebRTCConfigurationCopyWithImpl<$Res, $Val extends WebRTCConfiguration>
    implements $WebRTCConfigurationCopyWith<$Res> {
  _$WebRTCConfigurationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WebRTCConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? iceServers = null,
    Object? iceTransportPolicy = null,
    Object? bundlePolicy = null,
    Object? rtcpMuxPolicy = null,
    Object? sdpSemantics = null,
    Object? connectionTimeoutSeconds = null,
    Object? maxConnectionAttempts = null,
    Object? enableDtlsSrtp = null,
    Object? enableRtpDataChannels = null,
  }) {
    return _then(_value.copyWith(
      iceServers: null == iceServers
          ? _value.iceServers
          : iceServers // ignore: cast_nullable_to_non_nullable
              as List<WebRTCIceServer>,
      iceTransportPolicy: null == iceTransportPolicy
          ? _value.iceTransportPolicy
          : iceTransportPolicy // ignore: cast_nullable_to_non_nullable
              as WebRTCIceTransportPolicy,
      bundlePolicy: null == bundlePolicy
          ? _value.bundlePolicy
          : bundlePolicy // ignore: cast_nullable_to_non_nullable
              as WebRTCBundlePolicy,
      rtcpMuxPolicy: null == rtcpMuxPolicy
          ? _value.rtcpMuxPolicy
          : rtcpMuxPolicy // ignore: cast_nullable_to_non_nullable
              as WebRTCRtcpMuxPolicy,
      sdpSemantics: null == sdpSemantics
          ? _value.sdpSemantics
          : sdpSemantics // ignore: cast_nullable_to_non_nullable
              as WebRTCSdpSemantics,
      connectionTimeoutSeconds: null == connectionTimeoutSeconds
          ? _value.connectionTimeoutSeconds
          : connectionTimeoutSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      maxConnectionAttempts: null == maxConnectionAttempts
          ? _value.maxConnectionAttempts
          : maxConnectionAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      enableDtlsSrtp: null == enableDtlsSrtp
          ? _value.enableDtlsSrtp
          : enableDtlsSrtp // ignore: cast_nullable_to_non_nullable
              as bool,
      enableRtpDataChannels: null == enableRtpDataChannels
          ? _value.enableRtpDataChannels
          : enableRtpDataChannels // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WebRTCConfigurationImplCopyWith<$Res>
    implements $WebRTCConfigurationCopyWith<$Res> {
  factory _$$WebRTCConfigurationImplCopyWith(_$WebRTCConfigurationImpl value,
          $Res Function(_$WebRTCConfigurationImpl) then) =
      __$$WebRTCConfigurationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<WebRTCIceServer> iceServers,
      WebRTCIceTransportPolicy iceTransportPolicy,
      WebRTCBundlePolicy bundlePolicy,
      WebRTCRtcpMuxPolicy rtcpMuxPolicy,
      WebRTCSdpSemantics sdpSemantics,
      int connectionTimeoutSeconds,
      int maxConnectionAttempts,
      bool enableDtlsSrtp,
      bool enableRtpDataChannels});
}

/// @nodoc
class __$$WebRTCConfigurationImplCopyWithImpl<$Res>
    extends _$WebRTCConfigurationCopyWithImpl<$Res, _$WebRTCConfigurationImpl>
    implements _$$WebRTCConfigurationImplCopyWith<$Res> {
  __$$WebRTCConfigurationImplCopyWithImpl(_$WebRTCConfigurationImpl _value,
      $Res Function(_$WebRTCConfigurationImpl) _then)
      : super(_value, _then);

  /// Create a copy of WebRTCConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? iceServers = null,
    Object? iceTransportPolicy = null,
    Object? bundlePolicy = null,
    Object? rtcpMuxPolicy = null,
    Object? sdpSemantics = null,
    Object? connectionTimeoutSeconds = null,
    Object? maxConnectionAttempts = null,
    Object? enableDtlsSrtp = null,
    Object? enableRtpDataChannels = null,
  }) {
    return _then(_$WebRTCConfigurationImpl(
      iceServers: null == iceServers
          ? _value._iceServers
          : iceServers // ignore: cast_nullable_to_non_nullable
              as List<WebRTCIceServer>,
      iceTransportPolicy: null == iceTransportPolicy
          ? _value.iceTransportPolicy
          : iceTransportPolicy // ignore: cast_nullable_to_non_nullable
              as WebRTCIceTransportPolicy,
      bundlePolicy: null == bundlePolicy
          ? _value.bundlePolicy
          : bundlePolicy // ignore: cast_nullable_to_non_nullable
              as WebRTCBundlePolicy,
      rtcpMuxPolicy: null == rtcpMuxPolicy
          ? _value.rtcpMuxPolicy
          : rtcpMuxPolicy // ignore: cast_nullable_to_non_nullable
              as WebRTCRtcpMuxPolicy,
      sdpSemantics: null == sdpSemantics
          ? _value.sdpSemantics
          : sdpSemantics // ignore: cast_nullable_to_non_nullable
              as WebRTCSdpSemantics,
      connectionTimeoutSeconds: null == connectionTimeoutSeconds
          ? _value.connectionTimeoutSeconds
          : connectionTimeoutSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      maxConnectionAttempts: null == maxConnectionAttempts
          ? _value.maxConnectionAttempts
          : maxConnectionAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      enableDtlsSrtp: null == enableDtlsSrtp
          ? _value.enableDtlsSrtp
          : enableDtlsSrtp // ignore: cast_nullable_to_non_nullable
              as bool,
      enableRtpDataChannels: null == enableRtpDataChannels
          ? _value.enableRtpDataChannels
          : enableRtpDataChannels // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$WebRTCConfigurationImpl implements _WebRTCConfiguration {
  const _$WebRTCConfigurationImpl(
      {final List<WebRTCIceServer> iceServers = const [],
      this.iceTransportPolicy = WebRTCIceTransportPolicy.all,
      this.bundlePolicy = WebRTCBundlePolicy.balanced,
      this.rtcpMuxPolicy = WebRTCRtcpMuxPolicy.require,
      this.sdpSemantics = WebRTCSdpSemantics.unifiedPlan,
      this.connectionTimeoutSeconds = 30,
      this.maxConnectionAttempts = 5,
      this.enableDtlsSrtp = true,
      this.enableRtpDataChannels = true})
      : _iceServers = iceServers;

  final List<WebRTCIceServer> _iceServers;
  @override
  @JsonKey()
  List<WebRTCIceServer> get iceServers {
    if (_iceServers is EqualUnmodifiableListView) return _iceServers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_iceServers);
  }

  @override
  @JsonKey()
  final WebRTCIceTransportPolicy iceTransportPolicy;
  @override
  @JsonKey()
  final WebRTCBundlePolicy bundlePolicy;
  @override
  @JsonKey()
  final WebRTCRtcpMuxPolicy rtcpMuxPolicy;
  @override
  @JsonKey()
  final WebRTCSdpSemantics sdpSemantics;
  @override
  @JsonKey()
  final int connectionTimeoutSeconds;
  @override
  @JsonKey()
  final int maxConnectionAttempts;
  @override
  @JsonKey()
  final bool enableDtlsSrtp;
  @override
  @JsonKey()
  final bool enableRtpDataChannels;

  @override
  String toString() {
    return 'WebRTCConfiguration(iceServers: $iceServers, iceTransportPolicy: $iceTransportPolicy, bundlePolicy: $bundlePolicy, rtcpMuxPolicy: $rtcpMuxPolicy, sdpSemantics: $sdpSemantics, connectionTimeoutSeconds: $connectionTimeoutSeconds, maxConnectionAttempts: $maxConnectionAttempts, enableDtlsSrtp: $enableDtlsSrtp, enableRtpDataChannels: $enableRtpDataChannels)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WebRTCConfigurationImpl &&
            const DeepCollectionEquality()
                .equals(other._iceServers, _iceServers) &&
            (identical(other.iceTransportPolicy, iceTransportPolicy) ||
                other.iceTransportPolicy == iceTransportPolicy) &&
            (identical(other.bundlePolicy, bundlePolicy) ||
                other.bundlePolicy == bundlePolicy) &&
            (identical(other.rtcpMuxPolicy, rtcpMuxPolicy) ||
                other.rtcpMuxPolicy == rtcpMuxPolicy) &&
            (identical(other.sdpSemantics, sdpSemantics) ||
                other.sdpSemantics == sdpSemantics) &&
            (identical(
                    other.connectionTimeoutSeconds, connectionTimeoutSeconds) ||
                other.connectionTimeoutSeconds == connectionTimeoutSeconds) &&
            (identical(other.maxConnectionAttempts, maxConnectionAttempts) ||
                other.maxConnectionAttempts == maxConnectionAttempts) &&
            (identical(other.enableDtlsSrtp, enableDtlsSrtp) ||
                other.enableDtlsSrtp == enableDtlsSrtp) &&
            (identical(other.enableRtpDataChannels, enableRtpDataChannels) ||
                other.enableRtpDataChannels == enableRtpDataChannels));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_iceServers),
      iceTransportPolicy,
      bundlePolicy,
      rtcpMuxPolicy,
      sdpSemantics,
      connectionTimeoutSeconds,
      maxConnectionAttempts,
      enableDtlsSrtp,
      enableRtpDataChannels);

  /// Create a copy of WebRTCConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WebRTCConfigurationImplCopyWith<_$WebRTCConfigurationImpl> get copyWith =>
      __$$WebRTCConfigurationImplCopyWithImpl<_$WebRTCConfigurationImpl>(
          this, _$identity);
}

abstract class _WebRTCConfiguration implements WebRTCConfiguration {
  const factory _WebRTCConfiguration(
      {final List<WebRTCIceServer> iceServers,
      final WebRTCIceTransportPolicy iceTransportPolicy,
      final WebRTCBundlePolicy bundlePolicy,
      final WebRTCRtcpMuxPolicy rtcpMuxPolicy,
      final WebRTCSdpSemantics sdpSemantics,
      final int connectionTimeoutSeconds,
      final int maxConnectionAttempts,
      final bool enableDtlsSrtp,
      final bool enableRtpDataChannels}) = _$WebRTCConfigurationImpl;

  @override
  List<WebRTCIceServer> get iceServers;
  @override
  WebRTCIceTransportPolicy get iceTransportPolicy;
  @override
  WebRTCBundlePolicy get bundlePolicy;
  @override
  WebRTCRtcpMuxPolicy get rtcpMuxPolicy;
  @override
  WebRTCSdpSemantics get sdpSemantics;
  @override
  int get connectionTimeoutSeconds;
  @override
  int get maxConnectionAttempts;
  @override
  bool get enableDtlsSrtp;
  @override
  bool get enableRtpDataChannels;

  /// Create a copy of WebRTCConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WebRTCConfigurationImplCopyWith<_$WebRTCConfigurationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$WebRTCIceServer {
  List<String> get urls => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;
  String? get credential => throw _privateConstructorUsedError;
  WebRTCIceServerType get type => throw _privateConstructorUsedError;

  /// Create a copy of WebRTCIceServer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WebRTCIceServerCopyWith<WebRTCIceServer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WebRTCIceServerCopyWith<$Res> {
  factory $WebRTCIceServerCopyWith(
          WebRTCIceServer value, $Res Function(WebRTCIceServer) then) =
      _$WebRTCIceServerCopyWithImpl<$Res, WebRTCIceServer>;
  @useResult
  $Res call(
      {List<String> urls,
      String? username,
      String? credential,
      WebRTCIceServerType type});
}

/// @nodoc
class _$WebRTCIceServerCopyWithImpl<$Res, $Val extends WebRTCIceServer>
    implements $WebRTCIceServerCopyWith<$Res> {
  _$WebRTCIceServerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WebRTCIceServer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? urls = null,
    Object? username = freezed,
    Object? credential = freezed,
    Object? type = null,
  }) {
    return _then(_value.copyWith(
      urls: null == urls
          ? _value.urls
          : urls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      credential: freezed == credential
          ? _value.credential
          : credential // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as WebRTCIceServerType,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WebRTCIceServerImplCopyWith<$Res>
    implements $WebRTCIceServerCopyWith<$Res> {
  factory _$$WebRTCIceServerImplCopyWith(_$WebRTCIceServerImpl value,
          $Res Function(_$WebRTCIceServerImpl) then) =
      __$$WebRTCIceServerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String> urls,
      String? username,
      String? credential,
      WebRTCIceServerType type});
}

/// @nodoc
class __$$WebRTCIceServerImplCopyWithImpl<$Res>
    extends _$WebRTCIceServerCopyWithImpl<$Res, _$WebRTCIceServerImpl>
    implements _$$WebRTCIceServerImplCopyWith<$Res> {
  __$$WebRTCIceServerImplCopyWithImpl(
      _$WebRTCIceServerImpl _value, $Res Function(_$WebRTCIceServerImpl) _then)
      : super(_value, _then);

  /// Create a copy of WebRTCIceServer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? urls = null,
    Object? username = freezed,
    Object? credential = freezed,
    Object? type = null,
  }) {
    return _then(_$WebRTCIceServerImpl(
      urls: null == urls
          ? _value._urls
          : urls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      credential: freezed == credential
          ? _value.credential
          : credential // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as WebRTCIceServerType,
    ));
  }
}

/// @nodoc

class _$WebRTCIceServerImpl implements _WebRTCIceServer {
  const _$WebRTCIceServerImpl(
      {required final List<String> urls,
      this.username,
      this.credential,
      this.type = WebRTCIceServerType.stun})
      : _urls = urls;

  final List<String> _urls;
  @override
  List<String> get urls {
    if (_urls is EqualUnmodifiableListView) return _urls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_urls);
  }

  @override
  final String? username;
  @override
  final String? credential;
  @override
  @JsonKey()
  final WebRTCIceServerType type;

  @override
  String toString() {
    return 'WebRTCIceServer(urls: $urls, username: $username, credential: $credential, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WebRTCIceServerImpl &&
            const DeepCollectionEquality().equals(other._urls, _urls) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.credential, credential) ||
                other.credential == credential) &&
            (identical(other.type, type) || other.type == type));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_urls), username, credential, type);

  /// Create a copy of WebRTCIceServer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WebRTCIceServerImplCopyWith<_$WebRTCIceServerImpl> get copyWith =>
      __$$WebRTCIceServerImplCopyWithImpl<_$WebRTCIceServerImpl>(
          this, _$identity);
}

abstract class _WebRTCIceServer implements WebRTCIceServer {
  const factory _WebRTCIceServer(
      {required final List<String> urls,
      final String? username,
      final String? credential,
      final WebRTCIceServerType type}) = _$WebRTCIceServerImpl;

  @override
  List<String> get urls;
  @override
  String? get username;
  @override
  String? get credential;
  @override
  WebRTCIceServerType get type;

  /// Create a copy of WebRTCIceServer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WebRTCIceServerImplCopyWith<_$WebRTCIceServerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
