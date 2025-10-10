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
  String? _currentCallerId;
  String? _currentReceiverId;

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
    print('📞 endCall() called - updating state to ended');
    state = state.copyWith(
      status: CallStatus.ended,
      isConnecting: false,
      isConnected: false,
    );
    print('📞 Call state updated to: ${state.status}');
  }

  /// Close call and update Firebase status
  Future<void> closeCall({
    required String callerId,
    required String receiverId,
  }) async {
    try {
      print('📞 closeCall() called - updating Firebase to close_call');
      print('📞 Caller: $callerId, Receiver: $receiverId');
      
      // Update Firebase status to 'close_call'
      await _handshakeService?.updateHandshakeStatus(
        callerId: callerId,
        receiverId: receiverId,
        status: 'close_call',
      );
      
      // Update local state
      state = state.copyWith(
        status: CallStatus.ended,
        isConnecting: false,
        isConnected: false,
      );
      
      print('✅ Call closed and Firebase status updated to close_call');
      print('📞 Local call state updated to: ${state.status}');
    } catch (e) {
      print('❌ Error closing call: $e');
      // Still update local state even if Firebase fails
      state = state.copyWith(
        status: CallStatus.ended,
        isConnecting: false,
        isConnected: false,
      );
    }
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

  /// Start listening to handshake data changes (public method for incoming calls)
  void startListeningToHandshake({
    required String callerId,
    required String receiverId,
  }) {
    _startListening(callerId: callerId, receiverId: receiverId);
  }

  /// Start listening to handshake data changes
  void _startListening({
    required String callerId,
    required String receiverId,
  }) {
    _handshakeSubscription?.cancel();
    
    // Store current call participants
    _currentCallerId = callerId;
    _currentReceiverId = receiverId;
    
    _handshakeSubscription = _handshakeService
        ?.listenToHandshake(
          callerId: callerId,
          receiverId: receiverId,
        )
        ?.listen(
          (handshake) {
            print('📡 Handshake status changed: ${handshake.status}');
            print('📡 Handshake details: caller=${handshake.callerId}, receiver=${handshake.receiverId}');
            
            // Handle close_call status
            if (handshake.status == 'close_call') {
              print('📞 Close call detected - ending call for both parties');
              endCall();
            }
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
