import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../../domain/entities/handshake.dart';
import '../../../../core/utils/Utils.dart';
import 'base_call_provider.dart';

part 'global_handshake_provider.g.dart';

@riverpod
class GlobalHandshakeNotifier extends _$GlobalHandshakeNotifier with BaseCallProvider {
  String? _currentHandshakeId;

  @override
  Handshake? build() {
    initializeServices();
    return null;
  }


  /// Listen to handshake changes for a specific user (as caller or receiver)
  void listenForUserHandshakes(String userId) {
    stopListening();
    
    // Listen to all handshakes where this user is either caller or receiver
    handshakeSubscription = handshakeService!
        .listenToUserHandshakes(userId)
        .listen(
          (handshake) async {
            state = handshake;
            
            // Check if current user is the receiver and call is initiated
            if (handshake.receiverId == userId && 
                handshake.status == 'call_initiate' && 
                !handshake.receiverIdSent) {
              
              // Initialize WebRTC service if needed
              await initializeWebRTC();
              
              // Set remote description with caller's SDP
              if (handshake.sdpOffer != null) {
                final remoteDescription = RTCSessionDescription(handshake.sdpOffer!, 'offer');
                await setRemoteDescription(remoteDescription);
              }
              
              // Create answer SDP
              final answerSdp = await createSdpAnswer();
              if (answerSdp != null) {
                await setLocalDescription(answerSdp);
              }
              
              // Add caller's ICE candidates
              if (handshake.iceCandidates != null) {
                for (final iceData in handshake.iceCandidates!) {
                  final candidate = RTCIceCandidate(
                    iceData['candidate'],
                    iceData['sdpMid'] ?? '0',
                    iceData['sdpMLineIndex'] ?? 0,
                  );
                  await addIceCandidate(candidate);
                }
                Utils.log('Receiver', 'Added ${handshake.iceCandidates!.length} ICE candidates from caller');
              }
              
              // Get receiver's ICE candidates
              final receiverIceCandidates = await gatherIceCandidates();


              final addStreamResult = await webrtcService?.addLocalStreamToPeerConnection();
              addStreamResult?.fold(
                (failure) {
                  Utils.log('Receiver', 'Failed to add local stream to peer connection: ${failure.message}');
                },
                (_) {
                  Utils.log('Receiver', 'Local audio stream added to peer connection for incoming call');
                },
              );

              // Call is now ready - SDP and ICE exchange completed
              Utils.log('Receiver', 'Incoming call is ready - SDP and ICE exchange completed');

              // Now initiate the actual call using WebRTC service
              Utils.log('Receiver', 'Initiating incoming call...');
              final callResult = await webrtcService?.acceptCall();
              callResult?.fold(
                (failure) {
                  Utils.log('Receiver', 'Failed to accept call: ${failure.message}');
                },
                (_) {
                  Utils.log('Receiver', 'Incoming call accepted successfully');
                },
              );

              // Only proceed if we have valid data
              if (answerSdp?.sdp != null) {
                // Update Firebase: change status to 'call_acknowledge' and set receiverIdSent to true
                _handleIncomingCall(handshake, answerSdp, receiverIceCandidates);
              } else {
                Utils.log('Receiver', 'Cannot proceed: Answer SDP is missing');
              }
            }
            
            // Handle close_call status for both caller and receiver
            if (handshake.status == 'close_call' && 
                (handshake.callerId == userId || handshake.receiverId == userId)) {
              Utils.log('Receiver', 'Close call detected in global provider for user: $userId');
              // The call screen will handle the actual call ending
            }
          },
          onError: (error) {
            Utils.log('Receiver', 'User handshake stream error: $error');
          },
        );
  }

  /// Handle incoming call: update Firebase and trigger navigation
  Future<void> _handleIncomingCall(Handshake handshake, RTCSessionDescription? answerSdp, List<RTCIceCandidate> receiverIceCandidates) async {
    try {
      // Update Firebase status and receiverIdSent in a single operation using shared utility
      await handshakeService?.updateHandshakeStatusAndReceiverSent(
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
      Utils.log('Receiver', 'Error handling incoming call: $e');
    }
  }

  /// Stop listening and reset state
  void stopListeningAndReset() {
    stopListening();
    _currentHandshakeId = null;
    state = null;
  }

  /// Dispose resources
  @override
  void dispose() {
    super.dispose();
  }
}
