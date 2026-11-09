import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/level_system.dart';
import '../providers/quest_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/habit_helpers.dart';

const _diasSemana = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];

/// Pantalla de estadísticas: resumen semanal con gráfico de barras
/// hecho solo con widgets, y detalle por hábito.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(questProvider);
    final resumen = state.resumenSemanal;
    final dias = resumen.keys.toList()..sort();
    final maximo = dias.fold<int>(
      1,
      (m, d) => resumen[d]! > m ? resumen[d]! : m,
    );
    final totalSemana = resumen.values.fold(0, (a, b) => a + b);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        const Text(
          'Tu semana',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '$totalSemana misiones completadas en los últimos 7 días.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  height: 150,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: dias.map((dia) {
                      final valor = resumen[dia] ?? 0;
                      final esHoy =
                          dia.day == DateTime.now().day &&
                          dia.month == DateTime.now().month;
                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              valor == 0 ? '' : '$valor',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              height: 110 * (valor / maximo),
                              width: 26,
                              decoration: BoxDecoration(
                                color: esHoy
                                    ? AppTheme.amber
                                    : AppTheme.violet,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _diasSemana[dia.weekday - 1],
                              style: TextStyle(
                                fontSize: 12,
                                color: esHoy
                                    ? AppTheme.amber
                                    : AppTheme.textSecondary,
                                fontWeight: esHoy
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _StatCard(
              label: 'Misiones totales',
              value: '${state.totalCompletados}',
              icon: Icons.check_circle,
            ),
            const SizedBox(width: 10),
            _StatCard(
              label: 'Mejor racha',
              value: '${state.mejorRacha} días',
              icon: Icons.local_fire_department,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _StatCard(
              label: 'Nivel actual',
              value: '${state.nivel} · ${state.rango.nombre}',
              icon: Icons.shield,
            ),
            const SizedBox(width: 10),
            _StatCard(
              label: 'XP total',
              value: '${state.totalXp} XP',
              icon: Icons.star,
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Por hábito',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (state.habits.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Sin hábitos todavía.'),
            ),
          )
        else
          ...state.habits.map((h) {
            final color = Color(h.color);
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.18),
                  child: Icon(iconoDeHabito(h.icono), color: color),
                ),
                title: Text(h.nombre),
                subtitle: Text(
                  'Racha ${h.racha} días · ${h.totalCompletados} veces en total',
                ),
                trailing: Text(
                  '+${h.xpPorCompletar} XP',
                  style: const TextStyle(
                    color: AppTheme.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppTheme.amber, size: 20),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
