import 'package:flutter/material.dart';
import '../theme/app_gradients.dart';
import '../theme/app_spacing.dart';

class AppPage extends StatelessWidget {
  final Widget child;

  const AppPage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.mainBackground),
        child: SafeArea(
          child: Padding(padding: AppSpacing.pagePadding, child: child),
        ),
      ),
    );
  }
}
