import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/session_helper.dart';
import '../../login/provider/auth_provider.dart';
import '../../../../domain/entities/user.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    print('🚀 Splash screen: Starting session check...');
    
    // Wait a bit for the splash screen to be visible
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) {
      print('❌ Splash screen: Widget not mounted, returning');
      return;
    }
    
    try {
      print('🔍 Splash screen: Checking login status...');
      final isLoggedIn = await SessionHelper.isLoggedIn();
      print('📱 Splash screen: Login status: $isLoggedIn');
      
      if (!mounted) {
        print('❌ Splash screen: Widget not mounted after session check, returning');
        return;
      }
      
      if (isLoggedIn) {
        print('✅ Splash screen: User is logged in, restoring auth state...');
        
        // Restore auth state from session
        final userId = await SessionHelper.getUserId();
        final userName = await SessionHelper.getUserName();
        final userEmail = await SessionHelper.getUserEmail();
        
        if (userId != null && userName != null && userEmail != null) {
          // Create a mock user object for the session
          final user = User(
            id: userId,
            name: userName,
            email: userEmail,
            password: '', // Not needed for session restoration
            status: true,
            lastActive: DateTime.now().millisecondsSinceEpoch.toString(),
            friends: {},
          );
          
          // Update auth state
          ref.read(authProvider.notifier).state = ref.read(authProvider).copyWith(
            isAuthenticated: true,
            currentUser: user,
          );
          
          print('✅ Splash screen: Auth state restored for user: $userName');
          print('🔍 Splash screen: Auth state - isAuthenticated: ${ref.read(authProvider).isAuthenticated}');
          print('🔍 Splash screen: Auth state - currentUser: ${ref.read(authProvider).currentUser?.name}');
        }
        
        print('✅ Splash screen: Navigating to home...');
        context.go('/home');
      } else {
        print('❌ Splash screen: User is not logged in, navigating to login...');
        context.go('/login');
      }
    } catch (e) {
      print('❌ Splash screen: Error checking session: $e');
      // On error, go to login
      if (mounted) {
        print('🔄 Splash screen: Navigating to login due to error...');
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.directions_walk,
              size: 120,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            const Text(
              'Walkie',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Connecting...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
