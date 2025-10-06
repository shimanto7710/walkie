import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/call_state.dart';
import '../../../../domain/repositories/webrtc_repository.dart';
import '../../../../data/services/webrtc_service.dart';
import '../../../../data/services/webrtc_service_simple.dart';
import '../../../../core/di/injection.dart';

part 'webrtc_provider.g.dart';

@riverpod
class WebRTCNotifier extends _$WebRTCNotifier {
  late WebRTCRepository _webrtcRepository;

  @override
  CallState build() {
    _webrtcRepository = getIt<WebRTCRepository>();
    print('🔍 WebRTC Provider - Repository type: ${_webrtcRepository.runtimeType}');
    return const CallState();
  }

  Future<void> initialize(String userId) async {
    try {
      print('🔧 Initializing WebRTC for user: $userId');
      
      // Set current user ID
      if (_webrtcRepository is WebRTCService) {
        print('🔧 Setting current user ID for WebRTCService: $userId');
        (_webrtcRepository as WebRTCService).setCurrentUserId(userId);
      } else if (_webrtcRepository is WebRTCServiceSimple) {
        print('🔧 Setting current user ID for WebRTCServiceSimple: $userId');
        (_webrtcRepository as WebRTCServiceSimple).setCurrentUserId(userId);
      } else {
        print('❌ Unknown WebRTC repository type: ${_webrtcRepository.runtimeType}');
      }
      
      // Initialize WebRTC
      final result = await _webrtcRepository.initialize();
      result.fold(
        (failure) {
          print('❌ Failed to initialize WebRTC: ${failure.message}');
          state = state.copyWith(
            errorMessage: failure.message,
            status: CallStatus.failed,
          );
        },
        (_) {
          print('✅ WebRTC initialized successfully');
          state = state.copyWith(
            localUserId: userId,
            status: CallStatus.idle,
          );
        },
      );
    } catch (e) {
      print('❌ Exception during WebRTC initialization: $e');
      state = state.copyWith(
        errorMessage: 'Failed to initialize WebRTC: $e',
        status: CallStatus.failed,
      );
    }
  }

  Future<void> startCall(String remoteUserId) async {
    try {
      print('📞 Starting call to: $remoteUserId');
      
      final result = await _webrtcRepository.startCall(remoteUserId);
      result.fold(
        (failure) {
          print('❌ Failed to start call: ${failure.message}');
          state = state.copyWith(
            errorMessage: failure.message,
            status: CallStatus.failed,
          );
        },
        (_) {
          print('✅ Call started successfully');
          // State will be updated by the WebRTC service stream
        },
      );
    } catch (e) {
      print('❌ Exception during call start: $e');
      state = state.copyWith(
        errorMessage: 'Failed to start call: $e',
        status: CallStatus.failed,
      );
    }
  }

  Future<void> acceptCall() async {
    try {
      print('📞 Accepting call...');
      
      final result = await _webrtcRepository.acceptCall();
      result.fold(
        (failure) {
          print('❌ Failed to accept call: ${failure.message}');
          state = state.copyWith(
            errorMessage: failure.message,
            status: CallStatus.failed,
          );
        },
        (_) {
          print('✅ Call accepted successfully');
        },
      );
    } catch (e) {
      print('❌ Exception during call accept: $e');
      state = state.copyWith(
        errorMessage: 'Failed to accept call: $e',
        status: CallStatus.failed,
      );
    }
  }

  Future<void> rejectCall() async {
    try {
      print('📞 Rejecting call...');
      
      final result = await _webrtcRepository.rejectCall();
      result.fold(
        (failure) {
          print('❌ Failed to reject call: ${failure.message}');
        },
        (_) {
          print('✅ Call rejected successfully');
        },
      );
    } catch (e) {
      print('❌ Exception during call reject: $e');
    }
  }

  Future<void> endCall() async {
    try {
      print('📞 Ending call...');
      
      final result = await _webrtcRepository.endCall();
      result.fold(
        (failure) {
          print('❌ Failed to end call: ${failure.message}');
        },
        (_) {
          print('✅ Call ended successfully');
        },
      );
    } catch (e) {
      print('❌ Exception during call end: $e');
    }
  }

  Future<void> toggleMute() async {
    try {
      print('🎤 Toggling mute...');
      
      final result = await _webrtcRepository.toggleMute();
      result.fold(
        (failure) {
          print('❌ Failed to toggle mute: ${failure.message}');
        },
        (_) {
          print('✅ Mute toggled successfully');
        },
      );
    } catch (e) {
      print('❌ Exception during mute toggle: $e');
    }
  }

  Future<void> toggleSpeaker() async {
    try {
      print('🔊 Toggling speaker...');
      
      final result = await _webrtcRepository.toggleSpeaker();
      result.fold(
        (failure) {
          print('❌ Failed to toggle speaker: ${failure.message}');
        },
        (_) {
          print('✅ Speaker toggled successfully');
        },
      );
    } catch (e) {
      print('❌ Exception during speaker toggle: $e');
    }
  }

  Future<void> dispose() async {
    try {
      print('🔧 Disposing WebRTC...');
      
      final result = await _webrtcRepository.dispose();
      result.fold(
        (failure) {
          print('❌ Failed to dispose WebRTC: ${failure.message}');
        },
        (_) {
          print('✅ WebRTC disposed successfully');
          state = const CallState();
        },
      );
    } catch (e) {
      print('❌ Exception during WebRTC dispose: $e');
    }
  }
}

@riverpod
Stream<CallState> callStateStream(CallStateStreamRef ref) {
  final webrtcRepository = getIt<WebRTCRepository>();
  return webrtcRepository.callStateStream;
}

@riverpod
WebRTCRepository webrtcRepository(WebrtcRepositoryRef ref) {
  return getIt<WebRTCRepository>();
}
