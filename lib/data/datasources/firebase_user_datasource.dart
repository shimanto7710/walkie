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

  Stream<List<User>> watchUsers() {
    try {
      return _database.ref('users').onValue.map((event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value;
          if (data is Map) {
            return data.entries
              .map((entry) => User.fromJson({
                    'id': entry.key,
                    'name': entry.value['name'] ?? '',
                    'email': entry.value['email'] ?? '',
                    'password': entry.value['pass'] ?? '',
                    'status': entry.value['status'] == true,
                    'lastActive': entry.value['lastActive']?.toString() ?? '',
                    'friends': _convertFriendsData(entry.value['friends']),
                  }))
              .toList();
          }
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
        final data = snapshot.value;
        if (data is Map) {
        
        final users = data.entries
            .map((entry) => User.fromJson({
                  'id': entry.key,
                  'name': entry.value['name'] ?? '',
                  'email': entry.value['email'] ?? '',
                  'password': entry.value['pass'] ?? '',
                  'status': entry.value['status'] == true,
                  'lastActive': entry.value['lastActive']?.toString() ?? '',
                  'friends': _convertFriendsData(entry.value['friends']),
                }))
            .toList();

        return users;
        }
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

  Future<void> addUser(User user) async {
    try {
      await _database.ref('users').child(user.id).set({
        'name': user.name,
        'email': user.email,
        'pass': user.password,
        'status': user.status,
        'lastActive': user.lastActive,
      });
    } catch (e) {
      throw ServerException('Failed to add user: $e');
    }
  }
}
