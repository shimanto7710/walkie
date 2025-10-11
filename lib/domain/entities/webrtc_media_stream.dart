import 'package:freezed_annotation/freezed_annotation.dart';

part 'webrtc_media_stream.freezed.dart';

@freezed
class WebRTCMediaStream with _$WebRTCMediaStream {
  const factory WebRTCMediaStream({
    required String streamId,
    required WebRTCMediaType type,
    required bool isLocal,
    required bool isEnabled,
    String? userId,
    Map<String, dynamic>? constraints,
    DateTime? createdAt,
  }) = _WebRTCMediaStream;
}

@freezed
class WebRTCMediaConstraints with _$WebRTCMediaConstraints {
  const factory WebRTCMediaConstraints({
    @Default(true) bool audio,
    @Default(WebRTCAudioConstraints()) WebRTCAudioConstraints audioConstraints,
  }) = _WebRTCMediaConstraints;
}

@freezed
class WebRTCAudioConstraints with _$WebRTCAudioConstraints {
  const factory WebRTCAudioConstraints({
    @Default(true) bool echoCancellation,
    @Default(true) bool noiseSuppression,
    @Default(true) bool autoGainControl,
    @Default(48000) int sampleRate,
    @Default(1) int channelCount,
  }) = _WebRTCAudioConstraints;
}

enum WebRTCMediaType {
  audio,
}
