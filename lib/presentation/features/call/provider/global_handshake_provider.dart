import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../../domain/entities/handshake.dart';
import '../../../../data/services/firebase_handshake_service.dart';
import '../../../../data/services/handshake_operations.dart';
import '../../../../data/services/minimal_webrtc_service.dart';

part 'global_handshake_provider.g.dart';

@riverpod
class GlobalHandshakeNotifier extends _$GlobalHandshakeNotifier {
  FirebaseHandshakeService? _handshakeService;
  HandshakeOperations? _handshakeOperations;
  StreamSubscription<Handshake>? _handshakeSubscription;
  String? _currentHandshakeId;
  MinimalWebRTCService? _webrtcService;

  @override
  Handshake? build() {
    _handshakeService = FirebaseHandshakeService();
    _handshakeOperations = HandshakeOperations();
    _webrtcService = MinimalFlutterWebRTCService();
    return null;
  }


  /// Listen to handshake changes for a specific user (as caller or receiver)
  void listenForUserHandshakes(String userId) {
    _stopListening();
    
    // Listen to all handshakes where this user is either caller or receiver
    _handshakeSubscription = _handshakeService!
        .listenToUserHandshakes(userId)
        .listen(
          (handshake) async {
            print('🌍 User handshake update: ${handshake.status}');
            state = handshake;
            
            // Check if current user is the receiver and call is initiated
            if (handshake.receiverId == userId && 
                handshake.status == 'call_initiate' && 
                !handshake.receiverIdSent) {
              
              // Ensure WebRTC service is initialized
              if (_webrtcService == null) {
                print('❌ WebRTC service not initialized');
                return;
              }
              
              // Initialize WebRTC service if needed
              final initResult = await _webrtcService!.initialize();
              initResult.fold(
                (failure) {
                  print('❌ Failed to initialize WebRTC: ${failure.message}');
                  return;
                },
                (_) {
                  print('✅ WebRTC service initialized');
                  return;
                },
              );
              
              // Set remote description with caller's SDP
              if (handshake.sdpOffer != null) {
                final remoteDescription = RTCSessionDescription(handshake.sdpOffer!, 'offer');
                await _webrtcService!.setRemoteDescription(remoteDescription);
              }
              
              // Create answer SDP
              RTCSessionDescription? answerSdp;
              final answerResult = await _webrtcService!.createAnswer();
              await answerResult.fold(
                (failure) async {
                  print('Failed to create answer: ${failure.message}');
                },
                (answer) async {
                  answerSdp = answer;
                  print('✅ Answer SDP created: ${answer.sdp?.length ?? 0} chars');
                  await _webrtcService!.setLocalDescription(answer);
                },
              );
              
              // Add caller's ICE candidates
              if (handshake.iceCandidates != null) {
                for (final iceData in handshake.iceCandidates!) {
                  final candidate = RTCIceCandidate(
                    iceData['candidate'],
                    iceData['sdpMid'] ?? '0',
                    iceData['sdpMLineIndex'] ?? 0,
                  );
                  await _webrtcService!.addIceCandidate(candidate);
                }
                print('🧊 Added ${handshake.iceCandidates!.length} ICE candidates from caller');
              }
              
              // Wait longer for receiver's ICE candidates to be generated
              print('⏳ Waiting for ICE candidates to be generated...');
              await Future.delayed(const Duration(milliseconds: 2000));
              
              // Get receiver's ICE candidates
              final receiverIceCandidates = _webrtcService!.getIceCandidates();


              // Only proceed if we have valid data
              if (answerSdp?.sdp != null) {
                // Update Firebase: change status to 'call_acknowledge' and set receiverIdSent to true
                _handleIncomingCall(handshake, answerSdp, receiverIceCandidates);
              } else {
                print('❌ Cannot proceed: Answer SDP is missing');
              }
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
  Future<void> _handleIncomingCall(Handshake handshake, RTCSessionDescription? answerSdp, List<RTCIceCandidate> receiverIceCandidates) async {
    try {
      // Update Firebase status and receiverIdSent in a single operation using shared utility
      await _handshakeOperations?.updateHandshakeStatusAndReceiverSent(
        callerId: handshake.callerId,
        receiverId: handshake.receiverId,
        status: 'call_acknowledge',
        receiverIdSent: true,
        answerSdp: answerSdp,
        receiverIceCandidates: receiverIceCandidates,
      );
      

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

  /// Dispose resources
  void dispose() {
    _stopListening();
    _handshakeService?.dispose();
  }
}
