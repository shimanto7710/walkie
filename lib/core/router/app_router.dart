import 'package:go_router/go_router.dart';
import '../../presentation/features/home/ui/home_screen.dart';
import '../../presentation/features/login/ui/login_screen.dart';
import '../../presentation/features/signup/ui/signup_screen.dart';
import '../../presentation/features/splash/ui/splash_screen.dart';
import '../../presentation/features/call/ui/call_screen.dart';
import '../../domain/entities/user.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/call/:friendId',
      name: 'call',
      builder: (context, state) {
        final friendId = state.pathParameters['friendId']!;
        final queryParams = state.uri.queryParameters;
        
        // Check if this is an incoming call
        final isIncomingCall = queryParams['incoming'] == 'true';
        final handshakeId = queryParams['handshakeId'];
        
        // Create a mock user with proper name mapping
        final friend = User(
          id: friendId,
          name: _getFriendName(friendId),
          email: '$friendId@example.com',
          password: '',
          status: true,
          lastActive: DateTime.now().millisecondsSinceEpoch.toString(),
          friends: {},
        );
        
        return CallScreen(
          friend: friend,
          isIncomingCall: isIncomingCall,
          handshakeId: handshakeId,
        );
      },
    ),
  ],
);

/// Helper function to get friend name by ID
String _getFriendName(String friendId) {
  switch (friendId) {
    case 'ozil':
      return 'Mesut Ozil';
    case 'guler':
      return 'Arda Guler';
    case 'james':
      return 'James Rodriguez';
    default:
      return 'Unknown Friend';
  }
}