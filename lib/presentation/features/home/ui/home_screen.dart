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
    // Initialize WebRTC for incoming calls
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWebRTCForIncomingCalls();
    });
  }

  void _initializeWebRTCForIncomingCalls() async {
    if (_webrtcInitialized) return;
    
    try {
      final authState = ref.read(authProvider);
      if (authState.currentUser != null) {
        print('🔧 Simple call UI ready');
        
        // Start listening to global handshake changes for this user
        final globalHandshakeNotifier = ref.read(globalHandshakeNotifierProvider.notifier);
        globalHandshakeNotifier.listenForUserHandshakes(authState.currentUser!.id);
        
        _webrtcInitialized = true;
        print('✅ Simple call UI initialized with global handshake listener');
      }
    } catch (e) {
      print('❌ Failed to initialize Simple WebRTC for incoming calls: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(friendsNotifierProvider);
    
    // Listen for call state changes
    ref.listen<CallState>(callNotifierProvider, (previous, next) {
      if (next.status == CallStatus.ringing && next.remoteUserId != null) {
        print('📞 Incoming call detected on home screen from ${next.remoteUserId}');
        
        // Navigate to call screen
        context.go('/call/${next.remoteUserId}');
      }
    });

    // Listen for global handshake changes from anywhere in the app
    ref.listen<Handshake?>(globalHandshakeNotifierProvider, (previous, next) {
      if (next != null) {
        final authState = ref.read(authProvider);
        if (authState.currentUser != null) {
          // Check if this handshake involves the current user
          if (next.callerId == authState.currentUser!.id || 
              next.receiverId == authState.currentUser!.id) {
            
            print('🌍 Global handshake detected on home screen:');
            print('   Status: ${next.status}');
            print('   Caller: ${next.callerId}');
            print('   Receiver: ${next.receiverId}');
            
            // Handle different handshake statuses
            switch (next.status) {
              case 'call_initiate':
                print('📞 New call initiated!');
                break;
              case 'call_acknowledge':
                print('📞 Call acknowledged!');
                // Navigate to call screen when call is acknowledged
                if (next.receiverId == authState.currentUser!.id) {
                  print('📞 Navigating to call screen for incoming call from ${next.callerId}');
                  // Pass handshake data to indicate this is an incoming call
                  context.go('/call/${next.callerId}?incoming=true&handshakeId=${next.callerId}_${next.receiverId}');
                }
                break;
              case 'ringing':
                print('📞 Call is ringing!');
                break;
              case 'connected':
                print('📞 Call connected!');
                break;
              case 'completed':
                print('📞 Call completed!');
                break;
              case 'close_call':
                print('📞 Call closed by other party!');
                // Handle call closure - could show notification or update UI
                break;
              default:
                print('📞 Handshake status: ${next.status}');
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
          // Profile Icon
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // TODO: Navigate to profile screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile feature coming soon!')),
              );
            },
            tooltip: 'Profile',
          ),
          // Clean Signals Button
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            onPressed: () => _showCleanupDialog(context),
            tooltip: 'Clean Firebase Signals',
          ),
          // Debug Handshake Button
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () => _testHandshake(context, ref),
            tooltip: 'Test Handshake',
          ),
          // Debug Firebase Listener Button
          IconButton(
            icon: const Icon(Icons.wifi),
            onPressed: () => _testFirebaseListener(context, ref),
            tooltip: 'Test Firebase Listener',
          ),
          // Settings Icon
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings feature coming soon!')),
              );
            },
            tooltip: 'Settings',
          ),
          // Logout Button
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
                    onTap: null, // No tap action - status is managed automatically
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
    print('📞 Starting call with ${friend.name}');
    context.go('/call/${friend.id}');
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
      // Show loading dialog
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

      // Get signal count before cleanup
      final beforeCount = await FirebaseCleanup.getSignalCount();
      
      // Clean up signals
      await FirebaseCleanup.deleteAllSignals();
      
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // Show success message with count
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Cleaned up $beforeCount signals from Firebase!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // Show error message
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
      
      // Test handshake with ozil
      final testUserId = currentUserId == 'guler' ? 'ozil' : 'guler';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🧪 Testing handshake: $currentUserName -> $testUserId'),
          backgroundColor: Colors.blue,
        ),
      );

      // Test simple call functionality
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

      // Test Firebase listener directly
      final database = FirebaseDatabase.instance.ref();
      final handshakeRef = database.child('handshakes');
      
      print('🔥 Firebase test - Setting up listener for handshakes...');
      
      // Listen for 10 seconds
      final subscription = handshakeRef.onValue.listen((event) {
        print('🔥 Firebase test - Event received: ${event.snapshot.value}');
        
        if (event.snapshot.exists) {
          final data = event.snapshot.value;
          print('🔥 Firebase test - Data exists: $data');
          
          if (data is Map<dynamic, dynamic>) {
            for (final entry in data.entries) {
              if (entry.value is Map) {
                final handshakeData = Map<String, dynamic>.from(entry.value as Map);
                print('🔥 Firebase test - Handshake: ${entry.key} -> $handshakeData');
                
                // Check if this handshake involves the current user
                if (handshakeData['receiverId'] == currentUserId) {
                  print('🔥 Firebase test - Found handshake for current user: $currentUserId');
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
        } else {
          print('🔥 Firebase test - No data exists');
        }
      });
      
      // Cancel after 10 seconds
      Future.delayed(const Duration(seconds: 10), () {
        subscription.cancel();
        print('🔥 Firebase test - Listener cancelled after 10 seconds');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Firebase listener test completed! Check logs.'),
            backgroundColor: Colors.green,
          ),
        );
      });
      
    } catch (e) {
      print('❌ Firebase listener test error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Firebase listener test failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
