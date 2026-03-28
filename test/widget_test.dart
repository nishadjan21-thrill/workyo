import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:workyo/main.dart';

import 'package:workyo/providers/languageprovider.dart';

void main() {
  testWidgets('App loads splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => LanguageProvider())],
        child: const Workyo(),
      ),
    );

    // Wait for first frame
    await tester.pump();

    // Check splash screen appears
    expect(find.text('Splash Screen'), findsOneWidget);
  });
}
