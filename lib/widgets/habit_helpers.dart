import 'package:flutter/material.dart';

/// Iconos disponibles para un hábito, guardados por nombre en el modelo.
const Map<String, IconData> habitIcons = {
  'book': Icons.menu_book,
  'fitness': Icons.fitness_center,
  'language': Icons.language,
  'water': Icons.water_drop,
  'run': Icons.directions_run,
  'code': Icons.code,
  'music': Icons.music_note,
  'meditate': Icons.self_improvement,
  'food': Icons.restaurant,
  'sleep': Icons.bedtime,
  'write': Icons.edit_note,
  'flag': Icons.flag,
};

IconData iconoDeHabito(String nombre) =>
    habitIcons[nombre] ?? Icons.flag;

/// Colores disponibles para un hábito.
const List<Color> habitColors = [
  Color(0xFFFFB020),
  Color(0xFF8B5CF6),
  Color(0xFF2DD4BF),
  Color(0xFF42A5F5),
  Color(0xFFEF5350),
  Color(0xFF66BB6A),
  Color(0xFFEC407A),
  Color(0xFFFF7043),
];
