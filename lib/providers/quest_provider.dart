import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/habit.dart';
import '../models/quest_state.dart';
import '../services/storage_service.dart';

/// Estado inicial que se inyecta desde main() (datos guardados o semilla).
final initialStateProvider = Provider<QuestState>(
  (ref) => throw UnimplementedError('Se inyecta en main()'),
);

final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(),
);

/// Notifier principal: hábitos + XP, con persistencia automática.
class QuestNotifier extends Notifier<QuestState> {
  @override
  QuestState build() => ref.read(initialStateProvider);

  Future<void> _persist() async {
    await ref.read(storageServiceProvider).save(state);
  }

  /// Completa un hábito hoy. Devuelve false si ya estaba completado hoy.
  bool completarHabito(String id) {
    final index = state.habits.indexWhere((h) => h.id == id);
    if (index < 0) return false;
    final habit = state.habits[index];
    if (habit.completadoHoy()) return false;

    final actualizado = habit.completar();
    final habits = [...state.habits]..[index] = actualizado;
    state = state.copyWith(
      habits: habits,
      totalXp: state.totalXp + habit.xpPorCompletar,
    );
    _persist();
    return true;
  }

  void agregarHabito(Habit habit) {
    state = state.copyWith(habits: [...state.habits, habit]);
    _persist();
  }

  void editarHabito(Habit habit) {
    final index = state.habits.indexWhere((h) => h.id == habit.id);
    if (index < 0) return;
    final habits = [...state.habits]..[index] = habit;
    state = state.copyWith(habits: habits);
    _persist();
  }

  void eliminarHabito(String id) {
    state = state.copyWith(
      habits: state.habits.where((h) => h.id != id).toList(),
    );
    _persist();
  }

  /// Id único para un hábito nuevo.
  String nuevoId() =>
      'h-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(10000)}';
}

final questProvider = NotifierProvider<QuestNotifier, QuestState>(
  QuestNotifier.new,
);
