import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/entities/webrtc_connection_state.dart';
import '../../domain/entities/webrtc_media_stream.dart';
import '../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

abstract class MinimalWebRTCService {
  Future<Either<Failure, void>> initialize();
  Future<Either<Failure, void>> startCall(String remoteUserId);
  Future<Either<Failure, void>> acceptCall();
  Future<Either<Failure, void>> rejectCall();
  Future<Either<Failure, void>> endCall();
  Future<Either<Failure, void>> toggleMute();
  Future<Either<Failure, void>> toggleSpeaker();
  Future<Either<Failure, MediaStream>> getUserMedia(WebRTCMediaConstraints constraints);
  Stream<WebRTCConnectionState> get connectionStateStream;
  WebRTCConnectionState get currentState;
  
  // SDP Functions
  Future<Either<Failure, RTCSessionDescription>> createOffer();
  Future<Either<Failure, RTCSessionDescription>> createAnswer();
  Future<Either<Failure, void>> setLocalDescription(RTCSessionDescription description);
  Future<Either<Failure, void>> setRemoteDescription(RTCSessionDescription description);
  
  // ICE Functions
  List<RTCIceCandidate> getIceCandidates();
  Stream<RTCIceCandidate> get iceCandidateStream;
  Future<Either<Failure, void>> addIceCandidate(RTCIceCandidate candidate);
  
  void dispose();
}

class MinimalFlutterWebRTCService implements MinimalWebRTCService {
  // Singleton instance
  static MinimalFlutterWebRTCService? _instance;
  
  // Private constructor
  MinimalFlutterWebRTCService._internal();
  
  // Factory constructor that returns the singleton instance
  factory MinimalFlutterWebRTCService() {
    _instance ??= MinimalFlutterWebRTCService._internal();
    return _instance!;
  }
  
  // Static method to get the instance
  static MinimalFlutterWebRTCService get instance {
    _instance ??= MinimalFlutterWebRTCService._internal();
    return _instance!;
  }
  
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  
  final StreamController<WebRTCConnectionState> _connectionStateController =
      StreamController<WebRTCConnectionState>.broadcast();
  
  WebRTCConnectionState _currentState = const WebRTCConnectionState();
  bool _isInitialized = false;
  
  // ICE candidate collection
  final List<RTCIceCandidate> _iceCandidates = [];
  final StreamController<RTCIceCandidate> _iceCandidateController =
      StreamController<RTCIceCandidate>.broadcast();

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      if (_isInitialized) {
        return Left(const Failure.unknownFailure('WebRTC service already initialized'));
      }
      
      // Request permissions
      final permissionResult = await _requestPermissions();
      if (permissionResult.isLeft()) {
        return permissionResult;
      }
      
      // Create peer connection
      await _createPeerConnection();
      
      _isInitialized = true;
      _updateConnectionState(const WebRTCConnectionState(
        status: WebRTCConnectionStatus.disconnected,
        isInitialized: true,
      ));
      
