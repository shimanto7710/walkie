import 'package:go_router/go_router.dart';
import '../../presentation/features/home/ui/home_screen.dart';
import '../../presentation/features/firebase_test/ui/firebase_test_page.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
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
