import 'package:flutter/material.dart';

class PremiumTextField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final IconData? icon;
  final bool obscureText;

  const PremiumTextField({
    super.key,
    required this.hint,
    this.controller,
    this.icon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),

        // 🔥 Glass dark background
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),

        // ✨ Soft border
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),

        // 💡 Depth shadow
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),

        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),

          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white,
          ),

          prefixIcon: icon != null
              ? Icon(icon, color: Colors.white70)
              : null,
        ),
      ),
    );
  }
}