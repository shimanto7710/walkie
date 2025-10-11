import 'package:freezed_annotation/freezed_annotation.dart';

part 'webrtc_connection_state.freezed.dart';

@freezed
class WebRTCConnectionState with _$WebRTCConnectionState {
  const factory WebRTCConnectionState({
    @Default(WebRTCConnectionStatus.disconnected) WebRTCConnectionStatus status,
    @Default(false) bool isInitialized,
    @Default(false) bool isMuted,
    @Default(false) bool isSpeakerOn,
    @Default(false) bool isAudioEnabled,
    @Default(false) bool isLocalAudioEnabled,
    @Default(false) bool isRemoteAudioEnabled,
    String? localUserId,
    String? remoteUserId,
    String? roomId,
    String? errorMessage,
    @Default(0) int connectionAttempts,
    @Default(0) int maxConnectionAttempts,
    DateTime? lastConnectedAt,
    DateTime? lastDisconnectedAt,
  }) = _WebRTCConnectionState;
}

enum WebRTCConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  failed,
  closed,
}

enum WebRTCMediaType {
  audio,
}

enum WebRTCConnectionType {
  peerToPeer,
  group,
  broadcast,
}
