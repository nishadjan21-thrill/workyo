import 'dart:async';
import 'package:flutter/material.dart';

class DotsLoader extends StatefulWidget {
  const DotsLoader({super.key});

  @override
  State<DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<DotsLoader> {
  int activeDot = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!mounted) return; // ✅ IMPORTANT

      setState(() {
        activeDot = (activeDot + 1) % 3;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // ✅ MUST cancel timer
    super.dispose();
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: index == activeDot ? 10 : 8,
      width: index == activeDot ? 10 : 8,
      decoration: BoxDecoration(
        color: index == activeDot
            ? Colors.white
            : Colors.white.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildDot(0),
        buildDot(1),
        buildDot(2),
      ],
    );
  }
}