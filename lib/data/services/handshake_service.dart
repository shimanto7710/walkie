import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../domain/entities/handshake.dart';

abstract class HandshakeService {
  Future<void> initiateHandshake({
    required String callerId,
    required String receiverId,
    RTCSessionDescription? sdpOffer,
    List<RTCIceCandidate>? iceCandidates,
  });

  Stream<Handshake> listenToHandshake({
    required String callerId,
    required String receiverId,
  });

  Stream<Handshake> listenToUserHandshakes(String userId);

  Future<void> updateHandshakeStatus({
    required String callerId,
    required String receiverId,
    required String status,
  });

  Future<void> updateReceiverIdSent({
    required String callerId,
    required String receiverId,
    required bool receiverIdSent,
  });

  Future<void> updateHandshakeStatusAndReceiverSent({
    required String callerId,
    required String receiverId,
    required String status,
    required bool receiverIdSent,
    RTCSessionDescription? answerSdp,
    List<RTCIceCandidate>? receiverIceCandidates,
  });

  Future<void> completeHandshake({
    required String callerId,
    required String receiverId,
  });

  Future<void> removeHandshake({
    required String callerId,
    required String receiverId,
  });

  void dispose();
}
