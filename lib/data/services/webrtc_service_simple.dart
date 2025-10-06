import 'dart:async';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/call_state.dart';
import '../../domain/entities/signal_message.dart';
import '../../domain/repositories/webrtc_repository.dart';
import 'handshake_manager.dart';

/// Simple mock WebRTC service that doesn't cause crashes
class WebRTCServiceSimple implements WebRTCRepository {
  final StreamController<CallState> _callStateController = StreamController<CallState>.broadcast();
  final StreamController<SignalMessage> _signalController = StreamController<SignalMessage>.broadcast();
  final HandshakeManager _handshakeManager = HandshakeManager();
  
  CallState _currentCallState = const CallState();
  String? _currentUserId;
  String? _remoteUserId;
  StreamSubscription<Map<String, dynamic>>? _handshakeSubscription;

  @override
  CallState get currentCallState => _currentCallState;

  @override
  Stream<CallState> get callStateStream => _callStateController.stream;

  @override
  Stream<SignalMessage> get signalStream => _signalController.stream;

  @override
  Future<Either<Failure, void>> initialize() async {
    try {
      log('🔧 Initializing Simple WebRTC service...');
      
      // Update call state first
      _updateCallState(_currentCallState.copyWith(isConnected: true));
      
      // Set up handshake listeners if current user is set
      if (_currentUserId != null) {
        log('🔧 Simple WebRTC - Setting up handshake listeners during initialization...');
        _setupHandshakeListeners();
      } else {
        log('⚠️ Simple WebRTC - No current user ID set, handshake listeners will be set up when user ID is provided');
      }
      
      log('✅ Simple WebRTC service initialized successfully');
      
      return const Right(null);
    } catch (e) {
      log('❌ Failed to initialize Simple WebRTC service: $e');
      return Left(Failure.serverFailure('Failed to initialize WebRTC: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> dispose() async {
    try {
      log('🔧 Disposing Simple WebRTC service...');
      
      await _handshakeSubscription?.cancel();
      await _callStateController.close();
      await _signalController.close();
      
      log('✅ Simple WebRTC service disposed successfully');
      return const Right(null);
    } catch (e) {
      log('❌ Failed to dispose Simple WebRTC service: $e');
      return Left(Failure.serverFailure('Failed to dispose WebRTC: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> startCall(String remoteUserId) async {
    try {
      log('📞 Starting call with ID exchange to: $remoteUserId');
      
      _remoteUserId = remoteUserId;
      
      _updateCallState(_currentCallState.copyWith(
        status: CallStatus.calling,
        isConnecting: true,
        remoteUserId: remoteUserId,
      ));
      
      // Initiate handshake - guler sends ID to ozil
      if (_currentUserId != null) {
        await _handshakeManager.initiateHandshake(_currentUserId!, remoteUserId);
        log('🤝 Handshake initiated: $_currentUserId -> $remoteUserId');
      }
      
      log('✅ Call with ID exchange started successfully');
      return const Right(null);
    } catch (e) {
      log('❌ Failed to start call with ID exchange: $e');
      return Left(Failure.serverFailure('Failed to start call: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> acceptCall() async {
    try {
      log('📞 Accepting call and completing handshake...');
      
      // Complete handshake - ozil sends confirmation ID back to guler
      if (_currentUserId != null && _remoteUserId != null) {
        await _handshakeManager.completeHandshake(_remoteUserId!, _currentUserId!);
        log('🤝 Handshake completed: $_currentUserId -> $_remoteUserId');
      }
      
      _updateCallState(_currentCallState.copyWith(
        status: CallStatus.connected,
        isConnecting: false,
        isConnected: true,
      ));
      
      log('✅ Call accepted and handshake completed successfully');
      return const Right(null);
    } catch (e) {
      log('❌ Failed to accept call and complete handshake: $e');
      return Left(Failure.serverFailure('Failed to accept call: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> rejectCall() async {
    try {
      log('📞 Rejecting simple call...');
      
      _updateCallState(_currentCallState.copyWith(
        status: CallStatus.ended,
        isConnecting: false,
      ));
      
      log('✅ Simple call rejected successfully');
      return const Right(null);
    } catch (e) {
      log('❌ Failed to reject simple call: $e');
      return Left(Failure.serverFailure('Failed to reject call: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> endCall() async {
    try {
      log('📞 Ending simple call...');
      
      _updateCallState(_currentCallState.copyWith(
        status: CallStatus.ended,
        isConnecting: false,
        isConnected: false,
      ));
      
      log('✅ Simple call ended successfully');
      return const Right(null);
    } catch (e) {
      log('❌ Failed to end simple call: $e');
      return Left(Failure.serverFailure('Failed to end call: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleMute() async {
    try {
      log('🎤 Toggling mute in simple service...');
      // Simulate mute toggle
      return const Right(null);
    } catch (e) {
      log('❌ Failed to toggle mute: $e');
      return Left(Failure.serverFailure('Failed to toggle mute: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleSpeaker() async {
    try {
      log('🔊 Toggling speaker in simple service...');
      // Simulate speaker toggle
      return const Right(null);
    } catch (e) {
      log('❌ Failed to toggle speaker: $e');
      return Left(Failure.serverFailure('Failed to toggle speaker: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendSignal(SignalMessage message) async {
    try {
      log('📤 Simple WebRTC - Sending signal: ${message.type}');
      // Simulate signal sending
      return const Right(null);
    } catch (e) {
      log('❌ Failed to send signal: $e');
      return Left(Failure.serverFailure('Failed to send signal: $e'));
    }
  }

  /// Set current user ID
  void setCurrentUserId(String userId) {
    _currentUserId = userId;
    _handshakeManager.setCurrentUserId(userId);
    log('🔧 Simple WebRTC - Current user set to: $userId');
    log('🔍 Simple WebRTC - Service connected: ${_currentCallState.isConnected}');
    
    // Always set up handshake listeners when user ID is set
    log('🔧 Simple WebRTC - Setting up handshake listeners for user: $userId');
    _setupHandshakeListeners();
  }
  
  /// Set up handshake listeners for incoming calls and completions
  void _setupHandshakeListeners() {
    if (_currentUserId == null) {
      log('❌ Simple WebRTC - Cannot set up handshake listeners: no current user ID');
      return;
    }
    
    log('👂 Simple WebRTC - Setting up handshake listeners for: $_currentUserId');
    
    // Cancel existing subscription if any
    _handshakeSubscription?.cancel();
    
    // Listen for incoming handshake requests (ozil receives from guler)
    _handshakeSubscription = _handshakeManager.watchIncomingHandshakes(_currentUserId!).listen(
      (handshakeData) {
        log('📥 Simple WebRTC - Received handshake data: $handshakeData');
        if (handshakeData.isNotEmpty) {
          final callerId = handshakeData['callerId'] as String;
          log('📥 Simple WebRTC - Incoming handshake from: $callerId');
          
          // Update call state to ringing
          _updateCallState(_currentCallState.copyWith(
            status: CallStatus.ringing,
            remoteUserId: callerId,
          ));
          
          // Automatically send confirmation back to caller (guler)
          log('🤝 Simple WebRTC - Automatically sending confirmation back to: $callerId');
          _handshakeManager.completeHandshake(callerId, _currentUserId!);
        }
      },
      onError: (error) {
        log('❌ Simple WebRTC - Handshake listener error: $error');
      },
    );
    
    // Also listen for handshake completion (guler receives confirmation from ozil)
    _handshakeManager.watchHandshakeCompletion(_currentUserId!).listen((handshakeData) {
      if (handshakeData.isNotEmpty) {
        final receiverId = handshakeData['receiverId'] as String;
        log('📥 Simple WebRTC - Handshake completed with: $receiverId');
        
        // Update call state to connected
        _updateCallState(_currentCallState.copyWith(
          status: CallStatus.connected,
          isConnecting: false,
          isConnected: true,
        ));
      }
    });
    
    log('✅ Simple WebRTC - Handshake listeners set up successfully');
  }

  /// Update call state and notify listeners
  void _updateCallState(CallState newState) {
    _currentCallState = newState;
    _callStateController.add(newState);
  }
}
