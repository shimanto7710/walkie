import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../../domain/entities/handshake.dart';
import '../../../../data/services/firebase_handshake_service.dart';
import '../../../../data/services/handshake_operations.dart';
import '../../../../data/services/webrtc_service.dart';

/// Mixin for common call functionality shared between providers
mixin BaseCallProvider {
  // Common services
  FirebaseHandshakeService? _handshakeService;
  HandshakeOperations? _handshakeOperations;
  WebRTCService? _webrtcService;
  StreamSubscription<Handshake>? _handshakeSubscription;

  // Getters for subclasses
  FirebaseHandshakeService? get handshakeService => _handshakeService;
  HandshakeOperations? get handshakeOperations => _handshakeOperations;
  WebRTCService? get webrtcService => _webrtcService;
  StreamSubscription<Handshake>? get handshakeSubscription => _handshakeSubscription;
  
  // Setter for handshake subscription
  set handshakeSubscription(StreamSubscription<Handshake>? subscription) {
    _handshakeSubscription = subscription;
  }

  /// Initialize common services
  void initializeServices() {
    _handshakeService = FirebaseHandshakeService();
    _handshakeOperations = HandshakeOperations();
    _webrtcService = FlutterWebRTCService.instance;
  }

  /// Initialize WebRTC service with error handling
  Future<void> initializeWebRTC() async {
    if (_webrtcService != null) {
      final result = await _webrtcService!.initialize();
      result.fold(
        (failure) => print('❌ Failed to initialize WebRTC service: ${failure.message}'),
        (_) => print('✅ WebRTC service initialized successfully'),
      );
    }
  }

  /// Handle WebRTC errors consistently
  void handleWebRTCError(String operation, dynamic error) {
    print('❌ WebRTC $operation error: $error');
  }

  /// Create SDP offer with error handling
  Future<RTCSessionDescription?> createSdpOffer() async {
    try {
      if (_webrtcService == null) {
        print('❌ WebRTC service not initialized');
        return null;
      }

      final offerResult = await _webrtcService!.createOffer();
      RTCSessionDescription? sdpOffer;
      
      offerResult.fold(
        (failure) {
          print('❌ Failed to create offer: ${failure.message}');
          throw Exception('SDP offer creation failed: ${failure.message}');
        },
        (offer) {
          sdpOffer = offer;
          print('✅ SDP offer created successfully');
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
        print('❌ WebRTC service not initialized');
        return null;
      }

      final answerResult = await _webrtcService!.createAnswer();
      RTCSessionDescription? sdpAnswer;
      
      answerResult.fold(
        (failure) {
          print('❌ Failed to create answer: ${failure.message}');
          throw Exception('SDP answer creation failed: ${failure.message}');
        },
        (answer) {
          sdpAnswer = answer;
          print('✅ SDP answer created successfully');
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
        print('🧊 Gathered ${iceCandidates.length} ICE candidates');
        break;
      }
    }
    
    if (iceCandidates.isEmpty) {
      print('⚠️ No ICE candidates gathered within timeout');
    }

    return iceCandidates;
  }

  /// Set local description with error handling
  Future<bool> setLocalDescription(RTCSessionDescription description) async {
    try {
      if (_webrtcService == null) {
        print('❌ WebRTC service not initialized');
        return false;
      }

      final result = await _webrtcService!.setLocalDescription(description);
      return result.fold(
        (failure) {
          print('❌ Failed to set local description: ${failure.message}');
          return false;
        },
        (_) {
          print('✅ Local description set successfully');
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
        print('❌ WebRTC service not initialized');
        return false;
      }

      final result = await _webrtcService!.setRemoteDescription(description);
      return result.fold(
        (failure) {
          print('❌ Failed to set remote description: ${failure.message}');
          return false;
        },
        (_) {
          print('✅ Remote description set successfully');
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
        print('❌ WebRTC service not initialized');
        return false;
      }

      final result = await _webrtcService!.addIceCandidate(candidate);
      return result.fold(
        (failure) {
          print('❌ Failed to add ICE candidate: ${failure.message}');
          return false;
        },
        (_) {
          print('✅ ICE candidate added successfully');
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
    _handshakeSubscription?.cancel();
    _handshakeSubscription = null;
  }

  /// Dispose common resources
  void dispose() {
    stopListening();
    _handshakeService?.dispose();
  }
}
