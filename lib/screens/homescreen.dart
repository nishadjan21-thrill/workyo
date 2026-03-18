import 'package:flutter/material.dart';
import 'package:workyo/l10n/app_localizations.dart';


import 'workers_screen.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();
    screens = [
      const WorkersListScreen(),
      DashboardScreen(
        onGoProfile: () {
          if (!mounted) return;
          setState(() => currentIndex = 2);
        },
      ),
      const ProfileSetupScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: currentIndex,
            children: screens,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _navItem(Icons.people_outline,
                        AppLocalizations.of(context)!.workers, 0),
                    _navItem(Icons.dashboard_outlined,
                        AppLocalizations.of(context)!.dashboard, 1),
                    _navItem(Icons.person_outline,
                        AppLocalizations.of(context)!.profile, 2),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (!mounted) return;
        setState(() => currentIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black87 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}