import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:walkie/core/utils/Utils.dart';
import '../../../../domain/entities/call_state.dart';
import '../../../../domain/entities/handshake.dart';
import '../../../../domain/entities/webrtc_media_stream.dart';
import 'base_call_provider.dart';

part 'call_provider.g.dart';

@riverpod
class CallNotifier extends _$CallNotifier with BaseCallProvider {
  String? _currentCallerId;
  String? _currentReceiverId;

  @override
  CallState build() {
    initializeServices();
    // Initialize WebRTC service asynchronously
    initializeWebRTC();
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

  /// Close call and update Firebase status
  Future<void> closeCall({
    required String callerId,
    required String receiverId,
  }) async {
    try {
      Utils.log('Caller', 'Closing call between $callerId and $receiverId');
      // Update Firebase status to 'close_call' using shared utility
      await handshakeOperations?.updateHandshakeStatus(
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

    } catch (e) {
      state = state.copyWith(
        status: CallStatus.ended,
        isConnecting: false,
        isConnected: false,
      );
    }
  }

  void reset() {
    stopListening();
    state = const CallState();
  }

  /// Initialize Firebase handshake when entering call
  Future<void> initiateHandshake({
    required String callerId,
    required String receiverId,
  }) async {
    try {
      Utils.log('Caller', '$callerId Initiating handshake between $callerId and $receiverId');
      // Create SDP and ICE for caller
      final sdpOffer = await createSdpOffer();

      // Set local description to start ICE gathering
      if (sdpOffer != null) {
        // Utils.log('Caller', '$callerId Local SDP Offer: ${sdpOffer.sdp}');
        Utils.log('Caller', '$callerId Setting local description with SDP offer');
        await setLocalDescription(sdpOffer);
      }
      
      final iceCandidates = await gatherIceCandidates();
      Utils.log('Caller', '$callerId Gathered ${iceCandidates.length} ICE candidates');

      await handshakeService?.initiateHandshake(
        callerId: callerId,
        receiverId: receiverId,
        sdpOffer: sdpOffer,
        iceCandidates: iceCandidates,
      );

      // Start listening to handshake changes
      _startListening(callerId: callerId, receiverId: receiverId, isCaller: true);

      Utils.log('Caller', '$callerId Handshake initiated successfully between $callerId and $receiverId');
    } catch (e) {
      Utils.log('Caller', '$callerId Error initiating handshake: $e');
      rethrow;
    }
  }

  /// Start listening to handshake data changes (public method for incoming calls)
  void startListeningToHandshake({
    required String callerId,
    required String receiverId,
  }) {
    Utils.log('Receiver', '$receiverId Starting to listen to handshake between $callerId and $receiverId');
    _startListening(callerId: callerId, receiverId: receiverId, isCaller: false);
  }

  /// Start listening to handshake data changes
  void _startListening({
    required String callerId,
    required String receiverId,
    required bool isCaller,
  }) async {
    stopListening();

    // Store current call participants
    _currentCallerId = callerId;
    _currentReceiverId = receiverId;

    final role = isCaller ? 'Caller' : 'Receiver';
    final userId = isCaller ? callerId : receiverId;
    
    Utils.log(role, '$userId Starting to listen to handshake changes (Role: $role)');

    // Pass SDP and ICE values to handshake
    handshakeSubscription = handshakeService!
        .listenToHandshake(
      callerId: callerId,
      receiverId: receiverId
    )
        .listen(
      (handshake) {
        Utils.log(role, '$userId Received handshake status: ${handshake.status}');
        
        // Handle close_call status - both parties should handle this
        if (handshake.status == 'close_call') {
          Utils.log(role, '$userId Call closed by remote party');
          endCall();
        } 
        // Only CALLER handles call_acknowledge status
        else if (handshake.status == "call_acknowledge") {
          if (isCaller) {
            Utils.log(role, '$userId Handling call acknowledgment from receiver');
            _handleCallAcknowledge(handshake);
          } else {
            Utils.log(role, '$userId Ignoring call_acknowledge status (receiver should not handle this)');
          }
        }
        // Add other status handling here as needed
        // Only RECEIVER should handle certain statuses, only CALLER should handle others
      },
      onError: (error) {
        Utils.log(role, 'Error listening to handshake: $error');
      },
    );
  }


  /// Handle call acknowledge - set remote SDP and add ICE candidates
  Future<void> _handleCallAcknowledge(Handshake handshake) async {
    try {
      if (webrtcService == null) {
        Utils.log('Caller', 'WebRTC service not initialized');
        return;
      }

      // Ensure WebRTC service is properly initialized
      await initializeWebRTC();

      // Set remote description with receiver's SDP answer
      if (handshake.sdpAnswer != null) {
        // Utils.log('Caller', '${handshake.callerId} Setting remote description with SDP answer '+handshake.sdpAnswer!);
        final remoteDescription = RTCSessionDescription(handshake.sdpAnswer!, 'answer');
        await setRemoteDescription(remoteDescription);
      } else {
        Utils.log('Caller', 'No SDP answer received from receiver');
        return;
      }

      // Add receiver's ICE candidates
      if (handshake.iceCandidatesFromReceiver != null && handshake.iceCandidatesFromReceiver!.isNotEmpty) {
        Utils.log('Caller', 'Adding ${handshake.iceCandidatesFromReceiver!.length} ICE candidates from receiver');
        
        for (final iceData in handshake.iceCandidatesFromReceiver!) {
          try {
            final candidate = RTCIceCandidate(
              iceData['candidate'] ?? '',
              iceData['sdpMid'] ?? '0',
              iceData['sdpMLineIndex'] ?? 0,
            );
            
            await addIceCandidate(candidate);
          } catch (e) {
            Utils.log('Caller', 'Error adding ICE candidate: $e');
          }
        }
      } else {
       Utils.log('Caller', 'No ICE candidates received from receiver');
      }

      // Ensure we have local media stream for the call
      final mediaResult = await webrtcService!.getUserMedia(const WebRTCMediaConstraints(audio: true));
      if (mediaResult.isRight()) {
        Utils.log('Caller', 'Local media stream obtained successfully');
        
        // Add local stream to peer connection - this is crucial for call initiation
        final addStreamResult = await webrtcService!.addLocalStreamToPeerConnection();
        addStreamResult.fold(
          (failure) {
            Utils.log('Caller', 'Failed to add local audio stream to peer connection: ${failure.message}');
          },
          (_) {
            Utils.log('Caller', 'Local audio stream added to peer connection successfully');
          },
        );
      } else {
        Utils.log('Caller', 'Failed to obtain local media stream');
      }

      // Call is now ready - SDP and ICE exchange completed
      Utils.log('Caller', 'Call acknowledged by receiver, proceeding to establish connection');

      final callResult = await webrtcService!.startCall(_currentReceiverId ?? '');
      callResult.fold(
        (failure) {
          Utils.log('Caller', 'Failed to start call: ${failure.message}');
          state = state.copyWith(
            status: CallStatus.failed,
            isConnecting: false,
            isConnected: false,
            errorMessage: 'Failed to start call: ${failure.message}',
          );
        },
        (_) {
          Utils.log('Caller', 'WebRTC Call established successfully');
          
          // Update call state to connected
          state = state.copyWith(
            status: CallStatus.connected,
            isConnecting: false,
            isConnected: true,
          );

        },
      );

    } catch (e) {
      Utils.log('Caller', 'Error handling call acknowledge: $e');
      state = state.copyWith(
        status: CallStatus.failed,
        isConnecting: false,
        isConnected: false,
        errorMessage: 'Failed to establish connection: $e',
      );
    }
  }

  /// Dispose resources
  @override
  void dispose() {
    super.dispose();
  }
}
