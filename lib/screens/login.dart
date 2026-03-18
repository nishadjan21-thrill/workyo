import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:workyo/l10n/app_localizations.dart';
import 'package:workyo/widgets/continuebutton.dart';
import 'package:workyo/widgets/text_field.dart';
import 'package:workyo/services/auth_service.dart';

import '../theme/app_spacing.dart';
import '../theme/app_textstyles.dart';
import '../theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final authService = AuthService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => isLoading = true);

    final user = await authService.logIn(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (user != null) {
      context.go('/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log in failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20), // ✅ spacing fix
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.06),

              Center(
                child: Text("Yo", style: AppTextStyles.header),
              ),

              AppSpacing.section,

              Center(
                child: Text(
                  AppLocalizations.of(context)!.logIn,
                  style: AppTextStyles.title,
                ),
              ),

              AppSpacing.section,

              // ✅ Premium Email Field
              PremiumTextField(
                hint: "Enter your email",
                controller: emailController,
                icon: Icons.email,
              ),

              AppSpacing.small,

              // ✅ Premium Password Field
              PremiumTextField(
                hint: "Enter your password",
                controller: passwordController,
                icon: Icons.lock,
                obscureText: true,
              ),

              AppSpacing.small,

              TextButton(
                onPressed: () {
                  _showResetDialog();
                },
                child: const Text(
                  "Forgot password?",
                  style: TextStyle(color: AppColors.clr1),
                ),
              ),

              AppSpacing.small,

              TextButton(
                onPressed: () {
                  context.go('/signup');
                },
                child: Text(
                  AppLocalizations.of(context)!.createAccount,
                  style: TextStyle(color: AppColors.clr1),
                ),
              ),

              ContinueButton(
                text: isLoading
                    ? "Please wait..."
                    : AppLocalizations.of(context)!.logIn,
                onPressed: isLoading
                    ? null
                    : () async {
                        await _handleLogin();
                      },
              ),

              SizedBox(height: height * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetDialog() {
    final emailController = TextEditingController();
    final authService = AuthService();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black, // 🔥 match theme
          title: const Text(
            "Reset Password",
            style: TextStyle(color: Colors.white),
          ),
          content: PremiumTextField(
            hint: "Enter your email",
            controller: emailController,
            icon: Icons.email,
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (mounted) Navigator.pop(context);
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () async {
                await authService.resetPassword(emailController.text.trim());

                if (mounted) {
                  Navigator.pop(context); // Close dialog

                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text("Password reset email sent")),
                  );
                }
              },
              child: const Text(
                "Send",
                style: TextStyle(color: AppColors.clr1),
              ),
            ),
          ],
        );
      },
    );
  }
}