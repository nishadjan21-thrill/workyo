import 'package:flutter/material.dart';

class AppBackgroundWrapper extends StatelessWidget {
  final Widget child;

  const AppBackgroundWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF121212),
            Color.fromARGB(255, 4, 4, 4),
            Color(0xFF191414),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}