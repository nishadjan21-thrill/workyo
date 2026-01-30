import 'package:go_router/go_router.dart';

import 'package:workyo/screens/splashscreen.dart';

import '../screens/languageselect.dart';
import '../screens/signup.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',

  routes: [
    GoRoute(
      path: '/language',
      builder: (context, state) => const LanguageSelect(),
    ),

    GoRoute(path: '/signup', builder: (context, state) => SignUpScreen()),

    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
  ],
);
