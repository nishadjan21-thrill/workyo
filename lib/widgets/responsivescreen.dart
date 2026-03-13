import 'package:flutter/material.dart';
import 'package:workyo/theme/app_gradients.dart';

class ResponsiveScreen extends StatelessWidget {
  final Widget child;

  const ResponsiveScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      body: Container(
        decoration: BoxDecoration(gradient: AppGradients.mainBackground),

        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
