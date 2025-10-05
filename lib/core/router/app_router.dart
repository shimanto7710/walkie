import 'package:go_router/go_router.dart';
import '../../presentation/features/home/ui/home_screen.dart';
import '../../presentation/features/firebase_test/ui/firebase_test_page.dart';
import '../../presentation/features/login/ui/login_screen.dart';
import '../../presentation/features/signup/ui/signup_screen.dart';
import '../../presentation/features/splash/ui/splash_screen.dart';

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
      path: '/firebase-test',
      name: 'firebase-test',
      builder: (context, state) => const FirebaseTestPage(),
    ),
  ],
);
