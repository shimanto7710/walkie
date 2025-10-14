import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../domain/entities/handshake.dart';

/// Abstract interface for handshake operations
abstract class HandshakeService {
  /// Initialize a new handshake when entering a call
  Future<void> initiateHandshake({
    required String callerId,
    required String receiverId,
    RTCSessionDescription? sdpOffer,
    List<RTCIceCandidate>? iceCandidates,
  });

  /// Listen to handshake data changes
  Stream<Handshake> listenToHandshake({
    required String callerId,
    required String receiverId,
  });

  /// Listen to all handshakes for a specific user (as caller or receiver)
  Stream<Handshake> listenToUserHandshakes(String userId);

  /// Update handshake status
  Future<void> updateHandshakeStatus({
    required String callerId,
    required String receiverId,
    required String status,
  });

  /// Update receiver ID sent status
  Future<void> updateReceiverIdSent({
    required String callerId,
    required String receiverId,
    required bool receiverIdSent,
  });

  /// Update handshake status and receiver ID sent in a single operation
  Future<void> updateHandshakeStatusAndReceiverSent({
    required String callerId,
    required String receiverId,
    required String status,
    required bool receiverIdSent,
    RTCSessionDescription? answerSdp,
    List<RTCIceCandidate>? receiverIceCandidates,
  });

  /// Complete the handshake
  Future<void> completeHandshake({
    required String callerId,
    required String receiverId,
  });

  /// Remove handshake data
  Future<void> removeHandshake({
    required String callerId,
    required String receiverId,
  });

  /// Dispose resources
  void dispose();
}
