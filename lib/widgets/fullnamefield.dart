import 'package:flutter/material.dart';
import 'package:workyo/l10n/app_localizations.dart';
import 'package:workyo/theme/app_textstyles.dart';

class FullNameInputField extends StatelessWidget {
  final TextEditingController controller;

  const FullNameInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: AppTextStyles.subtitle,
      controller: controller,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        labelStyle: AppTextStyles.subtitle,
        labelText: AppLocalizations.of(context)!.name,
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Full name is required";
        }
        return null;
      },
    );
  }
}
