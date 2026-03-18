import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainNavBar extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  const MainNavBar({super.key, required this.child, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.transparent],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, -3),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'Workers',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                context.go('/dashboard');
                break;
              case 1:
                context.go('/workerslist');
                break;
              case 2:
                context.go('/profile');
                break;
            }
          },
        ),
      ),
    );
  }
}