import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workyo/l10n/app_localizations.dart';
import 'package:workyo/widgets/continuebutton.dart';
import 'package:workyo/widgets/text_field.dart';
import 'package:workyo/services/auth_service.dart';

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

    final error = await authService.logIn(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (error == null) {
      context.go('/workerslist');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error, style: TextStyle(fontSize: 14.sp)),
        ),
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
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.06),

              Center(
                child: Text(
                  "Workyo",
                  style: TextStyle(fontFamily: 'Carter-One', fontSize: 28.sp),
                ),
              ),

              SizedBox(height: 24.h),

              Center(
                child: Text(
                  AppLocalizations.of(context)!.logIn,
                  style: AppTextStyles.title.copyWith(fontSize: 20.sp),
                ),
              ),

              SizedBox(height: 24.h),

              PremiumTextField(
                hint: AppLocalizations.of(context)!.enterYourEmail,
                controller: emailController,
                icon: Icons.email,
              ),

              SizedBox(height: 12.h),

              PremiumTextField(
                hint: AppLocalizations.of(context)!.enterPassword,
                controller: passwordController,
                icon: Icons.lock,
                obscureText: true,
              ),

              SizedBox(height: 12.h),

              TextButton(
                onPressed: _showResetDialog,
                child: Text(
                  AppLocalizations.of(context)!.forgotPassword,
                  style: TextStyle(color: AppColors.clr1, fontSize: 14.sp),
                ),
              ),

              SizedBox(height: 8.h),

              TextButton(
                onPressed: () {
                  context.go('/signup');
                },
                child: Text(
                  AppLocalizations.of(context)!.createAccount,
                  style: TextStyle(color: AppColors.clr1, fontSize: 14.sp),
                ),
              ),

              SizedBox(height: 16.h),

              ContinueButton(
                text: isLoading
                    ? AppLocalizations.of(context)!.pleaseWait
                    : AppLocalizations.of(context)!.logIn,
                onPressed: isLoading ? null : _handleLogin,
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
          backgroundColor: Colors.black,
          title: Text(
            AppLocalizations.of(context)!.resetPassword,
            style: TextStyle(color: Colors.white, fontSize: 16.sp),
          ),
          content: PremiumTextField(
            hint: AppLocalizations.of(context)!.enterYourEmail,
            controller: emailController,
            icon: Icons.email,
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (mounted) Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(color: Colors.white70, fontSize: 14.sp),
              ),
            ),
            TextButton(
              onPressed: () async {
                await authService.resetPassword(emailController.text.trim());

                if (mounted) {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.resetEmailSent,
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                  );
                }
              },
              child: Text(
                AppLocalizations.of(context)!.send,
                style: TextStyle(color: AppColors.clr1, fontSize: 14.sp),
              ),
            ),
          ],
        );
      },
    );
  }
}
