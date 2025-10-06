import 'package:freezed_annotation/freezed_annotation.dart';

part 'call_state.freezed.dart';

@freezed
class CallState with _$CallState {
  const factory CallState({
    @Default(false) bool isConnected,
    @Default(false) bool isConnecting,
    @Default(false) bool isMuted,
    @Default(false) bool isSpeakerOn,
    @Default(CallStatus.idle) CallStatus status,
    String? errorMessage,
    String? localUserId,
    String? remoteUserId,
  }) = _CallState;
}

enum CallStatus {
  idle,
  calling,
  ringing,
  connected,
  ended,
  failed,
}
