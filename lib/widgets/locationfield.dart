import 'package:flutter/material.dart';
import 'package:workyo/l10n/app_localizations.dart';
import 'package:workyo/theme/app_textstyles.dart';

class Locationfield extends StatelessWidget {
  final TextEditingController controller;

  const Locationfield({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: AppTextStyles.subtitle,
      controller: controller,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.location,
        prefixIcon: const Icon(Icons.location_on),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Location is required";
        }
        return null;
      },
    );
  }
}
