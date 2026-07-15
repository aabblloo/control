import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:control/main.dart';
import 'package:control/screens/physical_control_screen.dart';

void main() {
  testWidgets('shows the login screen', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Connexion'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
  });

  testWidgets('shows the physical control screen structure', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PhysicalControlScreen()));

    expect(find.text('Contrôle physique'), findsOneWidget);
    expect(find.text('Établissement sélectionné'), findsOneWidget);
    expect(find.text('Matricule'), findsOneWidget);
    expect(find.text('Présents'), findsOneWidget);
  });

  testWidgets('opens the add student screen from the physical control screen', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PhysicalControlScreen()));

    await tester.tap(find.byTooltip('Ajouter un élève'));
    await tester.pumpAndSettle();

    expect(find.text('Ajouter un élève'), findsOneWidget);
  });
}
