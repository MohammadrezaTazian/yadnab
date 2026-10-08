import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Yadnab basic widget smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Yadnab'),
        ),
      ),
    );

    expect(find.text('Yadnab'), findsOneWidget);
  });
}