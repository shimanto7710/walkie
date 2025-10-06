// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signal_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SignalMessageImpl _$$SignalMessageImplFromJson(Map<String, dynamic> json) =>
    _$SignalMessageImpl(
      type: json['type'] as String,
      from: json['from'] as String,
      to: json['to'] as String,
      sdp: json['sdp'] as String?,
      candidate: json['candidate'] as Map<String, dynamic>?,
      roomId: json['roomId'] as String?,
    );

Map<String, dynamic> _$$SignalMessageImplToJson(_$SignalMessageImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'from': instance.from,
      'to': instance.to,
      'sdp': instance.sdp,
      'candidate': instance.candidate,
      'roomId': instance.roomId,
    };
