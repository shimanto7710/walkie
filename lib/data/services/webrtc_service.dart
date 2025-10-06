import 'dart:async';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/call_state.dart';
import '../../domain/entities/signal_message.dart';
import '../../domain/repositories/webrtc_repository.dart';
import 'signaling_manager.dart';

class WebRTCService implements WebRTCRepository {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  
  final SignalingManager _signalingManager = SignalingManager();
  final StreamController<CallState> _callStateController = StreamController<CallState>.broadcast();
  
  CallState _currentCallState = const CallState();
  String? _currentUserId;
  String? _remoteUserId;
  StreamSubscription<SignalMessage>? _signalSubscription;

  @override
  CallState get currentCallState => _currentCallState;

  @override
  Stream<CallState> get callStateStream => _callStateController.stream;

  @override
  Stream<SignalMessage> get signalStream => _signalingManager.incomingSignals;

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      log('🔧 Initializing WebRTC service...');
      
      // Initialize video renderers with error handling
      try {
        await _localRenderer.initialize();
        await _remoteRenderer.initialize();
        log('✅ Video renderers initialized');
      } catch (e) {
        log('⚠️ Video renderer initialization failed: $e');
        // Continue without video renderers for audio-only calls
      }
      
      // Create peer connection with error handling
      try {
        _peerConnection = await _createPeerConnection();
        log('✅ Peer connection created');
      } catch (e) {
        log('❌ Failed to create peer connection: $e');
        return Left(Failure.serverFailure('Failed to create peer connection: $e'));
      }
      
      // Get user media (microphone) with error handling
      try {
        _localStream = await _getUserMedia();
        if (_localStream != null) {
          _localRenderer.srcObject = _localStream;
          await _peerConnection?.addStream(_localStream!);
          log('✅ Local media stream created');
        } else {
          log('⚠️ No local media stream available');
        }
      } catch (e) {
        log('❌ Failed to get user media: $e');
        return Left(Failure.serverFailure('Failed to get microphone access: $e'));
      }
      
      // Set up signal listener
      try {
        _setupSignalListener();
        log('✅ Signal listener set up');
      } catch (e) {
        log('❌ Failed to set up signal listener: $e');
        return Left(Failure.serverFailure('Failed to set up signal listener: $e'));
      }
      
      // Set up periodic cleanup of old signals (every 5 minutes)
      Timer.periodic(const Duration(minutes: 5), (timer) {
        _signalingManager.deleteOldSignals(maxAgeMinutes: 3);
      });
      log('✅ Periodic signal cleanup scheduled');
      
      _updateCallState(_currentCallState.copyWith(isConnected: true));
      log('✅ WebRTC service initialized successfully');
      
