import 'package:go_router/go_router.dart';
import '../../presentation/features/home/ui/home_screen.dart';
import '../../presentation/features/login/ui/login_screen.dart';
import '../../presentation/features/signup/ui/signup_screen.dart';
import '../../presentation/features/splash/ui/splash_screen.dart';
import '../../presentation/features/call/ui/call_screen.dart';
import '../../domain/entities/user.dart';
import '../constants/app_constants.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: AppConstants.splashRouteName,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: AppConstants.loginRouteName,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/home',
      name: AppConstants.homeRouteName,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/call/:friendId',
      name: AppConstants.callRouteName,
      builder: (context, state) {
        final friendId = state.pathParameters['friendId']!;
        final queryParams = state.uri.queryParameters;
        
        final isIncomingCall = queryParams['incoming'] == 'true';
        final handshakeId = queryParams['handshakeId'];
        
        final currentUserId = queryParams['currentUserId']!;
        final currentUserName = queryParams['currentUserName']!;
        
        // Get friend data from query parameters instead of hardcoded values
        final friendName = queryParams['friendName'] ?? 'Unknown Friend';
        final friendEmail = queryParams['friendEmail'] ?? '$friendId@example.com';
        final friendStatus = queryParams['friendStatus'] == 'true';
        final friendLastActive = queryParams['friendLastActive'] ?? DateTime.now().millisecondsSinceEpoch.toString();
        
        final friend = User(
          id: friendId,
          name: friendName,
          email: friendEmail,
          password: '',
          status: friendStatus,
          lastActive: friendLastActive,
          friends: {},
        );
        
        return CallScreen(
          currentUserId: currentUserId,
          currentUserName: currentUserName,
          friend: friend,
          isIncomingCall: isIncomingCall,
          handshakeId: handshakeId,
        );
      },
    ),
  ],
);
