class Handshake {
  final String callerId;
  final String receiverId;
  final bool callerIdSent;
  final bool receiverIdSent;
  final String status;
  final int timestamp;
  final int lastUpdated;
  final String? sdpOffer;
  final List<Map<String, dynamic>>? iceCandidates;
  final String? sdpAnswer;
  final List<Map<String, dynamic>>? iceCandidatesFromReceiver;

  const Handshake({
    required this.callerId,
    required this.receiverId,
    required this.callerIdSent,
    required this.receiverIdSent,
    required this.status,
    required this.timestamp,
    required this.lastUpdated,
    this.sdpOffer,
    this.iceCandidates,
    this.sdpAnswer,
    this.iceCandidatesFromReceiver,
  });

  factory Handshake.fromMap(Map<String, dynamic> map) {
    return Handshake(
      callerId: map['callerId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      callerIdSent: map['callerIdSent'] ?? false,
      receiverIdSent: map['receiverIdSent'] ?? false,
      status: map['status'] ?? 'error',
      timestamp: map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      lastUpdated: map['lastUpdated'] ?? DateTime.now().millisecondsSinceEpoch,
      sdpOffer: map['sdpOfferFromCaller'],
      iceCandidates: map['iceCandidatesFromCaller'] != null ? 
        (map['iceCandidatesFromCaller'] is List ? 
          (map['iceCandidatesFromCaller'] as List).map((item) {
            if (item is Map) {
              return Map<String, dynamic>.from(item);
            } else if (item is String) {
              // Convert string candidate to proper format
              return {
                'type': 'candidate',
                'candidate': item,
                'sdpMid': '0',
                'sdpMLineIndex': 0,
              };
            }
            return <String, dynamic>{};
          }).toList() : null) : null,
      sdpAnswer: map['sdpAnswerFromReceiver'],
      iceCandidatesFromReceiver: map['iceCandidatesFromReceiver'] != null ? 
        (map['iceCandidatesFromReceiver'] is List ? 
          (map['iceCandidatesFromReceiver'] as List).map((item) {
            if (item is Map) {
              return Map<String, dynamic>.from(item);
            } else if (item is String) {
              // Convert string candidate to proper format
              return {
                'type': 'candidate',
                'candidate': item,
                'sdpMid': '0',
                'sdpMLineIndex': 0,
              };
            }
            return <String, dynamic>{};
          }).toList() : null) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'receiverId': receiverId,
      'callerIdSent': callerIdSent,
      'receiverIdSent': receiverIdSent,
      'status': status,
      'timestamp': timestamp,
      'lastUpdated': lastUpdated,
      'sdpOfferFromCaller': sdpOffer,
      'iceCandidatesFromCaller': iceCandidates,
      'sdpAnswerFromReceiver': sdpAnswer,
      'iceCandidatesFromReceiver': iceCandidatesFromReceiver,
    };
  }

  Handshake copyWith({
    String? callerId,
    String? receiverId,
    bool? callerIdSent,
    bool? receiverIdSent,
    String? status,
    int? timestamp,
    int? lastUpdated,
    String? sdpOffer,
    List<Map<String, dynamic>>? iceCandidates,
    String? sdpAnswer,
    List<Map<String, dynamic>>? iceCandidatesFromReceiver,
  }) {
    return Handshake(
      callerId: callerId ?? this.callerId,
      receiverId: receiverId ?? this.receiverId,
      callerIdSent: callerIdSent ?? this.callerIdSent,
      receiverIdSent: receiverIdSent ?? this.receiverIdSent,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      sdpOffer: sdpOffer ?? this.sdpOffer,
      iceCandidates: iceCandidates ?? this.iceCandidates,
      sdpAnswer: sdpAnswer ?? this.sdpAnswer,
      iceCandidatesFromReceiver: iceCandidatesFromReceiver ?? this.iceCandidatesFromReceiver,
    );
  }

  @override
  String toString() {
    return 'Handshake(callerId: $callerId, receiverId: $receiverId, callerIdSent: $callerIdSent, receiverIdSent: $receiverIdSent, status: $status, timestamp: $timestamp, lastUpdated: $lastUpdated, sdpOffer: $sdpOffer, iceCandidates: $iceCandidates, sdpAnswer: $sdpAnswer, iceCandidatesFromReceiver: $iceCandidatesFromReceiver)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Handshake &&
        other.callerId == callerId &&
        other.receiverId == receiverId &&
        other.callerIdSent == callerIdSent &&
        other.receiverIdSent == receiverIdSent &&
        other.status == status &&
        other.timestamp == timestamp &&
        other.lastUpdated == lastUpdated &&
        other.sdpOffer == sdpOffer &&
        other.iceCandidates == iceCandidates &&
        other.sdpAnswer == sdpAnswer &&
        other.iceCandidatesFromReceiver == iceCandidatesFromReceiver;
  }

  @override
  int get hashCode {
    return callerId.hashCode ^
        receiverId.hashCode ^
        callerIdSent.hashCode ^
        receiverIdSent.hashCode ^
        status.hashCode ^
        timestamp.hashCode ^
        lastUpdated.hashCode ^
        sdpOffer.hashCode ^
        iceCandidates.hashCode ^
        sdpAnswer.hashCode ^
        iceCandidatesFromReceiver.hashCode;
  }
}
