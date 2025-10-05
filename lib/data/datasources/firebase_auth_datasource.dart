import 'package:firebase_database/firebase_database.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/user.dart';

@injectable
class FirebaseAuthDataSource {
  final FirebaseDatabase _database;

  FirebaseAuthDataSource(this._database);

  Future<User?> authenticateUser(String email, String password) async {
    try {
      final username = email.split('@').first;
      final userRef = _database.ref('users/$username');
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        final userData = Map<String, dynamic>.from(snapshot.value as Map);
        final user = User.fromJson({
          'id': username,
          'name': userData['name'],
          'email': userData['email'],
          'password': userData['pass'],
          'status': userData['status'],
          'lastActive': userData['lastActive'],
        });

        // Check if password matches
        if (user.password == password) {
          return user;
        }
      }
      return null;
    } catch (e) {
      throw ServerException('Authentication failed: $e');
    }
  }

  Future<void> updateUserStatus(String userId, bool status) async {
    try {
      final userRef = _database.ref('users/$userId');
      await userRef.update({
        'status': status,
        'lastActive': DateTime.now().millisecondsSinceEpoch.toString(),
      });
    } catch (e) {
      throw ServerException('Failed to update user status: $e');
    }
  }

  Future<User?> getCurrentUser(String userId) async {
    try {
      final userRef = _database.ref('users/$userId');
      final snapshot = await userRef.get();

      if (snapshot.exists) {
        final userData = Map<String, dynamic>.from(snapshot.value as Map);
        return User.fromJson({
          'id': userId,
          'name': userData['name'],
          'email': userData['email'],
          'password': userData['pass'],
          'status': userData['status'],
          'lastActive': userData['lastActive'],
        });
      }
      return null;
    } catch (e) {
      throw ServerException('Failed to get current user: $e');
    }
  }
}
