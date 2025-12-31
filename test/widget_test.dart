// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:odisha_air_map/main.dart';

void main() {
  testWidgets('Splash displays app title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Only pump once because the splash has a repeating animation.
    await tester.pump();

    // Verify that the splash shows the app title.
    expect(find.text('ODISHA SCAN'), findsOneWidget);

    // Advance time so the 4s navigation timer can run and not remain pending.
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();
  });
}
