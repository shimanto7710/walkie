import 'package:freezed_annotation/freezed_annotation.dart';

part 'signal_message.freezed.dart';
part 'signal_message.g.dart';

@freezed
class SignalMessage with _$SignalMessage {
  const factory SignalMessage({
    required String type,
    required String from,
    required String to,
    String? sdp,
    Map<String, dynamic>? candidate,
    String? roomId,
  }) = _SignalMessage;

  factory SignalMessage.fromJson(Map<String, dynamic> json) =>
      _$SignalMessageFromJson(json);
}

enum SignalType {
  offer,
  answer,
  iceCandidate,
  callRequest,
  callAccepted,
  callRejected,
  callEnded,
}
