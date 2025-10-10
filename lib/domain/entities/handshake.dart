class Handshake {
  final String callerId;
  final String receiverId;
  final bool callerIdSent;
  final bool receiverIdSent;
  final String status;
  final int timestamp;
  final int lastUpdated;

  const Handshake({
    required this.callerId,
    required this.receiverId,
    required this.callerIdSent,
    required this.receiverIdSent,
    required this.status,
    required this.timestamp,
    required this.lastUpdated,
  });

  factory Handshake.fromMap(Map<String, dynamic> map) {
    return Handshake(
      callerId: map['callerId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      callerIdSent: map['callerIdSent'] ?? false,
      receiverIdSent: map['receiverIdSent'] ?? false,
      status: map['status'] ?? 'call_initiate',
      timestamp: map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      lastUpdated: map['lastUpdated'] ?? DateTime.now().millisecondsSinceEpoch,
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
  }) {
    return Handshake(
      callerId: callerId ?? this.callerId,
      receiverId: receiverId ?? this.receiverId,
      callerIdSent: callerIdSent ?? this.callerIdSent,
      receiverIdSent: receiverIdSent ?? this.receiverIdSent,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() {
    return 'Handshake(callerId: $callerId, receiverId: $receiverId, callerIdSent: $callerIdSent, receiverIdSent: $receiverIdSent, status: $status, timestamp: $timestamp, lastUpdated: $lastUpdated)';
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
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return callerId.hashCode ^
        receiverId.hashCode ^
        callerIdSent.hashCode ^
        receiverIdSent.hashCode ^
        status.hashCode ^
        timestamp.hashCode ^
        lastUpdated.hashCode;
  }
}
