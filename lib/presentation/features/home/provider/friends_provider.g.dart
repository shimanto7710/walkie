// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friends_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$watchFriendsHash() => r'f723d85cadcf1d0c76ca6d1c73129e3bcc68bb86';

/// See also [watchFriends].
@ProviderFor(watchFriends)
final watchFriendsProvider = AutoDisposeStreamProvider<List<User>>.internal(
  watchFriends,
  name: r'watchFriendsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$watchFriendsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WatchFriendsRef = AutoDisposeStreamProviderRef<List<User>>;
String _$friendsNotifierHash() => r'4590527ae047f6be7dbe553cf008feaebb84e984';

/// See also [FriendsNotifier].
@ProviderFor(FriendsNotifier)
final friendsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<FriendsNotifier, List<User>>.internal(
  FriendsNotifier.new,
  name: r'friendsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$friendsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FriendsNotifier = AutoDisposeAsyncNotifier<List<User>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
