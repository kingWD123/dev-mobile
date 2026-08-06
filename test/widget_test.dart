import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:covoiturage_app/main.dart';

void main() {
  testWidgets('Covoiturage app loads search screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CovoiturageApp());
    await tester.pumpAndSettle();

    expect(find.text('Où allez-vous ?'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Rechercher'), findsOneWidget);
  });
}
