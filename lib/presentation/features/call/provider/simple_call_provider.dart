import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/call_state.dart';
import '../../../../domain/entities/handshake.dart';
import '../../../../data/services/firebase_handshake_service.dart';

part 'simple_call_provider.g.dart';

@riverpod
class SimpleCallNotifier extends _$SimpleCallNotifier {
  FirebaseHandshakeService? _handshakeService;
  StreamSubscription<Handshake>? _handshakeSubscription;

  @override
  CallState build() {
    _handshakeService = FirebaseHandshakeService();
    return const CallState();
  }

  void startCall() {
    state = state.copyWith(
      status: CallStatus.calling,
      isConnecting: true,
    );
  }

  void acceptCall() {
    state = state.copyWith(
      status: CallStatus.connected,
      isConnecting: false,
      isConnected: true,
    );
  }

  void endCall() {
    state = state.copyWith(
      status: CallStatus.ended,
      isConnecting: false,
      isConnected: false,
    );
  }

  void reset() {
    _handshakeSubscription?.cancel();
    _handshakeSubscription = null;
    state = const CallState();
  }

  /// Initialize Firebase handshake when entering call
  Future<void> initiateHandshake({
    required String callerId,
    required String receiverId,
  }) async {
    try {
      await _handshakeService?.initiateHandshake(
        callerId: callerId,
        receiverId: receiverId,
      );
      
      // Start listening to handshake changes
      _startListening(callerId: callerId, receiverId: receiverId);
      
      print('✅ Firebase handshake initialized');
    } catch (e) {
      print('❌ Error initiating handshake: $e');
      rethrow;
    }
  }

  /// Start listening to handshake data changes
  void _startListening({
    required String callerId,
    required String receiverId,
  }) {
    _handshakeSubscription?.cancel();
    
    _handshakeSubscription = _handshakeService
        ?.listenToHandshake(
          callerId: callerId,
          receiverId: receiverId,
        )
        ?.listen(
          (handshake) {
            print('📡 Handshake status changed: ${handshake.status}');
            // Handle handshake status changes here
            // You can add more logic based on the status
          },
          onError: (error) {
            print('❌ Handshake stream error: $error');
          },
        );
  }

  /// Update handshake status
  Future<void> updateHandshakeStatus(String status) async {
    try {
      // You'll need to store callerId and receiverId in the state or pass them
      // For now, this is a placeholder - you can modify based on your needs
      print('📡 Updating handshake status to: $status');
    } catch (e) {
      print('❌ Error updating handshake status: $e');
      rethrow;
    }
  }

  /// Complete handshake
  Future<void> completeHandshake() async {
    try {
      // You'll need to store callerId and receiverId in the state or pass them
      // For now, this is a placeholder - you can modify based on your needs
      print('📡 Completing handshake');
    } catch (e) {
      print('❌ Error completing handshake: $e');
      rethrow;
    }
  }

  /// Dispose resources
  void dispose() {
    _handshakeSubscription?.cancel();
    _handshakeService?.dispose();
  }
}
