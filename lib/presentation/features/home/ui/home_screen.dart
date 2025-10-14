import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_database/firebase_database.dart';
import '../provider/friends_provider.dart';
import '../../../../presentation/widgets/user_list_item.dart';
import '../../login/provider/auth_provider.dart';
import '../../call/provider/call_provider.dart';
import '../../call/provider/global_handshake_provider.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/entities/call_state.dart';
import '../../../../domain/entities/handshake.dart';
import '../../../../utils/firebase_cleanup.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _webrtcInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWebRTCForIncomingCalls();
    });
  }

  void _initializeWebRTCForIncomingCalls() async {
    if (_webrtcInitialized) return;
    
    try {
      final authState = ref.read(authProvider);
      if (authState.currentUser != null) {
        final globalHandshakeNotifier = ref.read(globalHandshakeNotifierProvider.notifier);
        globalHandshakeNotifier.listenForUserHandshakes(authState.currentUser!.id);
        _webrtcInitialized = true;
      }
    } catch (e) {
      // Handle initialization error
    }
  }

  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(friendsNotifierProvider);
    
    ref.listen<CallState>(callNotifierProvider, (previous, next) {
      if (next.status == CallStatus.ringing && next.remoteUserId != null) {
        final authState = ref.read(authProvider);
        if (authState.currentUser != null) {
          context.go('/call/${next.remoteUserId}?currentUserId=${authState.currentUser!.id}&currentUserName=${authState.currentUser!.name}');
        }
      }
    });

    ref.listen<Handshake?>(globalHandshakeNotifierProvider, (previous, next) {
      if (next != null) {
        final authState = ref.read(authProvider);
        if (authState.currentUser != null) {
          if (next.callerId == authState.currentUser!.id || 
              next.receiverId == authState.currentUser!.id) {
            
            switch (next.status) {
              case 'call_initiate':
                break;
              case 'call_acknowledge':
                if (next.receiverId == authState.currentUser!.id) {
                  context.go('/call/${next.callerId}?incoming=true&handshakeId=${next.callerId}_${next.receiverId}&currentUserId=${authState.currentUser!.id}&currentUserName=${authState.currentUser!.name}');
                }
                break;
              case 'ringing':
                break;
              case 'connected':
                break;
              case 'completed':
                break;
              case 'close_call':
                break;
              default:
                break;
            }
          }
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Walkie'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile feature coming soon!')),
              );
            },
            tooltip: 'Profile',
          ),
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            onPressed: () => _showCleanupDialog(context),
            tooltip: 'Clean Firebase Signals',
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () => _testHandshake(context, ref),
            tooltip: 'Test Handshake',
          ),
          IconButton(
            icon: const Icon(Icons.wifi),
            onPressed: () => _testFirebaseListener(context, ref),
            tooltip: 'Test Firebase Listener',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings feature coming soon!')),
              );
            },
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context, ref),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: friendsAsync.when(
        data: (friends) => friends.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No friends found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add friends to see them here',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  final friend = friends[index];
                  return UserListItem(
                    user: friend,
                    onTap: null,
                    onCall: () => _startCall(context, friend),
                  );
                },
              ),
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading users from Firebase...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Connecting to real-time database',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading friends',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              ElevatedButton(
                    onPressed: () => ref.invalidate(friendsNotifierProvider),
                child: const Text('Retry'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => _cleanupFirebaseSignals(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Clean Signals'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startCall(BuildContext context, User friend) {
    final authState = ref.read(authProvider);
    if (authState.currentUser != null) {
      context.go('/call/${friend.id}?currentUserId=${authState.currentUser!.id}&currentUserName=${authState.currentUser!.name}');
    }
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleLogout(context, ref);
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) async {
    await ref.read(authProvider.notifier).logout();
    if (context.mounted) {
      context.go('/login');
    }
  }

  void _showCleanupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.cleaning_services, color: Colors.orange),
              SizedBox(width: 8),
              Text('Clean Firebase Signals'),
            ],
          ),
          content: const Text(
            'This will remove all signal data from Firebase Realtime Database. '
            'This includes all call requests, offers, answers, and ICE candidates.\n\n'
            'Are you sure you want to proceed?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cleanupFirebaseSignals();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clean Signals'),
            ),
          ],
        );
      },
    );
  }

  void _cleanupFirebaseSignals() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Cleaning up signals...'),
            ],
          ),
        ),
      );

      final beforeCount = await FirebaseCleanup.getSignalCount();
      await FirebaseCleanup.deleteAllSignals();
      
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Cleaned up $beforeCount signals from Firebase!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to clean signals: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _testHandshake(BuildContext context, WidgetRef ref) async {
    try {
      final authState = ref.read(authProvider);
      if (authState.currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ No authenticated user found'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final currentUserId = authState.currentUser!.id;
      final currentUserName = authState.currentUser!.name;
      
      final testUserId = currentUserId == 'guler' ? 'ozil' : 'guler';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🧪 Testing handshake: $currentUserName -> $testUserId'),
          backgroundColor: Colors.blue,
        ),
      );

      final callNotifier = ref.read(callNotifierProvider.notifier);
      callNotifier.startCall();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Call test initiated!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Handshake test failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _testFirebaseListener(BuildContext context, WidgetRef ref) async {
    try {
      final authState = ref.read(authProvider);
      if (authState.currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ No authenticated user found'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final currentUserId = authState.currentUser!.id;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🧪 Testing Firebase listener for user: $currentUserId'),
          backgroundColor: Colors.blue,
        ),
      );

      final database = FirebaseDatabase.instance.ref();
      final handshakeRef = database.child('handshakes');
      
      final subscription = handshakeRef.onValue.listen((event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value;
          
          if (data is Map<dynamic, dynamic>) {
            for (final entry in data.entries) {
              if (entry.value is Map) {
                final handshakeData = Map<String, dynamic>.from(entry.value as Map);
                
                if (handshakeData['receiverId'] == currentUserId) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🎯 Found handshake for you from: ${handshakeData['callerId']}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            }
          }
        }
      });
      
      Future.delayed(const Duration(seconds: 10), () {
        subscription.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Firebase listener test completed! Check logs.'),
            backgroundColor: Colors.green,
          ),
        );
      });
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Firebase listener test failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
