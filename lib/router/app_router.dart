import 'package:go_router/go_router.dart';

import 'package:workyo/screens/dashboard_screen.dart';

import 'package:workyo/screens/login.dart';
import 'package:workyo/screens/profile_screen.dart';
import 'package:workyo/screens/splashscreen.dart';
import 'package:workyo/screens/workerdetails_screen.dart';
import 'package:workyo/screens/workers_screen.dart';
import 'package:workyo/widgets/main_navbar.dart';
import '../screens/languageselect.dart';
import '../screens/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
User ? currentUser = FirebaseAuth.instance.currentUser;
bool profileExists = false;
Map<String, dynamic> currentWorkerProfile = {};
Future<void> loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("workers")
        .doc(uid)
        .get();

    if (!doc.exists) {
      profileExists = false;
      return;
    }

    profileExists = true;

    final data = doc.data()!;

    currentWorkerProfile = {
      "name": data["name"],
      "phone": data["phone"],
      "whatsapp": data["whatsapp"],
      "locationName": data["locationName"],
      "profileImage": data["profileImage"],
      "availableToday": data["availableToday"],
      "latitude": data["latitude"],
      "longitude": data["longitude"],
      "jobTypes": List<String>.from(data["jobTypes"] ?? []),
    };
    
  }

  /// LOAD JOBS
  Future<void> loadJobs() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // ignore: unused_local_variable
    final snapshot = await FirebaseFirestore.instance
        .collection("workers")
        .doc(uid)
        .collection("jobs")
        .get();

    

    
  }

final GoRouter appRouter = GoRouter(
  initialLocation: '/splashscreen',
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final loggingIn = state.uri.path == '/login' || state.uri.path == '/signup';

    if (user == null && !loggingIn) return '/login';
    if (user != null && loggingIn) return '/dashboard';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
    
    GoRoute(path: '/signup', builder: (_, _) => const SignUpScreen()),
    GoRoute(path: '/splashscreen', builder: (_, _) => const SplashScreen()),
    GoRoute(path: '/language', builder: (_, _) => const LanguageSelect()),
    GoRoute(path: '/workerdetail', builder: (_, state) {
      
      return WorkerDetailsScreen(worker: currentWorkerProfile, jobs: [],);
    }),

    /// ShellRoute for main nav
    ShellRoute(
      builder: (context, state, child) {
        int currentIndex = 0;
        if (state.uri.path.startsWith('/workerslist')) currentIndex = 1;
        if (state.uri.path.startsWith('/profile')) currentIndex = 2;

        return MainNavBar( currentIndex: currentIndex,child: child,);
      },
      routes: [
        GoRoute(path: '/dashboard', builder: (_, _) => const DashboardScreen()),
        GoRoute(path: '/workerslist', builder: (_, _) => const WorkersListScreen()),
        GoRoute(path: '/profile', builder: (_, _) => const ProfileSetupScreen()),
      ],
    ),
  ],
);
