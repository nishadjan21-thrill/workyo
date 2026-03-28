import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:workyo/l10n/app_localizations.dart';

import 'package:workyo/widgets/continuebutton.dart';
import 'package:workyo/widgets/text_field.dart';
import 'package:workyo/services/auth_service.dart';

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

    final error = await authService.signUp(
      emailController.text.trim(),
      passwordController.text.trim(),
      phoneController.text.trim(),
      fullnameController.text.trim(),
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (error == null) {
      // ✅ Success
      context.go('/workerslist');
    } else {
      // ❌ Show real error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 50.h),

              /// 🔹 LOGO
              Center(
                child: Text(
                  "Workyo",
                  style: TextStyle(fontFamily: 'Carter-One', fontSize: 28.sp),
                ),
              ),

              SizedBox(height: 24.h),

              /// 🔹 TITLE
              Center(
                child: Text(
                  l10n.createAccount,
                  style: AppTextStyles.header.copyWith(fontSize: 22.sp),
                ),
              ),

              SizedBox(height: 24.h),

              /// 🔹 INPUTS
              PremiumTextField(controller: fullnameController, hint: l10n.name),

              SizedBox(height: 12.h),

              PremiumTextField(
                controller: phoneController,
                hint: l10n.phone,
                icon: Icons.phone,
              ),

              SizedBox(height: 12.h),

              PremiumTextField(
                controller: emailController,
                hint: l10n.email,
                icon: Icons.email,
              ),

              SizedBox(height: 12.h),

              PremiumTextField(
                controller: passwordController,
                hint: l10n.password,
                obscureText: true,
                icon: Icons.lock,
              ),

              SizedBox(height: 12.h),

              /// 🔹 LOGIN REDIRECT
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text(
                  l10n.alreadyHaveAccount,
                  style: TextStyle(color: AppColors.primary, fontSize: 13.sp),
                ),
              ),

              SizedBox(height: 30.h),

              /// 🔹 BUTTON
              ContinueButton(
                text: isLoading ? l10n.pleaseWait : l10n.createAccount,
                onPressed: isLoading ? null : _handleSignUp,
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
