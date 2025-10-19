import 'package:firebase_database/firebase_database.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/user.dart';
import '../../core/errors/exceptions.dart';

@injectable
class FirebaseUserDataSource {
  final FirebaseDatabase _database;

  FirebaseUserDataSource(this._database);

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
    }
    
    return {};
  }



  Future<User?> getUserById(String userId) async {
    try {
      final userRef = _database.ref('users/$userId');
      final snapshot = await userRef.get().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw ServerException('Firebase call timed out');
        },
      );

      if (snapshot.exists) {
        final userData = Map<String, dynamic>.from(snapshot.value as Map);
        return User.fromJson({
          'id': userId,
          'name': userData['name'] ?? '',
          'email': userData['email'] ?? '',
          'password': userData['pass'] ?? '',
          'status': userData['status'] == true,
          'lastActive': userData['lastActive']?.toString() ?? '',
          'friends': _convertFriendsData(userData['friends']),
        });
      }
      return null;
    } catch (e) {
      throw ServerException('Failed to get user by ID: $e');
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

  Future<List<User>> getFriendsOfUser(String userId) async {
    try {
      
      // First get the current user's friends list
      final userRef = _database.ref('users/$userId');
      final userSnapshot = await userRef.get();
      
      if (!userSnapshot.exists) {
        return [];
      }
      
      final userData = Map<String, dynamic>.from(userSnapshot.value as Map);
      final friendsData = _convertFriendsData(userData['friends']);
      
      
      if (friendsData.isEmpty) {
        return [];
      }
      
      // Get all users
      final allUsersSnapshot = await _database.ref('users').get();
      if (!allUsersSnapshot.exists) {
        return [];
      }
      
      final allUsersData = allUsersSnapshot.value;
      if (allUsersData is Map) {
        final friends = <User>[];
      
      // Filter only the friends
      for (final friendId in friendsData.keys) {
        if (allUsersData.containsKey(friendId)) {
          final friendData = allUsersData[friendId];
          final friend = User.fromJson({
            'id': friendId,
            'name': friendData['name'] ?? '',
            'email': friendData['email'] ?? '',
            'password': friendData['pass'] ?? '',
            'status': friendData['status'] == true,
            'lastActive': friendData['lastActive']?.toString() ?? '',
            'friends': _convertFriendsData(friendData['friends']),
          });
          friends.add(friend);
        } else {
        }
      }
      
      return friends;
      }
      return [];
    } catch (e) {
      throw ServerException('Failed to get friends: $e');
    }
  }

  Stream<List<User>> watchFriendsOfUser(String userId) {
    try {
      
      return _database.ref('users').onValue.map((event) async {
        if (!event.snapshot.exists) {
          return <User>[];
        }
        
        // Get the current user's friends list
        final userRef = _database.ref('users/$userId');
        final userSnapshot = await userRef.get();
        
        if (!userSnapshot.exists) {
          return <User>[];
        }
        
        final userData = Map<String, dynamic>.from(userSnapshot.value as Map);
        final friendsData = _convertFriendsData(userData['friends']);
        
        if (friendsData.isEmpty) {
          return <User>[];
        }
        
        // Get all users data
        final allUsersData = event.snapshot.value;
        if (allUsersData is Map) {
          final friends = <User>[];
        
        // Filter only the friends
        for (final friendId in friendsData.keys) {
          if (allUsersData.containsKey(friendId)) {
            final friendData = allUsersData[friendId];
            final friend = User.fromJson({
              'id': friendId,
              'name': friendData['name'] ?? '',
              'email': friendData['email'] ?? '',
              'password': friendData['pass'] ?? '',
              'status': friendData['status'] == true,
              'lastActive': friendData['lastActive']?.toString() ?? '',
              'friends': _convertFriendsData(friendData['friends']),
            });
            friends.add(friend);
          }
        }
        
        return friends;
        }
        return <User>[];
      }).asyncMap((future) => future);
    } catch (e) {
      throw ServerException('Failed to watch friends: $e');
    }
  }

}
