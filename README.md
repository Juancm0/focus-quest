# Focus Quest

Soy Juan Carlos Martínez Mendoza, desarrollador Flutter. Focus Quest es mi
tracker de hábitos gamificado estilo RPG: creo mis hábitos, los completo
cada día y por cada misión ganada subo XP, subo de nivel, mantengo rachas y
desbloqueo logros. Mi avatar pixelado va subiendo de rango conforme subo
de nivel, de Novato a Leyenda.

## Qué hace

- **Inicio:** mi avatar pixelado, mi nivel y rango, mi barra de XP animada
  y mi lista de hábitos con botón para completar cada misión. Al completar
  una aparece un `+XP` flotante y la barra se anima.
- **Hábitos:** creo, edito y elimino hábitos eligiendo nombre, icono, color
  y cuánta XP da cada compleción (10, 20, 30 o 50). Cada hábito solo se
  puede completar una vez al día, así la racha es real.
- **Rachas y niveles:** si completo un hábito días seguidos la racha crece;
  si fallo un día, vuelve a 1. El XP para subir de nivel crece con el nivel
  (100 XP del 1 al 2, 150 del 2 al 3, y así). Los rangos del avatar son
  Novato (nivel 1), Aventurero (3), Caballero (5), Héroe (8) y Leyenda (10).
- **Estadísticas:** resumen de los últimos 7 días con un gráfico de barras
  hecho con widgets, mejor racha, misiones totales y detalle por hábito.
- **Logros:** 10 logros desbloqueables: primera misión, rachas de 3, 7, 14
  y 30 días, 10, 50 y 100 misiones, y niveles 5 y 10.
- **Persistencia local:** todo se guarda en el dispositivo con
  `shared_preferences` (JSON). No hay backend, no hay cuentas, no hay
  Firebase. La primera vez que se abre, la app trae 3 hábitos de ejemplo
  con algo de progreso (Leer 20 min, Entrenar y Practicar inglés) para que
  se vea viva desde el inicio.

## Tecnologías

Flutter, Dart, Riverpod para el estado y `shared_preferences` para
guardar el progreso. Arquitectura simple y limpia: modelos (`Habit`,
`QuestState`), lógica pura de niveles y logros, servicio de persistencia,
providers de Riverpod y pantallas. Sin librerías de gráficos: el gráfico
semanal y el avatar pixelado están dibujados con widgets.

## Cómo correrla

```bash
flutter pub get
flutter run
```

Para web:

```bash
flutter build web --release
```

Y para verificarla:

```bash
flutter analyze
flutter test
```

## Capturas

La captura de la pantalla principal está en `screenshots/home.png`
(también como golden test en `test/goldens/home.png`). En el entorno de
tests el texto se ve como bloques porque Flutter usa una fuente de prueba;
en el celular o en web se ve normal.

Para sacar capturas reales: corro la app en web con `flutter run -d chrome`
o en mi celular con `flutter run`, y tomo la captura desde el dispositivo
o con las herramientas de captura del navegador.

## Estructura

```
lib/
  main.dart                  Arranque, carga del progreso y navegación
  models/                    Habit y QuestState (hábitos + XP total)
  logic/                     level_system.dart (niveles, XP y rangos)
  services/                  storage_service.dart (shared_preferences + datos de ejemplo)
  providers/                 quest_provider.dart (Riverpod)
  widgets/                   pixel_avatar.dart, habit_card.dart
  screens/                   home, stats, achievements, habit_form
  theme/                     app_theme.dart (tema oscuro)
test/
  level_system_test.dart     Niveles, XP y rangos
  habit_test.dart            Rachas, resumen semanal, JSON y logros
  golden_test.dart           Captura de la pantalla principal
```
