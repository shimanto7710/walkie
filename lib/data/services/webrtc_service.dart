import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/entities/webrtc_connection_state.dart';
import '../../domain/entities/webrtc_media_stream.dart';
import '../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

abstract class WebRTCService {
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
  
  Future<Either<Failure, RTCSessionDescription>> createOffer();
  Future<Either<Failure, RTCSessionDescription>> createAnswer();
  Future<Either<Failure, void>> setLocalDescription(RTCSessionDescription description);
  Future<Either<Failure, void>> setRemoteDescription(RTCSessionDescription description);
  
  List<RTCIceCandidate> getIceCandidates();
  Stream<RTCIceCandidate> get iceCandidateStream;
  Future<Either<Failure, void>> addIceCandidate(RTCIceCandidate candidate);
  
  Future<Either<Failure, void>> reset();
  Future<Either<Failure, void>> addLocalStreamToPeerConnection();
  void dispose();
}

class FlutterWebRTCService implements WebRTCService {
  static FlutterWebRTCService? _instance;
  
  FlutterWebRTCService._internal();
  
  factory FlutterWebRTCService() {
    _instance ??= FlutterWebRTCService._internal();
    return _instance!;
  }
  
  static FlutterWebRTCService get instance {
    _instance ??= FlutterWebRTCService._internal();
    return _instance!;
  }
  
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  
  final StreamController<WebRTCConnectionState> _connectionStateController =
      StreamController<WebRTCConnectionState>.broadcast();
  
  WebRTCConnectionState _currentState = const WebRTCConnectionState();
  bool _isInitialized = false;
  
  final List<RTCIceCandidate> _iceCandidates = [];
  final StreamController<RTCIceCandidate> _iceCandidateController =
      StreamController<RTCIceCandidate>.broadcast();

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      if (_isInitialized) {
        final resetResult = await reset();
        if (resetResult.isLeft()) {
          return resetResult;
        }
      }
      
      final permissionResult = await _requestPermissions();
      if (permissionResult.isLeft()) {
        return permissionResult;
      }
      
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
    
    _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      _iceCandidates.add(candidate);
      _iceCandidateController.add(candidate);
    };

    _peerConnection?.onAddStream = (MediaStream stream) {
      _remoteStream = stream;
      _updateConnectionState(_currentState.copyWith(
        isRemoteAudioEnabled: stream.getAudioTracks().isNotEmpty,
      ));
    };

    _peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
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

      final mediaResult = await getUserMedia(const WebRTCMediaConstraints(audio: true));
      if (mediaResult.isLeft()) {
        return mediaResult;
      }

      if (_localStream != null && _peerConnection != null) {
        final addStreamResult = await addLocalStreamToPeerConnection();
        if (addStreamResult.isLeft()) {
          return addStreamResult;
        }
      }

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

      final mediaResult = await getUserMedia(const WebRTCMediaConstraints(audio: true));
      if (mediaResult.isLeft()) {
        return mediaResult;
      }

      if (_localStream != null && _peerConnection != null) {
        final addStreamResult = await addLocalStreamToPeerConnection();
        if (addStreamResult.isLeft()) {
          return addStreamResult;
        }
      }
      
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
      // Check if WebRTC is initialized and we have a local stream
      if (!_isInitialized || _localStream == null) {
        return Left(Failure.unknownFailure('WebRTC not initialized or no local stream available'));
      }
      
      // Get audio tracks from existing local stream
      List<MediaStreamTrack> audioTracks;
      try {
        audioTracks = _localStream!.getAudioTracks();
      } catch (e) {
        return Left(Failure.unknownFailure('Failed to access audio tracks: $e'));
      }
      
      if (audioTracks.isEmpty) {
        return Left(Failure.unknownFailure('No audio tracks found'));
      }
      
      // Toggle the enabled state of all audio tracks
      bool anySuccess = false;
      for (final track in audioTracks) {
        try {
          track.enabled = !track.enabled;
          anySuccess = true;
        } catch (e) {
          // Continue with other tracks even if one fails
        }
      }
      
      if (!anySuccess) {
        return Left(Failure.unknownFailure('Failed to toggle microphone'));
      }
      
      // Update connection state with new mute status
      _updateConnectionState(_currentState.copyWith(
        isMuted: !_currentState.isMuted,
        isLocalAudioEnabled: !_currentState.isMuted,
      ));

      return const Right(null);
      
    } catch (e) {
      return Left(Failure.unknownFailure('Microphone toggle failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleSpeaker() async {
    try {
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
  Future<Either<Failure, void>> reset() async {
    try {
      
      if (_peerConnection != null) {
        await _peerConnection!.close();
        _peerConnection = null;
      }
      
      _iceCandidates.clear();
      
      _isInitialized = false;
      _currentState = const WebRTCConnectionState();
      
      await _createPeerConnection();
      _isInitialized = true;
      
      _updateConnectionState(const WebRTCConnectionState(
        status: WebRTCConnectionStatus.disconnected,
        isInitialized: true,
      ));
      
      return const Right(null);
    } catch (e) {
      return Left(Failure.unknownFailure('Failed to reset WebRTC service: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addLocalStreamToPeerConnection() async {
    try {
      if (_localStream == null) {
        return Left(Failure.unknownFailure('No local stream available'));
      }
      
      if (_peerConnection == null) {
        return Left(Failure.unknownFailure('Peer connection not initialized'));
      }
      
      final audioTracks = _localStream!.getAudioTracks();
      for (final track in audioTracks) {
        await _peerConnection!.addTrack(track, _localStream!);
      }
      
      
      return const Right(null);
    } catch (e) {
      return Left(Failure.unknownFailure('Failed to add local stream: $e'));
    }
  }

  void printDebugInfo() {
    if (_peerConnection != null) {
    }
  }

  void debugIceCandidateStream() {
    
    if (_iceCandidates.isNotEmpty) {
      for (int i = 0; i < _iceCandidates.length; i++) {
        final candidate = _iceCandidates[i];
      }
    }
  }

  @override
  void dispose() {
    _peerConnection?.close();
    _localStream?.dispose();
    _remoteStream?.dispose();
    _connectionStateController.close();
    _iceCandidateController.close();
    
    _instance = null;
  }
  
  static void disposeInstance() {
    _instance?.dispose();
    _instance = null;
  }
}
