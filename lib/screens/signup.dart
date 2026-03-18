import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workyo/l10n/app_localizations.dart';

import 'package:workyo/widgets/continuebutton.dart';
import 'package:workyo/widgets/text_field.dart'; // For PremiumTextField

import 'package:workyo/services/auth_service.dart';
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
      context.go('/workerlist');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign up failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: 
         LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.06),

                      Center(
                        child: Text("Yo", style: AppTextStyles.subtitle),
                      ),

                      AppSpacing.section,

                      Center(
                        child: Text(
                          AppLocalizations.of(context)!.createAccount,
                          style: AppTextStyles.header,
                        ),
                      ),

                      AppSpacing.section,

                      // Full Name
                      PremiumTextField(
                        controller: fullnameController,hint: AppLocalizations.of(context)!.name,
                        
                        
                      ),
                      AppSpacing.small,

                      // Phone
                      PremiumTextField(
                        controller: phoneController,
                        hint: "phone",
                        
                      ),
                      AppSpacing.small,

                      // Email
                      PremiumTextField(
                        controller: emailController,
                        hint: AppLocalizations.of(context)!.email,
                        
                      ),
                      AppSpacing.small,

                      // Password
                      PremiumTextField(
                        controller: passwordController,
                        hint: AppLocalizations.of(context)!.password,
                        obscureText: true,
                      ),
                      AppSpacing.small,

                      // Already have account
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: Text(
                          AppLocalizations.of(context)!.alreadyHaveAccount,
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      ),

                      const Spacer(),

                      // Continue button pinned at bottom
                      ContinueButton(
                        text: isLoading
                            ? "Please wait..."
                            : AppLocalizations.of(context)!.createAccount,
                        onPressed: isLoading ? null : _handleSignUp,
                      ),

                      SizedBox(height: constraints.maxHeight * 0.02),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      
    );
  }
}