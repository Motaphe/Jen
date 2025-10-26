// Basic widget test for Jen app

import 'package:flutter_test/flutter_test.dart';

import 'package:jen/main.dart';

void main() {
  testWidgets('App loads home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const JenApp());

    // Verify that the home screen loads with the app name
    expect(find.text('Jen'), findsOneWidget);
  });
}
