import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workyo/widgets/continuebutton.dart';
import 'package:workyo/widgets/languagebutton.dart';
import 'package:workyo/providers/languageprovider.dart';

import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';

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
      builder: (context, languageProvider, child) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 70),
                  Image.asset('assets/images/splashscreen.png', height: 100),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)!.selectLanguage,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 24),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: languages.length,
                    itemBuilder: (context, index) {
                      final language = languages[index];

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
                    },
                  ),

                  const Spacer(),

                  ContinueButton(
                    text: AppLocalizations.of(context)!.selectLanguage,
                    onPressed: () {
                      context.push('/signup');
                      debugPrint(
                        "Locale: ${languageProvider.locale.languageCode}",
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
