import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../../../domain/entities/call_state.dart';
import '../../../../domain/entities/webrtc_media_stream.dart';
import '../../../../data/services/minimal_webrtc_service.dart';

final webrtcCallStateProvider = StateNotifierProvider<WebRTCCallNotifier, CallState>((ref) {
  return WebRTCCallNotifier();
});

class WebRTCCallNotifier extends StateNotifier<CallState> {
  final MinimalWebRTCService _webrtcService = MinimalFlutterWebRTCService();

  WebRTCCallNotifier() : super(const CallState()) {
    _initializeWebRTC();
  }

  Future<void> _initializeWebRTC() async {
    final result = await _webrtcService.initialize();
    
    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        status: CallStatus.idle,
      ),
    );
  }

  Future<void> initialize() async {
    await _initializeWebRTC();
  }

  Future<void> startCall(String remoteUserId) async {
    state = state.copyWith(
      isConnecting: true,
      status: CallStatus.calling,
      remoteUserId: remoteUserId,
    );
    
    final result = await _webrtcService.startCall(remoteUserId);
    
    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: failure.message,
        isConnecting: false,
        status: CallStatus.failed,
      ),
      (_) => state = state.copyWith(
        isConnecting: false,
        status: CallStatus.calling,
      ),
    );
  }

  Future<void> acceptCall() async {
    state = state.copyWith(
      isConnecting: true,
      status: CallStatus.ringing,
    );
    
    final result = await _webrtcService.acceptCall();
    
    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: failure.message,
        isConnecting: false,
        status: CallStatus.failed,
      ),
      (_) => state = state.copyWith(
        isConnecting: false,
        isConnected: true,
        status: CallStatus.connected,
      ),
    );
  }

  Future<void> rejectCall() async {
    final result = await _webrtcService.rejectCall();
    
    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        status: CallStatus.ended,
        isConnected: false,
        isConnecting: false,
      ),
    );
  }

  Future<void> endCall() async {
    final result = await _webrtcService.endCall();
    
    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        status: CallStatus.ended,
        isConnected: false,
        isConnecting: false,
      ),
    );
  }

  Future<void> toggleMute() async {
    final result = await _webrtcService.toggleMute();
    
    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        isMuted: !state.isMuted,
      ),
    );
  }

  Future<void> toggleSpeaker() async {
    final result = await _webrtcService.toggleSpeaker();
    
    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        isSpeakerOn: !state.isSpeakerOn,
      ),
    );
  }

  void setLocalUserId(String userId) {
    state = state.copyWith(localUserId: userId);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void reset() {
    state = const CallState();
  }

  @override
  void dispose() {
    _webrtcService.dispose();
    super.dispose();
  }
}