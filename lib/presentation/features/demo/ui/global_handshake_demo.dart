import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../call/provider/global_handshake_provider.dart';
import '../../../../domain/entities/handshake.dart';
import '../../login/provider/auth_provider.dart';

/// Demo screen showing how to listen to handshake changes from anywhere in the app
class GlobalHandshakeDemo extends ConsumerWidget {
  const GlobalHandshakeDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final handshake = ref.watch(globalHandshakeNotifierProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Handshake Demo'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current User: ${authState.currentUser?.id ?? "Not logged in"}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            const Text(
              'Global Handshake Status:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            if (handshake != null) ...[
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${handshake.status}'),
                      Text('Caller: ${handshake.callerId}'),
                      Text('Receiver: ${handshake.receiverId}'),
                      Text('Caller Sent: ${handshake.callerIdSent}'),
                      Text('Receiver Sent: ${handshake.receiverIdSent}'),
                      Text('Timestamp: ${DateTime.fromMillisecondsSinceEpoch(handshake.timestamp)}'),
                      Text('Last Updated: ${DateTime.fromMillisecondsSinceEpoch(handshake.lastUpdated)}'),
                    ],
                  ),
                ),
              ),
            ] else ...[
              const Card(
                color: Colors.grey,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No handshake data available'),
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            const Text(
              'How to use from any screen:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1. Import the provider:', style: TextStyle(fontFamily: 'monospace')),
                    Text('   import \'../../call/provider/global_handshake_provider.dart\';'),
                    SizedBox(height: 10),
                    Text('2. Listen to changes:', style: TextStyle(fontFamily: 'monospace')),
                    Text('   ref.listen<Handshake?>(globalHandshakeNotifierProvider, (prev, next) {'),
                    Text('     // Handle handshake changes'),
                    Text('   });'),
                    SizedBox(height: 10),
                    Text('3. Start listening for a user:', style: TextStyle(fontFamily: 'monospace')),
                    Text('   ref.read(globalHandshakeNotifierProvider.notifier)'),
                    Text('     .listenForUserHandshakes(userId);'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
