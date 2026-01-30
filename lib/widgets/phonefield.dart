import 'package:flutter/material.dart';

class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;

  const PhoneInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: "Phone Number",
        hintText: "+91 1234567890",
        prefixIcon: const Icon(Icons.phone),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Phone number is required";
        }
        if (value.length != 10) {
          return "Enter a valid 10-digit phone number";
        }
        return null;
      },
    );
  }
}
