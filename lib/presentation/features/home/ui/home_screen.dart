import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_database/firebase_database.dart';
import '../provider/home_provider.dart';
import '../../../../domain/entities/user.dart';
import '../../../../presentation/widgets/user_list_item.dart';
import '../../../../network_test.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Walkie - Users'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.wifi),
            onPressed: () async {
              // Test network connectivity
              await testNetworkConnectivity();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Network test completed - check console')),
              );
            },
            tooltip: 'Test Network',
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () async {
              // Test Firebase connection
              try {
                final database = FirebaseDatabase.instance;
                print("🧪 Manual Firebase test starting...");
                print("🔍 Database URL: ${database.databaseURL}");
                
                final snapshot = await database.ref('test').get().timeout(
                  const Duration(seconds: 5),
                  onTimeout: () {
                    print("⏰ Manual test timed out");
                    throw Exception('Manual test timed out');
                  },
                );
                
                print("✅ Manual test successful: ${snapshot.exists}");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Firebase test successful!')),
                );
              } catch (e) {
                print("❌ Manual test failed: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Firebase test failed: $e')),
                );
              }
            },
            tooltip: 'Test Firebase',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/firebase-test'),
            tooltip: 'Firebase Test',
          ),
        ],
      ),
      body: usersAsync.when(
        data: (users) => users.isEmpty
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
                      'No users found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Users will appear here when they connect',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return UserListItem(
                    user: user,
                    onTap: () => _toggleUserStatus(ref, user),
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
                'Error loading users',
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
                onPressed: () => ref.refresh(watchUsersProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleUserStatus(WidgetRef ref, User user) {
    ref.read(usersNotifierProvider.notifier).toggleUserStatus(user);
  }
}
