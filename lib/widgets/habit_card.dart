import 'package:flutter/material.dart';

import '../models/habit.dart';
import 'habit_helpers.dart';

/// Tarjeta de un hábito con su botón de completar.
class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.onComplete,
    required this.onEdit,
    required this.onDelete,
  });

  final Habit habit;
  final VoidCallback onComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = Color(habit.color);
    final hechoHoy = habit.completadoHoy();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconoDeHabito(habit.icono), color: color, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: [
                      _Chip(
                        icon: Icons.local_fire_department,
                        label: 'Racha ${habit.racha} días',
                        color: Colors.orange,
                      ),
                      _Chip(
                        icon: Icons.check_circle_outline,
                        label: '${habit.totalCompletados} veces',
                        color: Colors.grey,
                      ),
                      _Chip(
                        icon: Icons.star,
                        label: '+${habit.xpPorCompletar} XP',
                        color: Colors.amber,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: hechoHoy
                        ? Colors.green.withValues(alpha: 0.2)
                        : color,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    tooltip: hechoHoy
                        ? 'Ya completado hoy'
                        : 'Completar misión',
                    icon: Icon(
                      hechoHoy ? Icons.check : Icons.play_arrow,
                      color: hechoHoy ? Colors.green : Colors.black,
                    ),
                    onPressed: hechoHoy ? null : onComplete,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (value) {
                    if (value == 'editar') onEdit();
                    if (value == 'eliminar') onDelete();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'editar', child: Text('Editar')),
                    PopupMenuItem(
                      value: 'eliminar',
                      child: Text('Eliminar'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF9AA3B2)),
        ),
      ],
    );
  }
}
