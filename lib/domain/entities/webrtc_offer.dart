import 'package:freezed_annotation/freezed_annotation.dart';

part 'webrtc_offer.freezed.dart';
part 'webrtc_offer.g.dart';

@freezed
class WebRTCOffer with _$WebRTCOffer {
  const factory WebRTCOffer({
    required String sdp,
    required String type,
    DateTime? createdAt,
    String? id,
  }) = _WebRTCOffer;

  factory WebRTCOffer.fromJson(Map<String, dynamic> json) => _$WebRTCOfferFromJson(json);
}

@freezed
class WebRTCAnswer with _$WebRTCAnswer {
  const factory WebRTCAnswer({
    required String sdp,
    required String type,
    DateTime? createdAt,
    String? id,
  }) = _WebRTCAnswer;

  factory WebRTCAnswer.fromJson(Map<String, dynamic> json) => _$WebRTCAnswerFromJson(json);
}

@freezed
class WebRTCIceCandidate with _$WebRTCIceCandidate {
  const factory WebRTCIceCandidate({
    required String candidate,
    String? sdpMid,
    int? sdpMLineIndex,
    DateTime? createdAt,
    String? id,
  }) = _WebRTCIceCandidate;

  factory WebRTCIceCandidate.fromJson(Map<String, dynamic> json) => _$WebRTCIceCandidateFromJson(json);
}