import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../../domain/entities/call_state.dart';
import '../../../../domain/entities/handshake.dart';
import '../../../../data/services/firebase_handshake_service.dart';
import '../../../../data/services/handshake_operations.dart';
import '../../../../data/services/webrtc_service.dart';

part 'call_provider.g.dart';

@riverpod
class CallNotifier extends _$CallNotifier {
  FirebaseHandshakeService? _handshakeService;
  HandshakeOperations? _handshakeOperations;
  StreamSubscription<Handshake>? _handshakeSubscription;
  String? _currentCallerId;
  String? _currentReceiverId;
  WebRTCService? _webrtcService;

  @override
  CallState build() {
    _handshakeService = FirebaseHandshakeService();
    _handshakeOperations = HandshakeOperations();
    _webrtcService = FlutterWebRTCService.instance;
    // Initialize WebRTC service asynchronously
    _initializeWebRTCService();
    return const CallState();
  }

  /// Initialize WebRTC service
  Future<void> _initializeWebRTCService() async {
    if (_webrtcService != null) {
      final result = await _webrtcService!.initialize();
      result.fold(
        (failure) => print('❌ Failed to initialize WebRTC service: ${failure.message}'),
        (_) => print('✅ WebRTC service initialized successfully'),
      );
    }
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
      // Update Firebase status to 'close_call' using shared utility
      await _handshakeOperations?.updateHandshakeStatus(
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

      // Initialize WebRTC service

      // Create SDP and ICE for caller
      final sdpOffer = await _createSdpOffer();

      // Set local description to start ICE gathering
      if (sdpOffer != null) {
        await _webrtcService!.setLocalDescription(sdpOffer);
      }
      
      final iceCandidates = await _gatherIceCandidates();

      await _handshakeService?.initiateHandshake(
        callerId: callerId,
        receiverId: receiverId,
        sdpOffer: sdpOffer,
        iceCandidates: iceCandidates,
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
  }) async {
    _handshakeSubscription?.cancel();

    // Store current call participants
    _currentCallerId = callerId;
    _currentReceiverId = receiverId;


    // Pass SDP and ICE values to handshake
    _handshakeSubscription = _handshakeService!
        .listenToHandshake(
      callerId: callerId,
      receiverId: receiverId
    )
        .listen(
      (handshake) {
        // Handle close_call status
        if (handshake.status == 'close_call') {
          print('📞 Close call detected - ending call for both parties');
          endCall();
        } else if (handshake.status == "call_acknowledge") {
          print('📞 Call acknowledge received - setting up WebRTC connection');
          _handleCallAcknowledge(handshake);
        }
      },
      onError: (error) {
        print('❌ Handshake stream error: $error');
      },
    );
  }

  /// Create SDP offer
  Future<RTCSessionDescription?> _createSdpOffer() async {
    // Create SDP offer
    final offerResult = await _webrtcService!.createOffer();
    RTCSessionDescription? sdpOffer;
    
    offerResult.fold(
      (failure) => print('Failed to create offer: ${failure.message}'),
      (offer) {
        sdpOffer = offer;
      },
    );

    return sdpOffer;
  }

  /// Gather ICE candidates
  Future<List<RTCIceCandidate>> _gatherIceCandidates() async {
    List<RTCIceCandidate> iceCandidates = [];

    // Wait for ICE candidates to be gathered
    await Future.delayed(const Duration(milliseconds: 1000));

    // Get real ICE candidates from WebRTC service
    final realIceCandidates = _webrtcService!.getIceCandidates();
    iceCandidates.addAll(realIceCandidates);


    return iceCandidates;
  }

  /// Handle call acknowledge - set remote SDP and add ICE candidates
  Future<void> _handleCallAcknowledge(Handshake handshake) async {
    try {
      if (_webrtcService == null) {
        print('❌ WebRTC service not initialized');
        return;
      }

      // Ensure WebRTC service is properly initialized
      final initResult = await _webrtcService!.initialize();
      initResult.fold(
        (failure) {
          print('❌ Failed to initialize WebRTC service: ${failure.message}');
          return;
        },
        (_) {
          print('✅ WebRTC service ready for call acknowledge');
          return;
        },
      );

      // Set remote description with receiver's SDP answer
      if (handshake.sdpAnswer != null) {
        print('📞 Setting remote description with receiver SDP answer');
        final remoteDescription = RTCSessionDescription(handshake.sdpAnswer!, 'answer');
        final setRemoteResult = await _webrtcService!.setRemoteDescription(remoteDescription);
        
        setRemoteResult.fold(
          (failure) {
            print('❌ Failed to set remote description: ${failure.message}');
            return;
          },
          (_) {
            print('✅ Remote description set successfully');
            return;
          },
        );
      } else {
        print('❌ No SDP answer received from receiver');
        return;
      }

      // Add receiver's ICE candidates
      if (handshake.iceCandidatesFromReceiver != null && handshake.iceCandidatesFromReceiver!.isNotEmpty) {
        print('🧊 Adding ${handshake.iceCandidatesFromReceiver!.length} ICE candidates from receiver');
        
        for (final iceData in handshake.iceCandidatesFromReceiver!) {
          try {
            final candidate = RTCIceCandidate(
              iceData['candidate'] ?? '',
              iceData['sdpMid'] ?? '0',
              iceData['sdpMLineIndex'] ?? 0,
            );
            
            final addCandidateResult = await _webrtcService!.addIceCandidate(candidate);
            addCandidateResult.fold(
              (failure) {
                print('❌ Failed to add ICE candidate: ${failure.message}');
              },
              (_) {
                print('✅ ICE candidate added successfully');
              },
            );
          } catch (e) {
            print('❌ Error processing ICE candidate: $e');
          }
        }
      } else {
        print('⚠️ No ICE candidates received from receiver');
      }

      // Update call state to connected
      state = state.copyWith(
        status: CallStatus.connected,
        isConnecting: false,
        isConnected: true,
      );

      print('✅ WebRTC connection established successfully');

    } catch (e) {
      print('❌ Error handling call acknowledge: $e');
      state = state.copyWith(
        status: CallStatus.failed,
        isConnecting: false,
        isConnected: false,
        errorMessage: 'Failed to establish connection: $e',
      );
    }
  }

  /// Dispose resources
  void dispose() {
    _handshakeSubscription?.cancel();
    _handshakeService?.dispose();
  }
}
