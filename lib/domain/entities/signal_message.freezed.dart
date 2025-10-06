// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'signal_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SignalMessage _$SignalMessageFromJson(Map<String, dynamic> json) {
  return _SignalMessage.fromJson(json);
}

/// @nodoc
mixin _$SignalMessage {
  String get type => throw _privateConstructorUsedError;
  String get from => throw _privateConstructorUsedError;
  String get to => throw _privateConstructorUsedError;
  String? get sdp => throw _privateConstructorUsedError;
  Map<String, dynamic>? get candidate => throw _privateConstructorUsedError;
  String? get roomId => throw _privateConstructorUsedError;

  /// Serializes this SignalMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SignalMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SignalMessageCopyWith<SignalMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SignalMessageCopyWith<$Res> {
  factory $SignalMessageCopyWith(
          SignalMessage value, $Res Function(SignalMessage) then) =
      _$SignalMessageCopyWithImpl<$Res, SignalMessage>;
  @useResult
  $Res call(
      {String type,
      String from,
      String to,
      String? sdp,
      Map<String, dynamic>? candidate,
      String? roomId});
}

/// @nodoc
class _$SignalMessageCopyWithImpl<$Res, $Val extends SignalMessage>
    implements $SignalMessageCopyWith<$Res> {
  _$SignalMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SignalMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? from = null,
    Object? to = null,
    Object? sdp = freezed,
    Object? candidate = freezed,
    Object? roomId = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      from: null == from
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as String,
      to: null == to
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as String,
      sdp: freezed == sdp
          ? _value.sdp
          : sdp // ignore: cast_nullable_to_non_nullable
              as String?,
      candidate: freezed == candidate
          ? _value.candidate
          : candidate // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      roomId: freezed == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SignalMessageImplCopyWith<$Res>
    implements $SignalMessageCopyWith<$Res> {
  factory _$$SignalMessageImplCopyWith(
          _$SignalMessageImpl value, $Res Function(_$SignalMessageImpl) then) =
      __$$SignalMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String type,
      String from,
      String to,
      String? sdp,
      Map<String, dynamic>? candidate,
      String? roomId});
}

/// @nodoc
class __$$SignalMessageImplCopyWithImpl<$Res>
    extends _$SignalMessageCopyWithImpl<$Res, _$SignalMessageImpl>
    implements _$$SignalMessageImplCopyWith<$Res> {
  __$$SignalMessageImplCopyWithImpl(
      _$SignalMessageImpl _value, $Res Function(_$SignalMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of SignalMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? from = null,
    Object? to = null,
    Object? sdp = freezed,
    Object? candidate = freezed,
    Object? roomId = freezed,
  }) {
    return _then(_$SignalMessageImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      from: null == from
          ? _value.from
          : from // ignore: cast_nullable_to_non_nullable
              as String,
      to: null == to
          ? _value.to
          : to // ignore: cast_nullable_to_non_nullable
              as String,
      sdp: freezed == sdp
          ? _value.sdp
          : sdp // ignore: cast_nullable_to_non_nullable
              as String?,
      candidate: freezed == candidate
          ? _value._candidate
          : candidate // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      roomId: freezed == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SignalMessageImpl implements _SignalMessage {
  const _$SignalMessageImpl(
      {required this.type,
      required this.from,
      required this.to,
      this.sdp,
      final Map<String, dynamic>? candidate,
      this.roomId})
      : _candidate = candidate;

  factory _$SignalMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$SignalMessageImplFromJson(json);

  @override
  final String type;
  @override
  final String from;
  @override
  final String to;
  @override
  final String? sdp;
  final Map<String, dynamic>? _candidate;
  @override
  Map<String, dynamic>? get candidate {
    final value = _candidate;
    if (value == null) return null;
    if (_candidate is EqualUnmodifiableMapView) return _candidate;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? roomId;

  @override
  String toString() {
    return 'SignalMessage(type: $type, from: $from, to: $to, sdp: $sdp, candidate: $candidate, roomId: $roomId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SignalMessageImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.from, from) || other.from == from) &&
            (identical(other.to, to) || other.to == to) &&
            (identical(other.sdp, sdp) || other.sdp == sdp) &&
            const DeepCollectionEquality()
                .equals(other._candidate, _candidate) &&
            (identical(other.roomId, roomId) || other.roomId == roomId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, from, to, sdp,
      const DeepCollectionEquality().hash(_candidate), roomId);

  /// Create a copy of SignalMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SignalMessageImplCopyWith<_$SignalMessageImpl> get copyWith =>
      __$$SignalMessageImplCopyWithImpl<_$SignalMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SignalMessageImplToJson(
      this,
    );
  }
}

abstract class _SignalMessage implements SignalMessage {
  const factory _SignalMessage(
      {required final String type,
      required final String from,
      required final String to,
      final String? sdp,
      final Map<String, dynamic>? candidate,
      final String? roomId}) = _$SignalMessageImpl;

  factory _SignalMessage.fromJson(Map<String, dynamic> json) =
      _$SignalMessageImpl.fromJson;

  @override
  String get type;
  @override
  String get from;
  @override
  String get to;
  @override
  String? get sdp;
  @override
  Map<String, dynamic>? get candidate;
  @override
  String? get roomId;

  /// Create a copy of SignalMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SignalMessageImplCopyWith<_$SignalMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
