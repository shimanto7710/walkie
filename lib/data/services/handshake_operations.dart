import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Utility class for common handshake operations
/// This helps eliminate code duplication between providers
class HandshakeOperations {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final String _handshakesPath = 'handshakes';

  /// Update handshake status and receiver ID sent in a single operation
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
      
      // Add receiver's answer SDP if provided
      if (answerSdp != null && answerSdp.sdp != null) {
        updates['sdpAnswerFromReceiver'] = answerSdp.sdp!;
      }
      
      // Add receiver's ICE candidates if provided
      if (receiverIceCandidates != null && receiverIceCandidates.isNotEmpty) {
        updates['iceCandidatesFromReceiver'] = receiverIceCandidates.map((c) => {
          'type': 'candidate',
          'candidate': c.candidate,
          'sdpMid': c.sdpMid ?? '0',
          'sdpMLineIndex': c.sdpMLineIndex ?? 0,
        }).toList();
      }
      
      print('🔄 Updating handshake $handshakeId: status=$status, receiverIdSent=$receiverIdSent');
      
      await _database
          .ref('$_handshakesPath/$handshakeId')
          .update(updates);

      print('✅ Handshake updated successfully: status=$status, receiverIdSent=$receiverIdSent');
    } catch (e) {
      print('❌ Error updating handshake status and receiver sent: $e');
      print('❌ Handshake ID: ${_generateHandshakeId(callerId, receiverId)}');
      rethrow;
    }
  }

  /// Update handshake status only
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
      
      print('🔄 Updating handshake $handshakeId: status=$status');
      
      await _database
          .ref('$_handshakesPath/$handshakeId')
          .update(updates);

      print('✅ Handshake status updated successfully: $status');
    } catch (e) {
      print('❌ Error updating handshake status: $e');
      print('❌ Handshake ID: ${_generateHandshakeId(callerId, receiverId)}');
      rethrow;
    }
  }

  /// Generate consistent handshake ID
  String _generateHandshakeId(String callerId, String receiverId) {
    final sortedIds = [callerId, receiverId]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }
}
