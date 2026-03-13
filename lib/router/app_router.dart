import 'package:go_router/go_router.dart';
import 'package:workyo/screens/homescreen.dart';
import 'package:workyo/screens/login.dart';
import 'package:workyo/screens/profile_screen.dart';
import '../screens/languageselect.dart';
import '../screens/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',

  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;

    final loggingIn = state.uri.path == '/login' || state.uri.path == '/signup';

    if (user == null && !loggingIn) {
      return '/login';
    }

    if (user != null && loggingIn) {
      return '/home';
    }

    return null;
  },

  routes: [
    GoRoute(
      path: '/language',
      builder: (context, state) => const LanguageSelect(),
    ),

    GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),

    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    /// HOME ROUTE
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),

      routes: [
        /// CHILD ROUTE (keeps BottomBar)
        GoRoute(
          path: 'profile',
          builder: (context, state) => const ProfileSetupScreen(),
        ),
      ],
    ),
  ],
);
