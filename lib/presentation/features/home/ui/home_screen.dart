import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../provider/friends_provider.dart';
import '../../../../presentation/widgets/user_list_item.dart';
import '../../login/provider/auth_provider.dart';
import '../../call/provider/call_provider.dart';
import '../../call/provider/global_handshake_provider.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/entities/call_state.dart';
import '../../../../domain/entities/handshake.dart';
import '../../../../domain/repositories/user_repository.dart';
import '../../../../core/di/injection.dart';

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
                  _handleIncomingCall(context, next, authState.currentUser!);
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
              ElevatedButton(
                onPressed: () => ref.invalidate(friendsNotifierProvider),
                child: const Text('Retry'),
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
      // Pass actual friend data from Firebase instead of hardcoded values
      final friendName = Uri.encodeComponent(friend.name);
      final friendEmail = Uri.encodeComponent(friend.email);
      final friendStatus = friend.status.toString();
      final friendLastActive = friend.lastActive;
      
      context.go('/call/${friend.id}?currentUserId=${authState.currentUser!.id}&currentUserName=${authState.currentUser!.name}&friendName=$friendName&friendEmail=$friendEmail&friendStatus=$friendStatus&friendLastActive=$friendLastActive');
    }
  }

  void _handleIncomingCall(BuildContext context, Handshake handshake, User currentUser) async {
    try {
      // Fetch caller information from Firebase directly
      final userRepository = getIt<UserRepository>();
      final result = await userRepository.getUserById(handshake.callerId);
      
      result.fold(
        (failure) {
          // Fallback to basic navigation if caller data is not available
          context.go('/call/${handshake.callerId}?incoming=true&handshakeId=${handshake.callerId}_${handshake.receiverId}&currentUserId=${currentUser.id}&currentUserName=${currentUser.name}');
        },
        (caller) {
          if (caller != null) {
            // Pass actual caller data from Firebase
            final callerName = Uri.encodeComponent(caller.name);
            final callerEmail = Uri.encodeComponent(caller.email);
            final callerStatus = caller.status.toString();
            final callerLastActive = caller.lastActive;
            
            context.go('/call/${handshake.callerId}?incoming=true&handshakeId=${handshake.callerId}_${handshake.receiverId}&currentUserId=${currentUser.id}&currentUserName=${currentUser.name}&friendName=$callerName&friendEmail=$callerEmail&friendStatus=$callerStatus&friendLastActive=$callerLastActive');
          } else {
            // Fallback to basic navigation if caller data is not available
            context.go('/call/${handshake.callerId}?incoming=true&handshakeId=${handshake.callerId}_${handshake.receiverId}&currentUserId=${currentUser.id}&currentUserName=${currentUser.name}');
          }
        },
      );
    } catch (e) {
      // Fallback to basic navigation if there's an error
      context.go('/call/${handshake.callerId}?incoming=true&handshakeId=${handshake.callerId}_${handshake.receiverId}&currentUserId=${currentUser.id}&currentUserName=${currentUser.name}');
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

}
