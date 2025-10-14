import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:walkie/core/utils/Utils.dart';
import '../../../../domain/entities/handshake.dart';
import '../../../../data/services/handshake_service.dart';
import '../../../../data/services/firebase_handshake_service.dart';
import '../../../../data/services/webrtc_service.dart';

/// Mixin for common call functionality shared between providers
mixin BaseCallProvider {
  // Common services
  HandshakeService? _handshakeService;
  WebRTCService? _webrtcService;
  StreamSubscription<Handshake>? _handshakeSubscription;

  // Getters for subclasses
  HandshakeService? get handshakeService => _handshakeService;
  WebRTCService? get webrtcService => _webrtcService;
  StreamSubscription<Handshake>? get handshakeSubscription => _handshakeSubscription;
  
  // Setter for handshake subscription
  set handshakeSubscription(StreamSubscription<Handshake>? subscription) {
    _handshakeSubscription = subscription;
  }

  /// Initialize common services
  void initializeServices() {
    _handshakeService = FirebaseHandshakeService();
    _webrtcService = FlutterWebRTCService.instance;
  }

  /// Initialize WebRTC service with error handling
  Future<void> initializeWebRTC() async {
    if (_webrtcService != null) {
      final result = await _webrtcService!.initialize();
      result.fold(
        (failure) => Utils.log('WebRTC', 'Failed to initialize WebRTC service: ${failure.message}'),
        (_) => Utils.log('WebRTC', 'WebRTC service initialized successfully'),
      );
    }
  }

  /// Handle WebRTC errors consistently
  void handleWebRTCError(String operation, dynamic error) {
    Utils.log('WebRTC', 'WebRTC $operation error: $error');
  }

  /// Create SDP offer with error handling
  Future<RTCSessionDescription?> createSdpOffer() async {
    try {
      if (_webrtcService == null) {
        Utils.log('WebRTC', 'WebRTC service not initialized');
        return null;
      }

      Utils.log('WebRTC', '=== SDP OFFER CREATION ===');
      final offerResult = await _webrtcService!.createOffer();
      RTCSessionDescription? sdpOffer;
      
      offerResult.fold(
        (failure) {
          Utils.log('WebRTC', 'Failed to create offer: ${failure.message}');
          throw Exception('SDP offer creation failed: ${failure.message}');
        },
        (offer) {
          sdpOffer = offer;
          Utils.log('WebRTC', 'SDP offer created successfully');
          Utils.log('WebRTC', 'SDP Type: ${offer.type}');
          Utils.log('WebRTC', 'SDP Length: ${offer.sdp?.length ?? 0} characters');
          Utils.log('WebRTC', 'SDP Preview: ${offer.sdp?.substring(0, 100)}...');
          Utils.log('WebRTC', '=== END SDP OFFER ===');
        },
      );

      return sdpOffer;
    } catch (e) {
      handleWebRTCError('createSdpOffer', e);
      return null;
    }
  }

  /// Create SDP answer with error handling
  Future<RTCSessionDescription?> createSdpAnswer() async {
    try {
      if (_webrtcService == null) {
        Utils.log('WebRTC', 'WebRTC service not initialized');
        return null;
      }

      Utils.log('WebRTC', '=== SDP ANSWER CREATION ===');
      final answerResult = await _webrtcService!.createAnswer();
      RTCSessionDescription? sdpAnswer;
      
      answerResult.fold(
        (failure) {
          Utils.log('WebRTC', 'Failed to create answer: ${failure.message}');
          throw Exception('SDP answer creation failed: ${failure.message}');
        },
        (answer) {
          sdpAnswer = answer;
          Utils.log('WebRTC', 'SDP answer created successfully');
          Utils.log('WebRTC', 'SDP Type: ${answer.type}');
          Utils.log('WebRTC', 'SDP Length: ${answer.sdp?.length ?? 0} characters');
          Utils.log('WebRTC', 'SDP Preview: ${answer.sdp?.substring(0, 100)}...');
          Utils.log('WebRTC', '=== END SDP ANSWER ===');
        },
      );

      return sdpAnswer;
    } catch (e) {
      handleWebRTCError('createSdpAnswer', e);
      return null;
    }
  }

  /// Gather ICE candidates with timeout
  Future<List<RTCIceCandidate>> gatherIceCandidates() async {
    List<RTCIceCandidate> iceCandidates = [];
    
    if (_webrtcService == null) {
      print('❌ WebRTC service not initialized');
      return iceCandidates;
    }
    
    Utils.log('WebRTC', '=== ICE CANDIDATE GATHERING ===');
    Utils.log('WebRTC', 'Starting ICE candidate gathering...');
    
    // Wait for ICE candidates to be gathered with timeout
    const maxWaitTime = Duration(seconds: 3);
    const checkInterval = Duration(milliseconds: 100);
    int waitedTime = 0;
    
    while (waitedTime < maxWaitTime.inMilliseconds) {
      await Future.delayed(checkInterval);
      waitedTime += checkInterval.inMilliseconds;
      
      // Get current ICE candidates
      final currentCandidates = _webrtcService!.getIceCandidates();
      if (currentCandidates.isNotEmpty) {
        iceCandidates = List.from(currentCandidates);
        Utils.log('WebRTC', 'Gathered ${iceCandidates.length} ICE candidates');
        
        // Log details of each ICE candidate
        for (int i = 0; i < iceCandidates.length; i++) {
          final candidate = iceCandidates[i];
          Utils.log('WebRTC', 'ICE Candidate ${i + 1}:');
          Utils.log('WebRTC', '   Candidate: ${candidate.candidate}');
          Utils.log('WebRTC', '   SDP Mid: ${candidate.sdpMid}');
          Utils.log('WebRTC', '   SDP MLine Index: ${candidate.sdpMLineIndex}');
        }
        break;
      }
    }
    
    if (iceCandidates.isEmpty) {
      Utils.log('WebRTC', 'No ICE candidates gathered within ${maxWaitTime.inSeconds}s timeout');
    }
    
    Utils.log('WebRTC', '=== END ICE GATHERING ===');
    return iceCandidates;
  }

  /// Set local description with error handling
  Future<bool> setLocalDescription(RTCSessionDescription description) async {
    try {
      if (_webrtcService == null) {
        Utils.log('WebRTC', 'WebRTC service not initialized');
        return false;
      }

      final result = await _webrtcService!.setLocalDescription(description);
      return result.fold(
        (failure) {
          Utils.log('WebRTC', 'Failed to set local description: ${failure.message}');
          return false;
        },
        (_) {
          Utils.log('WebRTC', 'Local description set successfully');
          return true;
        },
      );
    } catch (e) {
      handleWebRTCError('setLocalDescription', e);
      return false;
    }
  }

  /// Set remote description with error handling
  Future<bool> setRemoteDescription(RTCSessionDescription description) async {
    try {
      if (_webrtcService == null) {
        Utils.log('WebRTC', 'WebRTC service not initialized');
        return false;
      }

      final result = await _webrtcService!.setRemoteDescription(description);
      return result.fold(
        (failure) {
          Utils.log('WebRTC', 'Failed to set remote description: ${failure.message}');
          return false;
        },
        (_) {
          Utils.log('WebRTC', 'Remote description set successfully');
          return true;
        },
      );
    } catch (e) {
      handleWebRTCError('setRemoteDescription', e);
      return false;
    }
  }

  /// Add ICE candidate with error handling
  Future<bool> addIceCandidate(RTCIceCandidate candidate) async {
    try {
      if (_webrtcService == null) {
        Utils.log('WebRTC', 'WebRTC service not initialized');
        return false;
      }

      final result = await _webrtcService!.addIceCandidate(candidate);
      return result.fold(
        (failure) {
          Utils.log('WebRTC', 'Failed to add ICE candidate: ${failure.message}');
          return false;
        },
        (_) {
          Utils.log('WebRTC', 'ICE candidate added successfully');
          return true;
        },
      );
    } catch (e) {
      handleWebRTCError('addIceCandidate', e);
      return false;
    }
  }

  /// Stop listening to handshake changes
  void stopListening() {
    Utils.log('Handshake', 'Stopping handshake listener');
    _handshakeSubscription?.cancel();
    _handshakeSubscription = null;
  }

  /// Dispose common resources
  void dispose() {
    stopListening();
    _handshakeService?.dispose();
  }
}
