import 'package:flutter_test/flutter_test.dart';
import 'package:focus_quest/logic/level_system.dart';
import 'package:focus_quest/models/habit.dart';
import 'package:focus_quest/models/quest_state.dart';
import 'package:focus_quest/services/storage_service.dart';

Habit habitoBase({DateTime? ultimaFecha, int racha = 0, int total = 0}) =>
    Habit(
      id: 'h1',
      nombre: 'Leer 20 min',
      icono: 'book',
      color: 0xFFFFB020,
      xpPorCompletar: 20,
      racha: racha,
      totalCompletados: total,
      ultimaFecha: ultimaFecha,
    );

void main() {
  final lunes = DateTime(2026, 11, 9);
  final martes = DateTime(2026, 11, 10);
  final jueves = DateTime(2026, 11, 12);

  group('Habit - rachas', () {
    test('primera compleción inicia la racha en 1', () {
      final h = habitoBase().completar(lunes);
      expect(h.racha, 1);
      expect(h.totalCompletados, 1);
      expect(h.ultimaFecha, Habit.soloFecha(lunes));
    });

    test('completar dos días seguidos sube la racha a 2', () {
      final h = habitoBase()
          .completar(lunes)
          .completar(martes);
      expect(h.racha, 2);
      expect(h.totalCompletados, 2);
    });

    test('un día de hueco reinicia la racha en 1', () {
      final h = habitoBase()
          .completar(lunes)
          .completar(jueves);
      expect(h.racha, 1);
      expect(h.totalCompletados, 2);
    });

    test('completar dos veces el mismo día no suma nada', () {
      final h = habitoBase().completar(lunes).completar(lunes);
      expect(h.racha, 1);
      expect(h.totalCompletados, 1);
      expect(h.completadoHoy(lunes), isTrue);
      expect(h.completadoHoy(martes), isFalse);
    });

    test('resumen semanal cuenta solo los últimos 7 días', () {
      final h = habitoBase()
          .completar(DateTime(2026, 11, 3))
          .completar(DateTime(2026, 11, 9))
          .completar(DateTime(2026, 11, 10));
      final resumen = h.resumenSemanal(DateTime(2026, 11, 10));
      expect(resumen.length, 7);
      expect(resumen.values.fold(0, (a, b) => a + b), 2);
      expect(resumen[Habit.soloFecha(DateTime(2026, 11, 10))], 1);
    });
  });

  group('Habit - JSON', () {
    test('toJson/fromJson conserva todos los campos', () {
      final original = habitoBase(
        ultimaFecha: lunes,
        racha: 3,
        total: 5,
      ).copyWith(historial: [lunes, martes]);
      final restaurado = Habit.fromJson(original.toJson());
      expect(restaurado.id, original.id);
      expect(restaurado.nombre, original.nombre);
      expect(restaurado.racha, 3);
      expect(restaurado.totalCompletados, 5);
      expect(restaurado.historial.length, 2);
    });
  });

  group('QuestState', () {
    test('nivel y rango se derivan del XP total', () {
      final state = QuestState(
        habits: [habitoBase(total: 5)],
        totalXp: 700,
      );
      expect(state.nivel, 5);
      expect(state.rango.nombre, 'Caballero');
      expect(state.totalCompletados, 5);
      expect(state.mejorRacha, 0);
    });

    test('mejor racha es la mayor entre los hábitos', () {
      final state = QuestState(
        habits: [
          habitoBase(racha: 3),
          habitoBase(racha: 7).copyWith(id: 'h2'),
        ],
      );
      expect(state.mejorRacha, 7);
    });

    test('seedData trae 3 hábitos con progreso y XP coherente', () {
      final seed = seedData(DateTime(2026, 11, 9));
      expect(seed.habits.length, 3);
      expect(seed.habits.map((h) => h.nombre), contains('Leer 20 min'));
      expect(seed.totalCompletados, greaterThan(10));
      expect(seed.totalXp, greaterThan(0));
      expect(seed.nivel, greaterThanOrEqualTo(2));
      final esperado = seed.habits.fold(
        0,
        (s, h) => s + h.totalCompletados * h.xpPorCompletar,
      );
      expect(seed.totalXp, esperado);
    });
  });

  group('Logros', () {
    test('sin progreso no hay logros', () {
      expect(logrosDesbloqueados(const QuestState()), isEmpty);
    });

    test('primera misión y 10 misiones se desbloquean por total', () {
      final state = QuestState(
        habits: [habitoBase(total: 10)],
        totalXp: 200,
      );
      final ids = logrosDesbloqueados(state).map((l) => l.id).toSet();
      expect(ids, contains('primera_mision'));
      expect(ids, contains('misiones_10'));
      expect(ids, isNot(contains('misiones_50')));
    });

    test('rachas y niveles desbloquean sus logros', () {
      final state = QuestState(
        habits: [habitoBase(racha: 7, total: 50)],
        totalXp: 700,
      );
      final ids = logrosDesbloqueados(state).map((l) => l.id).toSet();
      expect(ids, containsAll(['racha_3', 'racha_7', 'misiones_50', 'nivel_5']));
      expect(ids, isNot(contains('racha_30')));
      expect(ids, isNot(contains('nivel_10')));
    });

    test('hay 10 logros en total', () {
      expect(todosLosLogros().length, 10);
    });
  });
}
