import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:workyo/widgets/dots_loader.dart';

import '../theme/app_spacing.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      context.go('/language');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Workyo",
              style: TextStyle(fontFamily: 'CarterOne', fontSize: 48),
            ),

            AppSpacing.section,

            const DotsLoader(),
          ],
        ),
      ),
    );
  }
}
