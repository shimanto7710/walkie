import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../../domain/entities/handshake.dart';

class FirebaseHandshakeService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final String _handshakesPath = 'handshakes';
  
  StreamSubscription<DatabaseEvent>? _handshakeSubscription;
  StreamController<Handshake>? _handshakeController;

  /// Initialize a new handshake when entering a call
  Future<void> initiateHandshake({
    required String callerId,
    required String receiverId,
  }) async {
    try {
      final handshakeId = _generateHandshakeId(callerId, receiverId);
      final handshake = Handshake(
        callerId: callerId,
        receiverId: receiverId,
        callerIdSent: true,
        receiverIdSent: false,
        status: 'call_initiate',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
      );

      await _database
          .ref('$_handshakesPath/$handshakeId')
          .set(handshake.toMap());

      print('✅ Handshake initiated: $handshakeId');
    } catch (e) {
      print('❌ Error initiating handshake: $e');
      rethrow;
    }
  }

  /// Listen to handshake data changes
  Stream<Handshake> listenToHandshake({
    required String callerId,
    required String receiverId,
  }) {
    final handshakeId = _generateHandshakeId(callerId, receiverId);
    
    _handshakeController = StreamController<Handshake>.broadcast();
    
    _handshakeSubscription = _database
        .ref('$_handshakesPath/$handshakeId')
        .onValue
        .listen((DatabaseEvent event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final handshake = Handshake.fromMap(Map<String, dynamic>.from(data));
        
        print('📡 Handshake data received: ${handshake.status}');
        _handshakeController?.add(handshake);
      } else {
        print('📡 Handshake data not found');
      }
    }, onError: (error) {
      print('❌ Error listening to handshake: $error');
      _handshakeController?.addError(error);
    });

    return _handshakeController!.stream;
  }

  /// Listen to all handshakes for a specific user (as caller or receiver)
  Stream<Handshake> listenToUserHandshakes(String userId) {
    _handshakeController = StreamController<Handshake>.broadcast();
    
    _handshakeSubscription = _database
        .ref(_handshakesPath)
        .onChildChanged
        .listen((DatabaseEvent event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final handshake = Handshake.fromMap(Map<String, dynamic>.from(data));
        
        // Only emit if this handshake involves the user
        if (handshake.callerId == userId || handshake.receiverId == userId) {
          print('📡 User handshake data received: ${handshake.status}');
          _handshakeController?.add(handshake);
        }
      }
    }, onError: (error) {
      print('❌ Error listening to user handshakes: $error');
      _handshakeController?.addError(error);
    });

    return _handshakeController!.stream;
  }

  /// Update handshake status
  Future<void> updateHandshakeStatus({
    required String callerId,
    required String receiverId,
    required String status,
  }) async {
    try {
      final handshakeId = _generateHandshakeId(callerId, receiverId);
      
      await _database
          .ref('$_handshakesPath/$handshakeId/status')
          .set(status);
      
      await _database
          .ref('$_handshakesPath/$handshakeId/lastUpdated')
          .set(DateTime.now().millisecondsSinceEpoch);

      print('✅ Handshake status updated: $status');
    } catch (e) {
      print('❌ Error updating handshake status: $e');
      rethrow;
    }
  }

  /// Update receiver ID sent status
  Future<void> updateReceiverIdSent({
    required String callerId,
    required String receiverId,
    required bool receiverIdSent,
  }) async {
    try {
      final handshakeId = _generateHandshakeId(callerId, receiverId);
      
      await _database
          .ref('$_handshakesPath/$handshakeId/receiverIdSent')
          .set(receiverIdSent);
      
      await _database
          .ref('$_handshakesPath/$handshakeId/lastUpdated')
          .set(DateTime.now().millisecondsSinceEpoch);

      print('✅ Receiver ID sent status updated: $receiverIdSent');
    } catch (e) {
      print('❌ Error updating receiver ID sent status: $e');
      rethrow;
    }
  }

  /// Update handshake status and receiver ID sent in a single operation
  Future<void> updateHandshakeStatusAndReceiverSent({
    required String callerId,
    required String receiverId,
    required String status,
    required bool receiverIdSent,
  }) async {
    try {
      final handshakeId = _generateHandshakeId(callerId, receiverId);
      final updates = {
        'status': status,
        'receiverIdSent': receiverIdSent,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      };
      
      await _database
          .ref('$_handshakesPath/$handshakeId')
          .update(updates);

      print('✅ Handshake updated: status=$status, receiverIdSent=$receiverIdSent');
    } catch (e) {
      print('❌ Error updating handshake status and receiver sent: $e');
      rethrow;
    }
  }

  /// Complete the handshake
  Future<void> completeHandshake({
    required String callerId,
    required String receiverId,
  }) async {
    try {
      final handshakeId = _generateHandshakeId(callerId, receiverId);
      
      await _database
          .ref('$_handshakesPath/$handshakeId/status')
          .set('completed');
      
      await _database
          .ref('$_handshakesPath/$handshakeId/lastUpdated')
          .set(DateTime.now().millisecondsSinceEpoch);

      print('✅ Handshake completed');
    } catch (e) {
      print('❌ Error completing handshake: $e');
      rethrow;
    }
  }

  /// Remove handshake data
  Future<void> removeHandshake({
    required String callerId,
    required String receiverId,
  }) async {
    try {
      final handshakeId = _generateHandshakeId(callerId, receiverId);
      
      await _database
          .ref('$_handshakesPath/$handshakeId')
          .remove();

      print('✅ Handshake removed');
    } catch (e) {
      print('❌ Error removing handshake: $e');
      rethrow;
    }
  }

  /// Generate consistent handshake ID
  String _generateHandshakeId(String callerId, String receiverId) {
    // Sort IDs to ensure consistent handshake ID regardless of who calls whom
    final sortedIds = [callerId, receiverId]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  /// Dispose resources
  void dispose() {
    _handshakeSubscription?.cancel();
    _handshakeController?.close();
    _handshakeSubscription = null;
    _handshakeController = null;
  }
}
