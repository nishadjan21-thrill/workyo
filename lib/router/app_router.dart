import 'package:go_router/go_router.dart';
import '../screens/languageselect.dart';
import '../screens/signup.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/language',

  routes: [
    GoRoute(
      path: '/language',
      builder: (context, state) => const LanguageSelect(),
    ),

    GoRoute(path: '/signup', builder: (context, state) => SignUpScreen()),
  ],
);
