import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/usecases/get_users.dart';
import '../../../../domain/usecases/update_user_status.dart';
import '../../../../domain/usecases/watch_users.dart';
import '../../../../core/di/injection.dart';

part 'home_provider.g.dart';

@riverpod
class UsersNotifier extends _$UsersNotifier {
  @override
  Future<List<User>> build() async {
    print("🚀 UsersNotifier build() called - fetching initial data");
    
    // Initial data fetch when app starts
    final getUsers = getIt<GetUsers>();
    final result = await getUsers();
    
    if (result.isLeft()) {
      print("❌ Error fetching initial users: ${result.fold((l) => l.toString(), (r) => '')}");
      throw Exception(result.fold((l) => l.toString(), (r) => ''));
    }
    
    final initialUsers = result.getOrElse(() => []);
    print("✅ Initial users fetched: ${initialUsers.length} users");
    
    // Set up real-time listener
    final watchUsers = getIt<WatchUsers>();
    watchUsers().listen((realtimeUsers) {
      print("🔄 Real-time update received: ${realtimeUsers.length} users");
      state = AsyncValue.data(realtimeUsers);
    });
    
    return initialUsers;
  }

  Future<void> toggleUserStatus(User user) async {
    print("🔄 Toggling user status for: ${user.name}");
    final updateUserStatus = getIt<UpdateUserStatus>();
    final result = await updateUserStatus(user.id, !user.isOnline);

    result.fold(
      (failure) {
        print("❌ Error updating user status: ${failure.toString()}");
        throw Exception(failure.toString());
      },
      (_) {
        print("✅ User status updated successfully");
        // Update local state optimistically
        final currentUsers = state.value ?? [];
        final updatedUsers = currentUsers.map((u) {
          if (u.id == user.id) {
            return user.copyWith(isOnline: !user.isOnline);
          }
          return u;
        }).toList();
        state = AsyncValue.data(updatedUsers);
      },
    );
  }
}

@riverpod
Stream<List<User>> watchUsers(WatchUsersRef ref) {
  final watchUsers = getIt<WatchUsers>();
  return watchUsers();
}
