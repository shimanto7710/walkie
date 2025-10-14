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
    final authState = ref.watch(authProvider);
    
    if (!authState.isAuthenticated || authState.currentUser == null) {
      return [];
    }
    
    final currentUserId = authState.currentUser!.id;
    
    final userRepository = getIt<UserRepository>();
    final result = await userRepository.getFriendsOfUser(currentUserId);
    
    if (result.isLeft()) {
      throw Exception(result.fold((l) => l.toString(), (r) => ''));
    }
    
    final friends = result.getOrElse(() => []);
    
    userRepository.watchFriendsOfUser(currentUserId).listen((realtimeFriends) {
      state = AsyncValue.data(realtimeFriends);
    });
    
    return friends;
  }

}

@riverpod
Stream<List<User>> watchFriends(WatchFriendsRef ref) {
  final authState = ref.read(authProvider);
  if (!authState.isAuthenticated || authState.currentUser == null) {
    return Stream.value([]);
  }
  
  final currentUserId = authState.currentUser!.id;
  final userRepository = getIt<UserRepository>();
  return userRepository.watchFriendsOfUser(currentUserId);
}
