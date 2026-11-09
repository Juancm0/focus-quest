import 'package:flutter/material.dart';

import '../logic/level_system.dart';
import '../models/habit.dart';

/// Estado completo de la partida: hábitos + XP total.
///
/// El nivel y el rango se derivan del XP total, nunca se guardan aparte,
/// así que no pueden quedar desincronizados.
class QuestState {
  const QuestState({this.habits = const [], this.totalXp = 0});

  final List<Habit> habits;
  final int totalXp;

  int get nivel => LevelSystem.nivelParaXp(totalXp);
  Rango get rango => rangoParaNivel(nivel);
  double get progresoNivel => LevelSystem.progresoNivel(totalXp);
  int get xpEnNivel => LevelSystem.xpEnNivelActual(totalXp);
  int get xpNecesarioNivel => LevelSystem.xpNecesarioEnNivelActual(totalXp);

  int get totalCompletados =>
      habits.fold(0, (suma, h) => suma + h.totalCompletados);

  int get mejorRacha =>
      habits.fold(0, (max, h) => h.racha > max ? h.racha : max);

  int get habitosCompletadosHoy =>
      habits.where((h) => h.completadoHoy()).length;

  /// Misiones completadas en los últimos 7 días, por día.
  Map<DateTime, int> get resumenSemanal {
    final combinado = <DateTime, int>{};
    for (final h in habits) {
      for (final entry in h.resumenSemanal().entries) {
        combinado[entry.key] = (combinado[entry.key] ?? 0) + entry.value;
      }
    }
    return combinado;
  }

  QuestState copyWith({List<Habit>? habits, int? totalXp}) => QuestState(
    habits: habits ?? this.habits,
    totalXp: totalXp ?? this.totalXp,
  );

  Map<String, dynamic> toJson() => {
    'totalXp': totalXp,
    'habits': habits.map((h) => h.toJson()).toList(),
  };

  factory QuestState.fromJson(Map<String, dynamic> json) => QuestState(
    totalXp: json['totalXp'] as int? ?? 0,
    habits: (json['habits'] as List<dynamic>? ?? [])
        .map((e) => Habit.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

/// Un logro desbloqueable.
class Achievement {
  const Achievement({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.desbloqueado,
  });

  final String id;
  final String titulo;
  final String descripcion;
  final IconData icono;

  /// Función que decide si el estado actual lo desbloquea.
  final bool Function(QuestState state) desbloqueado;
}

/// Todos los logros del juego, con sus condiciones.
List<Achievement> todosLosLogros() => [
  Achievement(
    id: 'primera_mision',
    titulo: 'Primera misión',
    descripcion: 'Completa tu primer hábito.',
    icono: Icons.flag,
    desbloqueado: (s) => s.totalCompletados >= 1,
  ),
  Achievement(
    id: 'racha_3',
    titulo: 'Racha de 3 días',
    descripcion: 'Completa un hábito 3 días seguidos.',
    icono: Icons.local_fire_department,
    desbloqueado: (s) => s.mejorRacha >= 3,
  ),
  Achievement(
    id: 'racha_7',
    titulo: 'Una semana de fuego',
    descripcion: 'Completa un hábito 7 días seguidos.',
    icono: Icons.whatshot,
    desbloqueado: (s) => s.mejorRacha >= 7,
  ),
  Achievement(
    id: 'racha_14',
    titulo: 'Dos semanas imparable',
    descripcion: 'Completa un hábito 14 días seguidos.',
    icono: Icons.bolt,
    desbloqueado: (s) => s.mejorRacha >= 14,
  ),
  Achievement(
    id: 'racha_30',
    titulo: 'Un mes de leyenda',
    descripcion: 'Completa un hábito 30 días seguidos.',
    icono: Icons.emoji_events,
    desbloqueado: (s) => s.mejorRacha >= 30,
  ),
  Achievement(
    id: 'misiones_10',
    titulo: '10 misiones',
    descripcion: 'Completa 10 hábitos en total.',
    icono: Icons.check_circle,
    desbloqueado: (s) => s.totalCompletados >= 10,
  ),
  Achievement(
    id: 'misiones_50',
    titulo: '50 misiones',
    descripcion: 'Completa 50 hábitos en total.',
    icono: Icons.stars,
    desbloqueado: (s) => s.totalCompletados >= 50,
  ),
  Achievement(
    id: 'misiones_100',
    titulo: '100 misiones',
    descripcion: 'Completa 100 hábitos en total.',
    icono: Icons.military_tech,
    desbloqueado: (s) => s.totalCompletados >= 100,
  ),
  Achievement(
    id: 'nivel_5',
    titulo: 'Caballero nivel 5',
    descripcion: 'Alcanza el nivel 5.',
    icono: Icons.shield,
    desbloqueado: (s) => s.nivel >= 5,
  ),
  Achievement(
    id: 'nivel_10',
    titulo: 'Leyenda nivel 10',
    descripcion: 'Alcanza el nivel 10.',
    icono: Icons.workspace_premium,
    desbloqueado: (s) => s.nivel >= 10,
  ),
];

/// Logros ya desbloqueados en el estado actual.
List<Achievement> logrosDesbloqueados(QuestState state) =>
    todosLosLogros().where((l) => l.desbloqueado(state)).toList();
