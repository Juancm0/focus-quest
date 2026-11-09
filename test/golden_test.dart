import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_quest/main.dart';
import 'package:focus_quest/providers/quest_provider.dart';
import 'package:focus_quest/services/storage_service.dart';

/// Golden test de la pantalla principal: verifica que el layout no se
/// rompe y deja la captura en test/goldens/home.png (copia en screenshots/).
/// Nota: en el entorno de tests el texto se ve como bloques porque Flutter
/// usa una fuente de prueba; en el celular o en web el texto se ve normal.
void main() {
  testWidgets('captura pantalla principal', (tester) async {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialStateProvider.overrideWithValue(seedData()),
        ],
        child: const FocusQuestApp(),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MainScreen),
      matchesGoldenFile('goldens/home.png'),
    );
  });
}
