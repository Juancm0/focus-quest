import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/quest_state.dart';
import '../providers/quest_provider.dart';
import '../theme/app_theme.dart';

/// Pantalla de logros desbloqueables.
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(questProvider);
    final logros = todosLosLogros();
    final desbloqueados = logrosDesbloqueados(state);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        const Text(
          'Logros',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '${desbloqueados.length} de ${logros.length} desbloqueados. Sigue completando misiones para conseguirlos todos.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: logros.isEmpty
                ? 0
                : desbloqueados.length / logros.length,
            minHeight: 10,
            backgroundColor: const Color(0xFF232839),
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.amber),
          ),
        ),
        const SizedBox(height: 16),
        ...logros.map((logro) {
          final conseguido = logro.desbloqueado(state);
          return Card(
            color: conseguido
                ? AppTheme.surface
                : AppTheme.surface.withValues(alpha: 0.5),
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: conseguido
                      ? AppTheme.amber.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  conseguido ? logro.icono : Icons.lock,
                  color: conseguido
                      ? AppTheme.amber
                      : AppTheme.textSecondary,
                ),
              ),
              title: Text(
                logro.titulo,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: conseguido
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
                ),
              ),
              subtitle: Text(
                logro.descripcion,
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              trailing: conseguido
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
            ),
          );
        }),
      ],
    );
  }
}
