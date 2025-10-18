// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuang/game/my_game.dart';
import 'package:tuang/main.dart';

void main() {
  testWidgets('App boots and renders MaterialApp', (WidgetTester tester) async {
    final game = MyGame();
    await tester.pumpWidget(MyApp(game: game));
    await tester.pumpAndSettle();

    // Verify root MaterialApp is present in the widget tree
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
