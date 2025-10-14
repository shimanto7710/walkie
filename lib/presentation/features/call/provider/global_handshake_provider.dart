import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../../domain/entities/handshake.dart';
import '../../../../core/utils/Utils.dart';
import 'base_call_provider.dart';
import '../constants/call_constants.dart';

part 'global_handshake_provider.g.dart';

@riverpod
class GlobalHandshakeNotifier extends _$GlobalHandshakeNotifier with BaseCallProvider {
  String? _currentHandshakeId;

  @override
  Handshake? build() {
    initializeServices();
    return null;
  }


  void listenForUserHandshakes(String userId) {
    stopListening();
    
    handshakeSubscription = handshakeService!
        .listenToUserHandshakes(userId)
        .listen(
          (handshake) async {
            state = handshake;
            
            if (_shouldProcessIncomingCall(handshake, userId)) {
              await _processIncomingCall(handshake);
            }
            
            if (_shouldHandleCloseCall(handshake, userId)) {
              Utils.log(CallConstants.receiverRole, '${CallConstants.closeCallDetectedInGlobalProvider}: $userId');
            }
          },
          onError: (error) {
            Utils.log(CallConstants.receiverRole, '${CallConstants.userHandshakeStreamError}: $error');
          },
        );
  }

  bool _shouldProcessIncomingCall(Handshake handshake, String userId) {
    return handshake.receiverId == userId && 
           handshake.status == CallConstants.callInitiate && 
           !handshake.receiverIdSent;
  }

  bool _shouldHandleCloseCall(Handshake handshake, String userId) {
    return handshake.status == CallConstants.closeCall && 
           (handshake.callerId == userId || handshake.receiverId == userId);
  }

  Future<void> _processIncomingCall(Handshake handshake) async {
    await initializeWebRTC();
    await _setupRemoteDescription(handshake);
    final answerSdp = await _createAnswerSdp();
    await _processCallerIceCandidates(handshake);
    final receiverIceCandidates = await gatherIceCandidates();
    await _setupLocalMediaStream();
    await _acceptIncomingCall();
    
    if (answerSdp?.sdp != null) {
      await _handleIncomingCall(handshake, answerSdp, receiverIceCandidates);
    } else {
      Utils.log(CallConstants.receiverRole, CallConstants.cannotProceedAnswerSdpMissing);
    }
  }

  Future<void> _setupRemoteDescription(Handshake handshake) async {
    if (handshake.sdpOffer != null) {
      final remoteDescription = RTCSessionDescription(handshake.sdpOffer!, CallConstants.sdpOffer);
      await setRemoteDescription(remoteDescription);
    }
  }

  Future<RTCSessionDescription?> _createAnswerSdp() async {
    final answerSdp = await createSdpAnswer();
    if (answerSdp != null) {
      await setLocalDescription(answerSdp);
    }
    return answerSdp;
  }

  Future<void> _processCallerIceCandidates(Handshake handshake) async {
    if (handshake.iceCandidates == null) return;
    
    for (final iceData in handshake.iceCandidates!) {
      final candidate = RTCIceCandidate(
        iceData['candidate'],
        iceData['sdpMid'] ?? CallConstants.defaultSdpMid,
        iceData['sdpMLineIndex'] ?? CallConstants.defaultSdpMLineIndex,
      );
      await addIceCandidate(candidate);
    }
    Utils.log(CallConstants.receiverRole, '${CallConstants.addedIceCandidatesFromCaller} ${handshake.iceCandidates!.length} ICE candidates from caller');
  }

  Future<void> _setupLocalMediaStream() async {
    final addStreamResult = await webrtcService?.addLocalStreamToPeerConnection();
    addStreamResult?.fold(
      (failure) => Utils.log(CallConstants.receiverRole, '${CallConstants.failedToAddLocalStream}: ${failure.message}'),
      (_) => Utils.log(CallConstants.receiverRole, CallConstants.localAudioStreamAddedForIncomingCall),
    );
  }

  Future<void> _acceptIncomingCall() async {
    Utils.log(CallConstants.receiverRole, CallConstants.incomingCallIsReady);
    Utils.log(CallConstants.receiverRole, CallConstants.initiatingIncomingCall);
    
    final callResult = await webrtcService?.acceptCall();
    callResult?.fold(
      (failure) => Utils.log(CallConstants.receiverRole, '${CallConstants.failedToAcceptCall}: ${failure.message}'),
      (_) => Utils.log(CallConstants.receiverRole, CallConstants.incomingCallAcceptedSuccessfully),
    );
  }

  Future<void> _handleIncomingCall(Handshake handshake, RTCSessionDescription? answerSdp, List<RTCIceCandidate> receiverIceCandidates) async {
    try {
      await handshakeService?.updateHandshakeStatusAndReceiverSent(
        callerId: handshake.callerId,
        receiverId: handshake.receiverId,
        status: CallConstants.callAcknowledge,
        receiverIdSent: true,
        answerSdp: answerSdp,
        receiverIceCandidates: receiverIceCandidates,
      );
    } catch (e) {
      Utils.log(CallConstants.receiverRole, '${CallConstants.errorHandlingIncomingCall}: $e');
    }
  }

  void stopListeningAndReset() {
    stopListening();
    _currentHandshakeId = null;
    state = null;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
