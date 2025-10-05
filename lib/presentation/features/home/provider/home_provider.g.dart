// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$watchUsersHash() => r'b5267a15f6b2196ea9667075d5925421b0436b40';

/// See also [watchUsers].
@ProviderFor(watchUsers)
final watchUsersProvider = AutoDisposeStreamProvider<List<User>>.internal(
  watchUsers,
  name: r'watchUsersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$watchUsersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WatchUsersRef = AutoDisposeStreamProviderRef<List<User>>;
String _$usersNotifierHash() => r'1c5731a89c4e387db0ed5d04bcc5aaefb530a22e';

/// See also [UsersNotifier].
@ProviderFor(UsersNotifier)
final usersNotifierProvider =
    AutoDisposeAsyncNotifierProvider<UsersNotifier, List<User>>.internal(
  UsersNotifier.new,
  name: r'usersNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$usersNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UsersNotifier = AutoDisposeAsyncNotifier<List<User>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
