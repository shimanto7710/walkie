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
  
  // SDP Functions
  Future<Either<Failure, RTCSessionDescription>> createOffer();
  Future<Either<Failure, RTCSessionDescription>> createAnswer();
  Future<Either<Failure, void>> setLocalDescription(RTCSessionDescription description);
  Future<Either<Failure, void>> setRemoteDescription(RTCSessionDescription description);
  
  // ICE Functions
  List<RTCIceCandidate> getIceCandidates();
  Stream<RTCIceCandidate> get iceCandidateStream;
  Future<Either<Failure, void>> addIceCandidate(RTCIceCandidate candidate);
  
  Future<Either<Failure, void>> reset();
  Future<Either<Failure, void>> addLocalStreamToPeerConnection();
  void dispose();
}

class FlutterWebRTCService implements WebRTCService {
  // Singleton instance
  static FlutterWebRTCService? _instance;
  
  // Private constructor
  FlutterWebRTCService._internal();
  
  // Factory constructor that returns the singleton instance
  factory FlutterWebRTCService() {
    _instance ??= FlutterWebRTCService._internal();
    return _instance!;
  }
  
  // Static method to get the instance
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
  
  // ICE candidate collection
  final List<RTCIceCandidate> _iceCandidates = [];
  final StreamController<RTCIceCandidate> _iceCandidateController =
      StreamController<RTCIceCandidate>.broadcast();

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      if (_isInitialized) {
        print('⚠️ WebRTC service already initialized, resetting...');
        final resetResult = await reset();
        if (resetResult.isLeft()) {
          return resetResult;
        }
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
      print('🧊 ICE candidate sdpMid: ${candidate.sdpMid}, sdpMLineIndex: ${candidate.sdpMLineIndex}');
      _iceCandidates.add(candidate);
      _iceCandidateController.add(candidate);
      print('🧊 Total ICE candidates collected: ${_iceCandidates.length}');
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

      // Add local stream to peer connection using addTrack (Unified Plan)
      if (_localStream != null && _peerConnection != null) {
        final addStreamResult = await addLocalStreamToPeerConnection();
        if (addStreamResult.isLeft()) {
          return addStreamResult;
        }
        print('✅ Local audio stream added to peer connection');
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

      // Get user media
      final mediaResult = await getUserMedia(const WebRTCMediaConstraints(audio: true));
      if (mediaResult.isLeft()) {
        return mediaResult;
      }

      // Add local stream to peer connection using addTrack (Unified Plan)
      if (_localStream != null && _peerConnection != null) {
        final addStreamResult = await addLocalStreamToPeerConnection();
        if (addStreamResult.isLeft()) {
          return addStreamResult;
        }
        print('✅ Local audio stream added to peer connection');
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
      print('🔍 === TOGGLE MUTE START ===');
      print('🔍 _localStream: ${_localStream != null ? "Available" : "NULL"}');
      print('🔍 _isInitialized: $_isInitialized');
      print('🔍 _peerConnection: ${_peerConnection != null ? "Available" : "NULL"}');
      
      // Step 1: Check and request permissions first
      print('🔍 Step 1: Checking microphone permissions...');
      final permissionResult = await _requestPermissions();
      if (permissionResult.isLeft()) {
        print('❌ Microphone permission denied or failed');
        return Left(Failure.unknownFailure('Microphone permission required'));
      }
      print('✅ Microphone permission granted');
      
      // Step 2: Ensure WebRTC is initialized
      if (!_isInitialized) {
        print('🔍 Step 2: Initializing WebRTC...');
        final initResult = await initialize();
        if (initResult.isLeft()) {
          print('❌ Failed to initialize WebRTC');
          return Left(Failure.unknownFailure('WebRTC initialization failed'));
        }
        print('✅ WebRTC initialized');
      } else {
        print('✅ WebRTC already initialized');
      }
      
      // Step 3: Ensure we have a local stream
      if (_localStream == null) {
        print('🔍 Step 3: Getting user media...');
        final mediaResult = await getUserMedia(const WebRTCMediaConstraints(audio: true));
        if (mediaResult.isLeft()) {
          print('❌ Failed to get user media: ${mediaResult.fold((l) => l.message, (r) => '')}');
          return Left(Failure.unknownFailure('Failed to access microphone'));
        }
        print('✅ User media obtained');
        
        // Add stream to peer connection
        final addStreamResult = await addLocalStreamToPeerConnection();
        if (addStreamResult.isLeft()) {
          print('⚠️ Failed to add stream to peer connection: ${addStreamResult.fold((l) => l.message, (r) => '')}');
        } else {
          print('✅ Stream added to peer connection');
        }
      } else {
        print('✅ Local stream already available');
      }
      
      // Step 4: Final validation
      if (_localStream == null) {
        print('❌ Local stream still null after all attempts');
        return Left(Failure.unknownFailure('Microphone not available'));
      }
      
      // Step 5: Get and validate audio tracks
      print('🔍 Step 5: Getting audio tracks...');
      List<MediaStreamTrack> audioTracks;
      try {
        audioTracks = _localStream!.getAudioTracks();
        print('🔍 Found ${audioTracks.length} audio tracks');
      } catch (e) {
        print('❌ Error getting audio tracks: $e');
        return Left(Failure.unknownFailure('Failed to access audio tracks'));
      }
      
      if (audioTracks.isEmpty) {
        print('❌ No audio tracks available');
        return Left(Failure.unknownFailure('No audio tracks found'));
      }
      
      // Step 6: Toggle audio tracks with maximum safety
      print('🔍 Step 6: Toggling audio tracks...');
      bool anySuccess = false;
      
      for (int i = 0; i < audioTracks.length; i++) {
        try {
          final track = audioTracks[i];
          final currentState = track.enabled;
          final newState = !currentState;
          
          print('🔍 Track $i: $currentState -> $newState');
          
          // Track is already validated in the loop, no need to check for null
          
          track.enabled = newState;
          anySuccess = true;
          print('✅ Track $i toggled successfully');
          
        } catch (e) {
          print('⚠️ Error toggling track $i: $e');
          // Continue with other tracks
        }
      }
      
      if (!anySuccess) {
        print('❌ Failed to toggle any audio tracks');
        return Left(Failure.unknownFailure('Failed to toggle microphone'));
      }
      
      // Step 7: Update state (non-critical)
      try {
        _updateConnectionState(_currentState.copyWith(
          isMuted: !_currentState.isMuted,
          isLocalAudioEnabled: !_currentState.isMuted,
        ));
        print('✅ State updated - isMuted: ${_currentState.isMuted}');
      } catch (e) {
        print('⚠️ Error updating state: $e');
        // Don't fail the operation for state update error
      }

      print('✅ === TOGGLE MUTE SUCCESS ===');
      return const Right(null);
      
    } catch (e) {
      print('❌ === TOGGLE MUTE CRASH ===');
      print('❌ Error: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      return Left(Failure.unknownFailure('Microphone toggle failed: $e'));
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
      
      print('📞 Creating SDP offer...');
      final offer = await _peerConnection!.createOffer();
      print('✅ SDP offer created: ${offer.sdp?.length ?? 0} characters');
      print('📞 Offer type: ${offer.type}');
      return Right(offer);
    } catch (e) {
      print('❌ Failed to create offer: $e');
      return Left(Failure.unknownFailure('Failed to create offer: $e'));
    }
  }

  @override
  Future<Either<Failure, RTCSessionDescription>> createAnswer() async {
    try {
      if (_peerConnection == null) {
        return Left(Failure.unknownFailure('Peer connection not initialized'));
      }
      
      print('📞 Creating SDP answer...');
      final answer = await _peerConnection!.createAnswer();
      print('✅ SDP answer created: ${answer.sdp?.length ?? 0} characters');
      print('📞 Answer type: ${answer.type}');
      return Right(answer);
    } catch (e) {
      print('❌ Failed to create answer: $e');
      return Left(Failure.unknownFailure('Failed to create answer: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setLocalDescription(RTCSessionDescription description) async {
    try {
      if (_peerConnection == null) {
        return Left(Failure.unknownFailure('Peer connection not initialized'));
      }
      
      print('📞 Setting local description: ${description.type}');
      print('📞 Local SDP length: ${description.sdp?.length ?? 0} characters');
      await _peerConnection!.setLocalDescription(description);
      print('✅ Local description set successfully');
      return const Right(null);
    } catch (e) {
      print('❌ Failed to set local description: $e');
      return Left(Failure.unknownFailure('Failed to set local description: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setRemoteDescription(RTCSessionDescription description) async {
    try {
      if (_peerConnection == null) {
        return Left(Failure.unknownFailure('Peer connection not initialized'));
      }
      
      print('📞 Setting remote description: ${description.type}');
      print('📞 Remote SDP length: ${description.sdp?.length ?? 0} characters');
      await _peerConnection!.setRemoteDescription(description);
      print('✅ Remote description set successfully');
      return const Right(null);
    } catch (e) {
      print('❌ Failed to set remote description: $e');
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
      
      print('🧊 Adding ICE candidate: ${candidate.candidate}');
      print('🧊 ICE candidate sdpMid: ${candidate.sdpMid}, sdpMLineIndex: ${candidate.sdpMLineIndex}');
      await _peerConnection!.addCandidate(candidate);
      print('✅ ICE candidate added successfully');
      return const Right(null);
    } catch (e) {
      print('❌ Failed to add ICE candidate: $e');
      return Left(Failure.unknownFailure('Failed to add ICE candidate: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> reset() async {
    try {
      print('🔄 Resetting WebRTC service...');
      
      // Close existing peer connection
      if (_peerConnection != null) {
        await _peerConnection!.close();
        _peerConnection = null;
      }
      
      // Clear ICE candidates
      _iceCandidates.clear();
      
      // Reset state
      _isInitialized = false;
      _currentState = const WebRTCConnectionState();
      
      // Create new peer connection
      await _createPeerConnection();
      _isInitialized = true;
      
      _updateConnectionState(const WebRTCConnectionState(
        status: WebRTCConnectionStatus.disconnected,
        isInitialized: true,
      ));
      
      print('✅ WebRTC service reset successfully');
      return const Right(null);
    } catch (e) {
      print('❌ Failed to reset WebRTC service: $e');
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
      
      // Use addTrack instead of addStream (Unified Plan SDP semantics)
      final audioTracks = _localStream!.getAudioTracks();
      for (final track in audioTracks) {
        await _peerConnection!.addTrack(track, _localStream!);
        print('✅ Audio track added to peer connection: ${track.id}');
      }
      
      print('✅ All local audio tracks added to peer connection');
      
      return const Right(null);
    } catch (e) {
      return Left(Failure.unknownFailure('Failed to add local stream: $e'));
    }
  }

  /// Debug method to print current WebRTC state
  void printDebugInfo() {
    print('🔍 === WebRTC Debug Info ===');
    print('🔍 Initialized: $_isInitialized');
    print('🔍 Peer Connection: ${_peerConnection != null ? "Created" : "Null"}');
    print('🔍 ICE Candidates: ${_iceCandidates.length}');
    print('🔍 Local Stream: ${_localStream != null ? "Active" : "Null"}');
    print('🔍 Remote Stream: ${_remoteStream != null ? "Active" : "Null"}');
    print('🔍 Current State: ${_currentState.status}');
    if (_peerConnection != null) {
      print('🔍 Signaling State: ${_peerConnection!.signalingState}');
      print('🔍 Connection State: ${_peerConnection!.connectionState}');
    }
    print('🔍 === End Debug Info ===');
  }

  /// Debug method to check ICE candidate stream
  void debugIceCandidateStream() {
    print('🔍 === ICE CANDIDATE STREAM DEBUG ===');
    print('🔍 Stream Controller Closed: ${_iceCandidateController.isClosed}');
    print('🔍 Stream Has Listener: ${_iceCandidateController.hasListener}');
    print('🔍 Current ICE Candidates Count: ${_iceCandidates.length}');
    
    if (_iceCandidates.isNotEmpty) {
      print('🔍 ICE Candidates Details:');
      for (int i = 0; i < _iceCandidates.length; i++) {
        final candidate = _iceCandidates[i];
        print('   🧊 Candidate ${i + 1}: ${candidate.candidate}');
        print('   🏷️  SDP Mid: ${candidate.sdpMid}, Index: ${candidate.sdpMLineIndex}');
      }
    }
    print('🔍 === END ICE STREAM DEBUG ===');
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
