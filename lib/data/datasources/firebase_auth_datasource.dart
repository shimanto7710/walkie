import 'package:firebase_database/firebase_database.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/user.dart';

@injectable
class FirebaseAuthDataSource {
  final FirebaseDatabase _database;

  FirebaseAuthDataSource(this._database);

  Map<String, bool> _convertFriendsData(dynamic friendsData) {
    if (friendsData == null) return {};
    
    try {
      if (friendsData is Map) {
        return friendsData.map((key, value) => MapEntry(
          key.toString(),
          value is bool ? value : false,
        ));
      }
    } catch (e) {
      print('❌ Error converting friends data: $e');
    }
    
    return {};
  }

  Future<User?> authenticateUser(String email, String password) async {
    print('🔥 FirebaseAuthDataSource.authenticateUser called');
    print('  Email: $email');
    print('  Password: $password');
    
    try {
      final username = email.split('@').first;
      print('  Username extracted: $username');
      
      final userRef = _database.ref('users/$username');
      print('  Firebase path: users/$username');
      
      final snapshot = await userRef.get();
      print('  Snapshot exists: ${snapshot.exists}');

      if (snapshot.exists) {
        final userData = Map<String, dynamic>.from(snapshot.value as Map);
        print('  User data from Firebase: $userData');
        
        final user = User.fromJson({
          'id': username,
          'name': userData['name'],
          'email': userData['email'],
          'password': userData['pass'],
          'status': userData['status'],
          'lastActive': userData['lastActive'],
          'friends': _convertFriendsData(userData['friends']),
        });
        
        print('  User object created: ${user.name}');
        print('  Stored password: ${user.password}');
        print('  Entered password: $password');
        print('  Passwords match: ${user.password == password}');

        // Check if password matches
        if (user.password == password) {
          print('✅ Password matches, returning user');
          return user;
        } else {
          print('❌ Password does not match');
        }
      } else {
        print('❌ User not found in Firebase');
      }
      return null;
    } catch (e) {
      print('❌ Exception in authenticateUser: $e');
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
          'friends': _convertFriendsData(userData['friends']),
        });
      }
      return null;
    } catch (e) {
      throw ServerException('Failed to get current user: $e');
    }
  }

  Future<User> createUser(String name, String email, String password) async {
    print('🔥 FirebaseAuthDataSource.createUser called');
    print('  Name: $name');
    print('  Email: $email');
    print('  Password: $password');
    
    try {
      final username = email.split('@').first;
      print('  Username extracted: $username');
      
      final userRef = _database.ref('users/$username');
      print('  Firebase path: users/$username');
      
      // Check if user already exists
      final snapshot = await userRef.get();
      print('  User already exists: ${snapshot.exists}');
      
      if (snapshot.exists) {
        throw ServerException('User with this email already exists');
      }
      
      // Create new user
      final currentTime = DateTime.now().millisecondsSinceEpoch.toString();
      final userData = {
        'name': name,
        'email': email,
        'pass': password,
        'status': true, // Set as online when created
        'lastActive': currentTime,
      };
      
      print('  Creating user with data: $userData');
      await userRef.set(userData);
      print('✅ User created successfully');
      
      // Return the created user
      return User.fromJson({
        'id': username,
        'name': name,
        'email': email,
        'password': password,
        'status': true,
        'lastActive': currentTime,
        'friends': {},
      });
    } catch (e) {
      print('❌ Exception in createUser: $e');
      throw ServerException('Failed to create user: $e');
    }
  }
}
