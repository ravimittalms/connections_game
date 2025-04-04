import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:connections_game/main.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: MyApp()));
    expect(find.text('Games'), findsOneWidget);
  });
}
