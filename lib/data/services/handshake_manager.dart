import 'dart:async';
import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';

/// Manages handshake data for ID exchange between users
class HandshakeManager {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  
  String? _currentUserId;
  
  /// Set the current user ID
  void setCurrentUserId(String userId) {
    _currentUserId = userId;
    log('🔧 HandshakeManager - Current user set to: $userId');
  }
  
  /// Create a unique handshake key for two users
  String _createHandshakeKey(String userId1, String userId2) {
    // Sort user IDs to ensure consistent key regardless of who calls whom
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }
  
  /// Initiate handshake - guler calls ozil
  Future<void> initiateHandshake(String callerId, String receiverId) async {
    try {
      final handshakeKey = _createHandshakeKey(callerId, receiverId);
      
      log('🤝 HandshakeManager - Initiating handshake: $callerId -> $receiverId');
      
      final handshakeData = {
        'callerId': callerId,
        'receiverId': receiverId,
        'callerIdSent': true,
        'receiverIdSent': false,
        'status': 'waiting_for_receiver',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      };
      
      // Update handshake data (not create new entry)
      await _database.child('handshakes').child(handshakeKey).set(handshakeData);
      
      log('✅ HandshakeManager - Handshake initiated successfully');
    } catch (e) {
      log('❌ HandshakeManager - Failed to initiate handshake: $e');
      rethrow;
    }
  }
  
  /// Complete handshake - ozil sends confirmation
  Future<void> completeHandshake(String callerId, String receiverId) async {
    try {
      final handshakeKey = _createHandshakeKey(callerId, receiverId);
      
      log('🤝 HandshakeManager - Completing handshake: $receiverId -> $callerId');
      
      final handshakeData = {
        'callerId': callerId,
        'receiverId': receiverId,
        'callerIdSent': true,
        'receiverIdSent': true,
        'status': 'completed',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      };
      
      // Update handshake data
      await _database.child('handshakes').child(handshakeKey).set(handshakeData);
      
      log('✅ HandshakeManager - Handshake completed successfully');
    } catch (e) {
      log('❌ HandshakeManager - Failed to complete handshake: $e');
      rethrow;
    }
  }
  
  /// Listen for incoming handshake requests
  Stream<Map<String, dynamic>> watchIncomingHandshakes(String userId) {
    log('👂 HandshakeManager - Setting up listener for incoming handshakes: $userId');
    
    return _database.child('handshakes').onValue.map((event) {
      log('📡 HandshakeManager - Firebase event received for user: $userId');
      
      if (!event.snapshot.exists) {
        log('📡 HandshakeManager - No handshakes data in Firebase');
        return <String, dynamic>{};
      }
      
      final handshakes = event.snapshot.value as Map<dynamic, dynamic>;
      log('📡 HandshakeManager - Handshakes data: $handshakes');
      
      // Find handshakes where current user is the receiver
      for (final entry in handshakes.entries) {
        final handshakeData = Map<String, dynamic>.from(entry.value as Map<dynamic, dynamic>);
        log('📡 HandshakeManager - Checking handshake: ${entry.key} -> $handshakeData');
        
        if (handshakeData['receiverId'] == userId && 
            handshakeData['status'] == 'waiting_for_receiver') {
          log('📥 HandshakeManager - Incoming handshake detected from: ${handshakeData['callerId']}');
          return handshakeData;
        }
      }
      
      log('📡 HandshakeManager - No matching handshake found for user: $userId');
      return <String, dynamic>{};
    });
  }
  
  /// Listen for handshake completion
  Stream<Map<String, dynamic>> watchHandshakeCompletion(String userId) {
    log('👂 HandshakeManager - Setting up listener for handshake completion: $userId');
    
    return _database.child('handshakes').onValue.map((event) {
      if (!event.snapshot.exists) {
        return <String, dynamic>{};
      }
      
      final handshakes = event.snapshot.value as Map<dynamic, dynamic>;
      
      // Find handshakes where current user is the caller and status is completed
      for (final entry in handshakes.entries) {
        final handshakeData = Map<String, dynamic>.from(entry.value as Map<dynamic, dynamic>);
        
        if (handshakeData['callerId'] == userId && 
            handshakeData['status'] == 'completed') {
          log('📥 HandshakeManager - Handshake completion detected with: ${handshakeData['receiverId']}');
          return handshakeData;
        }
      }
      
      return <String, dynamic>{};
    });
  }
  
  /// Clear handshake data
  Future<void> clearHandshake(String callerId, String receiverId) async {
    try {
      final handshakeKey = _createHandshakeKey(callerId, receiverId);
      
      log('🗑️ HandshakeManager - Clearing handshake: $handshakeKey');
      
      await _database.child('handshakes').child(handshakeKey).remove();
      
      log('✅ HandshakeManager - Handshake cleared successfully');
    } catch (e) {
      log('❌ HandshakeManager - Failed to clear handshake: $e');
    }
  }
  
  /// Get current handshake status
  Future<Map<String, dynamic>?> getHandshakeStatus(String callerId, String receiverId) async {
    try {
      final handshakeKey = _createHandshakeKey(callerId, receiverId);
      
      final snapshot = await _database.child('handshakes').child(handshakeKey).get();
      
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);
        log('📊 HandshakeManager - Current status: ${data['status']}');
        return data;
      }
      
      return null;
    } catch (e) {
      log('❌ HandshakeManager - Failed to get handshake status: $e');
      return null;
    }
  }
}
