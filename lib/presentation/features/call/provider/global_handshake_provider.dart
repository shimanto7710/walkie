import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/handshake.dart';
import '../../../../data/services/firebase_handshake_service.dart';

part 'global_handshake_provider.g.dart';

@riverpod
class GlobalHandshakeNotifier extends _$GlobalHandshakeNotifier {
  FirebaseHandshakeService? _handshakeService;
  StreamSubscription<Handshake>? _handshakeSubscription;
  String? _currentHandshakeId;

  @override
  Handshake? build() {
    _handshakeService = FirebaseHandshakeService();
    return null;
  }

  /// Start listening to a specific handshake from anywhere in the app
  void startListeningToHandshake({
    required String callerId,
    required String receiverId,
  }) {
    final handshakeId = _generateHandshakeId(callerId, receiverId);
    
    // Only start listening if it's a different handshake
    if (_currentHandshakeId != handshakeId) {
      _stopListening();
      _currentHandshakeId = handshakeId;
      
      _handshakeSubscription = _handshakeService
          ?.listenToHandshake(
            callerId: callerId,
            receiverId: receiverId,
          )
          ?.listen(
            (handshake) {
              print('🌍 Global handshake update: ${handshake.status}');
              state = handshake;
            },
            onError: (error) {
              print('❌ Global handshake stream error: $error');
            },
          );
    }
  }

  /// Listen to handshake changes for a specific user (as caller or receiver)
  void listenForUserHandshakes(String userId) {
    _stopListening();
    
    // Listen to all handshakes where this user is either caller or receiver
    _handshakeSubscription = _handshakeService
        ?.listenToUserHandshakes(userId)
        ?.listen(
          (handshake) {
            print('🌍 User handshake update: ${handshake.status}');
            state = handshake;
            
            // Check if current user is the receiver and call is initiated
            if (handshake.receiverId == userId && 
                handshake.status == 'call_initiate' && 
                !handshake.receiverIdSent) {
              
              print('📞 Incoming call detected for user: $userId');
              print('📞 Caller: ${handshake.callerId}');
              print('📞 Status: ${handshake.status}');
              
              // Update Firebase: change status to 'call_acknowledge' and set receiverIdSent to true
              _handleIncomingCall(handshake);
            }
            
            // Handle close_call status for both caller and receiver
            if (handshake.status == 'close_call' && 
                (handshake.callerId == userId || handshake.receiverId == userId)) {
              print('🌍 Close call detected in global provider for user: $userId');
              // The call screen will handle the actual call ending
            }
          },
          onError: (error) {
            print('❌ User handshake stream error: $error');
          },
        );
  }

  /// Handle incoming call: update Firebase and trigger navigation
  Future<void> _handleIncomingCall(Handshake handshake) async {
    try {
      // Update Firebase status and receiverIdSent in a single operation
      await _handshakeService?.updateHandshakeStatusAndReceiverSent(
        callerId: handshake.callerId,
        receiverId: handshake.receiverId,
        status: 'call_acknowledge',
        receiverIdSent: true,
      );
      
      print('✅ Firebase updated: status=call_acknowledge, receiverIdSent=true');
      
      // Note: Navigation to calling screen should be handled by the UI layer
      // The provider just updates the state, UI listens and navigates
      
    } catch (e) {
      print('❌ Error handling incoming call: $e');
    }
  }

  /// Stop listening to handshake changes
  void _stopListening() {
    _handshakeSubscription?.cancel();
    _handshakeSubscription = null;
  }

  /// Stop listening and reset state
  void stopListening() {
    _stopListening();
    _currentHandshakeId = null;
    state = null;
  }

  /// Generate consistent handshake ID
  String _generateHandshakeId(String callerId, String receiverId) {
    final sortedIds = [callerId, receiverId]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  /// Dispose resources
  void dispose() {
    _stopListening();
    _handshakeService?.dispose();
  }
}
