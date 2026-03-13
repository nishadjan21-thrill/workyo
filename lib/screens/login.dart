import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:workyo/l10n/app_localizations.dart';
import 'package:workyo/widgets/continuebutton.dart';
import 'package:workyo/widgets/emailfield.dart';
import 'package:workyo/widgets/passwordfield.dart';
import 'package:workyo/services/auth_service.dart';
import 'package:workyo/widgets/responsivescreen.dart';

import '../widgets/app_page.dart';
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
      context.go('/home');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Log in failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return AppPage(
      child: ResponsiveScreen(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height * 0.06),

            Center(
              child: Image.asset(
                'assets/images/splashscreen.png',
                height: height * 0.12,
              ),
            ),

            AppSpacing.section,

            Center(
              child: Text(
                AppLocalizations.of(context)!.logIn,
                style: AppTextStyles.header,
              ),
            ),

            AppSpacing.section,

            EmailInputField(controller: emailController),

            AppSpacing.small,

            PasswordInputField(controller: passwordController),

            AppSpacing.small,

            TextButton(
              onPressed: () {
                _showResetDialog(context);
              },
              child: const Text(
                "Forgot password?",
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),

            AppSpacing.small,

            TextButton(
              onPressed: () {
                context.go('/signup');
              },
              child: Text(
                AppLocalizations.of(context)!.createAccount,
                style: TextStyle(color: AppColors.primary),
              ),
            ),
            const Spacer(),

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
    );
  }
}

void _showResetDialog(BuildContext context) {
  final emailController = TextEditingController();
  final authService = AuthService();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Reset Password"),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: "Enter your email"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await authService.resetPassword(emailController.text.trim());

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Password reset email sent")),
              );
            },
            child: const Text("Send"),
          ),
        ],
      );
    },
  );
}
