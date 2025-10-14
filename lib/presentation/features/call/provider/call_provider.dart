import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:walkie/core/utils/Utils.dart';
import '../../../../domain/entities/call_state.dart';
import '../../../../domain/entities/handshake.dart';
import '../../../../domain/entities/webrtc_media_stream.dart';
import 'base_call_provider.dart';
import '../constants/call_constants.dart';

part 'call_provider.g.dart';

@riverpod
class CallNotifier extends _$CallNotifier with BaseCallProvider {
  String? _currentCallerId;
  String? _currentReceiverId;

  @override
  CallState build() {
    initializeServices();
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

  Future<void> toggleMicrophone(bool isEnabled) async {
    try {
      if (webrtcService == null) {
        Utils.log(CallConstants.callerRole, CallConstants.webRtcServiceNotAvailableForMicrophone);
        return;
      }

      Utils.log(CallConstants.callerRole, '${CallConstants.togglingMicrophone}: ${isEnabled ? CallConstants.microphoneOn : CallConstants.microphoneOff}');
      
      final result = await webrtcService!.toggleMute();
      result.fold(
        (failure) {
          Utils.log(CallConstants.callerRole, '${CallConstants.failedToToggleMicrophone}: ${failure.message}');
          state = state.copyWith(isMuted: !isEnabled);
        },
        (_) {
          Utils.log(CallConstants.callerRole, '${CallConstants.microphoneToggledSuccessfully}: ${isEnabled ? CallConstants.microphoneOn : CallConstants.microphoneOff}');
          state = state.copyWith(isMuted: !isEnabled);
        },
      );
    } catch (e) {
      Utils.log(CallConstants.callerRole, '${CallConstants.errorTogglingMicrophone}: $e');
    }
  }

  Future<void> startPushToTalk() async {
    Utils.log(CallConstants.callerRole, CallConstants.startingPushToTalk);
    await toggleMicrophone(true);
  }

  Future<void> stopPushToTalk() async {
    Utils.log(CallConstants.callerRole, CallConstants.stoppingPushToTalk);
    await toggleMicrophone(false);
  }

  Future<void> closeCall({
    required String callerId,
    required String receiverId,
  }) async {
    try {
      Utils.log(CallConstants.callerRole, '${CallConstants.closingCallBetween} $callerId and $receiverId');
      await handshakeService?.updateHandshakeStatus(
        callerId: callerId,
        receiverId: receiverId,
        status: CallConstants.closeCall,
      );

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

  Future<void> initiateHandshake({
    required String callerId,
    required String receiverId,
  }) async {
    try {
      Utils.log(CallConstants.callerRole, '$callerId ${CallConstants.initiatingHandshakeBetween} $callerId and $receiverId');
      
      final sdpOffer = await createSdpOffer();
      if (sdpOffer != null) {
        Utils.log(CallConstants.callerRole, '$callerId ${CallConstants.settingLocalDescriptionWithSdpOffer}');
        await setLocalDescription(sdpOffer);
      }
      
      final iceCandidates = await gatherIceCandidates();
      Utils.log(CallConstants.callerRole, '$callerId ${CallConstants.gatheredIceCandidatesCount} ${iceCandidates.length} ICE candidates');

      await handshakeService?.initiateHandshake(
        callerId: callerId,
        receiverId: receiverId,
        sdpOffer: sdpOffer,
        iceCandidates: iceCandidates,
      );

      _startListening(callerId: callerId, receiverId: receiverId, isCaller: true);
      Utils.log(CallConstants.callerRole, '$callerId ${CallConstants.handshakeInitiatedSuccessfully}');
    } catch (e) {
      Utils.log(CallConstants.callerRole, '$callerId ${CallConstants.errorInitiatingHandshake}: $e');
      rethrow;
    }
  }

  void startListeningToHandshake({
    required String callerId,
    required String receiverId,
  }) {
    Utils.log(CallConstants.receiverRole, '$receiverId ${CallConstants.startingToListenToHandshake} $callerId and $receiverId');
    _startListening(callerId: callerId, receiverId: receiverId, isCaller: false);
  }

  void _startListening({
    required String callerId,
    required String receiverId,
    required bool isCaller,
  }) async {
    stopListening();

    _currentCallerId = callerId;
    _currentReceiverId = receiverId;

    final role = isCaller ? CallConstants.callerRole : CallConstants.receiverRole;
    final userId = isCaller ? callerId : receiverId;
    
    Utils.log(role, '$userId ${CallConstants.startingToListenToHandshakeChanges.replaceAll('role', role)}');

    handshakeSubscription = handshakeService!
        .listenToHandshake(
      callerId: callerId,
      receiverId: receiverId
    )
        .listen(
      (handshake) {
        Utils.log(role, '$userId ${CallConstants.receivedHandshakeStatus}: ${handshake.status}');
        
        if (handshake.status == CallConstants.closeCall) {
          Utils.log(role, '$userId ${CallConstants.callClosedByRemoteParty}');
          endCall();
        } else if (handshake.status == CallConstants.callAcknowledge) {
          if (isCaller) {
            Utils.log(role, '$userId ${CallConstants.handlingCallAcknowledgment}');
            _handleCallAcknowledge(handshake);
          } else {
            Utils.log(role, '$userId ${CallConstants.ignoringCallAcknowledgeStatus}');
          }
        }
      },
      onError: (error) {
        Utils.log(role, '${CallConstants.errorListeningToHandshake}: $error');
      },
    );
  }


  Future<void> _handleCallAcknowledge(Handshake handshake) async {
    try {
      if (webrtcService == null) {
        Utils.log(CallConstants.callerRole, CallConstants.webRtcServiceNotInitialized);
        return;
      }

      await initializeWebRTC();
      await _processSdpAnswer(handshake);
      await _processIceCandidates(handshake);
      await _setupLocalMediaStream();
      await _establishCall();
    } catch (e) {
      Utils.log(CallConstants.callerRole, '${CallConstants.errorHandlingCallAcknowledge}: $e');
      _updateCallStateToFailed('${CallConstants.failedToEstablishConnectionMessage}: $e');
    }
  }

  Future<void> _processSdpAnswer(Handshake handshake) async {
    if (handshake.sdpAnswer == null) {
      Utils.log(CallConstants.callerRole, CallConstants.noSdpAnswerReceived);
      throw Exception(CallConstants.noSdpAnswerReceivedMessage);
    }

    final remoteDescription = RTCSessionDescription(handshake.sdpAnswer!, CallConstants.sdpAnswer);
    await setRemoteDescription(remoteDescription);
  }

  Future<void> _processIceCandidates(Handshake handshake) async {
    if (handshake.iceCandidatesFromReceiver == null || handshake.iceCandidatesFromReceiver!.isEmpty) {
      Utils.log(CallConstants.callerRole, CallConstants.noIceCandidatesReceivedFromReceiver);
      return;
    }

    Utils.log(CallConstants.callerRole, '${CallConstants.addingIceCandidatesFromReceiver} ${handshake.iceCandidatesFromReceiver!.length} ICE candidates from receiver');
    
    for (final iceData in handshake.iceCandidatesFromReceiver!) {
      try {
        final candidate = RTCIceCandidate(
          iceData['candidate'] ?? CallConstants.emptyString,
          iceData['sdpMid'] ?? CallConstants.defaultSdpMid,
          iceData['sdpMLineIndex'] ?? CallConstants.defaultSdpMLineIndex,
        );
        await addIceCandidate(candidate);
      } catch (e) {
        Utils.log(CallConstants.callerRole, '${CallConstants.errorAddingIceCandidate}: $e');
      }
    }
  }

  Future<void> _setupLocalMediaStream() async {
    final mediaResult = await webrtcService!.getUserMedia(const WebRTCMediaConstraints(audio: true));
    if (mediaResult.isRight()) {
      Utils.log(CallConstants.callerRole, CallConstants.localMediaStreamObtainedSuccessfully);
      
      final addStreamResult = await webrtcService!.addLocalStreamToPeerConnection();
      addStreamResult.fold(
        (failure) => Utils.log(CallConstants.callerRole, '${CallConstants.failedToAddLocalAudioStream}: ${failure.message}'),
        (_) => Utils.log(CallConstants.callerRole, CallConstants.localAudioStreamAddedSuccessfully),
      );
    } else {
      Utils.log(CallConstants.callerRole, CallConstants.failedToObtainLocalMediaStream);
    }
  }

  Future<void> _establishCall() async {
    Utils.log(CallConstants.callerRole, CallConstants.callAcknowledgedByReceiver);

    final callResult = await webrtcService!.startCall(_currentReceiverId ?? CallConstants.emptyString);
    callResult.fold(
      (failure) {
        Utils.log(CallConstants.callerRole, '${CallConstants.failedToStartCall}: ${failure.message}');
        _updateCallStateToFailed('${CallConstants.failedToStartCallMessage}: ${failure.message}');
      },
      (_) {
        Utils.log(CallConstants.callerRole, CallConstants.webRtcCallEstablishedSuccessfully);
        state = state.copyWith(
          status: CallStatus.connected,
          isConnecting: false,
          isConnected: true,
        );
      },
    );
  }

  void _updateCallStateToFailed(String errorMessage) {
    state = state.copyWith(
      status: CallStatus.failed,
      isConnecting: false,
      isConnected: false,
      errorMessage: errorMessage,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
