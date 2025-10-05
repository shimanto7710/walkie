import 'package:firebase_database/firebase_database.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/user.dart';
import '../../core/errors/exceptions.dart';

@injectable
class FirebaseUserDataSource {
  final FirebaseDatabase _database;

  FirebaseUserDataSource(this._database);

  Stream<List<User>> watchUsers() {
    try {
      return _database.ref('users').onValue.map((event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          return data.entries
              .map((entry) => User.fromJson({
                    'id': entry.key,
                    'name': entry.value['name'] ?? '',
                    'isOnline': entry.value['status'] == true,
                    'lastActive': entry.value['lastActive']?.toString() ?? '',
                  }))
              .toList();
        }
        return <User>[];
      });
    } catch (e) {
      throw ServerException('Failed to watch users: $e');
    }
  }

  Future<List<User>> getUsers() async {
    try {
      final testRef = _database.ref();
      // Add timeout to prevent hanging
      final snapshot = await _database.ref('users').get().timeout(
        const Duration(seconds: 5), // Reduced timeout for faster debugging
        onTimeout: () {
          throw ServerException('Firebase call timed out');
        },
      );
      
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        print("🔍 Data keys: ${data.keys.toList()}");
        
        final users = data.entries
            .map((entry) => User.fromJson({
                  'id': entry.key,
                  'name': entry.value['name'] ?? '',
                  'isOnline': entry.value['status'] == true,
                  'lastActive': entry.value['lastActive']?.toString() ?? '',
                }))
            .toList();

        return users;
      }
      return [];
    } catch (e) {
      throw ServerException('Failed to get users: $e');
    }
  }

  Future<void> updateUserStatus(String userId, bool status) async {
    try {
      await _database.ref('users').child(userId).update({
        'status': status,
        'lastActive': DateTime.now().millisecondsSinceEpoch.toString(),
      });
    } catch (e) {
      throw ServerException('Failed to update user status: $e');
    }
  }

  Future<void> addUser(User user) async {
    try {
      await _database.ref('users').child(user.id).set({
        'name': user.name,
        'status': user.status,
        'lastActive': user.lastActive,
      });
    } catch (e) {
      throw ServerException('Failed to add user: $e');
    }
  }
}
