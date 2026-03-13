import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workyo/l10n/app_localizations.dart';

import 'package:workyo/widgets/continuebutton.dart';
import 'package:workyo/widgets/emailfield.dart';
import 'package:workyo/widgets/fullnamefield.dart';
import 'package:workyo/widgets/passwordfield.dart';
import 'package:workyo/widgets/phonefield.dart';
import 'package:workyo/widgets/responsivescreen.dart';
import 'package:workyo/services/auth_service.dart';

import '../widgets/app_page.dart';
import '../theme/app_spacing.dart';
import '../theme/app_textstyles.dart';
import '../theme/app_colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final authService = AuthService();

  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullnameController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    fullnameController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    setState(() => isLoading = true);

    final user = await authService.signUp(
      emailController.text.trim(),
      passwordController.text.trim(),
      phoneController.text.trim(),
      fullnameController.text.trim(),
    );

    setState(() => isLoading = false);

    if (!mounted) return;

    if (user != null) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sign up failed')));
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
                AppLocalizations.of(context)!.createAccount,
                style: AppTextStyles.header,
              ),
            ),

            AppSpacing.section,

            FullNameInputField(controller: fullnameController),

            AppSpacing.small,

            PhoneInputField(controller: phoneController),

            AppSpacing.small,

            EmailInputField(controller: emailController),

            AppSpacing.small,

            PasswordInputField(controller: passwordController),

            AppSpacing.small,

            TextButton(
              onPressed: () => context.go('/login'),
              child: Text(
                AppLocalizations.of(context)!.alreadyHaveAccount,
                style: const TextStyle(color: AppColors.primary),
              ),
            ),

            const Spacer(),

            ContinueButton(
              text: isLoading
                  ? "Please wait..."
                  : AppLocalizations.of(context)!.createAccount,
              onPressed: isLoading
                  ? null
                  : () async {
                      await _handleSignUp();
                    },
            ),

            SizedBox(height: height * 0.02),
          ],
        ),
      ),
    );
  }
}
