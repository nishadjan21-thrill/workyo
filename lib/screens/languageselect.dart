import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:workyo/providers/languageprovider.dart';
import 'package:workyo/widgets/continuebutton.dart';
import 'package:workyo/widgets/languagebutton.dart';


import '../l10n/app_localizations.dart';

import '../theme/app_spacing.dart';
import '../theme/app_textstyles.dart';

class LanguageSelect extends StatelessWidget {
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
        final height = MediaQuery.of(context).size.height;

        return Scaffold(backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                SizedBox(height: height * 0.08),

                Text("Yo", style: AppTextStyles.yosty1),

                AppSpacing.section,

                Text(
                  AppLocalizations.of(context)!.selectLanguage,
                  style: AppTextStyles.header,
                  textAlign: TextAlign.center,
                ),

                AppSpacing.section,

                ...languages.map((language) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: LanguageOptionTile(
                      title: language["title"]!,
                      subtitle: language["subtitle"]!,
                      isSelected:
                          languageProvider.locale.languageCode ==
                          language["code"],
                      onTap: () {
                        languageProvider.setLocale(
                          Locale(language["code"]!),
                        );
                      },
                    ),
                  );
                }),

                

                ContinueButton(
                  text: AppLocalizations.of(context)!.continueText,
                  onPressed: () async {
                    context.go('/signup');
                  },
                ),

                AppSpacing.small,
              ],
            ),
          ),
        );
      },
    );
  }
}