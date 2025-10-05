import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/repositories/user_repository.dart';
import '../../../../core/di/injection.dart';
import '../../login/provider/auth_provider.dart';

part 'friends_provider.g.dart';

@riverpod
class FriendsNotifier extends _$FriendsNotifier {
  @override
  Future<List<User>> build() async {
    print("🚀 FriendsNotifier build() called - fetching friends data");
    
    // Get current user from auth state
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated || authState.currentUser == null) {
      print("❌ No authenticated user found");
      return [];
    }
    
    final currentUserId = authState.currentUser!.id;
    print("📱 Current user ID: $currentUserId");
    
    // Get friends of current user
    final userRepository = getIt<UserRepository>();
    final result = await userRepository.getFriendsOfUser(currentUserId);
    
    if (result.isLeft()) {
      print("❌ Error fetching friends: ${result.fold((l) => l.toString(), (r) => '')}");
      throw Exception(result.fold((l) => l.toString(), (r) => ''));
    }
    
    final friends = result.getOrElse(() => []);
    print("✅ Friends fetched: ${friends.length} friends");
    
    // Set up real-time listener for friends
    userRepository.watchFriendsOfUser(currentUserId).listen((realtimeFriends) {
      print("🔄 Real-time friends update received: ${realtimeFriends.length} friends");
      state = AsyncValue.data(realtimeFriends);
    });
    
    return friends;
  }

  Future<void> toggleFriendStatus(User friend) async {
    print("🔄 Toggling friend status for: ${friend.name}");
    final userRepository = getIt<UserRepository>();
    final result = await userRepository.updateUserStatus(friend.id, !friend.status);

    result.fold(
      (failure) {
        print("❌ Error updating friend status: ${failure.toString()}");
        throw Exception(failure.toString());
      },
      (_) {
        print("✅ Friend status updated successfully");
        // Update local state optimistically
        final currentFriends = state.value ?? [];
        final updatedFriends = currentFriends.map((f) {
          if (f.id == friend.id) {
            return friend.copyWith(status: !friend.status);
          }
          return f;
        }).toList();
        state = AsyncValue.data(updatedFriends);
      },
    );
  }
}

@riverpod
Stream<List<User>> watchFriends(WatchFriendsRef ref) {
  // Get current user from auth state
  final authState = ref.read(authProvider);
  if (!authState.isAuthenticated || authState.currentUser == null) {
    return Stream.value([]);
  }
  
  final currentUserId = authState.currentUser!.id;
  final userRepository = getIt<UserRepository>();
  return userRepository.watchFriendsOfUser(currentUserId);
}
