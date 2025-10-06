import 'dart:async';
import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import '../../domain/entities/signal_message.dart';

/// Manages the signaling process for WebRTC calls including ID exchange
class SignalingManager {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final StreamController<SignalMessage> _incomingSignalsController = 
      StreamController<SignalMessage>.broadcast();
  
  String? _currentUserId;
  String? _roomId;
  StreamSubscription<DatabaseEvent>? _signalSubscription;
  
  /// Stream of incoming signals from other peers
  Stream<SignalMessage> get incomingSignals => _incomingSignalsController.stream;
  
  /// Set the current user ID
  void setCurrentUserId(String userId) {
    _currentUserId = userId;
    log('🔧 SignalingManager - Current user set to: $userId');
    
    // Set up global listener for incoming calls to this user
    _setupIncomingCallListener();
  }
  
  /// Create a unique room ID for two users
  String createRoomId(String userId1, String userId2) {
    // Sort user IDs to ensure consistent room ID regardless of who calls whom
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }
  
  /// Start listening for signals in a specific room
  Future<void> startListening(String roomId) async {
    _roomId = roomId;
    log('👂 SignalingManager - Starting to listen for signals in room: $roomId');
    
    _signalSubscription?.cancel();
    _signalSubscription = _database
        .child('signals')
        .child(roomId)
        .onChildAdded
        .listen(_handleIncomingSignal);
  }
  
  /// Stop listening for signals
  Future<void> stopListening() async {
    log('🔇 SignalingManager - Stopping signal listener');
    await _signalSubscription?.cancel();
    _signalSubscription = null;
    _roomId = null;
  }
  
  /// Send a signal message to Firebase and return the signal key
  Future<String> sendSignal(SignalMessage message) async {
    if (_roomId == null) {
      throw Exception('Room ID not set. Call startListening() first.');
    }
    
    log('📤 SignalingManager - Sending signal: ${message.type} from ${message.from} to ${message.to}');
    
    try {
      final signalRef = _database
          .child('signals')
          .child(_roomId!)
          .push();
      
      await signalRef.set(message.toJson());
      
      final signalKey = signalRef.key!;
      log('✅ SignalingManager - Signal sent successfully with key: $signalKey');
      
      // Auto-delete signal after 2 minutes to prevent accumulation
      Future.delayed(const Duration(minutes: 2), () {
        deleteSignal(_roomId!, signalKey);
      });
      
      return signalKey;
    } catch (e) {
      log('❌ SignalingManager - Failed to send signal: $e');
      rethrow;
    }
  }
  
  /// Handle incoming signals from Firebase
  void _handleIncomingSignal(DatabaseEvent event) {
    try {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final message = SignalMessage.fromJson(Map<String, dynamic>.from(data));
      
      // Only process messages not from current user
      if (message.from != _currentUserId) {
        log('📥 SignalingManager - Received signal: ${message.type} from ${message.from}');
        _incomingSignalsController.add(message);
      } else {
        log('🔄 SignalingManager - Ignoring signal from self: ${message.type}');
      }
    } catch (e) {
      log('❌ SignalingManager - Failed to process incoming signal: $e');
    }
  }
  
  /// Send call request with caller ID
  Future<void> sendCallRequest(String callerId, String receiverId) async {
    final roomId = createRoomId(callerId, receiverId);
    await startListening(roomId);
    
    final callRequest = SignalMessage(
      type: SignalType.callRequest.name,
      from: callerId,
      to: receiverId,
      roomId: roomId,
    );
    
    await sendSignal(callRequest);
    log('📞 SignalingManager - Call request sent from $callerId to $receiverId');
  }
  
  /// Send call acceptance with receiver ID
  Future<void> sendCallAccepted(String receiverId, String callerId) async {
    final roomId = createRoomId(callerId, receiverId);
    
    final callAccepted = SignalMessage(
      type: SignalType.callAccepted.name,
      from: receiverId,
      to: callerId,
      roomId: roomId,
    );
    
    await sendSignal(callAccepted);
    log('✅ SignalingManager - Call accepted by $receiverId for $callerId');
  }
  
  /// Send call rejection
  Future<void> sendCallRejected(String receiverId, String callerId) async {
    final roomId = createRoomId(callerId, receiverId);
    
    final callRejected = SignalMessage(
      type: SignalType.callRejected.name,
      from: receiverId,
      to: callerId,
      roomId: roomId,
    );
    
    await sendSignal(callRejected);
    log('❌ SignalingManager - Call rejected by $receiverId for $callerId');
  }
  
  /// Send SDP offer with both user IDs
  Future<void> sendOffer(String callerId, String receiverId, String sdp) async {
    final roomId = createRoomId(callerId, receiverId);
    
    final offer = SignalMessage(
      type: SignalType.offer.name,
      from: callerId,
      to: receiverId,
      sdp: sdp,
      roomId: roomId,
    );
    
    await sendSignal(offer);
    log('📤 SignalingManager - SDP offer sent from $callerId to $receiverId');
  }
  
