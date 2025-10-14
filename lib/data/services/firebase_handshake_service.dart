import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../domain/entities/handshake.dart';
import 'handshake_service.dart';

class FirebaseHandshakeService implements HandshakeService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final String _handshakesPath = 'handshakes';
  
  StreamSubscription<DatabaseEvent>? _handshakeSubscription;
  StreamController<Handshake>? _handshakeController;

  Future<void> initiateHandshake({
    required String callerId,
    required String receiverId,
    RTCSessionDescription? sdpOffer,
    List<RTCIceCandidate>? iceCandidates,
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
        sdpOffer: sdpOffer?.sdp,
        iceCandidates: iceCandidates?.map((c) => {
          'type': 'candidate',
          'candidate': c.candidate,
          'sdpMid': c.sdpMid ?? '0',
          'sdpMLineIndex': c.sdpMLineIndex ?? 0,
        }).toList(),
      );

      await _database
          .ref('$_handshakesPath/$handshakeId')
          .set(handshake.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Stream<Handshake> listenToHandshake({
    required String callerId,
    required String receiverId
  }) {
    final handshakeId = _generateHandshakeId(callerId, receiverId);
    
    _handshakeController = StreamController<Handshake>.broadcast();
    
    _handshakeSubscription = _database
        .ref('$_handshakesPath/$handshakeId')
        .onValue
        .listen((DatabaseEvent event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value;
        if (data is Map) {
          final handshake = Handshake.fromMap(Map<String, dynamic>.from(data));
          _handshakeController?.add(handshake);
        }
      }
    }, onError: (error) {
      _handshakeController?.addError(error);
    });

    return _handshakeController!.stream;
  }

  Stream<Handshake> listenToUserHandshakes(String userId) {
    _handshakeController = StreamController<Handshake>.broadcast();
    
    _handshakeSubscription = _database
        .ref(_handshakesPath)
        .onChildChanged
        .listen((DatabaseEvent event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value;
        if (data is Map) {
          try{
            final handshake = Handshake.fromMap(Map<String, dynamic>.from(data));

            if (handshake.callerId == userId || handshake.receiverId == userId) {
              _handshakeController?.add(handshake);
            }
          }catch(e){
            // Handle parsing error
          }

        }
      }
    }, onError: (error) {
      _handshakeController?.addError(error);
    });

    return _handshakeController!.stream;
  }

  Future<void> updateHandshakeStatus({
    required String callerId,
    required String receiverId,
    required String status,
  }) async {
    try {
      final handshakeId = _generateHandshakeId(callerId, receiverId);
      final updates = {
        'status': status,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      };
      
      await _database
          .ref('$_handshakesPath/$handshakeId')
          .update(updates);
    } catch (e) {
      rethrow;
    }
  }

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
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateHandshakeStatusAndReceiverSent({
    required String callerId,
    required String receiverId,
    required String status,
    required bool receiverIdSent,
    RTCSessionDescription? answerSdp,
    List<RTCIceCandidate>? receiverIceCandidates,
  }) async {
    try {
      final handshakeId = _generateHandshakeId(callerId, receiverId);
      final updates = {
        'status': status,
        'receiverIdSent': receiverIdSent,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      };
      
      if (answerSdp != null && answerSdp.sdp != null) {
        updates['sdpAnswerFromReceiver'] = answerSdp.sdp!;
      }
      
      if (receiverIceCandidates != null && receiverIceCandidates.isNotEmpty) {
        updates['iceCandidatesFromReceiver'] = receiverIceCandidates.map((c) => {
          'type': 'candidate',
          'candidate': c.candidate,
          'sdpMid': c.sdpMid ?? '0',
          'sdpMLineIndex': c.sdpMLineIndex ?? 0,
        }).toList();
      }
      
      await _database
          .ref('$_handshakesPath/$handshakeId')
          .update(updates);
    } catch (e) {
      rethrow;
    }
  }

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
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeHandshake({
    required String callerId,
    required String receiverId,
  }) async {
    try {
      final handshakeId = _generateHandshakeId(callerId, receiverId);
      
      await _database
          .ref('$_handshakesPath/$handshakeId')
          .remove();
    } catch (e) {
      rethrow;
    }
  }

  String _generateHandshakeId(String callerId, String receiverId) {
    final sortedIds = [callerId, receiverId]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  void dispose() {
    _handshakeSubscription?.cancel();
    _handshakeController?.close();
    _handshakeSubscription = null;
    _handshakeController = null;
  }
}
