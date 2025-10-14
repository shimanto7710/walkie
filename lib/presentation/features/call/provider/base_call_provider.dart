import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:walkie/core/utils/Utils.dart';
import '../../../../domain/entities/handshake.dart';
import '../../../../data/services/handshake_service.dart';
import '../../../../data/services/firebase_handshake_service.dart';
import '../../../../data/services/webrtc_service.dart';
import '../constants/call_constants.dart';

mixin BaseCallProvider {
  static const Duration _iceGatheringTimeout = Duration(seconds: 3);
  static const Duration _iceGatheringCheckInterval = Duration(milliseconds: 100);
  
  HandshakeService? _handshakeService;
  WebRTCService? _webrtcService;
  StreamSubscription<Handshake>? _handshakeSubscription;

  HandshakeService? get handshakeService => _handshakeService;
  WebRTCService? get webrtcService => _webrtcService;
  StreamSubscription<Handshake>? get handshakeSubscription => _handshakeSubscription;
  
  set handshakeSubscription(StreamSubscription<Handshake>? subscription) {
    _handshakeSubscription = subscription;
  }

  void initializeServices() {
    _handshakeService = FirebaseHandshakeService();
    _webrtcService = FlutterWebRTCService.instance;
  }

  Future<void> initializeWebRTC() async {
    if (_webrtcService == null) return;
    
    final result = await _webrtcService!.initialize();
    result.fold(
      (failure) => Utils.log(CallConstants.webRtcRole, '${CallConstants.failedToInitializeWebRtcService}: ${failure.message}'),
      (_) => Utils.log(CallConstants.webRtcRole, CallConstants.webRtcServiceInitializedSuccessfully),
    );
  }

  void _logWebRTCError(String operation, dynamic error) {
    Utils.log(CallConstants.webRtcRole, '${CallConstants.webRtcOperationError}: $operation - $error');
  }

  Future<RTCSessionDescription?> createSdpOffer() async {
    try {
      if (_webrtcService == null) {
        Utils.log(CallConstants.webRtcRole, CallConstants.webRtcServiceNotInitialized);
        return null;
      }

      Utils.log(CallConstants.webRtcRole, CallConstants.creatingSdpOffer);
      final offerResult = await _webrtcService!.createOffer();
      
      return offerResult.fold(
        (failure) {
          Utils.log(CallConstants.webRtcRole, 'Failed to create offer: ${failure.message}');
          throw Exception('${CallConstants.sdpOfferCreationFailedMessage}: ${failure.message}');
        },
        (offer) {
          Utils.log(CallConstants.webRtcRole, CallConstants.sdpOfferCreatedSuccessfully);
          Utils.log(CallConstants.webRtcRole, '${CallConstants.sdpType}: ${offer.type}, ${CallConstants.sdpLength}: ${offer.sdp?.length ?? 0}');
          return offer;
        },
      );
    } catch (e) {
      _logWebRTCError('createSdpOffer', e);
      return null;
    }
  }

  Future<RTCSessionDescription?> createSdpAnswer() async {
    try {
      if (_webrtcService == null) {
        Utils.log(CallConstants.webRtcRole, CallConstants.webRtcServiceNotInitialized);
        return null;
      }

      Utils.log(CallConstants.webRtcRole, CallConstants.creatingSdpAnswer);
      final answerResult = await _webrtcService!.createAnswer();
      
      return answerResult.fold(
        (failure) {
          Utils.log(CallConstants.webRtcRole, 'Failed to create answer: ${failure.message}');
          throw Exception('${CallConstants.sdpAnswerCreationFailedMessage}: ${failure.message}');
        },
        (answer) {
          Utils.log(CallConstants.webRtcRole, CallConstants.sdpAnswerCreatedSuccessfully);
          Utils.log(CallConstants.webRtcRole, '${CallConstants.sdpType}: ${answer.type}, ${CallConstants.sdpLength}: ${answer.sdp?.length ?? 0}');
          return answer;
        },
      );
    } catch (e) {
      _logWebRTCError('createSdpAnswer', e);
      return null;
    }
  }

  Future<List<RTCIceCandidate>> gatherIceCandidates() async {
    if (_webrtcService == null) {
      Utils.log(CallConstants.webRtcRole, CallConstants.webRtcServiceNotInitialized);
      return [];
    }
    
    Utils.log(CallConstants.webRtcRole, CallConstants.gatheringIceCandidates);
    
    int waitedTime = 0;
    while (waitedTime < _iceGatheringTimeout.inMilliseconds) {
      await Future.delayed(_iceGatheringCheckInterval);
      waitedTime += _iceGatheringCheckInterval.inMilliseconds;
      
      final currentCandidates = _webrtcService!.getIceCandidates();
      if (currentCandidates.isNotEmpty) {
        Utils.log(CallConstants.webRtcRole, '${CallConstants.gatheredIceCandidates} ${currentCandidates.length} ICE candidates');
        return List.from(currentCandidates);
      }
    }
    
    Utils.log(CallConstants.webRtcRole, '${CallConstants.noIceCandidatesGathered} ${_iceGatheringTimeout.inSeconds}${CallConstants.timeoutSeconds}');
    return [];
  }

  Future<bool> setLocalDescription(RTCSessionDescription description) async {
    try {
      if (_webrtcService == null) {
        Utils.log(CallConstants.webRtcRole, CallConstants.webRtcServiceNotInitialized);
        return false;
      }

      final result = await _webrtcService!.setLocalDescription(description);
      return result.fold(
        (failure) {
          Utils.log(CallConstants.webRtcRole, '${CallConstants.failedToSetLocalDescription}: ${failure.message}');
          return false;
        },
        (_) {
          Utils.log(CallConstants.webRtcRole, CallConstants.localDescriptionSetSuccessfully);
          return true;
        },
      );
    } catch (e) {
      _logWebRTCError('setLocalDescription', e);
      return false;
    }
  }

  Future<bool> setRemoteDescription(RTCSessionDescription description) async {
    try {
      if (_webrtcService == null) {
        Utils.log(CallConstants.webRtcRole, CallConstants.webRtcServiceNotInitialized);
        return false;
      }

      final result = await _webrtcService!.setRemoteDescription(description);
      return result.fold(
        (failure) {
          Utils.log(CallConstants.webRtcRole, '${CallConstants.failedToSetRemoteDescription}: ${failure.message}');
          return false;
        },
        (_) {
          Utils.log(CallConstants.webRtcRole, CallConstants.remoteDescriptionSetSuccessfully);
          return true;
        },
      );
    } catch (e) {
      _logWebRTCError('setRemoteDescription', e);
      return false;
    }
  }

  Future<bool> addIceCandidate(RTCIceCandidate candidate) async {
    try {
      if (_webrtcService == null) {
        Utils.log(CallConstants.webRtcRole, CallConstants.webRtcServiceNotInitialized);
        return false;
      }

      final result = await _webrtcService!.addIceCandidate(candidate);
      return result.fold(
        (failure) {
          Utils.log(CallConstants.webRtcRole, '${CallConstants.failedToAddIceCandidate}: ${failure.message}');
          return false;
        },
        (_) {
          Utils.log(CallConstants.webRtcRole, CallConstants.iceCandidateAddedSuccessfully);
          return true;
        },
      );
    } catch (e) {
      _logWebRTCError('addIceCandidate', e);
      return false;
    }
  }

  void stopListening() {
    Utils.log(CallConstants.handshakeRole, CallConstants.stoppingHandshakeListener);
    _handshakeSubscription?.cancel();
    _handshakeSubscription = null;
  }

  void dispose() {
    stopListening();
    _handshakeService?.dispose();
  }
}
