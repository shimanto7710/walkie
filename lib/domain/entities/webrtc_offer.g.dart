// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webrtc_offer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WebRTCOfferImpl _$$WebRTCOfferImplFromJson(Map<String, dynamic> json) =>
    _$WebRTCOfferImpl(
      sdp: json['sdp'] as String,
      type: json['type'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      id: json['id'] as String?,
    );

Map<String, dynamic> _$$WebRTCOfferImplToJson(_$WebRTCOfferImpl instance) =>
    <String, dynamic>{
      'sdp': instance.sdp,
      'type': instance.type,
      'createdAt': instance.createdAt?.toIso8601String(),
      'id': instance.id,
    };

_$WebRTCAnswerImpl _$$WebRTCAnswerImplFromJson(Map<String, dynamic> json) =>
    _$WebRTCAnswerImpl(
      sdp: json['sdp'] as String,
      type: json['type'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      id: json['id'] as String?,
    );

Map<String, dynamic> _$$WebRTCAnswerImplToJson(_$WebRTCAnswerImpl instance) =>
    <String, dynamic>{
      'sdp': instance.sdp,
      'type': instance.type,
      'createdAt': instance.createdAt?.toIso8601String(),
      'id': instance.id,
    };

_$WebRTCIceCandidateImpl _$$WebRTCIceCandidateImplFromJson(
        Map<String, dynamic> json) =>
    _$WebRTCIceCandidateImpl(
      candidate: json['candidate'] as String,
      sdpMid: json['sdpMid'] as String?,
      sdpMLineIndex: (json['sdpMLineIndex'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      id: json['id'] as String?,
    );

Map<String, dynamic> _$$WebRTCIceCandidateImplToJson(
        _$WebRTCIceCandidateImpl instance) =>
    <String, dynamic>{
      'candidate': instance.candidate,
      'sdpMid': instance.sdpMid,
      'sdpMLineIndex': instance.sdpMLineIndex,
      'createdAt': instance.createdAt?.toIso8601String(),
      'id': instance.id,
    };