      return const Right(null);
    } catch (e) {
      return Left(Failure.unknownFailure('Failed to initialize WebRTC service: $e'));
    }
  }

  Future<Either<Failure, void>> _requestPermissions() async {
    try {
      // Request microphone permission
      final micPermission = await Permission.microphone.request();
      if (!micPermission.isGranted) {
        return Left(const Failure.unknownFailure('Microphone permission denied'));
      }
      return const Right(null);
    } catch (e) {
      return Left(Failure.unknownFailure('Failed to request permissions: $e'));
    }
  }

  Future<void> _createPeerConnection() async {
    print('🔧 Creating peer connection...');
    
    final configuration = <String, dynamic>{
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };

    _peerConnection = await createPeerConnection(configuration, {
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': false,
      },
      'optional': [],
    });

    _setupPeerConnectionListeners();
  }

  void _setupPeerConnectionListeners() {
    print('🔧 Setting up peer connection listeners...');
    
    _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      print('🧊 ICE candidate received: ${candidate.candidate}');
      _iceCandidates.add(candidate);
      _iceCandidateController.add(candidate);
    };

    _peerConnection?.onAddStream = (MediaStream stream) {
      print('Remote stream added');
      _remoteStream = stream;
      _updateConnectionState(_currentState.copyWith(
        isRemoteAudioEnabled: stream.getAudioTracks().isNotEmpty,
      ));
    };

    _peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      print('Connection state: $state');
      WebRTCConnectionStatus status;
      switch (state) {
        case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
          status = WebRTCConnectionStatus.connected;
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateConnecting:
          status = WebRTCConnectionStatus.connecting;
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
          status = WebRTCConnectionStatus.disconnected;
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
          status = WebRTCConnectionStatus.failed;
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
          status = WebRTCConnectionStatus.closed;
          break;
        default:
          status = WebRTCConnectionStatus.disconnected;
      }
      _updateConnectionState(_currentState.copyWith(status: status));
    };
  }


  @override
  Future<Either<Failure, MediaStream>> getUserMedia(WebRTCMediaConstraints constraints) async {
    try {
      final mediaConstraints = <String, dynamic>{
        'audio': constraints.audio ? {
          'echoCancellation': constraints.audioConstraints.echoCancellation,
          'noiseSuppression': constraints.audioConstraints.noiseSuppression,
          'autoGainControl': constraints.audioConstraints.autoGainControl,
          'sampleRate': constraints.audioConstraints.sampleRate,
          'channelCount': constraints.audioConstraints.channelCount,
        } : false,
        'video': false,
      };

      final stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localStream = stream;

      _updateConnectionState(_currentState.copyWith(
        isLocalAudioEnabled: stream.getAudioTracks().isNotEmpty,
      ));

      return Right(stream);
    } catch (e) {
      return Left(Failure.unknownFailure('Failed to get user media: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> startCall(String remoteUserId) async {
    try {
      if (!_isInitialized) {
        return Left(Failure.unknownFailure('WebRTC service not initialized'));
      }

      _updateConnectionState(_currentState.copyWith(
        status: WebRTCConnectionStatus.connecting,
        remoteUserId: remoteUserId,
      ));

      // Get user media
      final mediaResult = await getUserMedia(const WebRTCMediaConstraints(audio: true));
      if (mediaResult.isLeft()) {
        return mediaResult;
      }

      // Simulate call start
      await Future.delayed(const Duration(seconds: 1));
      
      _updateConnectionState(_currentState.copyWith(
        status: WebRTCConnectionStatus.connected,
      ));

      return const Right(null);
    } catch (e) {
      return Left(Failure.unknownFailure('Failed to start call: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> acceptCall() async {
    try {
      if (!_isInitialized) {
        return Left(Failure.unknownFailure('WebRTC service not initialized'));
      }

      _updateConnectionState(_currentState.copyWith(
        status: WebRTCConnectionStatus.connecting,
      ));

      // Get user media
      final mediaResult = await getUserMedia(const WebRTCMediaConstraints(audio: true));
      if (mediaResult.isLeft()) {
        return mediaResult;
      }

      // Simulate call acceptance
      await Future.delayed(const Duration(seconds: 1));
      
      _updateConnectionState(_currentState.copyWith(
        status: WebRTCConnectionStatus.connected,
      ));

      return const Right(null);
    } catch (e) {
      return Left(Failure.unknownFailure('Failed to accept call: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> rejectCall() async {
    try {
      _updateConnectionState(_currentState.copyWith(
        status: WebRTCConnectionStatus.disconnected,
      ));
      return const Right(null);
    } catch (e) {
      return Left(Failure.unknownFailure('Failed to reject call: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> endCall() async {
    try {
      _localStream?.dispose();
      _remoteStream?.dispose();
      
      _updateConnectionState(WebRTCConnectionState(
        status: WebRTCConnectionStatus.disconnected,
        isInitialized: _isInitialized,
      ));
      
      return const Right(null);
    } catch (e) {
      return Left(Failure.unknownFailure('Failed to end call: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleMute() async {
    try {
      if (_localStream == null) {
        return Left(Failure.unknownFailure('No local stream available'));
      }
      
      final audioTracks = _localStream!.getAudioTracks();
      for (final track in audioTracks) {
        track.enabled = !track.enabled;
      }
      
      _updateConnectionState(_currentState.copyWith(
        isMuted: !_currentState.isMuted,
        isLocalAudioEnabled: !_currentState.isMuted,
      ));

      return const Right(null);
    } catch (e) {
      return Left(Failure.unknownFailure('Failed to toggle mute: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleSpeaker() async {
    try {
      // In a real implementation, you would control the speaker here
      _updateConnectionState(_currentState.copyWith(
        isSpeakerOn: !_currentState.isSpeakerOn,
      ));

      return const Right(null);
    } catch (e) {
      return Left(Failure.unknownFailure('Failed to toggle speaker: $e'));
    }
  }

  void _updateConnectionState(WebRTCConnectionState newState) {
    _currentState = newState;
    _connectionStateController.add(newState);
  }

  @override
  Stream<WebRTCConnectionState> get connectionStateStream => _connectionStateController.stream;

  @override
  WebRTCConnectionState get currentState => _currentState;

  // SDP Functions
  @override
  Future<Either<Failure, RTCSessionDescription>> createOffer() async {
    try {
      if (_peerConnection == null) {
        return Left(Failure.unknownFailure('Peer connection not initialized'));
      }
      
      final offer = await _peerConnection!.createOffer();
      return Right(offer);
    } catch (e) {
      return Left(Failure.unknownFailure('Failed to create offer: $e'));
    }
  }

  @override
  Future<Either<Failure, RTCSessionDescription>> createAnswer() async {
    try {
      if (_peerConnection == null) {
        return Left(Failure.unknownFailure('Peer connection not initialized'));
      }
      
      final answer = await _peerConnection!.createAnswer();
      return Right(answer);
    } catch (e) {
      return Left(Failure.unknownFailure('Failed to create answer: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setLocalDescription(RTCSessionDescription description) async {
    try {
      if (_peerConnection == null) {
        return Left(Failure.unknownFailure('Peer connection not initialized'));
      }
      
      await _peerConnection!.setLocalDescription(description);
      return const Right(null);
    } catch (e) {
      return Left(Failure.unknownFailure('Failed to set local description: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setRemoteDescription(RTCSessionDescription description) async {
    try {
      if (_peerConnection == null) {
        return Left(Failure.unknownFailure('Peer connection not initialized'));
      }
      
      await _peerConnection!.setRemoteDescription(description);
      return const Right(null);
    } catch (e) {
      return Left(Failure.unknownFailure('Failed to set remote description: $e'));
    }
  }

  // ICE Functions
  @override
  List<RTCIceCandidate> getIceCandidates() {
    return List.from(_iceCandidates);
  }

  @override
  Stream<RTCIceCandidate> get iceCandidateStream => _iceCandidateController.stream;

  @override
  Future<Either<Failure, void>> addIceCandidate(RTCIceCandidate candidate) async {
    try {
      if (_peerConnection == null) {
        return Left(Failure.unknownFailure('Peer connection not initialized'));
      }
      
      await _peerConnection!.addCandidate(candidate);
      return const Right(null);
    } catch (e) {
      return Left(Failure.unknownFailure('Failed to add ICE candidate: $e'));
    }
  }

  @override
  void dispose() {
    _peerConnection?.close();
    _localStream?.dispose();
    _remoteStream?.dispose();
    _connectionStateController.close();
    _iceCandidateController.close();
    
    // Reset singleton instance
    _instance = null;
  }
  
  // Static method to dispose the singleton
  static void disposeInstance() {
    _instance?.dispose();
    _instance = null;
  }
}

