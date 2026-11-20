import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habla_fluido/main.dart' as app;
import 'package:integration_test/integration_test.dart';

/// Recorre Habla Fluido en el emulador y toma una captura de cada pantalla.
/// Se corre con: flutter drive --driver=test_driver/integration_test.dart --target=integration_test/capturas_test.dart
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  var convertida = false;

  Future<void> esperar(WidgetTester tester, Finder f, {int veces = 60}) async {
    for (var i = 0; i < veces && f.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
  }

  Future<void> foto(WidgetTester tester, String nombre) async {
    if (!convertida) {
      await binding.convertFlutterSurfaceToImage();
      convertida = true;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    await binding.takeScreenshot(nombre);
  }

  Future<bool> tocar(WidgetTester tester, Finder f) async {
    await esperar(tester, f, veces: 12);
    if (f.evaluate().isEmpty) return false;
    await tester.ensureVisible(f.first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(f.first);
    await tester.pump(const Duration(milliseconds: 900));
    return true;
  }

  Future<void> volver(WidgetTester tester) async {
    await tester.pageBack();
    await tester.pump(const Duration(milliseconds: 900));
  }

  testWidgets('recorrido de Habla Fluido con capturas', (tester) async {
    app.main();
    await esperar(tester, find.textContaining('Plan de hoy'));
    await foto(tester, '01_inicio_plan_de_hoy');

    if (await tocar(tester, find.textContaining('Escritura ·'))) {
      await tester.enterText(find.byType(TextField).first, 'Yesterday I go to the market with my friends.');
      await tocar(tester, find.text('Pedir corrección'));
      await esperar(tester, find.text('Versión corregida:'), veces: 20);
      await foto(tester, '02_escritura_con_correccion');
      await volver(tester);
    }

    if (await tocar(tester, find.textContaining('Conversación ·'))) {
      await tester.enterText(find.byType(TextField).first, 'Hello! I want practice my english.');
      await tocar(tester, find.byIcon(Icons.send));
      await tester.pump(const Duration(seconds: 2));
      await foto(tester, '03_conversacion_con_el_tutor');
      await volver(tester);
    }

    if (await tocar(tester, find.textContaining('Lectura ·'))) {
      await foto(tester, '04_lectura');
      await volver(tester);
    }

    if (await tocar(tester, find.textContaining('Oído ·'))) {
      await foto(tester, '05_dictado');
      await volver(tester);
    }

    if (await tocar(tester, find.textContaining('Pronunciación ·'))) {
      await foto(tester, '06_pronunciacion');
      await volver(tester);
    }

    if (await tocar(tester, find.textContaining('Repaso espaciado'))) {
      await foto(tester, '07_repaso_espaciado');
      await volver(tester);
    }
  });
}
