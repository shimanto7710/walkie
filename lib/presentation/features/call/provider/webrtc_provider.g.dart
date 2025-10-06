// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webrtc_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$callStateStreamHash() => r'9165ae194b74f86bf99f958c367cb2b19d7c682f';

/// See also [callStateStream].
@ProviderFor(callStateStream)
final callStateStreamProvider = AutoDisposeStreamProvider<CallState>.internal(
  callStateStream,
  name: r'callStateStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$callStateStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CallStateStreamRef = AutoDisposeStreamProviderRef<CallState>;
String _$webrtcRepositoryHash() => r'871d48671d6de0ef37344bdb812332c49f4af2f2';

/// See also [webrtcRepository].
@ProviderFor(webrtcRepository)
final webrtcRepositoryProvider = AutoDisposeProvider<WebRTCRepository>.internal(
  webrtcRepository,
  name: r'webrtcRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$webrtcRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WebrtcRepositoryRef = AutoDisposeProviderRef<WebRTCRepository>;
String _$webRTCNotifierHash() => r'8c91f0fef12a73c64a3ac865eab1b3835b95526c';

/// See also [WebRTCNotifier].
@ProviderFor(WebRTCNotifier)
final webRTCNotifierProvider =
    AutoDisposeNotifierProvider<WebRTCNotifier, CallState>.internal(
  WebRTCNotifier.new,
  name: r'webRTCNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$webRTCNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WebRTCNotifier = AutoDisposeNotifier<CallState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
