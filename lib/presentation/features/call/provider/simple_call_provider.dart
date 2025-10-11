import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../../domain/entities/call_state.dart';
import '../../../../domain/entities/handshake.dart';
import '../../../../data/services/firebase_handshake_service.dart';
import '../../../../data/services/handshake_operations.dart';
import '../../../../data/services/minimal_webrtc_service.dart';

part 'simple_call_provider.g.dart';

@riverpod
class SimpleCallNotifier extends _$SimpleCallNotifier {
  FirebaseHandshakeService? _handshakeService;
  HandshakeOperations? _handshakeOperations;
  StreamSubscription<Handshake>? _handshakeSubscription;
  String? _currentCallerId;
  String? _currentReceiverId;
  MinimalWebRTCService? _webrtcService;

  @override
  CallState build() {
    _handshakeService = FirebaseHandshakeService();
    _handshakeOperations = HandshakeOperations();
    _webrtcService = MinimalFlutterWebRTCService();
    _webrtcService!.initialize();
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

  /// Dispose resources
  void dispose() {
    _handshakeSubscription?.cancel();
    _handshakeService?.dispose();
  }
}