  /// Send SDP answer with both user IDs
  Future<void> sendAnswer(String receiverId, String callerId, String sdp) async {
    final roomId = createRoomId(callerId, receiverId);
    
    final answer = SignalMessage(
      type: SignalType.answer.name,
      from: receiverId,
      to: callerId,
      sdp: sdp,
      roomId: roomId,
    );
    
    await sendSignal(answer);
    log('📤 SignalingManager - SDP answer sent from $receiverId to $callerId');
  }
  
  /// Send ICE candidate with both user IDs
  Future<void> sendIceCandidate(String fromId, String toId, Map<String, dynamic> candidate) async {
    final roomId = createRoomId(fromId, toId);
    
    final iceMessage = SignalMessage(
      type: SignalType.iceCandidate.name,
      from: fromId,
      to: toId,
      candidate: candidate,
      roomId: roomId,
    );
    
    await sendSignal(iceMessage);
    log('🧊 SignalingManager - ICE candidate sent from $fromId to $toId');
  }
  
  /// Send call ended signal
  Future<void> sendCallEnded(String fromId, String toId) async {
    final roomId = createRoomId(fromId, toId);
    
    final callEnded = SignalMessage(
      type: SignalType.callEnded.name,
      from: fromId,
      to: toId,
      roomId: roomId,
    );
    
    await sendSignal(callEnded);
    log('📞 SignalingManager - Call ended signal sent from $fromId to $toId');
  }
  
  /// Set up listener for incoming calls to current user
  void _setupIncomingCallListener() {
    if (_currentUserId == null) return;
    
    log('👂 SignalingManager - Setting up incoming call listener for: $_currentUserId');
    
    // Use a simpler approach - listen to all signals and filter
    _database.child('signals').onChildAdded.listen((roomEvent) {
      try {
        final roomId = roomEvent.snapshot.key;
        log('📥 SignalingManager - New room detected: $roomId');
        
        if (roomId != null && roomId.contains(_currentUserId!)) {
          log('📥 SignalingManager - Room contains current user: $roomId');
          
          // Listen to signals in this room
          _database.child('signals').child(roomId).onChildAdded.listen((signalEvent) {
            try {
              final data = signalEvent.snapshot.value as Map<dynamic, dynamic>;
              final message = SignalMessage.fromJson(Map<String, dynamic>.from(data));
              
              log('📥 SignalingManager - Processing signal: ${message.type} from ${message.from} to ${message.to}');
              
              // Only process messages to current user
              if (message.to == _currentUserId) {
                log('📥 SignalingManager - ✅ Received signal for current user: ${message.type} from ${message.from}');
                _incomingSignalsController.add(message);
              } else {
                log('📥 SignalingManager - ⏭️ Ignoring signal not for current user: ${message.to} != $_currentUserId');
              }
            } catch (e) {
              log('❌ SignalingManager - Error processing signal: $e');
            }
          });
        } else {
          log('📥 SignalingManager - ⏭️ Room does not contain current user: $roomId');
        }
      } catch (e) {
        log('❌ SignalingManager - Error in incoming call listener: $e');
      }
    });
  }

  /// Delete a specific signal from Firebase
  Future<void> deleteSignal(String roomId, String signalKey) async {
    try {
      await _database.child('signals').child(roomId).child(signalKey).remove();
      log('🗑️ SignalingManager - Deleted signal: $signalKey from room: $roomId');
    } catch (e) {
      log('❌ SignalingManager - Failed to delete signal: $e');
    }
  }
  
  /// Delete all signals in a room (useful for call cleanup)
  Future<void> deleteAllSignalsInRoom(String roomId) async {
    try {
      await _database.child('signals').child(roomId).remove();
      log('🗑️ SignalingManager - Deleted all signals in room: $roomId');
    } catch (e) {
      log('❌ SignalingManager - Failed to delete all signals in room: $e');
    }
  }
  
  /// Delete old signals (older than specified minutes)
  Future<void> deleteOldSignals({int maxAgeMinutes = 5}) async {
    try {
      final cutoffTime = DateTime.now().subtract(Duration(minutes: maxAgeMinutes)).millisecondsSinceEpoch;
      
      final snapshot = await _database.child('signals').get();
      if (snapshot.exists) {
        final signals = snapshot.value as Map<dynamic, dynamic>;
        
        for (final roomEntry in signals.entries) {
          final roomId = roomEntry.key;
          final roomData = roomEntry.value as Map<dynamic, dynamic>;
          
          for (final signalEntry in roomData.entries) {
            final signalData = signalEntry.value as Map<dynamic, dynamic>;
            final timestamp = signalData['timestamp'] as int?;
            
            if (timestamp != null && timestamp < cutoffTime) {
              await _database.child('signals').child(roomId).child(signalEntry.key).remove();
              log('🗑️ SignalingManager - Deleted old signal: ${signalEntry.key} from room: $roomId');
            }
          }
        }
      }
      
      log('✅ SignalingManager - Cleaned up old signals (older than $maxAgeMinutes minutes)');
    } catch (e) {
      log('❌ SignalingManager - Failed to delete old signals: $e');
    }
  }
  
  /// Clean up resources
  Future<void> dispose() async {
    log('🧹 SignalingManager - Disposing resources');
    await stopListening();
    await _incomingSignalsController.close();
  }
}
