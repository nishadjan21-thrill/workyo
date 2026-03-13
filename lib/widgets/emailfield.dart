import 'package:flutter/material.dart';
import 'package:workyo/l10n/app_localizations.dart';
import 'package:workyo/theme/app_textstyles.dart';

class EmailInputField extends StatelessWidget {
  final TextEditingController controller;

  const EmailInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: AppTextStyles.subtitle,
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.email,

        prefixIcon: const Icon(Icons.email),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Email is required";
        }
        if (!value.contains('@')) {
          return "Enter a valid email";
        }
        return null;
      },
    );
  }
}
