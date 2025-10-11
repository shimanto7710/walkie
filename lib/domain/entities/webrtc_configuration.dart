import 'package:freezed_annotation/freezed_annotation.dart';

part 'webrtc_configuration.freezed.dart';

@freezed
class WebRTCConfiguration with _$WebRTCConfiguration {
  const factory WebRTCConfiguration({
    @Default([]) List<WebRTCIceServer> iceServers,
    @Default(WebRTCIceTransportPolicy.all) WebRTCIceTransportPolicy iceTransportPolicy,
    @Default(WebRTCBundlePolicy.balanced) WebRTCBundlePolicy bundlePolicy,
    @Default(WebRTCRtcpMuxPolicy.require) WebRTCRtcpMuxPolicy rtcpMuxPolicy,
    @Default(WebRTCSdpSemantics.unifiedPlan) WebRTCSdpSemantics sdpSemantics,
    @Default(30) int connectionTimeoutSeconds,
    @Default(5) int maxConnectionAttempts,
    @Default(true) bool enableDtlsSrtp,
    @Default(true) bool enableRtpDataChannels,
  }) = _WebRTCConfiguration;
}

@freezed
class WebRTCIceServer with _$WebRTCIceServer {
  const factory WebRTCIceServer({
    required List<String> urls,
    String? username,
    String? credential,
    @Default(WebRTCIceServerType.stun) WebRTCIceServerType type,
  }) = _WebRTCIceServer;
}

enum WebRTCIceTransportPolicy {
  all,
  relay,
}

enum WebRTCBundlePolicy {
  balanced,
  maxCompat,
  maxBundle,
}

enum WebRTCRtcpMuxPolicy {
  negotiate,
  require,
}

enum WebRTCSdpSemantics {
  planB,
  unifiedPlan,
}

enum WebRTCIceServerType {
  stun,
  turn,
  turns,
}

// Default STUN servers
const List<WebRTCIceServer> defaultIceServers = [
  WebRTCIceServer(
    urls: ['stun:stun.l.google.com:19302'],
    type: WebRTCIceServerType.stun,
  ),
  WebRTCIceServer(
    urls: ['stun:stun1.l.google.com:19302'],
    type: WebRTCIceServerType.stun,
  ),
];

// Default WebRTC configuration
const WebRTCConfiguration defaultWebRTCConfiguration = WebRTCConfiguration(
  iceServers: defaultIceServers,
  iceTransportPolicy: WebRTCIceTransportPolicy.all,
  bundlePolicy: WebRTCBundlePolicy.balanced,
  rtcpMuxPolicy: WebRTCRtcpMuxPolicy.require,
  sdpSemantics: WebRTCSdpSemantics.unifiedPlan,
  connectionTimeoutSeconds: 30,
  maxConnectionAttempts: 5,
  enableDtlsSrtp: true,
  enableRtpDataChannels: true,
);
