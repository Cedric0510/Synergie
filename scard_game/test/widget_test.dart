// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scard_game/app.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: ScardApp()));

    // Wait for animations to settle
    await tester.pump(const Duration(milliseconds: 100));

    // Verify that the app loads by checking for MaterialApp
    expect(find.byType(MaterialApp), findsOneWidget);

    // Verify app has correct theme (dark theme)
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, 'Synergie');
    expect(materialApp.debugShowCheckedModeBanner, false);
  });
}
