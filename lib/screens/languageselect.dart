import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:workyo/providers/languageprovider.dart';
import 'package:workyo/widgets/continuebutton.dart';
import 'package:workyo/widgets/languagebutton.dart';

import '../l10n/app_localizations.dart';

import '../theme/app_textstyles.dart';

class LanguageSelect extends StatelessWidget {
  static Widget section = SizedBox(height: 24.h);
  static Widget small = SizedBox(height: 12.h);
  const LanguageSelect({super.key});

  final List<Map<String, String>> languages = const [
    {"title": "English", "subtitle": "English", "code": "en"},
    {"title": "Hindi", "subtitle": "हिंदी", "code": "hi"},
    {"title": "Malayalam", "subtitle": "മലയാളം", "code": "ml"},
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 80.h), // replaces height * 0.08

                  Text(
                    "Workyo",
                    style: TextStyle(fontFamily: 'CarterOne', fontSize: 28.sp),
                  ),

                  SizedBox(height: 24.h),

                  Text(
                    AppLocalizations.of(context)!.selectLanguage,
                    style: AppTextStyles.header.copyWith(fontSize: 20.sp),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 24.h),

                  ...languages.map((language) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: LanguageOptionTile(
                        title: language["title"]!,
                        subtitle: language["subtitle"]!,
                        isSelected:
                            languageProvider.locale.languageCode ==
                            language["code"],
                        onTap: () {
                          languageProvider.setLocale(Locale(language["code"]!));
                        },
                      ),
                    );
                  }),

                  SizedBox(height: 24.h),

                  ContinueButton(
                    text: AppLocalizations.of(context)!.continueText,
                    onPressed: () async {
                      context.go('/signup');
                    },
                  ),

                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
