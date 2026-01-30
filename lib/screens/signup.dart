import 'package:flutter/material.dart';
import 'package:workyo/l10n/app_localizations.dart';
import 'package:workyo/widgets/continuebutton.dart';
import 'package:workyo/widgets/emailfield.dart';
import 'package:workyo/widgets/passwordfield.dart';
import 'package:workyo/widgets/phonefield.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 70),
              Center(
                child: Image.asset(
                  'assets/images/splashscreen.png',
                  height: 100,
                ),
              ),
              SizedBox(height: 76),
              Center(
                child: Text(
                  AppLocalizations.of(context)!.createAccount,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
              SizedBox(height: 76),

              PhoneInputField(controller: phoneController),
              SizedBox(height: 30),
              EmailInputField(controller: emailController),
              SizedBox(height: 30),
              PasswordInputField(controller: passwordController),
              SizedBox(height: 50),
              ContinueButton(
                text: AppLocalizations.of(context)!.createAccount,
                onPressed: () {
                  // Handle continue button press
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
