import 'package:flutter/material.dart';
import 'package:workyo/theme/app_buttons.dart';
import 'package:workyo/theme/app_colors.dart';

class ContinueButton extends StatelessWidget {
  final String text;
  final Future<void> Function()? onPressed;

  const ContinueButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: AppButtons.primary,
        onPressed: onPressed == null
            ? null
            : () async {
                await onPressed!();
              },
        child: Text(text, style: TextStyle(color: AppColors.textPrimary)),
      ),
    );
  }
}
