import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calculadora_taller/main.dart';

void main() {
  testWidgets('Calculadora resuelve 2 + 3 = 5', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    final displayFinder = find.byKey(const Key('display_text'));
    String currentDisplay() => tester.widget<Text>(displayFinder).data ?? '';

    expect(currentDisplay(), '0');

    await tester.tap(find.widgetWithText(ElevatedButton, '2'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, '+'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, '3'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, '='));
    await tester.pump();

    expect(currentDisplay(), '5');
  });

  testWidgets('Calculadora maneja division por cero', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    final displayFinder = find.byKey(const Key('display_text'));
    String currentDisplay() => tester.widget<Text>(displayFinder).data ?? '';

    await tester.tap(find.widgetWithText(ElevatedButton, '8'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, '/'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, '0'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, '='));
    await tester.pump();

    expect(currentDisplay(), 'Error');
  });
}
