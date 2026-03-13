import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workyo/theme/app_colors.dart';

import '../widgets/app_page.dart';
import '../theme/app_textstyles.dart';
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
    return AppPage(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/splashscreen.png', height: 120),

            AppSpacing.section,

            const Text("Workyo", style: AppTextStyles.header),

            AppSpacing.section,

            const CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
