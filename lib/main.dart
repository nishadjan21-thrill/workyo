import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:workyo/l10n/app_localizations.dart';
import 'package:workyo/providers/languageprovider.dart';
import 'package:workyo/router/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:workyo/widgets/backround_wrapper.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final languageProvider = LanguageProvider();
  await languageProvider.loadSavedLocale();

  runApp(
    ChangeNotifierProvider.value(
      value: languageProvider,
      child: const Workyo(),
    ),
  );
}

class Workyo extends StatelessWidget {
  const Workyo({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return ScreenUtilInit(
          designSize: const Size(375, 812), // 📱 base design (important)
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, child) {
            return MaterialApp.router(
              routerConfig: appRouter,

              builder: (context, child) {
                return AppBackgroundWrapper(child: child!);
              },

              locale: languageProvider.locale,
              supportedLocales: const [
                Locale('en'),
                Locale('ml'),
                Locale('hi'),
              ],

              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],

              title: 'Workyo',

              theme: ThemeData(
                primaryColor: Colors.yellowAccent,
                fontFamily: 'ChelseaMarket',
                scaffoldBackgroundColor: Colors.transparent,
              ),
            );
          },
        );
      },
    );
  }
}