      return const Right(null);
    } catch (e) {
      log('❌ Failed to initialize WebRTC service: $e');
      return Left(Failure.serverFailure('Failed to initialize WebRTC: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> dispose() async {
    try {
      log('🔧 Disposing WebRTC service...');
      
      await _signalSubscription?.cancel();
      await _peerConnection?.close();
      await _localStream?.dispose();
      await _remoteStream?.dispose();
      await _localRenderer.dispose();
      await _remoteRenderer.dispose();
      
      // Dispose signaling manager
      await _signalingManager.dispose();
      
      _callStateController.close();
      
      log('✅ WebRTC service disposed successfully');
      return const Right(null);
    } catch (e) {
      log('❌ Failed to dispose WebRTC service: $e');
      return Left(Failure.serverFailure('Failed to dispose WebRTC: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> startCall(String remoteUserId) async {
    try {
      log('📞 Starting call to $remoteUserId');
      
      _remoteUserId = remoteUserId;
      
      _updateCallState(_currentCallState.copyWith(
        status: CallStatus.calling,
        isConnecting: true,
        remoteUserId: remoteUserId,
      ));
      
      // Set up signaling manager with current user ID
      _signalingManager.setCurrentUserId(_currentUserId!);
      
      // Send call request with proper ID exchange
      await _signalingManager.sendCallRequest(_currentUserId!, remoteUserId);
      
      // Create offer
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      
      // Send offer with proper ID exchange
      await _signalingManager.sendOffer(_currentUserId!, remoteUserId, offer.sdp!);
      
      log('✅ Call started successfully');
      return const Right(null);
    } catch (e) {
      log('❌ Failed to start call: $e');
      _updateCallState(_currentCallState.copyWith(
        status: CallStatus.failed,
        errorMessage: 'Failed to start call: $e',
      ));
      return Left(Failure.serverFailure('Failed to start call: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> acceptCall() async {
    try {
      log('📞 Accepting call...');
      
      _updateCallState(_currentCallState.copyWith(
        status: CallStatus.connected,
        isConnecting: false,
      ));
      
      // Send call accepted with proper ID exchange
      await _signalingManager.sendCallAccepted(_currentUserId!, _remoteUserId!);
      
      log('✅ Call accepted successfully');
      return const Right(null);
    } catch (e) {
      log('❌ Failed to accept call: $e');
      return Left(Failure.serverFailure('Failed to accept call: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> rejectCall() async {
    try {
      log('📞 Rejecting call...');
      
      // Send call rejected with proper ID exchange
      await _signalingManager.sendCallRejected(_currentUserId!, _remoteUserId!);
      
      _updateCallState(_currentCallState.copyWith(
        status: CallStatus.ended,
        isConnecting: false,
      ));
      
      log('✅ Call rejected successfully');
      return const Right(null);
    } catch (e) {
      log('❌ Failed to reject call: $e');
      return Left(Failure.serverFailure('Failed to reject call: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> endCall() async {
    try {
      log('📞 Ending call...');
      
      // Send call ended with proper ID exchange
      if (_currentUserId != null && _remoteUserId != null) {
        await _signalingManager.sendCallEnded(_currentUserId!, _remoteUserId!);
        
        // Clean up all signals for this call room
        final roomId = _signalingManager.createRoomId(_currentUserId!, _remoteUserId!);
        await _signalingManager.deleteAllSignalsInRoom(roomId);
        log('🗑️ Cleaned up all signals for call room: $roomId');
      }
      
      _updateCallState(_currentCallState.copyWith(
        status: CallStatus.ended,
        isConnecting: false,
        isConnected: false,
      ));
      
      log('✅ Call ended successfully');
      return const Right(null);
    } catch (e) {
      log('❌ Failed to end call: $e');
      return Left(Failure.serverFailure('Failed to end call: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleMute() async {
    try {
      if (_localStream != null) {
        final audioTracks = _localStream!.getAudioTracks();
        if (audioTracks.isNotEmpty) {
          final isMuted = !audioTracks.first.enabled;
          audioTracks.first.enabled = isMuted;
          
          _updateCallState(_currentCallState.copyWith(isMuted: !isMuted));
          log('🎤 Microphone ${isMuted ? 'unmuted' : 'muted'}');
        }
      }
      return const Right(null);
    } catch (e) {
      log('❌ Failed to toggle mute: $e');
      return Left(Failure.serverFailure('Failed to toggle mute: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleSpeaker() async {
    try {
      // Note: Speaker toggle implementation depends on platform-specific code
      // This is a placeholder implementation
      final isSpeakerOn = !_currentCallState.isSpeakerOn;
      _updateCallState(_currentCallState.copyWith(isSpeakerOn: isSpeakerOn));
      log('🔊 Speaker ${isSpeakerOn ? 'on' : 'off'}');
      return const Right(null);
    } catch (e) {
      log('❌ Failed to toggle speaker: $e');
      return Left(Failure.serverFailure('Failed to toggle speaker: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendSignal(SignalMessage message) async {
    try {
      // Delegate to signaling manager for proper ID exchange
      await _signalingManager.sendSignal(message);
      log('📡 Signal sent: ${message.type}');
      return const Right(null);
    } catch (e) {
      log('❌ Failed to send signal: $e');
      return Left(Failure.serverFailure('Failed to send signal: $e'));
    }
  }

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }


  void _setupSignalListener() {
    // Set up listener for incoming signals from signaling manager
    _signalSubscription = _signalingManager.incomingSignals.listen((message) {
      _handleIncomingSignal(message);
    });
  }

  void _handleIncomingSignal(SignalMessage message) async {
    try {
      switch (message.type) {
        case 'callRequest':
          _updateCallState(_currentCallState.copyWith(
            status: CallStatus.ringing,
            remoteUserId: message.from,
          ));
          break;
          
        case 'offer':
          await _handleOffer(message);
          break;
          
        case 'answer':
          await _handleAnswer(message);
          break;
          
        case 'iceCandidate':
          await _handleIceCandidate(message);
          break;
          
        case 'callAccepted':
          _updateCallState(_currentCallState.copyWith(
            status: CallStatus.connected,
            isConnecting: false,
          ));
          break;
          
        case 'callRejected':
        case 'callEnded':
          _updateCallState(_currentCallState.copyWith(
            status: CallStatus.ended,
            isConnecting: false,
          ));
          break;
      }
    } catch (e) {
      log('❌ Failed to handle signal: $e');
    }
  }

  Future<void> _handleOffer(SignalMessage message) async {
    if (message.sdp != null) {
      final offer = RTCSessionDescription(message.sdp!, 'offer');
      await _peerConnection!.setRemoteDescription(offer);
      
      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      
      // Send answer with proper ID exchange
      await _signalingManager.sendAnswer(_currentUserId!, message.from, answer.sdp!);
    }
  }

  Future<void> _handleAnswer(SignalMessage message) async {
    if (message.sdp != null) {
      final answer = RTCSessionDescription(message.sdp!, 'answer');
      await _peerConnection!.setRemoteDescription(answer);
    }
  }

  Future<void> _handleIceCandidate(SignalMessage message) async {
    if (message.candidate != null) {
      final candidate = RTCIceCandidate(
        message.candidate!['candidate'],
        message.candidate!['sdpMid'],
        message.candidate!['sdpMLineIndex'],
      );
      await _peerConnection!.addCandidate(candidate);
    }
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ]
    };

    final peerConnection = await createPeerConnection(configuration);

    peerConnection.onIceCandidate = (candidate) async {
      if (candidate != null && _remoteUserId != null) {
        // Send ICE candidate with proper ID exchange
        await _signalingManager.sendIceCandidate(
          _currentUserId!,
          _remoteUserId!,
          {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          },
        );
      }
    };

    peerConnection.onAddStream = (stream) {
      _remoteStream = stream;
      _remoteRenderer.srcObject = stream;
      log('📺 Remote stream added');
    };

    return peerConnection;
  }

  Future<MediaStream> _getUserMedia() async {
    final constraints = {
      'audio': true,
      'video': false,
    };
    return await navigator.mediaDevices.getUserMedia(constraints);
  }

  void _updateCallState(CallState newState) {
    _currentCallState = newState;
    _callStateController.add(newState);
  }
}
