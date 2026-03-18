import 'package:flutter/material.dart';
import 'package:workyo/theme/app_gradients.dart';

class ResponsiveScreen extends StatelessWidget {
  final Widget child;

  const ResponsiveScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Workyo', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white))),
      resizeToAvoidBottomInset: true,

      body: Container(
        decoration: BoxDecoration(gradient: AppGradients.mainBackground),

        child: SafeArea(
          child: child,
        ),
      ),
    );
  }
}
