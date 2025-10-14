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
    final getUsers = getIt<GetUsers>();
    final result = await getUsers();
    
    if (result.isLeft()) {
      throw Exception(result.fold((l) => l.toString(), (r) => ''));
    }
    
    final initialUsers = result.getOrElse(() => []);
    
    final watchUsers = getIt<WatchUsers>();
    watchUsers().listen((realtimeUsers) {
      state = AsyncValue.data(realtimeUsers);
    });
    
    return initialUsers;
  }

  Future<void> toggleUserStatus(User user) async {
    final updateUserStatus = getIt<UpdateUserStatus>();
    final result = await updateUserStatus(user.id, !user.status);

    result.fold(
      (failure) {
        throw Exception(failure.toString());
      },
      (_) {
        final currentUsers = state.value ?? [];
        final updatedUsers = currentUsers.map((u) {
          if (u.id == user.id) {
            return user.copyWith(status: !user.status);
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
