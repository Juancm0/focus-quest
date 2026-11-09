import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/habit.dart';
import '../models/quest_state.dart';

/// Persistencia local con shared_preferences (JSON, sin backend).
///
/// Todo el progreso vive en el dispositivo, bajo la clave [storageKey].
class StorageService {
  static const storageKey = 'focus_quest_state_v1';

  Future<QuestState?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null) return null;
    try {
      return QuestState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(QuestState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, jsonEncode(state.toJson()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
  }
}

/// Datos de ejemplo del primer arranque, para que la app se vea viva.
///
/// Las fechas se generan relativas a hoy, así el resumen semanal y las
/// rachas siempre tienen sentido cuando se abre la app por primera vez.
QuestState seedData([DateTime? hoy]) {
  final hoyFecha = Habit.soloFecha(hoy ?? DateTime.now());

  List<DateTime> diasAtras(List<int> dias) => dias
      .map((d) => hoyFecha.subtract(Duration(days: d)))
      .toList();

  final leerDias = diasAtras([0, 1, 2, 3, 5, 6, 8, 9, 10, 12, 13, 15]);
  final entrenarDias = diasAtras([0, 1, 4, 5, 7, 8, 11, 12]);
  final inglesDias = diasAtras([
    0,
    1,
    2,
    3,
    4,
    5,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
  ]);

  final leer = Habit(
    id: 'seed-leer',
    nombre: 'Leer 20 min',
    icono: 'book',
    color: Colors.amber.toARGB32(),
    xpPorCompletar: 20,
    racha: 4,
    totalCompletados: leerDias.length,
    ultimaFecha: hoyFecha,
    historial: leerDias,
  );
  final entrenar = Habit(
    id: 'seed-entrenar',
    nombre: 'Entrenar',
    icono: 'fitness',
    color: Colors.deepPurpleAccent.toARGB32(),
    xpPorCompletar: 30,
    racha: 2,
    totalCompletados: entrenarDias.length,
    ultimaFecha: hoyFecha,
    historial: entrenarDias,
  );
  final ingles = Habit(
    id: 'seed-ingles',
    nombre: 'Practicar inglés',
    icono: 'language',
    color: Colors.teal.toARGB32(),
    xpPorCompletar: 20,
    racha: 6,
    totalCompletados: inglesDias.length,
    ultimaFecha: hoyFecha,
    historial: inglesDias,
  );

  final habits = [leer, entrenar, ingles];
  final totalXp = habits.fold(
    0,
    (suma, h) => suma + h.totalCompletados * h.xpPorCompletar,
  );
  return QuestState(habits: habits, totalXp: totalXp);
}
